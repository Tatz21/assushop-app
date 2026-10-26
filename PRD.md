# AUPL Sales Team App — Product Requirements Document (PRD)

**Company:** ANSU UDYOG PRIVATE LIMITED (AUPL)  
**Product:** AUPL Sales Team Mobile App & Central Admin Portal  
**Tagline:** *Field Sales | Visit | Sale | Collection | Ledger | Reports — Better Tracking, Bigger Growth*  
**Document Version:** 1.0.0  
**Status:** Approved for Implementation  
**Primary Target Platform:** Android (Flutter) + Central Web Admin Panel (Flutter Web / React) + Firebase Backend  

---

## 1. Executive Summary & Vision

ANSU UDYOG PRIVATE LIMITED (AUPL) is a fast-growing manufacturing and distribution enterprise requiring end-to-end digital transformation of its field sales operations. Currently, field sales tracking, outlet visits, invoice generation, payment collections, and party ledger maintenance suffer from fragmented paper records, delayed reconciliation, and lack of geographical visit accountability.

The **AUPL Sales Team Ecosystem** consists of two core components:
1. **AUPL Sales Team Mobile App (Android):** A field-optimized, offline-first mobile application empowering sales representatives to view assigned outlets, check in via GPS verification, record SKU-level sales, log payment collections (Cash/UPI/Cheque), inspect real-time party ledgers, and export A4 invoices/statements.
2. **AUPL Central Admin Web Portal:** A desktop-first management dashboard allowing corporate leadership and regional area managers to centrally manage master catalogs (States, Districts, Markets, Outlets, Products/SKUs), dynamically assign salesmen to specific territories and stores, monitor live field visits, review consolidated aging/debtors, and inspect financial audit trails.

---

## 2. Problem Statement & Objectives

### 2.1 The Core Problems
* **Lack of Field Accountability:** Inability to verify whether a sales representative actually visited a retail outlet or logged orders remotely.
* **Manual Ledger Inaccuracies:** Field sales orders and payment collections take days to reflect in central accounting, leading to disputes over pending dues and credit limits.
* **Territory Overlap & Unauthorized Access:** Salesmen viewing or tampering with competitors' or peer territories, creating commission and distribution conflicts.
* **Spotty Field Connectivity:** Sales reps operating in semi-urban and rural markets frequently encounter zero internet access, causing halted operations or double-booked data upon reconnection.
* **Complex Store/Salesman Reassignments:** Store assignments change frequently. When a representative leaves or shifts routes, manually transferring dozens of stores across Excel sheets causes operational chaos.

### 2.2 Core Objectives
| Metric | Goal |
|---|---|
| **Visit Verification** | 100% of visits verified within 50–100m GPS geofence of the outlet. |
| **Ledger Real-time Synchronization** | Auto-calculate party balance and mini-ledger immediately upon sale/collection booking. |
| **Offline Reliability** | 100% feature availability offline for core field workflow with deterministic sync. |
| **Zero Duplicate Billing** | Enforce client + server idempotency preventing duplicate invoices and receipt numbers. |
| **Single-Click Reporting** | Instant generation of A4-printable Party Ledgers, Debtor Lists, and Salesman Performance scorecards. |

---

## 3. User Personas & Stakeholders

### 3.1 Field Salesman (Primary Mobile User)
* **Profile:** Field representative covering designated markets, visiting 15–30 outlets daily.
* **Needs:** 
  * Simple, 1-hand ergonomic UI usable under direct sunlight.
  * Instant view of "Today's Assigned Outlets" sorted by route/market.
  * Rapid GPS check-in without cumbersome loading delays.
  * Immediate visibility into outlet credit limits, previous orders, and outstanding dues.
  * Quick SKU-based order entry and instant receipt printing/sharing (WhatsApp/Bluetooth/PDF).
* **Constraints:** Must only access assigned territories/outlets. Cannot alter past ledger records or bypass GPS geofences.

### 3.2 Area / District Sales Manager (Regional Supervisor)
* **Profile:** Oversees multiple markets, districts, and sales representatives.
* **Needs:**
  * Real-time monitoring of salesman check-ins, route progress, and collection targets.
  * Reassignment of outlets to alternative reps during emergencies or leave.
  * Review of daily collection reconciliations (Cash in Hand vs UPI vs Cheques).

### 3.3 Super Admin / Finance Operations (Central Admin Portal User)
* **Profile:** Head office management at ANSU UDYOG PRIVATE LIMITED.
* **Needs:**
  * Complete Master Data Management: States, Districts, Markets, Outlets, Products/SKUs, Price Lists, and Tax rates.
  * Dynamic Salesman Assignment Matrix: Bulk allocate or switch salesman mappings.
  * Consolidated Business Intelligence: State/District-wise revenue, debtor aging reports (30/60/90+ days), and collection health.
  * Immutable Audit Log: Detailed transaction history of every invoice, collection, return, and modification.

---

## 4. Key Functional Modules

