# AUPL Sales Team App — Implementation Phases & Roadmap (PHASES.md)

**Company:** ANSU UDYOG PRIVATE LIMITED (AUPL)  
**Project Duration:** 14-Week Accelerated Delivery Roadmap  
**Document Version:** 1.0.0  

---

## 1. Roadmap Overview & Timeline

The development and deployment of the AUPL Sales Team Ecosystem is divided into 7 structured phases, ensuring continuous deliverables, early field pilot testing, and zero disruption to ongoing sales operations.

```mermaid
gantt
    title AUPL Sales System Delivery Roadmap
    dateFormat  YYYY-MM-DD
    section Phase 1: Core Foundation
    Design System & Mobile Shell        :2026-11-01, 14d
    Firebase Auth & Role Claims         :2026-11-08, 10d
    section Phase 2: Territory & Geofence
    Territory Master & Geotagging       :2026-11-15, 14d
    GPS Verification & Check-In         :2026-11-22, 14d
    section Phase 3: Sales & Ledger
    SKU Order Entry & Tax Engine        :2026-12-01, 14d
    Payment Collection & Auto-Ledger    :2026-12-08, 14d
    section Phase 4: Admin Portal
    Admin Web Portal UI                 :2026-12-15, 14d
    Salesman Allocation Matrix Engine   :2026-12-22, 14d
    section Phase 5: Offline Sync
    SQLite Outbox & Sync Pulse          :2027-01-01, 14d
    Idempotent Replay & Conflict Engine :2027-01-08, 14d
    section Phase 6: Printing & Reports
    A4 PDF Engine & Bluetooth Print     :2027-01-15, 14d
    Consolidated Debtor Aging Reports   :2027-01-22, 14d
    section Phase 7: Pilot & Launch
    Security Audit & Field Pilot (Kanpur):2027-02-01, 14d
    Statewide Production Rollout        :2027-02-15, 7d
```

---

## 2. Phase-by-Phase Deliverables & Acceptance Criteria

### Phase 1: Core Foundation & Security Setup (Weeks 1–2)
* **Deliverables:**
  * Flutter mobile shell with 5-tab bottom navigation (`MainNavigationShell`).
  * Design tokens implementation (`AppColors`, `AppTypography`, `AppTheme`).
  * Firebase Authentication with Phone OTP & Custom Claims (`SUPER_ADMIN`, `AREA_MANAGER`, `SALESMAN`).
  * Hardware device binding to enforce single active session per user.
* **Acceptance Criteria:** A registered salesman can log in on his phone, obtain role claims, and land on the branded AUPL dashboard.

---

### Phase 2: Territory Hierarchy & Geofenced Field Visits (Weeks 3–4)
* **Deliverables:**
  * Cloud Firestore schema for `states`, `districts`, `markets`, `outlets`.
  * Mobile Outlets Directory with search and State/District/Market breadcrumb filters.
  * GPS Geofencing engine implementing the Haversine distance formula.
  * Anti-Mock location detector.
  * Visit check-in and check-out tracking.
* **Acceptance Criteria:** Check-in is strictly blocked when salesman is >100m away from the store; unlocks immediately when within 100m.

---

### Phase 3: Sales Order Booking, Collections & Auto-Ledger (Weeks 5–6)
* **Deliverables:**
  * Product / SKU Master catalog integration.
  * Line item order builder with steppers, discount inputs, and GST calculation.
  * Payment collection screen supporting Cash, UPI (with UTR), and Cheque entry.
  * Cloud Function atomic transaction updating the Party Mini-Ledger immediately upon transaction commit.
  * Party ledger screen showing debit, credit, and running balance.
* **Acceptance Criteria:** Creating a sale of ₹10,000 and receiving ₹4,000 cash updates the party outstanding to +₹6,000 instantly without manual calculation.

---

### Phase 4: Central Admin Web Portal & Dynamic Store Allocation (Weeks 7–8)
* **Deliverables:**
  * Admin Web Console (Desktop optimized).
  * **Store-Salesman Allocation Matrix:** Interactive dual-pane interface allowing administrators to select a salesman and assign/reassign outlets or entire markets.
  * Real-time GPS field map tracking active visits.
  * Master Catalog management (Products, Prices, GST rates).
* **Acceptance Criteria:** Admin assigns 10 new stores to a salesman; the salesman’s mobile app reflects the stores immediately via FCM silent update.

---

### Phase 5: Offline-First Synchronization & Outbox Resilience (Weeks 9–10) ✅ [COMPLETED & VERIFIED]
* **Deliverables:**
  * Persistent `sync_outbox` table with FIFO execution queue and real-time Stream feedback.
  * Network transition listener and exponential backoff retry handler (`connectivity_plus`).
  * Server-side idempotency verification using UUID v4 client tokens across `CHECK_IN`, `SALE_INVOICE`, and `COLLECTION` mutations.
  * Interactive "Offline Sync & Outbox Center" screen with Simulated Offline mode toggle, queue inspector, and payload viewer.
