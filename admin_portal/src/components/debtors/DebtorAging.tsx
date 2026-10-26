'use client';

import React, { useMemo } from 'react';
import { useAdmin } from '@/context/AdminContext';
import { formatCurrency, exportCsv } from '@/lib/utils';

export default function DebtorAging() {
  const { outlets, salesmen, globalSearch, showToast, openModal } = useAdmin();

  const debtors = useMemo(() => {
    const list = outlets.filter(o => o.balance > 0).sort((a, b) => b.balance - a.balance);
    if (!globalSearch) return list;
    const q = globalSearch.toLowerCase().trim();
    return list.filter(
      d =>
        d.name.toLowerCase().includes(q) ||
        d.code.toLowerCase().includes(q) ||
        d.market.toLowerCase().includes(q) ||
        d.ownerName.toLowerCase().includes(q)
    );
  }, [outlets, globalSearch]);

  // Aging totals
  const { a0, a30, a60, a90 } = useMemo(() => {
    let a0 = 0,
      a30 = 0,
      a60 = 0,
      a90 = 0;
    outlets.forEach(d => {
      if (d.balance > 0) {
        if (d.agingDays <= 30) a0 += d.balance;
        else if (d.agingDays <= 60) a30 += d.balance;
        else if (d.agingDays <= 90) a60 += d.balance;
        else a90 += d.balance;
      }
    });
    return { a0, a30, a60, a90 };
  }, [outlets]);

  const handleExportCsv = () => {
    const headers = [
      'Party Code',
      'Store Name',
      'Market',
      'Owner',
      'Mobile',
      'Credit Limit',
      'Total Due',
      'Aging Days',
      'Risk Status',
    ];
    const rows = debtors.map(d => {
      const status = d.agingDays > 90 ? 'CRITICAL' : d.agingDays > 60 ? 'HIGH' : 'NORMAL';
      return [
        d.code,
        d.name,
        d.market,
        d.ownerName,
        d.mobile,
        d.creditLimit,
        d.balance,
        d.agingDays,
        status,
      ];
    });
    exportCsv(`AUPL_Debtors_Aging_${new Date().toISOString().slice(0, 10)}.csv`, headers, rows);
    showToast('CSV Exported', 'Debtors Aging Report downloaded successfully.');
  };

  const handlePrint = () => {
    openModal('modal-a4-statement', null);
  };

  return (
    <section className="view-panel active" id="view-debtors">
      <div className="debtors-container">
        <div className="debtors-summary-row">
          <div className="aging-box b0">
            <span className="aging-title">0 - 30 Days (Current)</span>
            <span className="aging-amount" id="aging-0-30">
              ₹ {formatCurrency(a0)}
            </span>
            <span className="aging-status safe">Low Risk</span>
          </div>
          <div className="aging-box b30">
            <span className="aging-title">31 - 60 Days</span>
            <span className="aging-amount" id="aging-31-60">
              ₹ {formatCurrency(a30)}
            </span>
            <span className="aging-status moderate">Moderate Alert</span>
          </div>
          <div className="aging-box b60">
            <span className="aging-title">61 - 90 Days</span>
            <span className="aging-amount" id="aging-61-90">
              ₹ {formatCurrency(a60)}
            </span>
            <span className="aging-status high">High Risk</span>
          </div>
          <div className="aging-box b90">
            <span className="aging-title">90+ Days Overdue</span>
            <span className="aging-amount" id="aging-90-plus">
              ₹ {formatCurrency(a90)}
            </span>
            <span className="aging-status critical">Critical Default</span>
          </div>
        </div>

        <div className="table-card">
          <div className="table-card-header">
            <h3>Retail Outlets Outstanding Ledger &amp; Aging Analysis</h3>
            <div className="header-actions">
              <button className="btn btn-outline btn-sm" onClick={handleExportCsv}>
                <i className="fa-solid fa-file-csv"></i> Export CSV
              </button>
              <button className="btn btn-primary btn-sm" onClick={handlePrint}>
                <i className="fa-solid fa-print"></i> Print A4 Statement
              </button>
            </div>
          </div>
          <table className="data-table" id="debtors-table">
            <thead>
              <tr>
                <th>Party Code</th>
                <th>Retail Store Name</th>
                <th>Market</th>
                <th>Assigned Rep</th>
                <th>Credit Limit</th>
                <th>Total Due</th>
                <th>Aging Bucket</th>
                <th>Risk Level</th>
                <th>Action</th>
              </tr>
            </thead>
            <tbody id="debtors-table-body">
              {debtors.map(d => {
                const rep = salesmen.find(s => s.id === d.assignedSalesmanId);
                let riskClass = 'safe';
                let riskLabel = 'Normal';

                if (d.agingDays > 90 || d.balance > d.creditLimit) {
                  riskClass = 'critical';
                  riskLabel = 'CRITICAL OVERDUE';
                } else if (d.agingDays > 60) {
                  riskClass = 'high';
                  riskLabel = 'HIGH RISK';
                }

                return (
                  <tr key={d.id}>
                    <td>
                      <span className="code-badge">{d.code}</span>
                    </td>
                    <td>
                      <strong>{d.name}</strong>
                    </td>
                    <td>{d.market}</td>
                    <td>
                      {rep ? (
                        rep.name
                      ) : (
                        <span style={{ color: '#D97706' }}>Unassigned</span>
                      )}
                    </td>
                    <td>₹{formatCurrency(d.creditLimit)}</td>
                    <td>
                      <strong style={{ color: 'var(--danger)' }}>₹{formatCurrency(d.balance)}</strong>
                    </td>
                    <td>{d.agingDays} Days</td>
                    <td>
                      <span className={`badge-risk ${riskClass}`}>{riskLabel}</span>
                    </td>
                    <td>
                      <button
                        className="btn btn-outline btn-sm"
                        onClick={() => openModal('modal-a4-statement', d)}
                      >
                        <i className="fa-solid fa-file-invoice"></i> Ledger
                      </button>
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>
      </div>
    </section>
  );
}
