'use client';

import React, { useState } from 'react';
import { useAdmin } from '@/context/AdminContext';

export default function AddSalesmanModal() {
  const { activeModal, closeModal, addSalesman, salesmen } = useAdmin();

  const [name, setName] = useState('');
  const [empId, setEmpId] = useState(`EMP-010${salesmen.length + 1}`);
  const [mobile, setMobile] = useState('');
  const [email, setEmail] = useState('');
  const [territory, setTerritory] = useState('');
  const [target, setTarget] = useState(125000);
  const [status, setStatus] = useState('Active (In Store)');
  const [commission, setCommission] = useState(2.5);

  if (activeModal !== 'modal-add-salesman') return null;

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!name.trim()) return;
    addSalesman({
      name: name.trim(),
      employeeId: empId.trim(),
      mobile: mobile.trim() || '+91 98394 56789',
      email: email.trim(),
      territory: territory.trim() || 'Kanpur Central',
      target: Number(target) || 125000,
      status,
      commissionRate: Number(commission) || 2.5,
    });
    setName('');
    setMobile('');
    setEmail('');
    setTerritory('');
  };

  return (
    <div className="modal-backdrop open">
      <div className="modal-card">
        <div className="modal-header">
          <h3><i className="fa-solid fa-user-plus"></i> Onboard Field Sales Executive</h3>
          <button className="modal-close" onClick={closeModal}>&times;</button>
        </div>
        <form onSubmit={handleSubmit}>
          <div className="form-grid">
            <div className="form-group">
              <label>Full Name *</label>
              <input
                type="text"
                placeholder="e.g. Vikas Mehrotra"
                value={name}
                onChange={(e) => setName(e.target.value)}
                required
              />
            </div>
            <div className="form-group">
              <label>Employee ID *</label>
              <input
                type="text"
                value={empId}
                onChange={(e) => setEmpId(e.target.value)}
                required
              />
            </div>
            <div className="form-group">
              <label>Mobile Number *</label>
              <input
                type="tel"
                placeholder="e.g. +91 98394 56789"
                value={mobile}
                onChange={(e) => setMobile(e.target.value)}
                required
              />
            </div>
            <div className="form-group">
              <label>Work Email</label>
              <input
                type="email"
                placeholder="e.g. vikas.m@ansuudyog.com"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
              />
            </div>
            <div className="form-group">
              <label>Primary Assigned Beat / Territory *</label>
              <input
                type="text"
                placeholder="e.g. Gumti No. 5 & Shastri Nagar"
                value={territory}
                onChange={(e) => setTerritory(e.target.value)}
                required
              />
            </div>
            <div className="form-group">
              <label>Monthly Sales Target (₹) *</label>
              <input
                type="number"
                min="10000"
                step="5000"
                value={target}
                onChange={(e) => setTarget(Number(e.target.value))}
                required
              />
            </div>
            <div className="form-group">
              <label>Field Status</label>
              <select value={status} onChange={(e) => setStatus(e.target.value)}>
                <option value="Active (In Store)">Active (In Store)</option>
                <option value="In Transit (GT Road)">In Transit</option>
                <option value="On Leave">On Leave / Off-Duty</option>
              </select>
            </div>
            <div className="form-group">
              <label>Commission Rate (%)</label>
              <input
                type="number"
                min="0"
                max="15"
                step="0.5"
                value={commission}
                onChange={(e) => setCommission(Number(e.target.value))}
              />
            </div>
          </div>
          <div className="modal-footer">
            <button type="button" className="btn btn-secondary" onClick={closeModal}>Cancel</button>
            <button type="submit" className="btn btn-primary"><i className="fa-solid fa-check"></i> Register Sales Executive</button>
          </div>
        </form>
      </div>
    </div>
  );
}
