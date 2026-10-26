# AUPL Sales Team App — Cloud Functions & API Specifications (API.md)

**Company:** ANSU UDYOG PRIVATE LIMITED (AUPL)  
**Backend Runtime:** Firebase Cloud Functions v2 (Node.js 20 / TypeScript)  
**Document Version:** 1.0.0  

---

## 1. Cloud Function Architecture & API Standards

The AUPL backend exposes a combination of **Firebase Callable Functions** (for authenticated mobile & admin RPCs), **Firestore Database Triggers** (for automated ledger consistency and audit logging), and **Cloud Storage Triggers** (for PDF invoice archival).

### Standard Response Envelope
```json
{
  "success": true,
  "data": { ... },
  "message": "Operation completed successfully.",
  "timestamp": "2026-10-12T11:35:00Z"
}
```

### Standard Error Envelope
```json
{
  "success": false,
  "error": {
    "code": "GEOFENCE_VIOLATION",
    "message": "User location is 240m away from the outlet. Must be within 100m to check in.",
    "details": {
      "allowedRadiusMeters": 100,
      "detectedDistanceMeters": 240.2
    }
  },
  "timestamp": "2026-10-12T11:35:00Z"
}
```

---

## 2. Admin Portal APIs

### 2.1 `assignSalesmanToStores`
Enables corporate management to dynamically select a salesman and assign or reassign retail outlets and markets.

* **Type:** Callable Function (`https.onCall`)
* **Auth Requirement:** Role must be `SUPER_ADMIN` or `AREA_MANAGER`.
* **Request Payload:**
```json
{
  "salesmanId": "uid_rajesh_004",
  "action": "ASSIGN_OUTLETS", // "ASSIGN_OUTLETS" | "REPLACE_ALL" | "UNASSIGN" | "ASSIGN_MARKET"
  "outletIds": ["out_1042", "out_1043", "out_1049"],
  "marketIds": ["mkt_civil_lines"],
  "effectiveDate": "2026-10-12",
  "reason": "Route expansion for Q3"
}
```
* **Response Payload (Success):**
```json
{
  "success": true,
  "data": {
    "salesmanId": "uid_rajesh_004",
    "salesmanName": "Rajesh Kumar",
    "totalAssignedOutlets": 27,
    "updatedOutletsCount": 3,
    "auditLogId": "audit_assign_91823"
  },
  "message": "Stores successfully assigned to salesman."
}
```
* **Business Logic & Side Effects:**
  1. Validates that `salesmanId` exists and is active.
  2. Batches writes to `outlets/{outletId}`, updating `assignedSalesmanIds` array (`arrayUnion` or `arrayRemove`).
  3. Updates `users/{salesmanId}` document with the new `assignedTerritory.assignedOutletIds`.
  4. Emits a background FCM notification to the salesman's mobile device triggering a background sync: `"New outlets have been added to your route."`
  5. Records an immutable entry in `audit_logs`.

---

### 2.2 `manageMasterCatalog`
Handles CRUD operations for territorial masters (State, District, Market) and Product/SKU definitions.

* **Type:** Callable Function (`https.onCall`)
* **Auth Requirement:** `SUPER_ADMIN` only.
* **Request Payload (Example: Add / Update Product):**
```json
{
  "entity": "PRODUCT", // "STATE" | "DISTRICT" | "MARKET" | "OUTLET" | "PRODUCT"
  "action": "UPSERT",
  "data": {
    "skuCode": "SKU-AUPL-02",
    "productName": "Ansu Clean Floor Wash 1000ml",
    "category": "Household Cleaning",
    "packSize": "1000ml Bottle (Carton of 12)",
    "mrp": 210.0,
    "baseRate": 150.0,
    "gstPercentage": 18.0,
    "hsnCode": "3402",
    "isActive": true
  }
}
```

---

## 3. Mobile Field Operations APIs

### 3.1 `verifyAndCheckIn`
Validates the salesman's GPS coordinates against the store location before granting access to visit features.

* **Type:** Callable Function (`https.onCall`)
* **Auth Requirement:** Authenticated Salesman assigned to the target store.
* **Request Payload:**
```json
{
  "outletId": "out_1042",
  "deviceLocation": {
    "latitude": 26.46745,
    "longitude": 80.35029,
    "accuracyMeters": 14.2
  },
  "isMockLocation": false,
  "clientTimestamp": "2026-10-12T11:20:15Z"
}
```
* **Server Verification Rules:**
  1. Rejects if `isMockLocation === true` (Security error).
  2. Rejects if `accuracyMeters > 35` (Prompting user to acquire clear GPS fix).
  3. Queries `outlets/{outletId}` coordinates.
  4. Runs Haversine distance formula.
  5. Rejects if `distance > outlets.geofenceRadiusMeters` (100m).
  6. Creates a new `visits` document with `isGpsVerified: true`.
