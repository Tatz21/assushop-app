'use client';

import React, { useState, useMemo } from 'react';
import { useAdmin } from '@/context/AdminContext';
import { exportCsv, formatCurrency } from '@/lib/utils';
import { InventoryCheck } from '@/types';

export default function InventoryCheckResults() {
  const {
    inventoryChecks,
    outlets,
    globalSearch,
    openModal,
    triggerReplenishmentOrder,
    resolveAuditDiscrepancy,
    showToast,
  } = useAdmin();

  const [localSearch, setLocalSearch] = useState('');
  const [storeFilter, setStoreFilter] = useState('ALL');
  const [statusFilter, setStatusFilter] = useState('ALL');

  const filteredChecks = useMemo(() => {
    const q = (localSearch || globalSearch).toLowerCase().trim();
    return inventoryChecks.filter(chk => {
      const matchesQuery =
        !q ||
        chk.outletName.toLowerCase().includes(q) ||
        chk.productName.toLowerCase().includes(q) ||
        chk.auditorName.toLowerCase().includes(q) ||
        chk.id.toLowerCase().includes(q) ||
        chk.skuCode.toLowerCase().includes(q);

      const matchesStore = storeFilter === 'ALL' || chk.outletId === storeFilter;
      const matchesStatus = statusFilter === 'ALL' || chk.status === statusFilter;

      return matchesQuery && matchesStore && matchesStatus;
    });
  }, [inventoryChecks, localSearch, globalSearch, storeFilter, statusFilter]);

  // Metrics
  const criticalDeficitsCount = useMemo(
    () => inventoryChecks.filter(c => c.status === 'CRITICAL_DEFICIT' || c.variance <= -15).length,
    [inventoryChecks]
  );
  const nearExpiryCount = useMemo(
    () => inventoryChecks.filter(c => c.status === 'EXPIRING_SOON').length,
    [inventoryChecks]
  );
  const replenishmentCount = useMemo(
    () => inventoryChecks.filter(c => c.replenishmentStatus === 'PO_GENERATED' || c.variance < 0).length,
    [inventoryChecks]
  );

  const handleExportCsv = () => {
    const headers = [
      'Audit ID',
      'Retail Store',
      'Market',
      'Auditor Name',
      'Emp ID',
      'Timestamp',
      'SKU Code',
      'Product Name',
      'Physical Count',
      'Target Count',
      'Variance',
      'Batch No',
      'Expiry Date',
      'Status',
      'Replenishment Status',
      'PO Number',
    ];
    const rows = inventoryChecks.map(c => [
      c.id,
      c.outletName,
      c.market,
      c.auditorName,
      c.auditorEmpId,
      c.timestamp,
      c.skuCode,
      c.productName,
      c.physicalCount,
      c.targetCount,
      c.variance,
      c.batchNo || '',
      c.expiryDate || '',
      c.status,
      c.replenishmentStatus,
      c.replenishmentPoId || '',
    ]);
    exportCsv(`AUPL_Store_Inventory_Checks_${new Date().toISOString().slice(0, 10)}.csv`, headers, rows);
    showToast('CSV Exported', 'Store shelf inventory audit log downloaded.');
  };

  return (
    <section className="view-panel active" id="view-inventory-checks">
      <div className="inventory-checks-view-container">
        {/* Summary Cards */}
        <div className="audit-summary-row">
          <div className="summary-metric-card">
            <div className="metric-icon blue">
              <i className="fa-solid fa-clipboard-check"></i>
            </div>
            <div className="metric-body">
              <span className="metric-label">Total Store Audits</span>
              <span className="metric-num" id="audit-metric-total">
                {inventoryChecks.length}
              </span>
              <span className="metric-sub text-success">
                <i className="fa-solid fa-calendar-check"></i> Real-time Telemetry
              </span>
            </div>
          </div>
          <div className="summary-metric-card">
            <div className="metric-icon red">
              <i className="fa-solid fa-triangle-exclamation"></i>
            </div>
            <div className="metric-body">
              <span className="metric-label">Stockout / Critical Deficits</span>
              <span className="metric-num" id="audit-metric-stockouts">
                {criticalDeficitsCount} Outlets
              </span>
              <span className="metric-sub text-danger">
                <i className="fa-solid fa-bell"></i> Immediate PO Required
              </span>
            </div>
          </div>
          <div className="summary-metric-card">
            <div className="metric-icon amber">
              <i className="fa-solid fa-hourglass-half"></i>
            </div>
            <div className="metric-body">
              <span className="metric-label">Near-Expiry Flagged</span>
              <span className="metric-num" id="audit-metric-expiry">
                {nearExpiryCount} Batches
              </span>
              <span className="metric-sub text-warning">
                <i className="fa-solid fa-clock-rotate-left"></i> &lt; 45 Days Shelf Life
              </span>
            </div>
          </div>
          <div className="summary-metric-card">
            <div className="metric-icon green">
              <i className="fa-solid fa-truck-ramp-box"></i>
            </div>
            <div className="metric-body">
              <span className="metric-label">Replenishment Triggered</span>
              <span className="metric-num" id="audit-metric-replenish">
                ₹ 68,400
              </span>
              <span className="metric-sub text-success">
                <i className="fa-solid fa-check-double"></i> {replenishmentCount} Orders Handled
              </span>
            </div>
          </div>
        </div>

        {/* Inventory Checks Table Card */}
        <div className="table-card">
          <div className="table-card-header">
            <div className="table-title-group">
              <h3>Store Shelf Inventory Audit Log & Health Verification</h3>
              <p>Real-time physical stock counts audited by field reps during beat visits. Detects stockouts, damaged goods & shelf rotation.</p>
            </div>
            <div className="header-actions">
              <div className="search-mini">
                <i className="fa-solid fa-magnifying-glass"></i>
                <input
                  type="text"
                  id="audit-search-input"
                  placeholder="Search store, SKU, auditor..."
                  value={localSearch}
                  onChange={e => setLocalSearch(e.target.value)}
                />
              </div>
              <select
                id="audit-store-filter"
                className="select-sm"
                value={storeFilter}
                onChange={e => setStoreFilter(e.target.value)}
              >
                <option value="ALL">All Retail Stores</option>
                {outlets.slice(0, 15).map(o => (
                  <option key={o.id} value={o.id}>
                    {o.name} ({o.market})
                  </option>
                ))}
              </select>
              <select
                id="audit-status-filter"
                className="select-sm"
                value={statusFilter}
                onChange={e => setStatusFilter(e.target.value)}
              >
                <option value="ALL">All Audit Statuses</option>
                <option value="CRITICAL_DEFICIT">Critical Stockout</option>
                <option value="LOW_STOCK">Low Stock</option>
                <option value="HEALTHY">Passed / Healthy</option>
                <option value="EXPIRING_SOON">Expiring Soon</option>
                <option value="OVERSTOCKED">Overstocked</option>
              </select>
              <button className="btn btn-outline btn-sm" onClick={handleExportCsv}>
                <i className="fa-solid fa-file-csv"></i> Export CSV
              </button>
              <button
                className="btn btn-primary btn-sm"
                onClick={() => openModal('modal-add-inventory-check')}
              >
                <i className="fa-solid fa-plus"></i> Record Stock Audit
              </button>
            </div>
          </div>
          <table className="data-table" id="audit-results-table">
            <thead>
              <tr>
                <th>Audit ID</th>
                <th>Retail Store & Market</th>
                <th>Audited By</th>
                <th>Audit Timestamp</th>
                <th>Product SKU Audited</th>
                <th>Shelf Stock vs Required</th>
                <th>Stock Gap / Variance</th>
                <th>Batch & Expiry</th>
                <th>Audit Verdict</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody id="audit-results-table-body">
              {filteredChecks.length === 0 ? (
                <tr>
                  <td colSpan={10} style={{ textAlign: 'center', padding: '36px', color: '#94A3B8' }}>
                    <i className="fa-solid fa-clipboard-question" style={{ fontSize: '28px', marginBottom: '8px', display: 'block' }}></i>
                    No inventory check results found matching current filter criteria.
                  </td>
                </tr>
              ) : (
                filteredChecks.map(chk => {
                  let badge = null;
                  if (chk.status === 'CRITICAL_DEFICIT') {
                    badge = <span className="audit-status-badge critical"><i className="fa-solid fa-triangle-exclamation"></i> Critical Deficit</span>;
                  } else if (chk.status === 'LOW_STOCK') {
                    badge = <span className="audit-status-badge low"><i className="fa-solid fa-triangle-exclamation"></i> Low Stock</span>;
                  } else if (chk.status === 'HEALTHY') {
                    badge = <span className="audit-status-badge healthy"><i className="fa-solid fa-circle-check"></i> Passed Healthy</span>;
                  } else if (chk.status === 'EXPIRING_SOON') {
                    badge = <span className="audit-status-badge expiring"><i className="fa-solid fa-hourglass-half"></i> Expiring Soon</span>;
                  } else if (chk.status === 'OVERSTOCKED') {
                    badge = <span className="audit-status-badge overstock"><i className="fa-solid fa-box-archive"></i> Overstocked</span>;
                  }

                  let varianceElem = null;
                  if (chk.variance < 0) {
                    varianceElem = <span className="variance-pill deficit"><i className="fa-solid fa-arrow-down"></i> {chk.variance} units</span>;
                  } else if (chk.variance > 0) {
                    varianceElem = <span className="variance-pill surplus"><i className="fa-solid fa-arrow-up"></i> +{chk.variance} units</span>;
                  } else {
                    varianceElem = <span className="variance-pill zero">0 (Exact)</span>;
                  }

                  return (
                    <tr key={chk.id}>
                      <td><code>{chk.id}</code></td>
                      <td>
                        <div><strong>{chk.outletName}</strong></div>
                        <span style={{ fontSize: '11px', color: '#64748B' }}>{chk.market}</span>
                      </td>
                      <td>
                        <span style={{ fontWeight: 600, color: '#1E293B' }}>{chk.auditorName}</span>
                        <div style={{ fontSize: '11px', color: '#64748B' }}>{chk.auditorEmpId}</div>
                      </td>
                      <td><span style={{ fontSize: '12px', color: '#475569' }}>{chk.timestamp}</span></td>
                      <td>
                        <strong>{chk.productName}</strong>
                        <div style={{ fontSize: '11px', color: '#64748B' }}><code>{chk.skuCode}</code></div>
                      </td>
                      <td>
                        <span style={{ fontWeight: 700, color: chk.physicalCount < 5 ? '#DC2626' : '#0F172A' }}>
                          {chk.physicalCount}
                        </span>
                        <span style={{ color: '#64748B', fontSize: '11.5px' }}> / {chk.targetCount} min</span>
                      </td>
                      <td>{varianceElem}</td>
                      <td>
                        <div style={{ fontSize: '12px' }}><code>{chk.batchNo || 'N/A'}</code></div>
                        <span style={{ fontSize: '11px', color: chk.status === 'EXPIRING_SOON' ? '#DC2626' : '#64748B' }}>
                          Exp: {chk.expiryDate || 'N/A'}
                        </span>
                      </td>
                      <td>{badge}</td>
                      <td>
                        <div className="action-buttons-group">
                          <button
                            className="btn-icon"
                            onClick={() => openModal('modal-view-audit-detail', chk)}
                            title="View Inspection Slip"
                          >
                            <i className="fa-solid fa-receipt"></i>
                          </button>
                          {chk.variance < 0 && chk.replenishmentStatus !== 'PO_GENERATED' && (
                            <button
                              className="btn-icon text-success"
                              onClick={() => triggerReplenishmentOrder(chk.id)}
                              title="Create Restock PO"
                            >
                              <i className="fa-solid fa-truck-ramp-box"></i>
                            </button>
                          )}
                          <button
                            className="btn-icon text-neutral"
                            onClick={() => resolveAuditDiscrepancy(chk.id)}
                            title="Resolve Audit Ticket"
                          >
                            <i className="fa-solid fa-circle-check"></i>
                          </button>
                        </div>
                      </td>
                    </tr>
                  );
                })
              )}
            </tbody>
          </table>
        </div>
      </div>
    </section>
  );
}
