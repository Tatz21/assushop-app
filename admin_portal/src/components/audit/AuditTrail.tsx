'use client';

import React, { useMemo } from 'react';
import { useAdmin } from '@/context/AdminContext';

export default function AuditTrail() {
  const { auditLogs, globalSearch } = useAdmin();

  const filteredLogs = useMemo(() => {
    if (!globalSearch) return auditLogs;
    const q = globalSearch.toLowerCase().trim();
    return auditLogs.filter(
      l =>
        l.id.toLowerCase().includes(q) ||
        l.action.toLowerCase().includes(q) ||
        l.entity.toLowerCase().includes(q) ||
        l.desc.toLowerCase().includes(q) ||
        l.actor.toLowerCase().includes(q)
    );
  }, [auditLogs, globalSearch]);

  return (
    <section className="view-panel active" id="view-audit">
      <div className="audit-container">
        <div className="table-card">
          <div className="table-card-header">
            <div>
              <h3>Immutable Compliance &amp; Security Audit Trail</h3>
              <p>Every store allocation, pricing change, and voucher generation is cryptographically logged.</p>
            </div>
            <span className="badge-audit">
              <i className="fa-solid fa-lock"></i> Append-Only Immutability
            </span>
          </div>
          <table className="data-table" id="audit-table">
            <thead>
              <tr>
                <th>Log Token</th>
                <th>Timestamp</th>
                <th>Action Code</th>
                <th>Target Entity</th>
                <th>Description / Payload</th>
                <th>Actor (Role)</th>
                <th>Verification</th>
              </tr>
            </thead>
            <tbody id="audit-table-body">
              {filteredLogs.map(log => (
                <tr key={log.id}>
                  <td>
                    <span className="code-badge">{log.id}</span>
                  </td>
                  <td>{log.timestamp}</td>
                  <td>
                    <span className="status-badge-live transit">{log.action}</span>
                  </td>
                  <td>
                    <code>{log.entity}</code>
                  </td>
                  <td>{log.desc}</td>
                  <td>{log.actor}</td>
                  <td>
                    <span className="pill-chip green">
                      <i className="fa-solid fa-shield"></i> Verified
                    </span>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </section>
  );
}
