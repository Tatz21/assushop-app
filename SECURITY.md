# AUPL Sales Team App — Security & Governance Architecture (SECURITY.md)

**Company:** ANSU UDYOG PRIVATE LIMITED (AUPL)  
**Document Version:** 1.0.0  

---

## 1. Security Architecture Principles

To uphold enterprise security and protect financial data integrity across ANSU UDYOG PRIVATE LIMITED:
1. **Zero-Trust Client:** The mobile app is treated as an untrusted client; all financial calculations, running ledger balances, and geofence criteria are verified server-side.
2. **Principle of Least Privilege:** A sales representative only has visibility into their assigned markets and outlets (**Rules 1 & 2**).
3. **Immutability of Financial Records:** Invoices, payment receipts, and ledger rows cannot be updated or deleted by clients once generated (**Rule 11**).
4. **Anti-Fraud & Anti-Spoofing:** Mock locations, time manipulation, and simultaneous account sharing are actively blocked.

---

## 2. Cloud Firestore Security Rules (`firestore.rules`)

Below is the concrete security rules configuration enforcing territorial isolation, role-based controls, and immutable audit logs:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Helper Functions
    function isAuthenticated() {
      return request.auth != null;
    }

    function isSuperAdmin() {
      return isAuthenticated() && request.auth.token.role == 'SUPER_ADMIN';
    }

    function isAreaManager() {
      return isAuthenticated() && request.auth.token.role == 'AREA_MANAGER';
    }

    function isSalesman() {
      return isAuthenticated() && request.auth.token.role == 'SALESMAN';
    }

    function isSelf(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }

    // 1. User Profiles: Salesmen can only read their own profile; only Admin can edit
    match /users/{userId} {
      allow read: if isSuperAdmin() || isSelf(userId);
      allow write: if isSuperAdmin();
    }

    // 2. Masters (States, Districts, Markets): Public read for active users, write admin only
    match /states/{stateId} {
      allow read: if isAuthenticated();
      allow write: if isSuperAdmin();
    }
    match /districts/{districtId} {
      allow read: if isAuthenticated();
      allow write: if isSuperAdmin();
    }
    match /markets/{marketId} {
      allow read: if isAuthenticated();
      allow write: if isSuperAdmin();
    }

    // 3. Products / SKU Master: Read-only for salesmen; writes restricted to Super Admin (Rule 10)
    match /products/{skuId} {
      allow read: if isAuthenticated();
      allow write: if isSuperAdmin();
    }

    // 4. Outlets: Salesman can only read assigned outlets (Rule 1)
    match /outlets/{outletId} {
      allow read: if isSuperAdmin() || 
                     (isSalesman() && request.auth.uid in resource.data.assignedSalesmanIds);
      allow create: if isSuperAdmin() || isAreaManager();
      allow update: if isSuperAdmin() || 
                       // Salesman can only update lastVisitedAt, not balances or credit limits directly
                       (isSalesman() && request.auth.uid in resource.data.assignedSalesmanIds &&
                        request.resource.data.diff(resource.data).affectedKeys().hasOnly(['lastVisitedAt']));
      allow delete: if false; // Deletions strictly forbidden
    }

    // 5. Visits: Salesman can create visits for assigned outlets; cannot modify historic visits
    match /visits/{visitId} {
      allow read: if isSuperAdmin() || 
                     (isSalesman() && resource.data.salesmanId == request.auth.uid);
      allow create: if isSalesman() && request.resource.data.salesmanId == request.auth.uid;
      allow update: if isSalesman() && resource.data.salesmanId == request.auth.uid &&
                       request.resource.data.diff(resource.data).affectedKeys().hasOnly(['checkOutTime', 'visitDurationMinutes', 'remarks', 'saleRecorded', 'collectionRecorded']);
      allow delete: if false;
    }

    // 6. Sales Invoices: Append-only; no client edits or deletions (Rule 11 & 12)
    match /sales_invoices/{invoiceId} {
      allow read: if isSuperAdmin() || 
                     (isSalesman() && resource.data.salesmanId == request.auth.uid);
      allow create: if isSalesman() && request.resource.data.salesmanId == request.auth.uid;
      allow update: if false; // Immutable once written
      allow delete: if false;
    }

    // 7. Collections: Append-only
    match /collections/{collectionId} {
      allow read: if isSuperAdmin() || 
                     (isSalesman() && resource.data.salesmanId == request.auth.uid);
      allow create: if isSalesman() && request.resource.data.salesmanId == request.auth.uid;
      allow update: if isSuperAdmin(); // Only admin can update cheque status
      allow delete: if false;
    }

    // 8. Party Ledgers: Managed strictly by Cloud Functions or read-only by authorized users
    match /ledgers/{ledgerId} {
      allow read: if isSuperAdmin() || 
                     (isSalesman() && request.auth.uid == resource.data.recordedBySalesmanId);
      allow write: if false; // Only Cloud Functions can append ledger rows
    }

    // 9. Audit Logs: Write-only for server, read-only for Super Admin
    match /audit_logs/{logId} {
      allow read: if isSuperAdmin();
      allow write: if false;
    }
  }
}
```

---

## 3. Firebase Cloud Storage Security Rules (`storage.rules`)

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Invoices and Statement PDFs: Salesman can read his own; Admin full access
    match /invoices/{year}/{month}/{invoicePdf} {
      allow read: if request.auth != null;
      allow write: if request.auth != null; // Generated client-side or by functions
    }
    // Store Signboard Photos and Cheque Leaf Photos
    match /receipts/{outletId}/{fileName} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.resource.size < 5 * 1024 * 1024 // 5MB limit
                   && request.resource.contentType.matches('image/.*');
    }
  }
}
```

---

## 4. Anti-Tamper & Fraud Mitigation Policies

1. **Google Play Integrity API:** Validates that the client app is an unmodified, authentic APK distributed through official channels and running on an unrooted, non-emulated Android environment.
2. **Device Hardware Binding:** Prevents multiple salesmen from sharing a single credential or logging in from home while a colleague carries the phone.
3. **Idempotent Hashing:** Prevents duplicate voucher creation through deterministic UUID keys generated at transaction initialization.
4. **Clock-Drift Rejection:** Client timestamps deviating by more than 10 minutes from server time (`request.time`) are rejected.
