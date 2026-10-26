'use client';

import React, { useState } from 'react';
import { useAdmin } from '@/context/AdminContext';
import { formatCurrency } from '@/lib/utils';

export default function StoreAllocationMatrix() {
  const {
    salesmen,
    outlets,
    selectedSalesmanId,
    setSelectedSalesmanId,
    assignStore,
    openModal,
    globalSearch,
  } = useAdmin();

  const [assignedFilter, setAssignedFilter] = useState('');
  const [availableFilter, setAvailableFilter] = useState('');
  const [marketFilter, setMarketFilter] = useState('ALL');

  const selectedRep = salesmen.find(s => s.id === selectedSalesmanId) || salesmen[0];

  const assignedStores = outlets.filter(o => {
    const isAssigned = o.assignedSalesmanId === selectedRep?.id;
    const matchesLocal = !assignedFilter || o.name.toLowerCase().includes(assignedFilter.toLowerCase()) || o.ownerName.toLowerCase().includes(assignedFilter.toLowerCase());
    const matchesGlobal = !globalSearch || o.name.toLowerCase().includes(globalSearch.toLowerCase());
    return isAssigned && matchesLocal && matchesGlobal;
  });

  const availableStores = outlets.filter(o => {
    const isAvailable = o.assignedSalesmanId !== selectedRep?.id;
    const matchesMarket = marketFilter === 'ALL' || o.market === marketFilter;
    const matchesLocal = !availableFilter || o.name.toLowerCase().includes(availableFilter.toLowerCase()) || o.ownerName.toLowerCase().includes(availableFilter.toLowerCase());
    const matchesGlobal = !globalSearch || o.name.toLowerCase().includes(globalSearch.toLowerCase());
    return isAvailable && matchesMarket && matchesLocal && matchesGlobal;
  });

  return (
    <section className="view-panel active">
      <div className="matrix-container">
        {/* SALESMAN SELECTOR ROW */}
        <div className="salesman-selector-card">
          <div className="section-headline">
            <div>
              <h2>Step 1: Select Field Sales Representative</h2>
              <p>Choose an active salesman to inspect and modify his assigned retail outlets</p>
            </div>
            <button className="btn btn-secondary btn-sm" onClick={() => openModal('modal-reassign-route')}>
              <i className="fa-solid fa-arrows-split-up-and-left"></i> Reassign Entire Route
            </button>
          </div>
          <div className="salesman-cards-grid">
            {salesmen.map(rep => {
              const repStores = outlets.filter(o => o.assignedSalesmanId === rep.id);
              const isSelected = rep.id === selectedRep?.id;
              return (
                <div
                  key={rep.id}
                  className={`rep-selector-card ${isSelected ? 'selected' : ''}`}
                  onClick={() => setSelectedSalesmanId(rep.id)}
                >
                  <div className="rep-card-top">
                    <span className="rep-name">{rep.name}</span>
                    <span className="rep-badge">{rep.employeeId}</span>
                  </div>
                  <div className="rep-card-details">
                    <span><i className="fa-solid fa-map-pin"></i> {rep.territory}</span>
                    <span><i className="fa-solid fa-store"></i> <strong>{repStores.length}</strong> Outlets</span>
                  </div>
                  <div className="rep-card-bottom">
                    <span className="rep-quota">Quota: ₹{formatCurrency(rep.target)}</span>
                    <span className={`status-pill ${rep.status.includes('Active') ? 'active' : ''}`}>{rep.status}</span>
                  </div>
                </div>
              );
            })}
          </div>
        </div>

        {/* DUAL-PANE ALLOCATION MATRIX */}
        <div className="dual-pane-grid">
          {/* LEFT PANE: ASSIGNED STORES */}
          <div className="pane-column assigned-pane">
            <div className="pane-header">
              <div className="pane-title-group">
                <span className="pane-indicator active"></span>
                <h3>Assigned Stores for <span className="highlight-rep">{selectedRep?.name}</span></h3>
              </div>
              <span className="count-pill green">{assignedStores.length} Stores</span>
            </div>
            <div className="pane-search-bar">
              <input
                type="text"
                placeholder="Filter assigned stores..."
                value={assignedFilter}
                onChange={(e) => setAssignedFilter(e.target.value)}
              />
            </div>
            <div className="stores-list-scrollable">
              {assignedStores.length === 0 ? (
                <div className="empty-state-box">
                  <i className="fa-solid fa-inbox"></i>
                  <p>No stores assigned to this representative yet.</p>
                </div>
              ) : (
                assignedStores.map(store => (
                  <div key={store.id} className="store-matrix-card">
                    <div className="store-info-main">
                      <div className="store-title-row">
                        <span className="store-name">{store.name}</span>
                        <span className="market-pill">{store.market}</span>
                      </div>
                      <div className="store-sub-row">
                        <span><i className="fa-solid fa-user"></i> {store.ownerName}</span>
                        <span><i className="fa-solid fa-phone"></i> {store.mobile}</span>
                        <span><i className="fa-solid fa-receipt"></i> Due: <strong>₹{formatCurrency(store.balance)}</strong></span>
                      </div>
                    </div>
                    <button
                      className="btn btn-danger btn-xs"
                      onClick={() => assignStore(store.id, null)}
                      title="Unassign Store"
                    >
                      <i className="fa-solid fa-minus"></i> Remove
                    </button>
                  </div>
                ))
              )}
            </div>
          </div>

          {/* RIGHT PANE: AVAILABLE STORES */}
          <div className="pane-column available-pane">
            <div className="pane-header">
              <div className="pane-title-group">
                <span className="pane-indicator neutral"></span>
                <h3>Available Stores in Territory</h3>
              </div>
              <div className="header-tools">
                <select
                  className="select-sm"
                  value={marketFilter}
                  onChange={(e) => setMarketFilter(e.target.value)}
                >
                  <option value="ALL">All Markets</option>
                  <option value="Civil Lines">Civil Lines</option>
                  <option value="Nayaganj">Nayaganj</option>
                  <option value="Govind Nagar">Govind Nagar</option>
                  <option value="Kidwai Nagar">Kidwai Nagar</option>
                  <option value="Gumti No. 5">Gumti No. 5</option>
                </select>
                <button className="btn btn-outline btn-sm" onClick={() => openModal('modal-bulk-market')}>
                  <i className="fa-solid fa-object-group"></i> Bulk Market
                </button>
              </div>
            </div>
            <div className="pane-search-bar">
              <input
                type="text"
                placeholder="Search by store or owner name..."
                value={availableFilter}
                onChange={(e) => setAvailableFilter(e.target.value)}
              />
            </div>
            <div className="stores-list-scrollable">
              {availableStores.length === 0 ? (
                <div className="empty-state-box">
                  <i className="fa-solid fa-check-circle"></i>
                  <p>All stores in this market are currently allocated.</p>
                </div>
              ) : (
                availableStores.map(store => {
                  const currentRep = salesmen.find(s => s.id === store.assignedSalesmanId);
                  return (
                    <div key={store.id} className="store-matrix-card">
                      <div className="store-info-main">
                        <div className="store-title-row">
                          <span className="store-name">{store.name}</span>
                          <span className="market-pill">{store.market}</span>
                        </div>
                        <div className="store-sub-row">
                          <span><i className="fa-solid fa-user"></i> {store.ownerName}</span>
                          {currentRep ? (
                            <span className="assigned-tag"><i className="fa-solid fa-user-tag"></i> Current: {currentRep.name}</span>
                          ) : (
                            <span className="unassigned-tag"><i className="fa-solid fa-circle-exclamation"></i> Unassigned</span>
                          )}
                        </div>
                      </div>
                      <button
                        className="btn btn-primary btn-xs"
                        onClick={() => assignStore(store.id, selectedRep?.id || null)}
                        title={`Assign to ${selectedRep?.name}`}
                      >
                        <i className="fa-solid fa-plus"></i> Assign
                      </button>
                    </div>
                  );
                })
              )}
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
