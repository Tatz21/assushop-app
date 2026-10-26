'use client';

import React, { useState, useEffect } from 'react';
import { useAdmin } from '@/context/AdminContext';
import { Salesman } from '@/types';

export default function EditSalesmanModal() {
  const { activeModal, modalPayload, closeModal, updateSalesman } = useAdmin();

  const [name, setName] = useState('');
  const [mobile, setMobile] = useState('');
  const [territory, setTerritory] = useState('');
  const [target, setTarget] = useState(125000);
  const [status, setStatus] = useState('Active (In Store)');

  useEffect(() => {
    if (modalPayload) {
      const rep = modalPayload as Salesman;
      setName(rep.name || '');
      setMobile(rep.mobile || '');
      setTerritory(rep.territory || '');
      setTarget(rep.target || 125000);
      setStatus(rep.status || 'Active (In Store)');
    }
  }, [modalPayload]);

  if (activeModal !== 'modal-edit-salesman' || !modalPayload) return null;
  const rep = modalPayload as Salesman;

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    updateSalesman(rep.id, {
      name: name.trim(),
      mobile: mobile.trim(),
      territory: territory.trim(),
      target: Number(target),
      status,
    });
  };

  return (
    <div className="modal-backdrop open">
      <div className="modal-card">
        <div className="modal-header">
          <h3><i className="fa-solid fa-user-pen"></i> Edit Sales Executive Profile</h3>
          <button className="modal-close" onClick={closeModal}>&times;</button>
        </div>
        <form onSubmit={handleSubmit}>
          <div className="form-grid">
            <div className="form-group">
              <label>Full Name *</label>
              <input
                type="text"
                value={name}
                onChange={(e) => setName(e.target.value)}
                required
              />
            </div>
            <div className="form-group">
              <label>Employee ID</label>
              <input
                type="text"
                value={rep.employeeId}
                readOnly
                className="input-readonly"
              />
            </div>
            <div className="form-group">
              <label>Mobile Number *</label>
              <input
                type="tel"
                value={mobile}
                onChange={(e) => setMobile(e.target.value)}
                required
              />
            </div>
            <div className="form-group">
              <label>Territory / Beat *</label>
              <input
                type="text"
                value={territory}
                onChange={(e) => setTerritory(e.target.value)}
                required
              />
            </div>
            <div className="form-group">
              <label>Monthly Target (₹) *</label>
              <input
                type="number"
                step="5000"
                value={target}
                onChange={(e) => setTarget(Number(e.target.value))}
                required
              />
            </div>
            <div className="form-group">
              <label>Status</label>
              <select value={status} onChange={(e) => setStatus(e.target.value)}>
                <option value="Active (In Store)">Active (In Store)</option>
                <option value="In Transit (GT Road)">In Transit</option>
                <option value="On Leave">On Leave / Off-Duty</option>
              </select>
            </div>
          </div>
          <div className="modal-footer">
            <button type="button" className="btn btn-secondary" onClick={closeModal}>Cancel</button>
            <button type="submit" className="btn btn-primary"><i className="fa-solid fa-floppy-disk"></i> Save Changes</button>
          </div>
        </form>
      </div>
    </div>
  );
}
