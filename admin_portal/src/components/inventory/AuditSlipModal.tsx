'use client';

import React from 'react';
import { useAdmin } from '@/context/AdminContext';
import { InventoryCheck } from '@/types';

export default function AuditSlipModal() {
  const { activeModal, modalPayload, closeModal, triggerReplenishmentOrder } = useAdmin();

  if (activeModal !== 'modal-view-audit-detail' || !modalPayload) {
    return null;
  }

  const chk = modalPayload as InventoryCheck;

  const handleTriggerReorder = () => {
    triggerReplenishmentOrder(chk.id);
  };

  return (
    <div className="modal-backdrop active" id="modal-view-audit-detail">
      <div className="modal-card">
        <div className="modal-header">
          <h3>
            <i className="fa-solid fa-receipt"></i> Store Shelf Audit Inspection Slip
          </h3>
          <button className="modal-close" onClick={closeModal}>
            &times;
          </button>
        </div>
        <div className="audit-slip-body" id="audit-slip-content">
          <div className="audit-slip-card">
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
              <div>
                <span style={{ fontSize: '11px', fontWeight: 700, color: '#64748B', textTransform: 'uppercase' }}>
                  AUDIT TICKET
                </span>
                <h4 style={{ fontSize: '19px', fontWeight: 800, color: '#0F172A', margin: '2px 0' }}>
                  {chk.id}
                </h4>
                <span style={{ fontSize: '12.5px', color: '#475569' }}>Recorded on {chk.timestamp}</span>
              </div>
              <div>
                {chk.variance < 0 ? (
                  <span className="audit-status-badge critical">
                    <i className="fa-solid fa-triangle-exclamation"></i> Deficit Alert
                  </span>
                ) : (
                  <span className="audit-status-badge healthy">
                    <i className="fa-solid fa-check"></i> Stock Verified
                  </span>
                )}
              </div>
            </div>

            <div className="slip-detail-grid">
              <div className="slip-item">
                <span className="slip-item-label">Retail Store</span>
                <span className="slip-item-val">
                  {chk.outletName} ({chk.market})
                </span>
              </div>
              <div className="slip-item">
                <span className="slip-item-label">Audited By</span>
                <span className="slip-item-val">
                  {chk.auditorName} [{chk.auditorEmpId}]
                </span>
              </div>
              <div className="slip-item">
                <span className="slip-item-label">Audited SKU</span>
                <span className="slip-item-val">
                  {chk.productName} (<code>{chk.skuCode}</code>)
                </span>
              </div>
              <div className="slip-item">
                <span className="slip-item-label">Shelf Facing Quality</span>
                <span className="slip-item-val">
                  <span className="facing-badge">
                    <i className="fa-solid fa-eye"></i> {chk.facingGrade}
                  </span>
                </span>
              </div>
              <div className="slip-item">
                <span className="slip-item-label">Physical Shelf Count</span>
                <span
                  className="slip-item-val"
                  style={{ fontSize: '16px', color: chk.physicalCount < 5 ? '#DC2626' : '#16A34A', fontWeight: 700 }}
                >
                  {chk.physicalCount} Units
                </span>
              </div>
              <div className="slip-item">
                <span className="slip-item-label">Minimum Required Stock</span>
                <span className="slip-item-val">{chk.targetCount} Units</span>
              </div>
              <div className="slip-item">
                <span className="slip-item-label">Batch Code</span>
                <span className="slip-item-val">
                  <code>{chk.batchNo || 'N/A'}</code>
                </span>
              </div>
              <div className="slip-item">
                <span className="slip-item-label">Expiry Date</span>
                <span className="slip-item-val">{chk.expiryDate || 'N/A'}</span>
              </div>
            </div>

            <div style={{ marginTop: '14px', paddingTop: '12px', borderTop: '1px dashed #E2E8F0' }}>
              <span className="slip-item-label">Auditor Observations:</span>
              <p style={{ fontSize: '13px', color: '#334155', marginTop: '4px', fontStyle: 'italic' }}>
                &ldquo;{chk.notes}&rdquo;
              </p>
            </div>

            {chk.replenishmentPoId && (
              <div
                style={{
                  marginTop: '12px',
                  background: '#DCFCE7',
                  border: '1px solid #86EFAC',
                  borderRadius: '8px',
                  padding: '10px 12px',
                  fontSize: '12px',
                  color: '#166534',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'space-between',
                }}
              >
                <span>
                  <i className="fa-solid fa-truck-ramp-box"></i> Auto-Replenishment PO Active:{' '}
                  <strong>{chk.replenishmentPoId}</strong>
                </span>
                <span style={{ fontWeight: 700 }}>Status: DISPATCHED</span>
              </div>
            )}
          </div>
        </div>
        <div className="modal-footer">
          <button type="button" className="btn btn-secondary" onClick={closeModal}>
            Close
          </button>
          {chk.variance < 0 && chk.replenishmentStatus !== 'PO_GENERATED' && (
            <button type="button" className="btn btn-success" onClick={handleTriggerReorder}>
              <i className="fa-solid fa-truck-ramp-box"></i> Trigger Replenishment PO
            </button>
          )}
        </div>
      </div>
    </div>
  );
}