* **Response Payload (Success):**
```json
{
  "success": true,
  "data": {
    "visitId": "9b1deb4d-3b7d-4bad-9bdd-2b0d7b3dcb6d",
    "outletId": "out_1042",
    "isGpsVerified": true,
    "calculatedDistanceMeters": 4.1,
    "checkInTime": "2026-10-12T11:20:16Z",
    "activeSessionToken": "sess_tok_991823"
  },
  "message": "GPS Check-In successfully verified."
}
```

---

### 3.2 `processSaleInvoice` (Atomic Transaction)
Submits a confirmed SKU sales order, decrements credit limit, updates running outstanding, and posts to the party ledger.

* **Type:** Firestore Transaction Trigger / Callable Function
* **Request Payload:**
```json
{
  "invoiceId": "f47ac10b-58cc-4372-a567-0e02b2c3d479", // Client UUID v4 (Idempotency Key)
  "visitId": "9b1deb4d-3b7d-4bad-9bdd-2b0d7b3dcb6d",
  "outletId": "out_1042",
  "items": [
    {
      "skuId": "sku_aupl_500ml",
      "quantity": 10,
      "baseRate": 85.0,
      "discountPercent": 5.0,
      "gstPercentage": 18.0
    }
  ],
  "invoiceDate": "2026-10-12"
}
```
* **Transactional Execution Steps (Cloud Firestore Atomic Batch):**
  1. Check if `sales_invoices/{invoiceId}` already exists. If yes, return existing document (Idempotent replay).
  2. Compute total line amounts, discount, and tax server-side to guarantee pricing integrity.
  3. Fetch current `outlets/{outletId}.currentOutstanding`.
  4. Create `sales_invoices/{invoiceId}` record.
  5. Compute new outstanding balance: $\text{newOutstanding} = \text{currentOutstanding} + \text{invoiceTotal}$.
  6. Create `ledgers/{ledgerId}` entry with `transactionType: "SALE_INVOICE"`, `debitAmount: invoiceTotal`, `creditAmount: 0.0`, `runningBalance: newOutstanding`.
  7. Update `outlets/{outletId}`: `currentOutstanding = newOutstanding`, `lastVisitedAt = now`.
  8. Update `visits/{visitId}`: `saleRecorded = true`.

---

### 3.3 `recordPaymentCollection` (Atomic Transaction)
Registers a payment collection (Cash, UPI, or Cheque), reduces party outstanding, and posts credit entry.

* **Type:** Firestore Transaction Trigger / Callable Function
* **Request Payload:**
```json
{
  "collectionId": "c8a42b10-67c2-4011-8be3-5813f8c05e32", // Client UUID v4
  "visitId": "9b1deb4d-3b7d-4bad-9bdd-2b0d7b3dcb6d",
  "outletId": "out_1042",
  "amount": 5000.0,
  "paymentMode": "UPI",
  "upiDetails": {
    "utrReferenceNumber": "628519402851"
  },
  "chequeDetails": null,
  "collectionDate": "2026-10-12"
}
```
* **Transactional Execution Steps:**
  1. Idempotency check on `collections/{collectionId}`.
  2. Fetch `outlets/{outletId}.currentOutstanding`.
  3. Calculate: $\text{newOutstanding} = \text{currentOutstanding} - \text{amount}$.
  4. Insert `collections/{collectionId}` record.
  5. Insert `ledgers/{ledgerId}` entry with `transactionType: "COLLECTION_UPI"`, `debitAmount: 0.0`, `creditAmount: amount`, `runningBalance: newOutstanding`.
  6. Update `outlets/{outletId}`: `currentOutstanding = newOutstanding`.
  7. Update `visits/{visitId}`: `collectionRecorded = true`.

---

### 3.4 `syncBatchOutbox` (Offline Sync API)
Allows the mobile client to upload multiple queued offline operations in one atomic HTTP round-trip upon regaining network connectivity.

* **Type:** Callable Function (`https.onCall`)
* **Request Payload:**
```json
{
  "batchId": "sync_batch_441",
  "operations": [
    {
      "outboxId": "uuid-1",
      "type": "CHECK_IN",
      "payload": { ... }
    },
    {
      "outboxId": "uuid-2",
      "type": "SALE_INVOICE",
      "payload": { ... }
    },
    {
      "outboxId": "uuid-3",
      "type": "COLLECTION",
      "payload": { ... }
    }
  ]
}
```
* **Response Payload:** Returns array of operations with status (`COMMITTED` or `DUPLICATE_IGNORED` or `REJECTED_WITH_REASON`).
