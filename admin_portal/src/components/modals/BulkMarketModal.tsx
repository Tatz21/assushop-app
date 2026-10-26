'use client';

import React, { useState } from 'react';
import { useAdmin } from '@/context/AdminContext';

export default function BulkMarketModal() {
  const { activeModal, closeModal, salesmen, outlets, bulkAssignMarket } = useAdmin();

  const [market, setMarket] = useState('Nayaganj');
  const [toRep, setToRep] = useState('USR001');

  if (activeModal !== 'modal-bulk-market') {
    return null;
  }

  const markets = ['Nayaganj', 'Civil Lines', 'Govind Nagar', 'Kidwai Nagar', 'Gumti No. 5'];

  const handleExecute = () => {
    bulkAssignMarket(market, toRep);
  };

  return (
    <div className="modal-backdrop active" id="modal-bulk-market">
      <div className="modal-card">
        <div className="modal-header">
          <h3>
            <i className="fa-solid fa-object-group"></i> Bulk Market Area Assignment
          </h3>
          <button className="modal-close" onClick={closeModal}>
            &times;
          </button>
        </div>
        <div className="modal-body-pad">
          <p className="modal-desc">
            Assign every retail outlet in an entire market cluster to a single sales representative with one click.
          </p>
          <div className="form-group">
            <label>Select Market Area Cluster:</label>
            <select
              id="bulk-market-select"
              value={market}
              onChange={e => setMarket(e.target.value)}
            >
              {markets.map(m => {
                const count = outlets.filter(o => o.market === m).length;
                return (
                  <option key={m} value={m}>
                    {m} Market ({count} Stores)
                  </option>
                );
              })}
            </select>
          </div>
          <div className="form-group" style={{ marginTop: '12px' }}>
            <label>Assign all stores in this market to:</label>
            <select
              id="bulk-market-rep"
              value={toRep}
              onChange={e => setToRep(e.target.value)}
            >
              {salesmen.map(s => (
                <option key={s.id} value={s.id}>
                  {s.name} ({s.employeeId})
                </option>
              ))}
            </select>
          </div>
        </div>
        <div className="modal-footer">
          <button className="btn btn-secondary" onClick={closeModal}>
            Cancel
          </button>
          <button className="btn btn-primary" onClick={handleExecute}>
            <i className="fa-solid fa-check-double"></i> Assign Market Cluster
          </button>
        </div>
      </div>
    </div>
  );
}