```
                    ┌────────────────────────────────────────────────────────┐
                    │            AUPL SALES ECOSYSTEM ARCHITECTURE           │
                    └────────────────────────────────────────────────────────┘
                                                 │
            ┌────────────────────────────────────┴───────────────────────────────────┐
            ▼                                                                        ▼
┌───────────────────────────────┐                                        ┌───────────────────────────────┐
│     AUPL MOBILE APP (FLUTTER) │                                        │    AUPL ADMIN WEB PORTAL      │
├───────────────────────────────┤                                        ├───────────────────────────────┤
│ 1. Home / Dashboard           │                                        │ 1. Territorial Master Hub     │
│ 2. Outlets & GPS Check-In     │                                        │ 2. Store-Salesman Assignment  │
│ 3. SKU-Based Sales Entry      │                                        │ 3. SKU / Product Price Master │
│ 4. Collections (Cash/UPI/Chq) │                                        │ 4. Live Field Visit Tracker   │
│ 5. Auto Party Ledger & A4 PDF │                                        │ 5. Consolidated Ledgers & Aging│
│ 6. Offline Storage & Auto Sync│                                        │ 6. Full Audit Trail & Security│
└───────────────────────────────┘                                        └───────────────────────────────┘
            │                                                                        │
            └────────────────────────────────────┬───────────────────────────────────┘
                                                 ▼
                               ┌───────────────────────────────────┐
                               │     FIREBASE BACKEND SERVICES     │
                               ├───────────────────────────────────┤
                               │ • Firebase Authentication         │
                               │ • Cloud Firestore (Data & Rules)  │
                               │ • Cloud Functions (Logic & Sync)  │
                               │ • Firebase Cloud Storage (PDFs)   │
                               │ • Cloud Messaging (FCM Alerts)    │
                               └───────────────────────────────────┘
```

### 4.1 Mobile Application Modules
1. **Home / Dashboard:** Today's Sales, Today's Collection broken down by Payment Mode (Cash/UPI/Cheque), Outlets Visited vs Pending, Target Achievement gauge, Outstanding Collection spotlight.
2. **Outlets Directory:** Hierarchical navigation (`State -> District -> Market -> Outlet`), strict filter by assigned outlets only, GPS Geofenced Check-In button (active within 50–100m radius), Outlet Details, Order History, and Mini Ledger.
3. **Sales Booking:** SKU master selector with real-time stock/price reference, quantity, unit, discount, GST calculations, automatic invoice numbering, and auto-posting to party ledger.
4. **Collection Booking:** Receipt generator supporting Cash, UPI (with transaction reference/QR), and Cheque (with bank and cheque number). Instant auto-deduction from party outstanding.
5. **Ledger & Outstanding:** Instant Party Mini-Ledger, separate opening balance maintenance, running debit/credit balance, and single-click A4 PDF export/sharing.
6. **Reports & Analytics:** Salesman-wise, outlet-wise, date-wise sales reports; collection reports; outstanding debtor lists; and visit verification logs.

### 4.2 Admin Web Portal Modules
1. **Salesman Allocation Engine:** Interactive UI to select a salesman and assign/reassign him to States, Districts, Markets, or individual Outlets. Batch reassignment tools.
2. **Master Catalog Control:** CRUD operations for States, Districts, Markets, Retail Outlets, and SKU/Product Master with tiered pricing and GST slabs.
3. **Real-Time Field Map & Visit Monitor:** Live feed of check-ins with GPS coordinates, timestamps, and visit duration.
4. **Consolidated Financial Reports:** Company-wide aging analysis (0–30, 31–60, 61–90, 90+ days), top-performing outlets/reps, and consolidated cash reconciliation.
5. **System Audit Logs:** Immutable logs recording every creation, update, sync, and security exception.

---

## 5. Non-Functional Requirements (NFR)

| Area | Requirement |
|---|---|
| **Performance** | App cold launch < 2.0s; local SQLite query < 50ms; GPS lock acquisition < 5s. |
| **Offline Capability** | 100% of daily transactions (Check-in, Sale, Collection, Ledger view) functional without internet. Automatic 2-way sync within 5s of network restoration. |
| **Data Integrity** | Zero data loss; deterministic client-generated UUIDs; idempotent sync endpoints preventing duplicate entries. |
| **Security & Privacy** | AES-256 encrypted local database; TLS 1.3 in-transit encryption; Role-Based Firestore Security Rules; device-bound single-session login. |
| **Compatibility** | Android 7.0 (Nougat, API 24) through Android 15 (API 35); screen adaptability for 4.7" to 6.8" smartphones. |
| **Print Standards** | Standard A4 format layout compliant with thermal portable printers and commercial office printers. |

---

## 6. Success Metrics & KPIs

* **Field Visit Adherence:** ≥ 95% of visits verified through GPS check-in within designated geofence.
* **Collection Turnaround Time:** Payment entry to ledger update reduced from 48 hours to 0 seconds (instant).
* **Sync Conflict Rate:** < 0.01% of offline transactions resulting in synchronization conflicts.
* **App Adoption Rate:** 100% daily active usage across the active sales force within 14 days of deployment.