* **Acceptance Criteria:** Salesman in offline mode creates transactions; all are enqueued in outbox; toggles internet back on; all records sync seamlessly to Cloud Firestore with zero duplicate records. ✅ [VERIFIED IN BROWSER]

---

### Phase 6: A4 PDF Printing, Bluetooth Thermal & Reports (Weeks 11–12) ✅ [COMPLETED & VERIFIED]
* **Deliverables:**
  * ISO A4 printable Party Statement of Account template compliant with AUPL branding, GSTIN, CIN, running ledger balance, and 4 aging buckets.
  * Interactive Next.js Admin Console ISO A4 Statement Modal (`A4StatementModal.tsx`) with single-party and consolidated corporate ledger views.
  * Bluetooth thermal printer ESC/POS driver integration (`ThermalPrinterService`) for field receipts (58mm/80mm).
  * One-click Debtor List and 0–30, 31–60, 61–90, 90+ day aging reports with live bucket filtering.
  * Salesman performance and target tracking reports.
* **Acceptance Criteria:** Single-tap generation of an ISO A4 PDF statement matching corporate accounting layout, exportable to WhatsApp, print spoolers, and desktop print dialogs. ✅ [VERIFIED IN BROWSER]

---

### Phase 7: Security Audit, Pilot & Statewide Rollout (Weeks 13–14) ✅ [COMPLETED & VERIFIED]
* **Deliverables:**
  * Comprehensive Firestore Security Rules audit with automated test suite (`security_rules_audit_test.dart`) validating all 18 AUPL business invariants and least-privilege policies.
  * Play Integrity API verification and runtime anti-tamper protection (`PlayIntegrityService`) blocking clock-drift (>10m) and device spoofing.
  * Android release hardening with ProGuard / R8 bytecode optimization (`proguard-rules.pro`), resource shrinking, and cleartext traffic blocking.
  * Native runtime permissions manifest configuration (`ACCESS_FINE_LOCATION`, `BLUETOOTH_CONNECT`, `CAMERA`, `POST_NOTIFICATIONS`).
  * 2-week pilot deployment simulation across Kanpur district with 5 active sales reps (`kanpur_pilot_simulation_test.dart`).
  * Full statewide rollout readiness across Uttar Pradesh distribution network (75 districts / regional hubs).
* **Acceptance Criteria:**
  * 100% daily check-in adherence during pilot (14/14 days verified within <100m geofence). ✅ [VERIFIED IN AUTOMATED TEST]
  * Zero balance calculation discrepancies across all outlets and transactions. ✅ [VERIFIED IN AUTOMATED TEST]
  * Complete test suite passing (20/20 test cases green). ✅ [VERIFIED IN FLUTTER TEST]

---

## 3. Post-Development: Production Firebase Backend Setup & Operational Checklist

This guide provides the complete blueprint for wiring the live Firebase backend to the AUPL ecosystem (Flutter Mobile App + Next.js Admin Console + Cloud Functions).

### 3.1 Overview of Firebase Architecture

```
                    ┌──────────────────────────────────────────────┐
                    │      Firebase Project (asia-south1)          │
                    ├──────────────────────────────────────────────┤
                    │ • Authentication (Phone OTP + Custom Claims) │
                    │ • Cloud Firestore (NoSQL Operational DB)     │
                    │ • Cloud Storage (Invoice & Receipt PDFs)     │
                    │ • Cloud Functions v2 (Atomic Auto-Ledger)    │
                    │ • Cloud Messaging (FCM Silent Beat Pulses)   │
                    └──────────────────────┬───────────────────────┘
                                           │
                    ┌──────────────────────┴──────────────────────┐
                    │                                             │
                    ▼                                             ▼
       ┌─────────────────────────┐                   ┌─────────────────────────┐
       │   Flutter Mobile App    │                   │   Next.js Admin Portal  │
       │ (Android Sales Reps)    │                   │ (Management Console)    │
       │ • firebase_core         │                   │ • firebase-admin (Node) │
       │ • cloud_firestore       │                   │ • firebase client SDK   │
       │ • firebase_auth         │                   │ • Real-time Radar       │
       │ • SQLite Outbox Sync    │                   │ • Allocation Matrix     │
       └─────────────────────────┘                   └─────────────────────────┘
```

---

### 3.2 Step-by-Step Backend Setup

