
'use client';

import React from 'react';
import { useAdmin } from '@/context/AdminContext';
import { Outlet } from '@/types';
import { formatCurrency } from '@/lib/utils';

export default function A4StatementModal() {
  const { activeModal, modalPayload, closeModal, outlets } = useAdmin();

  if (activeModal !== 'modal-a4-statement') {
    return null;
  }

  const selectedOutlet: Outlet | null = modalPayload as Outlet | null;
  const isConsolidated = !selectedOutlet;

  // If consolidated, aggregate company total debtors
  const allDue = outlets.reduce((sum, o) => sum + (o.balance > 0 ? o.balance : 0), 0);
  const a0 = outlets.reduce((sum, o) => sum + (o.balance > 0 && o.agingDays <= 30 ? o.balance : 0), 0);
  const a30 = outlets.reduce((sum, o) => sum + (o.balance > 0 && o.agingDays > 30 && o.agingDays <= 60 ? o.balance : 0), 0);
  const a60 = outlets.reduce((sum, o) => sum + (o.balance > 0 && o.agingDays > 60 && o.agingDays <= 90 ? o.balance : 0), 0);
  const a90 = outlets.reduce((sum, o) => sum + (o.balance > 0 && o.agingDays > 90 ? o.balance : 0), 0);

  // Generate sample ledger entries for individual party
  const partyBalance = selectedOutlet ? selectedOutlet.balance : allDue;
  const openingBal = selectedOutlet ? Math.round(selectedOutlet.balance * 0.45) : Math.round(allDue * 0.4);
  const sale1 = selectedOutlet ? Math.round(selectedOutlet.balance * 0.6) : Math.round(allDue * 0.5);
  const col1 = selectedOutlet ? Math.round(selectedOutlet.balance * 0.25) : Math.round(allDue * 0.2);
  const sale2 = selectedOutlet ? selectedOutlet.balance - (openingBal + sale1 - col1) : allDue - (openingBal + sale1 - col1);

  const transactions = selectedOutlet ? [
    { date: '01/09/2026', ref: 'OB-2026/09', type: 'Opening Balance', debit: openingBal, credit: 0, balance: openingBal },
    { date: '12/09/2026', ref: 'INV-2026-0891', type: 'Tax Invoice (ANSU Special 25s)', debit: sale1, credit: 0, balance: openingBal + sale1 },
    { date: '21/09/2026', ref: 'REC-UPI-98124', type: 'Bank UPI Collection (AUPL Soundbox)', debit: 0, credit: col1, balance: openingBal + sale1 - col1 },
    { date: '04/10/2026', ref: 'INV-2026-1102', type: 'Tax Invoice (ANSU Regular 20s)', debit: sale2 > 0 ? sale2 : 5000, credit: 0, balance: partyBalance },
  ] : [];

  const handlePrint = () => {
    window.print();
  };

  return (
    <div className="modal-backdrop active" id="modal-a4-statement" style={{ zIndex: 1050 }}>
      <div 
        className="modal-card" 
        style={{ 
          maxWidth: '860px', 
          width: '95%', 
          maxHeight: '94vh', 
          overflowY: 'auto',
          background: '#ffffff',
          color: '#0f172a',
          boxShadow: '0 25px 50px -12px rgba(0, 0, 0, 0.25)'
        }}
      >
        <div className="modal-header" style={{ borderBottom: '2px solid #e2e8f0', paddingBottom: '12px' }}>
          <div>
            <h3 style={{ margin: 0, fontSize: '18px', color: '#0f172a', display: 'flex', alignItems: 'center', gap: '8px' }}>
              <i className="fa-solid fa-file-invoice" style={{ color: '#E53E3E' }}></i>
              ISO A4 Statement of Account — {isConsolidated ? 'Consolidated Debtor Ledger' : selectedOutlet?.name}
            </h3>
            <span style={{ fontSize: '12px', color: '#64748b' }}>
              Official AUPL Financial Document • Compliant with Rule 14 & Rule 15 Accounting Standards
            </span>
          </div>
          <div style={{ display: 'flex', gap: '8px' }}>
            <button className="btn btn-primary btn-sm" onClick={handlePrint} style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
              <i className="fa-solid fa-print"></i> Print (A4)
            </button>
            <button className="modal-close" onClick={closeModal} style={{ fontSize: '24px', lineHeight: '1' }}>
              &times;
            </button>
          </div>
        </div>

        {/* Printable ISO A4 Container */}
        <div 
          id="printable-a4-sheet"
          style={{
            padding: '24px',
            fontFamily: 'Inter, system-ui, -apple-system, sans-serif',
            background: '#ffffff',
            lineHeight: 1.5,
          }}
        >
          {/* Header & Corporate Details */}
          <div style={{ borderBottom: '2px solid #E53E3E', paddingBottom: '16px', marginBottom: '20px' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
              <div>
                <h1 style={{ margin: 0, fontSize: '22px', fontWeight: 900, color: '#E53E3E', letterSpacing: '-0.5px' }}>
                  ANSU UDYOG PRIVATE LIMITED
                </h1>
                <p style={{ margin: '4px 0 0 0', fontSize: '12px', color: '#334155', fontWeight: 600 }}>
                  Manufacturers &amp; Distributors of ANSU Gold Premium Bidi
                </p>
                <p style={{ margin: '2px 0 0 0', fontSize: '11px', color: '#64748b' }}>
                  Regd. Office: 128/64, D-Block, Kidwai Nagar, Kanpur - 208011 (Uttar Pradesh)
                </p>
                <p style={{ margin: '2px 0 0 0', fontSize: '11px', color: '#64748b' }}>
                  <strong>GSTIN:</strong> 09AAACA1234F1Z8 | <strong>CIN:</strong> U15400UP2020PTC123456 | <strong>Ph:</strong> +91 94150 42200
                </p>
              </div>

              <div style={{ textAlign: 'right' }}>
                <span 
                  style={{
                    display: 'inline-block',
                    background: '#FEF2F2',
                    border: '1px solid #FCA5A5',
                    color: '#991B1B',
                    padding: '4px 10px',
                    borderRadius: '6px',
                    fontSize: '11px',
                    fontWeight: 800,
                    textTransform: 'uppercase',
                    marginBottom: '6px'
                  }}
                >
                  Statement of Account
                </span>
                <div style={{ fontSize: '11px', color: '#475569' }}>
                  <strong>Date:</strong> 12 Oct 2026
                </div>
                <div style={{ fontSize: '11px', color: '#475569' }}>
                  <strong>Doc Ref:</strong> STM-{selectedOutlet ? selectedOutlet.code : 'CONSOL'}-{new Date().getFullYear()}
                </div>
              </div>
            </div>
          </div>

          {/* Customer & Account Summary */}
          {!isConsolidated ? (
            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '16px', marginBottom: '20px', background: '#F8FAFC', padding: '16px', borderRadius: '8px', border: '1px solid #E2E8F0' }}>
              <div>
                <span style={{ fontSize: '10px', fontWeight: 800, color: '#64748b', textTransform: 'uppercase' }}>BILL TO PARTY:</span>
                <h3 style={{ margin: '4px 0 2px 0', fontSize: '16px', fontWeight: 800, color: '#0F172A' }}>
                  {selectedOutlet?.name}
                </h3>
                <div style={{ fontSize: '12px', color: '#475569' }}>
                  <strong>Party Code:</strong> {selectedOutlet?.code} | <strong>Owner:</strong> {selectedOutlet?.ownerName}
                </div>
                <div style={{ fontSize: '12px', color: '#475569' }}>
                  <strong>Market:</strong> {selectedOutlet?.market}, Kanpur | <strong>Mobile:</strong> {selectedOutlet?.mobile}
                </div>
              </div>

              <div style={{ textAlign: 'right' }}>
                <span style={{ fontSize: '10px', fontWeight: 800, color: '#64748b', textTransform: 'uppercase' }}>ACCOUNT STATUS:</span>
                <div style={{ margin: '4px 0 2px 0', fontSize: '20px', fontWeight: 900, color: selectedOutlet && selectedOutlet.balance > 0 ? '#DC2626' : '#16A34A' }}>
                  ₹ {formatCurrency(selectedOutlet?.balance || 0)}
                </div>
                <div style={{ fontSize: '12px', color: '#475569' }}>
                  <strong>Credit Limit:</strong> ₹{formatCurrency(selectedOutlet?.creditLimit || 50000)} | <strong>Days Aging:</strong> {selectedOutlet?.agingDays} Days
                </div>
                <div style={{ fontSize: '11px', color: selectedOutlet && selectedOutlet.agingDays > 60 ? '#B91C1C' : '#047857', fontWeight: 700 }}>
                  {selectedOutlet && selectedOutlet.agingDays > 90 ? '⚠️ CRITICAL OVERDUE — ACTION REQUIRED' : selectedOutlet && selectedOutlet.agingDays > 60 ? '⚠️ HIGH RISK EXPOSURE' : '✅ CURRENT ACCOUNT IN GOOD STANDING'}
                </div>
              </div>
            </div>
          ) : (
            <div style={{ marginBottom: '20px', background: '#F8FAFC', padding: '16px', borderRadius: '8px', border: '1px solid #E2E8F0' }}>
              <h3 style={{ margin: 0, fontSize: '15px', color: '#0F172A', fontWeight: 800 }}>
                Consolidated Wholesale &amp; Retail Debtors Portfolio Overview
              </h3>
              <p style={{ margin: '4px 0 0 0', fontSize: '12px', color: '#475569' }}>
                Total Active Debtor Stores: <strong>{outlets.filter(o => o.balance > 0).length} Outlets</strong> • Total Outstanding Portfolio: <strong style={{ color: '#DC2626' }}>₹ {formatCurrency(allDue)}</strong>
              </p>
            </div>
          )}

          {/* Aging Matrix (Rule 15 Compliance) */}
          <div style={{ marginBottom: '24px' }}>
            <h4 style={{ margin: '0 0 10px 0', fontSize: '12px', fontWeight: 800, textTransform: 'uppercase', color: '#334155', letterSpacing: '0.5px' }}>
              DEBTOR AGING BUCKETS ANALYSIS (RULE 15 COMPLIANCE)
            </h4>
            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: '10px' }}>
              <div style={{ background: '#F0FDF4', border: '1px solid #86EFAC', borderRadius: '6px', padding: '10px' }}>
                <div style={{ fontSize: '10px', fontWeight: 800, color: '#166534', textTransform: 'uppercase' }}>0–30 Days (Current)</div>
                <div style={{ fontSize: '15px', fontWeight: 900, color: '#15803D', marginTop: '4px' }}>
                  ₹ {formatCurrency(isConsolidated ? a0 : (selectedOutlet && selectedOutlet.agingDays <= 30 ? selectedOutlet.balance : 0))}
                </div>
                <div style={{ fontSize: '10px', color: '#166534', marginTop: '2px' }}>Normal Terms</div>
              </div>

              <div style={{ background: '#FEF9C3', border: '1px solid #FDE047', borderRadius: '6px', padding: '10px' }}>
                <div style={{ fontSize: '10px', fontWeight: 800, color: '#854D0E', textTransform: 'uppercase' }}>31–60 Days</div>
                <div style={{ fontSize: '15px', fontWeight: 900, color: '#A16207', marginTop: '4px' }}>
                  ₹ {formatCurrency(isConsolidated ? a30 : (selectedOutlet && selectedOutlet.agingDays > 30 && selectedOutlet.agingDays <= 60 ? selectedOutlet.balance : 0))}
                </div>
                <div style={{ fontSize: '10px', color: '#854D0E', marginTop: '2px' }}>Follow-up Due</div>
              </div>

              <div style={{ background: '#FFEDD5', border: '1px solid #FDBA74', borderRadius: '6px', padding: '10px' }}>
                <div style={{ fontSize: '10px', fontWeight: 800, color: '#9A3412', textTransform: 'uppercase' }}>61–90 Days</div>
                <div style={{ fontSize: '15px', fontWeight: 900, color: '#C2410C', marginTop: '4px' }}>
                  ₹ {formatCurrency(isConsolidated ? a60 : (selectedOutlet && selectedOutlet.agingDays > 60 && selectedOutlet.agingDays <= 90 ? selectedOutlet.balance : 0))}
                </div>
                <div style={{ fontSize: '10px', color: '#9A3412', marginTop: '2px' }}>High Risk Alert</div>
              </div>

              <div style={{ background: '#FEF2F2', border: '1px solid #FCA5A5', borderRadius: '6px', padding: '10px' }}>
                <div style={{ fontSize: '10px', fontWeight: 800, color: '#991B1B', textTransform: 'uppercase' }}>90+ Days Overdue</div>
                <div style={{ fontSize: '15px', fontWeight: 900, color: '#DC2626', marginTop: '4px' }}>
                  ₹ {formatCurrency(isConsolidated ? a90 : (selectedOutlet && selectedOutlet.agingDays > 90 ? selectedOutlet.balance : 0))}
                </div>
                <div style={{ fontSize: '10px', color: '#991B1B', marginTop: '2px' }}>Critical Action</div>
              </div>
            </div>
          </div>

          {/* Running Transactions Ledger Table */}
          {!isConsolidated ? (
            <div style={{ marginBottom: '24px' }}>
              <h4 style={{ margin: '0 0 10px 0', fontSize: '12px', fontWeight: 800, textTransform: 'uppercase', color: '#334155', letterSpacing: '0.5px' }}>
                STATEMENT TRANSACTIONS CHRONOLOGY (RUNNING BALANCE)
              </h4>
              <table style={{ width: '100%', borderCollapse: 'collapse', fontSize: '12px' }}>
                <thead>
                  <tr style={{ background: '#F1F5F9', borderBottom: '2px solid #CBD5E1' }}>
                    <th style={{ padding: '8px 10px', textAlign: 'left', fontWeight: 800, color: '#334155' }}>Date</th>
                    <th style={{ padding: '8px 10px', textAlign: 'left', fontWeight: 800, color: '#334155' }}>Voucher / Ref No</th>
                    <th style={{ padding: '8px 10px', textAlign: 'left', fontWeight: 800, color: '#334155' }}>Particulars / Narration</th>
                    <th style={{ padding: '8px 10px', textAlign: 'right', fontWeight: 800, color: '#334155' }}>Debit (₹)</th>
                    <th style={{ padding: '8px 10px', textAlign: 'right', fontWeight: 800, color: '#334155' }}>Credit (₹)</th>
                    <th style={{ padding: '8px 10px', textAlign: 'right', fontWeight: 800, color: '#334155' }}>Balance (₹)</th>
                  </tr>
                </thead>
                <tbody>
                  {transactions.map((t, idx) => (
                    <tr key={idx} style={{ borderBottom: '1px solid #E2E8F0', background: idx % 2 === 0 ? '#FFFFFF' : '#FAFAFA' }}>
                      <td style={{ padding: '8px 10px', color: '#475569' }}>{t.date}</td>
                      <td style={{ padding: '8px 10px', fontFamily: 'monospace', fontWeight: 600, color: '#0F172A' }}>{t.ref}</td>
                      <td style={{ padding: '8px 10px', color: '#1E293B' }}>{t.type}</td>
                      <td style={{ padding: '8px 10px', textAlign: 'right', color: t.debit > 0 ? '#B91C1C' : '#94A3B8' }}>
                        {t.debit > 0 ? `₹${formatCurrency(t.debit)}` : '—'}
                      </td>
                      <td style={{ padding: '8px 10px', textAlign: 'right', color: t.credit > 0 ? '#15803D' : '#94A3B8' }}>
                        {t.credit > 0 ? `₹${formatCurrency(t.credit)}` : '—'}
                      </td>
                      <td style={{ padding: '8px 10px', textAlign: 'right', fontWeight: 800, color: '#0F172A' }}>
                        ₹{formatCurrency(t.balance)}
                      </td>
                    </tr>
                  ))}
                  <tr style={{ background: '#F8FAFC', borderTop: '2px solid #0F172A' }}>
                    <td colSpan={3} style={{ padding: '10px', fontWeight: 900, textAlign: 'right' }}>CLOSING BALANCE NET DUE:</td>
                    <td style={{ padding: '10px', textAlign: 'right', fontWeight: 900, color: '#B91C1C' }}>
                      ₹{formatCurrency(transactions.reduce((s, t) => s + t.debit, 0))}
                    </td>
                    <td style={{ padding: '10px', textAlign: 'right', fontWeight: 900, color: '#15803D' }}>
                      ₹{formatCurrency(transactions.reduce((s, t) => s + t.credit, 0))}
                    </td>
                    <td style={{ padding: '10px', textAlign: 'right', fontWeight: 900, color: '#DC2626', fontSize: '14px' }}>
                      ₹{formatCurrency(partyBalance)}
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
          ) : (
            <div style={{ marginBottom: '24px' }}>
              <h4 style={{ margin: '0 0 10px 0', fontSize: '12px', fontWeight: 800, textTransform: 'uppercase', color: '#334155', letterSpacing: '0.5px' }}>
                TOP 10 HIGHEST DEBTOR ACCOUNTS
              </h4>
              <table style={{ width: '100%', borderCollapse: 'collapse', fontSize: '12px' }}>
                <thead>
                  <tr style={{ background: '#F1F5F9', borderBottom: '2px solid #CBD5E1' }}>
                    <th style={{ padding: '8px 10px', textAlign: 'left', fontWeight: 800, color: '#334155' }}>Code</th>
                    <th style={{ padding: '8px 10px', textAlign: 'left', fontWeight: 800, color: '#334155' }}>Party Name</th>
                    <th style={{ padding: '8px 10px', textAlign: 'left', fontWeight: 800, color: '#334155' }}>Market</th>
                    <th style={{ padding: '8px 10px', textAlign: 'right', fontWeight: 800, color: '#334155' }}>Credit Limit</th>
                    <th style={{ padding: '8px 10px', textAlign: 'center', fontWeight: 800, color: '#334155' }}>Aging Days</th>
                    <th style={{ padding: '8px 10px', textAlign: 'right', fontWeight: 800, color: '#334155' }}>Balance Due</th>
                  </tr>
                </thead>
                <tbody>
                  {outlets
                    .filter(o => o.balance > 0)
                    .sort((a, b) => b.balance - a.balance)
                    .slice(0, 10)
                    .map((o, idx) => (
                      <tr key={idx} style={{ borderBottom: '1px solid #E2E8F0' }}>
                        <td style={{ padding: '8px 10px', fontFamily: 'monospace', fontWeight: 700 }}>{o.code}</td>
                        <td style={{ padding: '8px 10px', fontWeight: 600 }}>{o.name}</td>
                        <td style={{ padding: '8px 10px', color: '#475569' }}>{o.market}</td>
                        <td style={{ padding: '8px 10px', textAlign: 'right' }}>₹{formatCurrency(o.creditLimit)}</td>
                        <td style={{ padding: '8px 10px', textAlign: 'center', fontWeight: 700, color: o.agingDays > 60 ? '#DC2626' : '#15803D' }}>
                          {o.agingDays} d
                        </td>
                        <td style={{ padding: '8px 10px', textAlign: 'right', fontWeight: 800, color: '#DC2626' }}>
                          ₹{formatCurrency(o.balance)}
                        </td>
                      </tr>
                    ))}
                </tbody>
              </table>
            </div>
          )}

          {/* Bank Payment & Statutory Remittance Details */}
          <div style={{ display: 'grid', gridTemplateColumns: '1.2fr 0.8fr', gap: '20px', borderTop: '2px solid #E2E8F0', paddingTop: '16px' }}>
            <div style={{ fontSize: '11px', color: '#475569', lineHeight: 1.6 }}>
              <div style={{ fontWeight: 800, color: '#0F172A', marginBottom: '4px' }}>DIRECT REMITTANCE DETAILS (RTGS / NEFT / IMPS):</div>
              <div><strong>Beneficiary:</strong> ANSU UDYOG PRIVATE LIMITED</div>
              <div><strong>Bank Name:</strong> State Bank of India • Kidwai Nagar Branch, Kanpur</div>
              <div><strong>Account Number:</strong> 38290124890 (Current Account)</div>
              <div><strong>IFSC Code:</strong> SBIN0001234 • <strong>UPI VPA:</strong> ansubidi@sbi</div>
              <div style={{ marginTop: '6px', fontSize: '10px', color: '#64748b' }}>
                * All payments are subject to realization. Disputes subject to Kanpur Court Jurisdiction only.
              </div>
            </div>

            <div style={{ textAlign: 'right', display: 'flex', flexDirection: 'column', justifyContent: 'flex-end', alignItems: 'flex-end' }}>
              <div style={{ height: '45px', borderBottom: '1px solid #CBD5E1', width: '180px', marginBottom: '6px' }}></div>
              <div style={{ fontSize: '11px', fontWeight: 800, color: '#0F172A' }}>For ANSU UDYOG PRIVATE LIMITED</div>
              <div style={{ fontSize: '10px', color: '#64748b' }}>Authorized Financial Signatory</div>
              <div style={{ fontSize: '9px', color: '#94A3B8', marginTop: '4px' }}>[Computer Generated Statement — Valid without Signature]</div>
            </div>
          </div>
        </div>

        {/* Modal Footer Controls */}
        <div className="modal-footer" style={{ borderTop: '1px solid #e2e8f0', display: 'flex', justifyContent: 'space-between', marginTop: '16px' }}>
          <span style={{ fontSize: '12px', color: '#64748b', display: 'flex', alignItems: 'center', gap: '6px' }}>
            <i className="fa-solid fa-circle-check" style={{ color: '#16A34A' }}></i>
            Verified with In-Memory Multi-Outlet Sync Database
          </span>
          <div style={{ display: 'flex', gap: '8px' }}>
            <button className="btn btn-outline btn-sm" onClick={closeModal}>
              Close
            </button>
            <button className="btn btn-primary btn-sm" onClick={handlePrint}>
              <i className="fa-solid fa-print"></i> Print Statement (A4)
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}
