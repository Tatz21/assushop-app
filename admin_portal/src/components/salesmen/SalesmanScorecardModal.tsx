'use client';

import React from 'react';
import { useAdmin } from '@/context/AdminContext';
import { formatCurrency } from '@/lib/utils';
import { Salesman } from '@/types';

export default function SalesmanScorecardModal() {
  const { activeModal, modalPayload, closeModal, outlets, setSelectedSalesmanId, setActiveView } = useAdmin();

  if (activeModal !== 'modal-salesman-scorecard' || !modalPayload) return null;

  const rep = modalPayload as Salesman;
  const assignedStores = outlets.filter(o => o.assignedSalesmanId === rep.id);
  const target = rep.target || 125000;
  const achieved = rep.achieved || (assignedStores.length * 5800);
  const pct = Math.min(100, Math.round((achieved / target) * 100));
  const totalOutstanding = assignedStores.reduce((sum, s) => sum + s.balance, 0);

  const handleAllocateStores = () => {
    setSelectedSalesmanId(rep.id);
    closeModal();
    setActiveView('allocation');
  };

  return (
    <div className="modal-backdrop open">
      <div className="modal-card modal-lg">
        <div className="modal-header">
          <h3><i className="fa-solid fa-award"></i> Sales Executive Performance Scorecard</h3>
          <button className="modal-close" onClick={closeModal}>&times;</button>
        </div>
        <div className="scorecard-body">
          <div className="scorecard-header-card">
            <div className="scorecard-avatar-lg">{rep.name.split(' ').map(n => n[0]).join('')}</div>
            <div style={{ flex: 1 }}>
              <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
                <h4 style={{ fontSize: '18px', fontWeight: 800, color: '#0F172A' }}>{rep.name}</h4>
                <span className="badge-status online">{rep.status}</span>
              </div>
              <div style={{ fontSize: '13px', color: '#64748B', marginTop: '2px' }}>
                <code>{rep.employeeId}</code> • {rep.territory} • {rep.mobile}
              </div>
            </div>
          </div>

          <div className="scorecard-kpi-grid">
            <div className="scorecard-kpi-card">
              <span className="kpi-sub-label">Assigned Retail Outlets</span>
              <div className="kpi-main-val">{assignedStores.length} Outlets</div>
            </div>
            <div className="scorecard-kpi-card">
              <span className="kpi-sub-label">Monthly Sales Target</span>
              <div className="kpi-main-val">₹ {formatCurrency(target)}</div>
            </div>
            <div className="scorecard-kpi-card">
              <span className="kpi-sub-label">Realized Invoiced Value</span>
              <div className="kpi-main-val" style={{ color: '#16A34A' }}>₹ {formatCurrency(achieved)} ({pct}%)</div>
            </div>
            <div className="scorecard-kpi-card">
              <span className="kpi-sub-label">Territory Outstanding</span>
              <div className="kpi-main-val" style={{ color: '#DC2626' }}>₹ {formatCurrency(totalOutstanding)}</div>
            </div>
            <div className="scorecard-kpi-card">
              <span className="kpi-sub-label">Geofence Compliance</span>
              <div className="kpi-main-val" style={{ color: '#2563EB' }}>98.4% (&le; 100m)</div>
            </div>
            <div className="scorecard-kpi-card">
              <span className="kpi-sub-label">Commission Earned</span>
              <div className="kpi-main-val" style={{ color: '#7C3AED' }}>₹ {formatCurrency(achieved * 0.025)} (2.5%)</div>
            </div>
          </div>

          <div>
            <h5 style={{ fontSize: '13px', fontWeight: 700, color: '#1E293B', marginBottom: '6px' }}>
              <i className="fa-solid fa-route" style={{ color: '#2563EB' }}></i> Assigned Store Beat Network ({assignedStores.length})
            </h5>
            <div className="scorecard-stores-list">
              {assignedStores.length > 0 ? (
                assignedStores.map(s => (
                  <span key={s.id} className="scorecard-store-chip">
                    <i className="fa-solid fa-shop" style={{ color: '#64748B' }}></i>
                    <strong>{s.name}</strong> ({s.market})
                  </span>
                ))
              ) : (
                <span style={{ color: '#94A3B8', fontSize: '12.5px' }}>No stores assigned currently. Click &quot;Allocate Stores&quot; below.</span>
              )}
            </div>
          </div>
        </div>
        <div className="modal-footer">
          <button type="button" className="btn btn-secondary" onClick={closeModal}>Close</button>
          <button type="button" className="btn btn-primary" onClick={handleAllocateStores}>
            <i className="fa-solid fa-arrows-split-up-and-left"></i> Allocate Stores
          </button>
        </div>
      </div>
    </div>
  );
}