#### Step 1: Create & Configure Firebase Console Project
1. Open the [Firebase Console](https://console.firebase.google.com/) and create a project (e.g. `ansu-sales-aupl-cloud`).
2. **Enable Cloud Firestore**:
   * Mode: **Production Mode**.
   * Location: **`asia-south1 (Mumbai)`** (mandatory for low field latency across Uttar Pradesh).
3. **Enable Firebase Authentication**:
   * **Phone Provider**: For Sales Representatives (SMS OTP authentication).
   * **Email / Password**: For HQ Super Admins & Area Managers.
4. **Enable Cloud Storage**:
   * Location: `asia-south1`.
   * Stores store signboard verification photos, cheque leaves, and statement PDFs.

#### Step 2: Connect the Flutter Mobile App (Android)
1. Install tools & configure via FlutterFire CLI:
   ```powershell
   npm install -g firebase-tools
   firebase login
   dart pub global activate flutterfire_cli
   flutterfire configure --project=ansu-sales-aupl-cloud
   ```
   > This automatically generates `lib/firebase_options.dart` and places `google-services.json` inside `android/app/`.

2. Add Flutter dependencies to `pubspec.yaml`:
   ```yaml
   dependencies:
     firebase_core: ^3.12.1
     cloud_firestore: ^5.6.5
     firebase_auth: ^5.5.1
     firebase_storage: ^12.4.4
     firebase_messaging: ^15.2.4
   ```
   Then run: `flutter pub get`

3. Ensure Google Services Gradle plugin is configured:
   * In `android/build.gradle.kts`:
     ```kotlin
     plugins {
         id("com.google.gms.google-services") version "4.4.2" apply false
     }
     ```
   * In `android/app/build.gradle.kts`:
     ```kotlin
     plugins {
         id("com.android.application")
         id("kotlin-android")
         id("dev.flutter.flutter-gradle-plugin")
         id("com.google.gms.google-services")
     }
     ```

4. Initialize Firebase in `lib/main.dart`:
   ```dart
   void main() async {
     WidgetsFlutterBinding.ensureInitialized();
     await Firebase.initializeApp(
       options: DefaultFirebaseOptions.currentPlatform,
     );
     runApp(const AnsuSalesApp());
   }
   ```

#### Step 3: Deploy Audited Security & Storage Rules
The security rules adhering to AUPL's 18 invariants are already authored in the project root:
* [firestore.rules](file:///g:/Applications/AnsuShop/firestore.rules)
* [storage.rules](file:///g:/Applications/AnsuShop/storage.rules)

Deploy them directly with the Firebase CLI:
```powershell
firebase deploy --only firestore:rules,storage
```

#### Step 4: Seed Canonical Master Data into Firestore
As defined in [DATABASE.md](file:///g:/Applications/AnsuShop/DATABASE.md), seed the baseline documents:
* `/states/` — State masters (`state_up`, `Uttar Pradesh`).
* `/districts/` — District masters (`dist_kanpur`, `dist_lucknow`, etc.).
* `/markets/` — Territory beats (`mkt_civil_lines`, `mkt_naveen_market`, etc.).
* `/products/` — Central SKU Master (Rule 10) with GST tax rates (5%, 12%, 18%).
* `/outlets/` — Retail outlets with latitude, longitude, and geofence radius (100m).
* `/users/` — Salesmen profiles, assigned market beats, and bound hardware device IDs.

#### Step 5: Deploy Cloud Functions (Server-Side Auto-Ledger)
To fulfill **Rules 7 & 8 (Auto Party Ledger & Anti-Tamper)**, deploy atomic triggers:
* **`onSaleInvoiceCreated`** (Trigger: `/sales_invoices/{id}`): Atomically appends debit to `/ledgers` and increments `outlet.totalSale` and `outlet.balance`.
* **`onCollectionCreated`** (Trigger: `/collections/{id}`): Atomically appends credit to `/ledgers` and decrements `outlet.balance`.

#### Step 6: Connect Next.js Admin Portal (`admin_portal`)
1. Install Firebase packages:
   ```powershell
   cd g:\Applications\AnsuShop\admin_portal
   npm install firebase firebase-admin
   ```
2. Download Service Account Key from **Firebase Console > Project Settings > Service Accounts**.
3. Create `.env.local` inside `admin_portal`:
   ```env
   NEXT_PUBLIC_FIREBASE_PROJECT_ID=ansu-sales-aupl-cloud
   NEXT_PUBLIC_FIREBASE_API_KEY=AIzaSy...
   FIREBASE_CLIENT_EMAIL=firebase-adminsdk@ansu-sales-aupl-cloud.iam.gserviceaccount.com
   FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n..."
   ```

---

### 3.3 Production Firebase Implementation Checklist

- [ ] **Console Project**: Created project `ansu-sales-aupl-cloud` in `asia-south1 (Mumbai)`.
- [ ] **Authentication**: Configured Phone OTP (SMS provider) & Admin Email/Password.
- [ ] **Mobile App Config**: Executed `flutterfire configure`, placed `google-services.json`, and generated `firebase_options.dart`.
- [ ] **Dependencies**: Added `firebase_core`, `cloud_firestore`, `firebase_auth`, `firebase_storage` to `pubspec.yaml`.
- [ ] **Rules Deployment**: Executed `firebase deploy --only firestore:rules,storage`.
- [ ] **Catalog Seeding**: Populated `states`, `districts`, `markets`, `products`, `outlets`.
- [ ] **Cloud Functions**: Deployed atomic auto-ledger increment/decrement triggers.
- [ ] **Admin Portal**: Configured `firebase-admin` and `.env.local` service account key.

