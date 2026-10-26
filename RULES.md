# AUPL Sales Team App — Critical Business Rules Specification (RULES.md)

**Company:** ANSU UDYOG PRIVATE LIMITED (AUPL)  
**Governance Standard:** 18 Critical Development Invariants  
**Document Version:** 1.0.0  

---

## 1. Overview of the 18 Critical Business Rules

These 18 rules represent strict non-negotiable operational and financial invariants defined by ANSU UDYOG PRIVATE LIMITED leadership. Every rule must be enforced at both the **Mobile Client Interface** and the **Cloud Backend Security & Database Tier**.

```
┌────────────────────────────────────────────────────────────────────────┐
│                   AUPL 18 CRITICAL BUSINESS RULES MATRIX               │
├────────────────────────────────┬───────────────────────────────────────┤
│ TERRITORY & ACCESS GOVERNANCE  │ FINANCIAL & LEDGER INTEGRITY          │
│ • Rule 1: Assigned Access Only │ • Rule 7: Auto Party Ledger Update    │
│ • Rule 2: Employee Data Guard  │ • Rule 8: Auto Outstanding Calc       │
│ • Rule 13: Management Console  │ • Rule 9: Opening Balance Isolation   │
│ • Rule 16: Central AUPL Masters│ • Rule 11: Immutable Audit Trail      │
├────────────────────────────────┼───────────────────────────────────────┤
│ FIELD VISIT & GEOLOCATION      │ OFFLINE & TRANSACTION RELIABILITY     │
│ • Rule 3: GPS Verification     │ • Rule 5: Sale-to-Outlet Linking      │
│ • Rule 4: Anti-Remote Check-In │ • Rule 6: Collection-to-Outlet Linking│
├────────────────────────────────┤ • Rule 12: Duplicate Prevention       │
│ REPORTING & COMMERCIAL OPS     │ • Rule 17: Offline Entry Support      │
│ • Rule 10: Central SKU Master  │ • Rule 18: Zero Duplicate Sync        │
│ • Rule 14: A4 Printable Ledger │                                       │
│ • Rule 15: 1-Click Debtor List │                                       │
└────────────────────────────────┴───────────────────────────────────────┘
```

---

## 2. In-Depth Technical Specification of Rules

### Rule 1: Salesman Can Only Access Assigned Areas/Outlets
* **Business Purpose:** Prevent unauthorized cross-territory interference, customer poaching, or route confusion.
* **Technical Enforcement:**
  * **Client:** The Outlets directory filters queries strictly by the authenticated salesman's assigned market and outlet IDs retrieved at login.
  * **Firestore Rules:** `allow read: if isSuperAdmin() || (isSalesman() && request.auth.uid in resource.data.assignedSalesmanIds);`
* **Breach Result:** Attempting to query an unassigned outlet returns an empty list or `PERMISSION_DENIED`.

---

### Rule 2: Cannot Access Another Employee's Data
* **Business Purpose:** Protect privacy, commission transparency, and competitive morale among field staff.
* **Technical Enforcement:**
  * **Firestore Rules:** Access to `/users/{userId}`, `/visits/{visitId}`, and performance target records is restricted to `request.auth.uid == userId` or `SUPER_ADMIN`.
* **Breach Result:** HTTP 403 Forbidden.

---

### Rule 3: Outlet Visit Requires GPS Verification
* **Business Purpose:** Eliminate "proxy visits" where sales representatives mark attendance without physically visiting retail stores.
* **Technical Enforcement:**
  * App queries Android GPS provider with high accuracy.
  * Captures latitude, longitude, and accuracy radius ($< 25\text{m}$).
  * Anti-mock location filter rejects spoofed coordinates.
* **Breach Result:** Check-in denied if GPS is disabled or inaccurate.

---

