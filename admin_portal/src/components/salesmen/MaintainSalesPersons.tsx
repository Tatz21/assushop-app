'use client';

import React, { useState } from 'react';
import { useAdmin } from '@/context/AdminContext';
import { formatCurrency, exportCsv } from '@/lib/utils';
import { Salesman } from '@/types';

export default function MaintainSalesPersons() {
  const {
    salesmen,
    outlets,
    openModal,
    deleteSalesman,
    setSelectedSalesmanId,
    setActiveView,
    globalSearch,
  } = useAdmin();

  const [search, setSearch] = useState('');
  const [statusFilter, setStatusFilter] = useState('ALL');

  const totalAssignedStores = outlets.filter(o => o.assignedSalesmanId).length;
  const totalTeamTarget = salesmen.reduce((sum, s) => sum + s.target, 0);
  const totalRealizedSales = salesmen.reduce((sum, s) => sum + (s.achieved || 0), 0);
  const inStoreCount = salesmen.filter(s => s.status.includes('Active')).length;

  const filteredSalesmen = salesmen.filter(rep => {
    const query = (search || globalSearch).toLowerCase().trim();
    const matchesQuery = !query ||
      rep.name.toLowerCase().includes(query) ||
      rep.employeeId.toLowerCase().includes(query) ||
      rep.territory.toLowerCase().includes(query) ||
      rep.mobile.includes(query);

    let matchesStatus = true;
    if (statusFilter !== 'ALL') {
      if (statusFilter === 'Active') matchesStatus = rep.status.includes('Active');
      else if (statusFilter === 'In Transit') matchesStatus = rep.status.includes('Transit');
      else if (statusFilter === 'On Leave') matchesStatus = rep.status.includes('Leave');
    }

    return matchesQuery && matchesStatus;
  });

  const handleExportCsv = () => {
    const headers = ['Employee ID', 'Full Name', 'Mobile', 'Email', 'Assigned Territory', 'Assigned Stores Count', 'Monthly Target (INR)', 'Realized Sales (INR)', 'Achievement %', 'Status'];
    const rows = salesmen.map(rep => {
      const assignedStores = outlets.filter(o => o.assignedSalesmanId === rep.id);
      const target = rep.target || 125000;
      const achieved = rep.achieved || (assignedStores.length * 5800);
      const pct = Math.round((achieved / target) * 100);
      return [rep.employeeId, rep.name, rep.mobile, rep.email, rep.territory, assignedStores.length, target, achieved, `${pct}%`, rep.status];
    });
    exportCsv(`AUPL_Sales_Team_Master_${new Date().toISOString().slice(0, 10)}.csv`, headers, rows);
  };

  const handleJumpToAllocation = (repId: string) => {
    setSelectedSalesmanId(repId);
    setActiveView('allocation');
  };

  return (
    <section className="view-panel active">
      <div className="salesmen-view-container">
        {/* Summary Metric Cards */}
        <div className="salesmen-summary-row">
          <div className="summary-metric-card">
            <div className="metric-icon purple"><i className="fa-solid fa-users"></i></div>
            <div className="metric-body">
              <span className="metric-label">Sales Executives</span>
              <span className="metric-num">{salesmen.length}</span>
              <span className="metric-sub text-success"><i className="fa-solid fa-check"></i> 100% Onboarded</span>
            </div>
          </div>
          <div className="summary-metric-card">
            <div className="metric-icon blue"><i className="fa-solid fa-store"></i></div>
            <div className="metric-body">
              <span className="metric-label">Total Assigned Stores</span>
              <span className="metric-num">{totalAssignedStores}</span>
              <span className="metric-sub text-info"><i className="fa-solid fa-map-location-dot"></i> 5 Market Clusters</span>
            </div>
          </div>
          <div className="summary-metric-card">
            <div className="metric-icon green"><i className="fa-solid fa-bullseye"></i></div>
            <div className="metric-body">
              <span className="metric-label">Monthly Team Target</span>
              <span className="metric-num">₹ {formatCurrency(totalTeamTarget)}</span>
              <span className="metric-sub text-success"><i className="fa-solid fa-arrow-trend-up"></i> ₹ {formatCurrency(totalRealizedSales)} Realized</span>
            </div>
          </div>
          <div className="summary-metric-card">
            <div className="metric-icon amber"><i className="fa-solid fa-signal"></i></div>
            <div className="metric-body">
              <span className="metric-label">Live In-Field Status</span>
              <span className="metric-num">{inStoreCount} In-Store</span>
              <span className="metric-sub text-warning"><i className="fa-solid fa-motorcycle"></i> 1 In-Transit</span>
            </div>
          </div>
        </div>

        {/* Salesmen Table Card */}
        <div className="table-card">
          <div className="table-card-header">
            <div className="table-title-group">
              <h3>Sales Representatives Directory & Performance</h3>
              <p>Maintain employee master, mobile credentials, assigned beats, quotas, and field active status.</p>
            </div>
            <div className="header-actions">
              <div className="search-mini">
                <i className="fa-solid fa-magnifying-glass"></i>
                <input
                  type="text"
                  placeholder="Search by name, ID or beat..."
                  value={search}
                  onChange={(e) => setSearch(e.target.value)}
                />
              </div>
              <select
                className="select-sm"
                value={statusFilter}
                onChange={(e) => setStatusFilter(e.target.value)}
              >
                <option value="ALL">All Status</option>
                <option value="Active">Active In-Store</option>
                <option value="In Transit">In Transit</option>
                <option value="On Leave">On Leave / Off-Duty</option>
              </select>
              <button className="btn btn-outline btn-sm" onClick={handleExportCsv}>
                <i className="fa-solid fa-file-csv"></i> Export CSV
              </button>
              <button className="btn btn-primary btn-sm" onClick={() => openModal('modal-add-salesman')}>
                <i className="fa-solid fa-user-plus"></i> Add Sales Executive
              </button>
            </div>
          </div>

          <table className="data-table">
            <thead>
              <tr>
                <th>Executive</th>
                <th>Emp ID</th>
                <th>Contact Info</th>
                <th>Assigned Beat / Territory</th>
                <th>Allocated Stores</th>
                <th>Monthly Target</th>
                <th>Achievement %</th>
                <th>Live Field Status</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              {filteredSalesmen.length === 0 ? (
                <tr>
                  <td colSpan={9} style={{ textAlign: 'center', padding: '36px', color: '#94A3B8' }}>
                    <i className="fa-solid fa-user-slash" style={{ fontSize: '28px', marginBottom: '8px', display: 'block' }}></i>
                    No sales representatives found matching filters.
                  </td>
                </tr>
              ) : (
                filteredSalesmen.map(rep => {
                  const assignedStores = outlets.filter(o => o.assignedSalesmanId === rep.id);
                  const target = rep.target || 125000;
                  const achieved = rep.achieved || (assignedStores.length * 5800);
                  const pct = Math.min(100, Math.round((achieved / target) * 100));

                  let fillClass = 'low';
                  if (pct >= 65) fillClass = 'high';
                  else if (pct >= 40) fillClass = 'mid';

                  let statusBadge = (
                    <span className="status-badge-live leave"><span className="pulse-dot-sm gray"></span> Off-Duty</span>
                  );
                  if (rep.status.includes('Active')) {
                    statusBadge = (
                      <span className="status-badge-live active"><span className="pulse-dot-sm green"></span> In-Store Active</span>
                    );
                  } else if (rep.status.includes('Transit')) {
                    statusBadge = (
                      <span className="status-badge-live transit"><span className="pulse-dot-sm blue"></span> In Transit</span>
                    );
                  }

                  return (
                    <tr key={rep.id}>
                      <td>
                        <div className="rep-profile-cell">
                          <div className="rep-avatar-sm">{rep.name.split(' ').map(n => n[0]).join('')}</div>
                          <div className="rep-info-col">
                            <span className="rep-name-bold">{rep.name}</span>
                            <span className="rep-sub-title">{rep.email}</span>
                          </div>
                        </div>
                      </td>
                      <td><code>{rep.employeeId}</code></td>
                      <td>
                        <div><i className="fa-solid fa-phone" style={{ fontSize: '11px', color: '#64748B' }}></i> {rep.mobile}</div>
                      </td>
                      <td>
                        <span style={{ fontWeight: 600, color: '#1E293B' }}>{rep.territory}</span>
                      </td>
                      <td>
                        <button
                          className="btn btn-outline btn-xs"
                          onClick={() => handleJumpToAllocation(rep.id)}
                          title="Inspect stores in matrix"
                        >
                          <i className="fa-solid fa-store" style={{ color: '#2563EB' }}></i> <strong>{assignedStores.length}</strong> Stores
                        </button>
                      </td>
                      <td>
                        <strong>₹ {formatCurrency(target)}</strong>
                      </td>
                      <td>
                        <div className="target-bar-wrap">
                          <div className="target-text-row">
                            <span>₹ {formatCurrency(achieved)}</span>
                            <span>{pct}%</span>
                          </div>
                          <div className="target-bar-bg">
                            <div className={`target-bar-fill ${fillClass}`} style={{ width: `${pct}%` }}></div>
                          </div>
                        </div>
                      </td>
                      <td>{statusBadge}</td>
                      <td>
                        <div className="action-buttons-group">
                          <button
                            className="btn-icon"
                            onClick={() => openModal('modal-salesman-scorecard', rep)}
                            title="Performance Scorecard"
                          >
                            <i className="fa-solid fa-chart-line"></i>
                          </button>
                          <button
                            className="btn-icon"
                            onClick={() => openModal('modal-edit-salesman', rep)}
                            title="Edit Profile"
                          >
                            <i className="fa-solid fa-pen-to-square"></i>
                          </button>
                          <button
                            className="btn-icon text-danger"
                            onClick={() => deleteSalesman(rep.id)}
                            title="Remove Rep"
                          >
                            <i className="fa-solid fa-trash-can"></i>
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
