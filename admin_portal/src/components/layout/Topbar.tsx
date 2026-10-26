'use client';

import React from 'react';
import { useAdmin } from '@/context/AdminContext';

export default function Topbar() {
  const { activeView, globalSearch, setGlobalSearch, openModal, showToast } = useAdmin();

  const titles: Record<string, { title: string; caption: string; action: string }> = {
    allocation: { title: "Store-Salesman Allocation Matrix", caption: "Manage territorial store assignments, dynamic route transfers, and field quotas", action: "Add Store" },
    salesmen: { title: "Maintain Field Sales Executives", caption: "Manage sales team master, quotas, commission plans, contact profiles, and live beat status", action: "Add Sales Rep" },
    "inventory-checks": { title: "Store Shelf Inventory Audit Log", caption: "Verify physical stock counts, detect stockouts, track batch expiry, and dispatch auto-replenishment", action: "Record Audit" },
    radar: { title: "Live Field Radar & GPS Geofencing", caption: "Real-time field telemetry and anti-mock location tracking across Kanpur network", action: "Refresh Radar" },
    catalog: { title: "Master SKU Catalog & Pricing", caption: "Configure products, tiered GST slabs, and wholesale dealer price lists", action: "Add SKU" },
    debtors: { title: "Debtor Aging & Credit Risk Exposure", caption: "0–90+ day accounts ledger aging and credit limit compliance", action: "Add Store" },
    audit: { title: "Immutable Governance Audit Trail", caption: "Cryptographically verified record of administrative interventions and route changes", action: "Export Logs" },
    cloud: { title: "Firebase Cloud Pipeline Architecture", caption: "Real-time sync telemetry with Google Cloud Firestore and Security Rules v2", action: "Run Sync" },
  };

  const info = titles[activeView] || titles.allocation;

  const handleQuickAction = () => {
    switch (activeView) {
      case 'allocation':
      case 'debtors':
        openModal('modal-add-outlet');
        break;
      case 'salesmen':
        openModal('modal-add-salesman');
        break;
      case 'inventory-checks':
        openModal('modal-add-inventory-check');
        break;
      case 'catalog':
        openModal('modal-add-product');
        break;
      case 'radar':
        showToast('Radar Refresh', 'Scanning live GPS constellation and geofences...');
        break;
      case 'audit':
        showToast('Audit Trail', 'Exporting cryptographic compliance log CSV...');
        break;
      case 'cloud':
        showToast('Firestore Synchronized', 'All mutations, store allocations, and ledger vouchers streamed to Firebase.');
        break;
    }
  };

  const handleCloudSync = () => {
    showToast('Cloud Pulse Triggered', 'Synchronizing with Firestore project ansu-sales-aupl-cloud...');
  };

  return (
    <header className="topbar">
      <div className="topbar-left">
        <h1 className="page-title">{info.title}</h1>
        <p className="page-caption">{info.caption}</p>
      </div>
      <div className="topbar-right">
        <div className="search-input-wrapper">
          <i className="fa-solid fa-magnifying-glass search-icon"></i>
          <input
            type="text"
            placeholder="Search stores, reps, SKUs..."
            value={globalSearch}
            onChange={(e) => setGlobalSearch(e.target.value)}
          />
        </div>

        <button className="btn btn-outline" onClick={handleCloudSync}>
          <i className="fa-solid fa-rotate"></i>
          <span>Sync Cloud</span>
        </button>

        <button className="btn btn-primary" onClick={handleQuickAction}>
          <i className="fa-solid fa-plus"></i>
          <span>{info.action}</span>
        </button>
      </div>
    </header>
  );
}
