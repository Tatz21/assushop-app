'use client';

import React, { useState } from 'react';
import { useAdmin } from '@/context/AdminContext';

export default function AddStoreModal() {
  const { activeModal, closeModal, salesmen, addOutlet } = useAdmin();

  const [name, setName] = useState('');
  const [owner, setOwner] = useState('');
  const [mobile, setMobile] = useState('');
  const [market, setMarket] = useState('Civil Lines');
  const [assignee, setAssignee] = useState<string>('USR001');
  const [creditLimit, setCreditLimit] = useState<number | ''>(50000);
  const [openingBalance, setOpeningBalance] = useState<number | ''>(0);

  if (activeModal !== 'modal-add-outlet') {
    return null;
  }

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!name.trim() || !owner.trim() || !mobile.trim()) return;

    addOutlet({
      name: name.trim(),
      ownerName: owner.trim(),
      mobile: mobile.trim(),
      market,
      assignedSalesmanId: assignee ? assignee : null,
      creditLimit: typeof creditLimit === 'number' ? creditLimit : 50000,
      balance: typeof openingBalance === 'number' ? openingBalance : 0,
      agingDays: typeof openingBalance === 'number' && openingBalance > 0 ? 15 : 0,
    });

    setName('');
    setOwner('');
    setMobile('');
  };

  return (
    <div className="modal-backdrop active" id="modal-add-outlet">
      <div className="modal-card">
        <div className="modal-header">
          <h3>
            <i className="fa-solid fa-shop"></i> Onboard New Retail Store
          </h3>
          <button className="modal-close" onClick={closeModal}>
            &times;
          </button>
        </div>
        <form id="form-add-outlet" onSubmit={handleSubmit}>
          <div className="form-grid">
            <div className="form-group full-width">
              <label>Store Name *</label>
              <input
                type="text"
                id="outlet-name"
                placeholder="e.g. Royal Medical & General Store"
                required
                value={name}
                onChange={e => setName(e.target.value)}
              />
            </div>
            <div className="form-group">
              <label>Proprietor / Owner Name *</label>
              <input
                type="text"
                id="outlet-owner"
                placeholder="e.g. Vijay Khanna"
                required
                value={owner}
                onChange={e => setOwner(e.target.value)}
              />
            </div>
            <div className="form-group">
              <label>Mobile Number *</label>
              <input
                type="tel"
                id="outlet-mobile"
                placeholder="e.g. 9839012345"
                required
                value={mobile}
                onChange={e => setMobile(e.target.value)}
              />
            </div>
            <div className="form-group">
              <label>Market Area *</label>
              <select
                id="outlet-market"
                required
                value={market}
                onChange={e => setMarket(e.target.value)}
              >
                <option value="Civil Lines">Civil Lines</option>
                <option value="Nayaganj">Nayaganj</option>
                <option value="Govind Nagar">Govind Nagar</option>
                <option value="Kidwai Nagar">Kidwai Nagar</option>
                <option value="Gumti No. 5">Gumti No. 5</option>
              </select>
            </div>
            <div className="form-group">
              <label>Assign Salesman Immediately</label>
              <select
                id="outlet-assignee"
                value={assignee}
                onChange={e => setAssignee(e.target.value)}
              >
                {salesmen.map(s => (
                  <option key={s.id} value={s.id}>
                    {s.name} ({s.employeeId})
                  </option>
                ))}
                <option value="">Leave Unassigned (Pool)</option>
              </select>
            </div>
            <div className="form-group">
              <label>Credit Limit (₹)</label>
              <input
                type="number"
                id="outlet-credit-limit"
                min="0"
                step="5000"
                value={creditLimit}
                onChange={e => setCreditLimit(e.target.value === '' ? '' : parseFloat(e.target.value))}
              />
            </div>
            <div className="form-group">
              <label>Opening Balance (₹)</label>
              <input
                type="number"
                id="outlet-opening-balance"
                min="0"
                step="1000"
                value={openingBalance}
                onChange={e => setOpeningBalance(e.target.value === '' ? '' : parseFloat(e.target.value))}
              />
            </div>
          </div>
          <div className="modal-footer">
            <button type="button" className="btn btn-secondary" onClick={closeModal}>
              Cancel
            </button>
            <button type="submit" className="btn btn-primary">
              <i className="fa-solid fa-check"></i> Register Store
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
