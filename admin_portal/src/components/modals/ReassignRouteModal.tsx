'use client';

import React, { useState, useEffect } from 'react';
import { useAdmin } from '@/context/AdminContext';

export default function ReassignRouteModal() {
  const { activeModal, closeModal, salesmen, outlets, reassignEntireRoute } = useAdmin();

  const [fromRep, setFromRep] = useState('USR001');
  const [toRep, setToRep] = useState('USR002');

  useEffect(() => {
    if (salesmen.length >= 2) {
      setFromRep(salesmen[0].id);
      setToRep(salesmen[1].id);
    }
  }, [salesmen]);

  if (activeModal !== 'modal-reassign-route') {
    return null;
  }

  const handleExecute = () => {
    if (fromRep === toRep) {
      alert('Source and destination salesmen cannot be the same person.');
      return;
    }
    reassignEntireRoute(fromRep, toRep);
  };

  return (
    <div className="modal-backdrop active" id="modal-reassign-route">
      <div className="modal-card">
        <div className="modal-header">
          <h3>
            <i className="fa-solid fa-arrows-split-up-and-left"></i> Reassign Entire Sales Route
          </h3>
          <button className="modal-close" onClick={closeModal}>
            &times;
          </button>
        </div>
        <div className="modal-body-pad">
          <p className="modal-desc">
            Transfer all retail outlets assigned to a representative to another salesman in one atomic batch. This creates an immutable audit trail entry and pushes real-time FCM update to mobile clients.
          </p>
          <div className="form-group">
            <label>Source Salesman (Transfer From):</label>
            <select
              id="route-from-rep"
              value={fromRep}
              onChange={e => setFromRep(e.target.value)}
            >
              {salesmen.map(s => {
                const count = outlets.filter(o => o.assignedSalesmanId === s.id).length;
                return (
                  <option key={s.id} value={s.id}>
                    {s.name} ({count} Stores)
                  </option>
                );
              })}
            </select>
          </div>
          <div className="form-group" style={{ marginTop: '12px' }}>
            <label>Destination Salesman (Transfer To):</label>
            <select
              id="route-to-rep"
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
          <button className="btn btn-danger" onClick={handleExecute}>
            <i className="fa-solid fa-shuffle"></i> Execute Route Transfer
          </button>
        </div>
      </div>
    </div>
  );
}
