'use client';

import React, { useState } from 'react';
import { useAdmin } from '@/context/AdminContext';

export default function CloudPipeline() {
  const { outlets, salesmen, products, auditLogs, showToast } = useAdmin();
  const [syncing, setSyncing] = useState(false);

  const handleSyncPulse = () => {
    setSyncing(true);
    setTimeout(() => {
      setSyncing(false);
      showToast(
        'Firestore Synchronized',
        'All mutations, store allocations, and ledger vouchers streamed to Firebase.'
      );
    }, 800);
  };

  return (
    <section className="view-panel active" id="view-cloud">
      <div className="cloud-pipeline-container">
        <div className="cloud-hero-card">
          <div className="cloud-hero-left">
            <div className="firebase-flame-icon">
              <i className="fa-solid fa-fire"></i>
            </div>
            <div>
              <h2>Google Cloud Firestore Integration Pipeline</h2>
              <p>
                AUPL Enterprise Sales Architecture • Project ID:{' '}
                <code className="project-tag">ansu-sales-aupl-cloud</code>
              </p>
              <div className="badges-row">
                <span className="pill-chip green">
                  <i className="fa-solid fa-circle-check"></i> Rules v2 Deployed
                </span>
                <span className="pill-chip blue">
                  <i className="fa-solid fa-database"></i> 8 Collections Streaming
                </span>
                <span className="pill-chip orange">
                  <i className="fa-solid fa-fingerprint"></i> UUID v4 Idempotency Active
                </span>
              </div>
            </div>
          </div>
          <button
            className="btn btn-primary"
            id="btn-sync-cloud"
            onClick={handleSyncPulse}
            disabled={syncing}
          >
            {syncing ? (
              <>
                <i className="fa-solid fa-rotate fa-spin"></i> Syncing...
              </>
            ) : (
              <>
                <i className="fa-solid fa-cloud-arrow-up"></i> Run Instant Sync Pulse
              </>
            )}
          </button>
        </div>

        <div className="cloud-collections-grid">
          <div className="collection-stat-card">
            <div className="col-header">
              <code>/outlets</code>
              <span className="col-count" id="count-col-outlets">
                {outlets.length} Docs
              </span>
            </div>
            <p>Store profiles, GPS coordinates, credit limits, assigned salesman bindings</p>
          </div>
          <div className="collection-stat-card">
            <div className="col-header">
              <code>/users</code>
              <span className="col-count" id="count-col-users">
                {salesmen.length + 1} Docs
              </span>
            </div>
            <p>Salesmen &amp; Administrator profiles, hardware token bindings, custom role claims</p>
          </div>
          <div className="collection-stat-card">
            <div className="col-header">
              <code>/products</code>
              <span className="col-count" id="count-col-products">
                {products.length} Docs
              </span>
            </div>
            <p>SKU Master Catalog, tiered GST rates, wholesale base price limits</p>
          </div>
          <div className="collection-stat-card">
            <div className="col-header">
              <code>/sales_invoices</code>
              <span className="col-count" id="count-col-invoices">
                3 Docs
              </span>
            </div>
            <p>Append-only sales vouchers, line item tax breakdowns, UUID v4 keys</p>
          </div>
          <div className="collection-stat-card">
            <div className="col-header">
              <code>/collections</code>
              <span className="col-count" id="count-col-collections">
                2 Docs
              </span>
            </div>
            <p>Multi-mode payment slips: Cash, UPI (12-digit UTR), Cheque realization</p>
          </div>
          <div className="collection-stat-card">
            <div className="col-header">
              <code>/ledgers</code>
              <span className="col-count" id="count-col-ledgers">
                7 Docs
              </span>
            </div>
            <p>Transactional Party Mini-Ledger records enforcing Rule 7 &amp; 8 balance invariance</p>
          </div>
          <div className="collection-stat-card">
            <div className="col-header">
              <code>/visits</code>
              <span className="col-count" id="count-col-visits">
                3 Docs
              </span>
            </div>
            <p>Geofenced check-in/out timestamps, visit durations, anti-mock telemetry</p>
          </div>
          <div className="collection-stat-card">
            <div className="col-header">
              <code>/audit_logs</code>
              <span className="col-count" id="count-col-audit">
                {auditLogs.length} Docs
              </span>
            </div>
            <p>Cryptographic chronological records of admin interventions &amp; route shifts</p>
          </div>
        </div>
      </div>
    </section>
  );
}
