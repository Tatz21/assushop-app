# AUPL Sales Team App — QA & Testing Strategy (TESTING.md)

**Company:** ANSU UDYOG PRIVATE LIMITED (AUPL)  
**Testing Frameworks:** Flutter Test, Mockito, Firebase Emulator Suite, Patrol / Integration Test  
**Document Version:** 1.0.0  

---

## 1. Testing Pyramid & QA Philosophy

Given the financial and field-operational nature of the AUPL Sales System, testing is structured to ensure absolute correctness of **Ledger Calculations**, **GPS Geofence Rules**, **Offline Synchronization**, and **Store Assignment Matrices**.

```
                ▲
               / \
              /   \
             / E2E \       Patrol / Integration Test (Real Android Device)
            /-------\
           / Service \     Firebase Emulator Suite (Cloud Functions & Firestore)
          /-----------\
         /  Widget UI  \   Flutter Widget Tests (State & Component Rendering)
        /---------------\
       /    Unit Tests   \  Ledger Math, Haversine Geodesic, GST Calculations
      /───────────────────\
```

---

## 2. Unit Testing Specifications

### 2.1 Ledger Calculation Engine Unit Tests
* **Test Suite:** `test/unit/ledger_math_test.dart`
* **Test Cases:**
  1. *Opening Balance Preservation:* Verify that adding an invoice does not modify the baseline `opening_balance` field.
  2. *Single Sale Posting:* Given opening balance ₹10,000, post invoice of ₹5,000 $\implies$ New Outstanding = ₹15,000.
  3. *Single Collection Posting:* Given outstanding ₹15,000, post cash receipt of ₹7,000 $\implies$ New Outstanding = ₹8,000.
  4. *Multiple Concurrent Transactions:* Verify running balances across sequence of 5 mixed sales and collections.
  5. *Zero Negative Outstanding Exception:* Handle store credit/overpayments gracefully without arithmetic underflow.

### 2.2 Geofence Haversine Verification Unit Tests
* **Test Suite:** `test/unit/geofence_haversine_test.dart`
* **Test Cases:**
  1. *Store Proximity Exact Match:* $\text{Distance}(P_{\text{store}}, P_{\text{user}}) < 10\text{ m} \implies \text{Result} = \text{Within Geofence}$.
  2. *Store Proximity Boundary:* Distance at exactly 99.5m $\implies$ Allowed.
  3. *Store Proximity Breach:* Distance at 101.2m $\implies$ Denied with `GEOFENCE_OUT_OF_BOUNDS`.
  4. *Anti-Mock GPS Filter:* Position with `isMocked == true` must fail immediately regardless of coordinate distance.

### 2.3 Tax & Invoice Computation Unit Tests
* **Test Suite:** `test/unit/tax_invoice_test.dart`
* **Test Cases:**
  1. *Intra-State GST (UP to UP):* Split 18% GST into 9% CGST and 9% SGST.
  2. *Inter-State IGST:* Apply full 18% IGST.
  3. *Dealer Discount Application:* Verify discount is deducted prior to GST calculation.

---

## 3. Integration & Sync Engine Tests

### 3.1 Offline Outbox & Idempotency Integration Test
* **Objective:** Ensure transactions made offline sync reliably without data duplication when connectivity resumes.
* **Test Steps:**
  1. Launch app with network mock disconnected (`ConnectivityResult.none`).
  2. Create 2 sales orders and 1 UPI collection receipt.
  3. Inspect local SQLite `sync_outbox` table: verify 3 rows with status `PENDING`.
  4. Verify local outlet balance reflects optimistic updates.
  5. Restore network mock (`ConnectivityResult.mobile`).
  6. Trigger sync loop; intercept Cloud Function requests.
  7. Replay the same sync request twice to simulate network packet drop.
  8. Assert server returns `200 OK` for duplicate UUIDs and exactly 3 documents exist in Firestore.

---

## 4. End-to-End (E2E) Test Scenarios

| Test Case ID | Test Title | Execution Flow | Expected Outcome |
|---|---|---|---|
| **E2E-01** | Full Salesman Daily Visit Flow | Login $\to$ View Assigned Outlets $\to$ Reach Store $\to$ Check-in (<100m) $\to$ Add SKU Order $\to$ Add Cash Collection $\to$ Check-out. | Visit logged, invoice generated, collection receipt printed, ledger updated atomically. |
| **E2E-02** | Geofence Rejection at Distance | Salesman attempts Check-In while 350 meters away from target store. | Check-In button locked; error modal displays *"You are 350m away from store"*. |
| **E2E-03** | Admin Store Reassignment | Admin assigns Store A to Salesman 1 $\to$ Salesman 1 opens app $\to$ Admin transfers Store A to Salesman 2. | Store A immediately disappears from Salesman 1 and appears in Salesman 2's route upon silent FCM sync. |
| **E2E-04** | A4 Statement Print Spooling | Select Store $\to$ Open Party Ledger $\to$ Click "Print A4 PDF". | Renders standard ISO A4 document matching AUPL design guidelines with accurate debit/credit totals. |
| **E2E-05** | Unauthorized Data Access | Salesman 1 attempts to query Outlets of Salesman 2 via direct Firestore query. | Request rejected with `PERMISSION_DENIED` by Firestore Security Rules. |