### Rule 4: Visited Cannot Be Marked from Outside the Outlet
* **Business Purpose:** Enforce that visits are logged within the physical boundary of the store.
* **Technical Enforcement:**
  * Calculates geodesic distance to the store's registered coordinates using the Haversine formula.
  * Check-In is strictly locked if distance $> 100\text{ meters}$ (or outlet's configured `geofenceRadiusMeters`).
* **Breach Result:** Action button remains locked; toast message reads: *"You are 240m away. Must be within 100m to check in."*

---

### Rule 5: Every Sale Linked to an Outlet
* **Business Purpose:** Prevent unassigned or loose cash sales; ensure strict product batch traceability.
* **Technical Enforcement:**
  * Order creation requires an active, verified `visitId` and an immutable `outletId`.
  * Invoice document cannot be saved without foreign key references to `outlets` and `users`.
* **Breach Result:** Schema validation error if `outletId` is null or empty.

---

### Rule 6: Every Collection Linked to an Outlet
* **Business Purpose:** Ensure payment receipts directly reduce the debt of the paying retail partner.
* **Technical Enforcement:**
  * Payment collection screen is initialized with the current store's context.
  * Receipt documents require mandatory `outletId` and `receiptNumber`.
* **Breach Result:** Collection creation fails validation if not tied to an active outlet profile.

---

### Rule 7: All Transactions Update the Party Ledger Automatically
* **Business Purpose:** Eliminate manual end-of-month bookkeeping and disputes over missing payment credits.
* **Technical Enforcement:**
  * Committing an invoice or collection immediately generates an atomic debit or credit entry in `ledgers` subcollection/collection.
  * Executed within an atomic transaction both in local SQLite and in Cloud Firestore.
* **Breach Result:** Transaction is rolled back if the corresponding ledger entry fails to write.

---

### Rule 8: Outstanding Is Auto-Calculated
* **Business Purpose:** Always present the exact current debt to salesmen and store proprietors in real time.
* **Technical Enforcement:**
  * Formula: $\text{Current Outstanding} = \text{Opening Balance} + \sum(\text{Debits}) - \sum(\text{Credits})$.
  * Recalculated atomically upon every invoice and collection transaction.
* **Breach Result:** Manual manual override of `currentOutstanding` is rejected by security rules.

---

### Rule 9: Opening Balance Maintained Separately
* **Business Purpose:** Maintain historical accounting baselines when onboarding legacy retail accounts into AUPL.
* **Technical Enforcement:**
  * `openingBalance` field in `outlets` is immutable for field sales personnel.
  * Only Super Admin can modify opening balance during onboarding.
* **Breach Result:** Any update modifying `openingBalance` by non-admin users is rejected.

---

### Rule 10: SKU/Product Master Managed Centrally
* **Business Purpose:** Ensure consistent pricing, GST tax compliance, and official pack sizes across all distribution territories.
* **Technical Enforcement:**
  * Write access to `/products/{skuId}` restricted strictly to `SUPER_ADMIN`.
  * Mobile client syncs products in read-only mode.
* **Breach Result:** Field users cannot add custom SKUs, modify base rates, or adjust GST rates.

---

### Rule 11: Financial Transactions Need Audit Trail
* **Business Purpose:** Prevent financial embezzlement, unrecorded discounts, or tampered invoices.
* **Technical Enforcement:**
  * Every mutation to financial collections triggers an append-only entry into `audit_logs` storing user ID, timestamp, before-state, and after-state.
  * Firestore rules forbid deletion of invoice, collection, or audit records (`allow delete: if false;`).
* **Breach Result:** Any attempt to delete financial documents is blocked at database engine level.

---

### Rule 12: Prevent Duplicate Invoices/Collections
* **Business Purpose:** Prevent accidental double-tapping or multiple billing of the same order.
* **Technical Enforcement:**
  * Client generates unique UUID v4 idempotency tokens prior to network dispatch.
  * Server checks if the token already exists before processing transactions.
  * Local UI buttons disable immediately upon tap with loading spinners.
* **Breach Result:** Subsequent duplicate requests return the existing document without creating new entries.

---

### Rule 13: Management Can Access Consolidated Data
* **Business Purpose:** Provide executive leadership with company-wide visibility across all states, districts, and field representatives.
* **Technical Enforcement:**
  * Admin Portal uses Super Admin credentials bypassing territorial filters.
  * Aggregation Cloud Functions compile company-level debtor aging sheets and target achievement scorecards.
* **Breach Result:** Non-admin users attempting to query global analytics receive `PERMISSION_DENIED`.

---

### Rule 14: Party Ledger Must Be Printable in A4 Format
* **Business Purpose:** Enable professional physical statement handovers during field collections or formal audit reconciliations.
* **Technical Enforcement:**
  * Native Flutter `pdf` template formats statements to standard ISO A4 dimensions ($210\text{ mm} \times 297\text{ mm}$).
  * Features AUPL corporate header, tax identifiers, running balance table, and authorized signatory blocks.
* **Breach Result:** Layout is locked to standardized A4 dimensions preventing cut-offs or margin errors.

---

### Rule 15: Debtor List in One Click
* **Business Purpose:** Provide instantaneous visibility into overdue accounts without running slow database reports.
* **Technical Enforcement:**
  * Composite index on `outlets` (`assignedSalesmanIds` + `currentOutstanding` DESC).
  * Single-click query returns all debtors sorted by exposure with color-coded aging tags (`0-30d`, `31-60d`, `60+d`).
* **Breach Result:** Instant response time ($< 200\text{ms}$).

---

### Rule 16: Market/District/State/Outlet Master from AUPL
* **Business Purpose:** Canonical corporate structure originating strictly from AUPL headquarters.
* **Technical Enforcement:**
  * Masters are pre-populated and managed via the Admin Console.
  * Field salesmen cannot create phantom markets or unverified outlets without supervisor approval.
* **Breach Result:** All dropdowns and route selectors are populated strictly from corporate master documents.

---

### Rule 17: Offline Transaction Entry for Field Use
* **Business Purpose:** Guarantee continuous field operations regardless of mobile network connectivity.
* **Technical Enforcement:**
  * 100% of core field workflows (Check-in, Sale, Collection, Mini-Ledger) operate against local SQLite storage.
  * Transactions are stored in the local outbox with `PENDING` status.
* **Breach Result:** The app never blocks a transaction due to lack of network connection.

---

### Rule 18: No Duplicate Data After Sync
* **Business Purpose:** Ensure perfect data consistency when syncing backlogged offline transactions to the cloud.
* **Technical Enforcement:**
  * Outbox sync engine transmits deterministic client UUIDs.
  * Server uses these UUIDs as Firestore document keys (`.doc(idempotencyKey).set(...)`).
  * Replayed network transmissions are safely de-duplicated.
* **Breach Result:** Repeated sync pulses never result in duplicate invoices or inflated ledger balances.
