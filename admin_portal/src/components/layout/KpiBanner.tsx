'use client';

import React from 'react';
import { useAdmin } from '@/context/AdminContext';
import { formatCurrency } from '@/lib/utils';

export default function KpiBanner() {
  const { outlets, salesmen } = useAdmin();

  const totalOutlets = outlets.length;
  const activeReps = salesmen.length;
  const totalDebt = outlets.reduce((sum, o) => sum + o.balance, 0);
  const overdueCount = outlets.filter(o => o.balance > 0 && o.agingDays > 60).length;

  return (
    <section className="kpi-banner">
      <div className="kpi-card">
        <div className="kpi-icon-circle blue">
          <i className="fa-solid fa-shop"></i>
        </div>
        <div className="kpi-content">
          <span className="kpi-label">Total Outlets</span>
          <div className="kpi-value">{totalOutlets}</div>
          <span className="kpi-trend positive"><i className="fa-solid fa-check"></i> 100% Geotagged</span>
        </div>
      </div>

      <div className="kpi-card">
        <div className="kpi-icon-circle purple">
          <i className="fa-solid fa-user-tie"></i>
        </div>
        <div className="kpi-content">
          <span className="kpi-label">Active Field Reps</span>
          <div className="kpi-value">{activeReps}</div>
          <span className="kpi-trend neutral"><i className="fa-solid fa-location-crosshairs"></i> Kanpur Central</span>
        </div>
      </div>

      <div className="kpi-card">
        <div className="kpi-icon-circle amber">
          <i className="fa-solid fa-indian-rupee-sign"></i>
        </div>
        <div className="kpi-content">
          <span className="kpi-label">Market Outstanding</span>
          <div className="kpi-value">₹ {formatCurrency(totalDebt)}</div>
          <span className="kpi-trend alert"><i className="fa-solid fa-triangle-exclamation"></i> {overdueCount} Debtors Active</span>
        </div>
      </div>

      <div className="kpi-card">
        <div className="kpi-icon-circle green">
          <i className="fa-solid fa-cloud-bolt"></i>
        </div>
        <div className="kpi-content">
          <span className="kpi-label">Cloud Sync State</span>
          <div className="kpi-value">100% Online</div>
          <span className="kpi-trend positive"><i className="fa-solid fa-shield"></i> Idempotent v4</span>
        </div>
      </div>
    </section>
  );
}
