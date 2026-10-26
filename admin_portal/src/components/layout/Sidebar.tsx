'use client';

import React from 'react';
import { useAdmin } from '@/context/AdminContext';
import { ViewType } from '@/types';

export default function Sidebar() {
  const { activeView, setActiveView, outlets, salesmen, inventoryChecks } = useAdmin();

  const unassignedCount = outlets.filter(o => !o.assignedSalesmanId).length;
  const criticalOverdueCount = outlets.filter(o => o.balance > 0 && o.agingDays > 90).length;
  const criticalStockoutCount = inventoryChecks.filter(c => c.status === 'CRITICAL_DEFICIT').length;

  const navItems: { id: ViewType; label: string; icon: string; badge?: number | string; badgeAlert?: boolean; pulse?: boolean }[] = [
    { id: 'allocation', label: 'Store Allocation Matrix', icon: 'fa-network-wired', badge: unassignedCount },
    { id: 'salesmen', label: 'Maintain Sales Persons', icon: 'fa-users-gear', badge: salesmen.length },
    { id: 'inventory-checks', label: 'Inventory Check Results', icon: 'fa-clipboard-check', badge: criticalStockoutCount, badgeAlert: true },
    { id: 'radar', label: 'Live Field Radar & GPS', icon: 'fa-satellite-dish', pulse: true },
    { id: 'catalog', label: 'Master SKU Catalog', icon: 'fa-layer-group' },
    { id: 'debtors', label: 'Debtor Aging & Outstandings', icon: 'fa-file-invoice-dollar', badge: criticalOverdueCount, badgeAlert: true },
    { id: 'audit', label: 'Immutable Audit Trail', icon: 'fa-shield-halved' },
    { id: 'cloud', label: 'Firebase Cloud Pipeline', icon: 'fa-cloud-arrow-up' },
  ];

  return (
    <aside className="sidebar">
      <div className="brand-header">
        <div className="brand-logo-badge">
          <i className="fa-solid fa-boxes-stacked"></i>
        </div>
        <div className="brand-text">
          <span className="brand-title">ANSU UDYOG</span>
          <span className="brand-subtitle">CENTRAL ADMIN CONSOLE</span>
        </div>
      </div>

      <div className="admin-profile-card">
        <div className="avatar-wrapper">
          <div className="avatar-initials">SA</div>
          <span className="status-indicator online"></span>
        </div>
        <div className="profile-info">
          <div className="profile-name">Sunil Agarwal</div>
          <div className="profile-role">Super Administrator</div>
          <div className="profile-org">HQ • Kanpur, UP</div>
        </div>
      </div>

      <nav className="nav-menu">
        <div className="nav-section-label">OPERATIONS & FIELD REPS</div>
        {navItems.slice(0, 5).map(item => (
          <a
            key={item.id}
            href={`#${item.id}`}
            className={`nav-item ${activeView === item.id ? 'active' : ''}`}
            onClick={(e) => {
              e.preventDefault();
              setActiveView(item.id);
            }}
          >
            <i className={`fa-solid ${item.icon}`}></i>
            <span>{item.label}</span>
            {item.badge !== undefined && (
              <span className={`nav-badge ${item.badgeAlert ? 'alert' : ''}`}>{item.badge}</span>
            )}
            {item.pulse && <span className="nav-pulse-dot"></span>}
          </a>
        ))}

        <div className="nav-section-label">FINANCE & GOVERNANCE</div>
        {navItems.slice(5).map(item => (
          <a
            key={item.id}
            href={`#${item.id}`}
            className={`nav-item ${activeView === item.id ? 'active' : ''}`}
            onClick={(e) => {
              e.preventDefault();
              setActiveView(item.id);
            }}
          >
            <i className={`fa-solid ${item.icon}`}></i>
            <span>{item.label}</span>
            {item.badge !== undefined && (
              <span className={`nav-badge ${item.badgeAlert ? 'alert' : ''}`}>{item.badge}</span>
            )}
            {item.id === 'cloud' && <span className="status-pill-mini">ACTIVE</span>}
          </a>
        ))}
      </nav>

      <div className="sidebar-footer">
        <div className="cloud-status-box">
          <div className="cloud-status-header">
            <i className="fa-brands fa-google cloud-icon"></i>
            <span>Firestore Security v2</span>
          </div>
          <div className="cloud-status-detail">
            <span className="dot-active"></span>
            <span>Project: ansu-sales-aupl-cloud</span>
          </div>
        </div>
      </div>
    </aside>
  );
}
