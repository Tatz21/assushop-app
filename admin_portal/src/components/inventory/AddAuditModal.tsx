'use client';

import React, { useState, useEffect } from 'react';
import { useAdmin } from '@/context/AdminContext';

export default function AddAuditModal() {
  const { activeModal, closeModal, outlets, salesmen, products, addInventoryCheck } = useAdmin();

  const [outletId, setOutletId] = useState('');
  const [repId, setRepId] = useState('');
  const [skuCode, setSkuCode] = useState('');
  const [facingGrade, setFacingGrade] = useState('A+ Prime Eye-Level');
  const [physicalCount, setPhysicalCount] = useState<number | ''>(4);
  const [targetCount, setTargetCount] = useState<number | ''>(24);
  const [batchNo, setBatchNo] = useState('AU-26K09');
  const [expiryDate, setExpiryDate] = useState('2027-11-30');
  const [notes, setNotes] = useState('');

  // Set defaults when opened
  useEffect(() => {
    if (activeModal === 'modal-add-inventory-check') {
      if (outlets.length > 0) {
        const firstStore = outlets[0];
        setOutletId(firstStore.id);
        setRepId(firstStore.assignedSalesmanId || (salesmen[0] ? salesmen[0].id : ''));
      }
      if (products.length > 0) {
        setSkuCode(products[0].skuCode);
      }
      setFacingGrade('A+ Prime Eye-Level');
      setPhysicalCount(4);
      setTargetCount(24);
      setBatchNo('AU-26K09');
      setExpiryDate('2027-11-30');
      setNotes('');
    }
  }, [activeModal, outlets, salesmen, products]);

  if (activeModal !== 'modal-add-inventory-check') {
    return null;
  }

  const handleOutletChange = (storeId: string) => {
    setOutletId(storeId);
    const store = outlets.find(o => o.id === storeId);
    if (store && store.assignedSalesmanId) {
      setRepId(store.assignedSalesmanId);
    }
  };

  const phys = typeof physicalCount === 'number' ? physicalCount : NaN;
  const target = typeof targetCount === 'number' ? targetCount : 24;
  const gap = !isNaN(phys) ? phys - target : null;

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!outletId || !repId || !skuCode || isNaN(phys)) return;

    addInventoryCheck({
      outletId,
      auditedBySalesmanId: repId,
      skuCode,
      facingGrade,
      physicalCount: phys,
      targetCount: target,
      batchNo: batchNo.trim() || 'AU-26K09',
      expiryDate: expiryDate || '2027-12-31',
      notes: notes.trim(),
    });
  };

  return (
    <div className="modal-backdrop active" id="modal-add-inventory-check">
      <div className="modal-card">
        <div className="modal-header">
          <h3>
            <i className="fa-solid fa-clipboard-check"></i> Record Store Inventory Audit
          </h3>
          <button className="modal-close" onClick={closeModal}>
            &times;
          </button>
        </div>
        <form id="form-add-inventory-check" onSubmit={handleSubmit}>
          <div className="form-grid">
            <div className="form-group">
              <label>Retail Store *</label>
              <select
                id="audit-outlet-select"
                required
                value={outletId}
                onChange={e => handleOutletChange(e.target.value)}
              >
                {outlets.map(o => (
                  <option key={o.id} value={o.id}>
                    {o.name} [{o.market}]
                  </option>
                ))}
              </select>
            </div>
            <div className="form-group">
              <label>Audited By (Sales Rep) *</label>
              <select
                id="audit-salesman-select"
                required
                value={repId}
                onChange={e => setRepId(e.target.value)}
              >
                {salesmen.map(s => (
                  <option key={s.id} value={s.id}>
                    {s.name} ({s.employeeId})
                  </option>
                ))}
              </select>
            </div>
            <div className="form-group">
              <label>Product SKU Audited *</label>
              <select
                id="audit-sku-select"
                required
                value={skuCode}
                onChange={e => setSkuCode(e.target.value)}
              >
                {products.map(p => (
                  <option key={p.skuCode} value={p.skuCode}>
                    {p.name} ({p.unit})
                  </option>
                ))}
              </select>
            </div>
            <div className="form-group">
              <label>Shelf Facing / Placement Grade</label>
              <select
                id="audit-facing-grade"
                value={facingGrade}
                onChange={e => setFacingGrade(e.target.value)}
              >
                <option value="A+ Prime Eye-Level">A+ Prime Eye-Level (Front Rack)</option>
                <option value="B Standard Shelf">B Standard Shelf (Mid Level)</option>
                <option value="C Bottom / Secondary">C Bottom / Secondary Shelf</option>
                <option value="D Blocked / Not Visible">D Blocked / Backroom only</option>
              </select>
            </div>
            <div className="form-group">
              <label>Physical Shelf Count (Units) *</label>
              <input
                type="number"
                id="audit-physical-count"
                placeholder="e.g. 4"
                min="0"
                required
                value={physicalCount}
                onChange={e => setPhysicalCount(e.target.value === '' ? '' : parseInt(e.target.value))}
              />
            </div>
            <div className="form-group">
              <label>Recommended Minimum Shelf Stock *</label>
              <input
                type="number"
                id="audit-target-count"
                placeholder="e.g. 24"
                min="1"
                required
                value={targetCount}
                onChange={e => setTargetCount(e.target.value === '' ? '' : parseInt(e.target.value))}
              />
            </div>
            <div className="form-group">
              <label>Batch Code Number</label>
              <input
                type="text"
                id="audit-batch-no"
                placeholder="e.g. B2408-AUPL"
                value={batchNo}
                onChange={e => setBatchNo(e.target.value)}
              />
            </div>
            <div className="form-group">
              <label>Batch Expiry Date</label>
              <input
                type="date"
                id="audit-expiry-date"
                value={expiryDate}
                onChange={e => setExpiryDate(e.target.value)}
              />
            </div>
            <div className="form-group full-width">
              <div className="calc-preview-card" id="audit-deficit-preview">
                <span>Audit Stock Health Calculation:</span>
                <strong id="audit-calc-result">
                  {gap === null ? (
                    <span className="text-neutral">Enter physical count to calculate variance</span>
                  ) : gap <= -15 ? (
                    <span className="text-danger">
                      <i className="fa-solid fa-triangle-exclamation"></i> Critical Deficit ({gap} units)! Severe Stockout Risk. Auto-PO required.
                    </span>
                  ) : gap < 0 ? (
                    <span className="text-warning">
                      <i className="fa-solid fa-bell"></i> Low Stock ({gap} units). Restock recommended.
                    </span>
                  ) : gap > 10 ? (
                    <span className="text-info">
                      <i className="fa-solid fa-box-archive"></i> Overstocked (+{gap} units above threshold).
                    </span>
                  ) : (
                    <span className="text-success">
                      <i className="fa-solid fa-circle-check"></i> Stock Level Balanced &amp; Healthy.
                    </span>
                  )}
                </strong>
              </div>
            </div>
            <div className="form-group full-width">
              <label>Auditor Notes &amp; Store Feedback</label>
              <textarea
                id="audit-notes"
                rows={2}
                placeholder="e.g. High demand on weekend. Store owner requested urgent delivery of 2 cartons."
                value={notes}
                onChange={e => setNotes(e.target.value)}
              ></textarea>
            </div>
          </div>
          <div className="modal-footer">
            <button type="button" className="btn btn-secondary" onClick={closeModal}>
              Cancel
            </button>
            <button type="submit" className="btn btn-primary">
              <i className="fa-solid fa-floppy-disk"></i> Submit Audit Result
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
