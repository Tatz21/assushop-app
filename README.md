# AUPL Sales Team App & Central Admin Portal

**Company:** ANSU UDYOG PRIVATE LIMITED (AUPL)  
**Tagline:** *Better Tracking, Bigger Growth*  
**Core Modules:** Field Sales | Visit | Sale | Collection | Ledger | Reports | Admin Console  
**Technology Stack:** Flutter (Android Mobile) • Web Admin Portal • Firebase (Firestore, Auth, Functions, Storage, FCM)  

---

## 1. Project Overview

The **AUPL Sales Team Ecosystem** is an enterprise-grade digital solution engineered for **ANSU UDYOG PRIVATE LIMITED**. It unifies field sales execution with corporate governance, featuring:

* **Field Sales Mobile App (Android):** An offline-first mobile application empowering sales representatives with GPS-verified outlet check-ins, SKU-based sales booking, multi-mode payment collections, auto-updating party ledgers, and A4 statement printing.
* **Central Web Admin Portal:** A desktop-first administrative console for managing territorial master catalogs (`State -> District -> Market -> Outlet`), dynamically allocating salesmen to retail routes, tracking live field visits, monitoring consolidated debtor aging, and inspecting financial audit trails.
* **Serverless Firebase Cloud Backend:** Real-time Cloud Firestore, Cloud Functions v2 for atomic transactions, Firebase Authentication with hardware device binding, and Firebase Cloud Messaging (FCM).

---

## 2. Master Documentation Index

Comprehensive documentation has been authored to guide architecture, development, security, and quality assurance:

| Document | Description | Key Focus Area |
|---|---|---|
| [**PRD.md**](file:///g:/Applications/AnsuShop/PRD.md) | Product Requirements Document | Business vision, problem statement, user personas, success metrics. |
| [**ARCHITECTURE.md**](file:///g:/Applications/AnsuShop/ARCHITECTURE.md) | System Architecture Specification | High-level architecture, tech stack, ledger engine, geofencing. |
| [**UI-UX.md**](file:///g:/Applications/AnsuShop/UI-UX.md) | UI/UX Design Specifications | Mobile screen specs, field ergonomics, admin portal layout. |
| [**DESIGN-SYSTEM.md**](file:///g:/Applications/AnsuShop/DESIGN-SYSTEM.md) | Design Token System (A-Design) | AUPL brand palette, typography, elevation, A4 print layout tokens. |
| [**DATABASE.md**](file:///g:/Applications/AnsuShop/DATABASE.md) | Database Architecture & Schema | Cloud Firestore collections, local SQLite tables, composite indexes. |
| [**API.md**](file:///g:/Applications/AnsuShop/API.md) | Cloud Functions & API Specifications | Admin allocation APIs, GPS verification, atomic sales/ledger transactions. |
| [**AUTH.md**](file:///g:/Applications/AnsuShop/AUTH.md) | Authentication & Authorization | Firebase Auth, Custom Claims, hardware device binding, RBAC matrix. |
| [**NAVIGATION.md**](file:///g:/Applications/AnsuShop/NAVIGATION.md) | Navigation & Routing Architecture | Mobile bottom navigation shell, admin sitemap, deep linking. |
| [**FEATURES.md**](file:///g:/Applications/AnsuShop/FEATURES.md) | Detailed Feature Specifications | Master data, store allocation, visits, sales, collections, ledgers. |
| [**USER-FLOWS.md**](file:///g:/Applications/AnsuShop/USER-FLOWS.md) | End-to-End User Flows | Salesman daily 9-step workflow, admin store reassignment, edge cases. |
| [**ANDROID.md**](file:///g:/Applications/AnsuShop/ANDROID.md) | Android Platform Specifications | SDK 24–35, anti-mock GPS, Bluetooth thermal printing, Proguard. |
| [**PERMISSIONS.md**](file:///g:/Applications/AnsuShop/PERMISSIONS.md) | Hardware & OS Permissions | Runtime permission lifecycle, location rationale, graceful fallbacks. |
| [**NOTIFICATIONS.md**](file:///g:/Applications/AnsuShop/NOTIFICATIONS.md) | Push & In-App Notifications | FCM channels, topic broadcasts, route alerts, silent sync pulses. |
| [**SECURITY.md**](file:///g:/Applications/AnsuShop/SECURITY.md) | Security & Governance Architecture | Firestore rules (`firestore.rules`), storage rules, anti-spoofing. |
| [**OFFLINE-SYNC.md**](file:///g:/Applications/AnsuShop/OFFLINE-SYNC.md) | Offline-First Architecture & Sync | SQLite outbox queue, client idempotency keys, conflict prevention. |
| [**TESTING.md**](file:///g:/Applications/AnsuShop/TESTING.md) | QA & Testing Strategy | Unit tests for ledger math, geofence tests, sync integration tests. |
| [**PHASES.md**](file:///g:/Applications/AnsuShop/PHASES.md) | Implementation Phases & Roadmap | 14-week delivery timeline, sprints, milestones, acceptance criteria. |
| [**RULES.md**](file:///g:/Applications/AnsuShop/RULES.md) | 18 Critical Business Rules | Comprehensive technical specification of AUPL's 18 development invariants. |

---

## 3. The 18 Critical Business Rules Summary

All development is bound by the 18 invariants specified in [RULES.md](file:///g:/Applications/AnsuShop/RULES.md):
1. **Assigned Access Only:** Salesman can only access assigned areas/outlets.
2. **Data Isolation:** Cannot access another employee's data.
3. **GPS Verification:** Outlet visit requires GPS verification.
4. **Anti-Remote Check-In:** Visited cannot be marked from outside the outlet ($>100\text{m}$).
5. **Outlet-Linked Sales:** Every sale must be linked to an outlet.
6. **Outlet-Linked Collections:** Every collection must be linked to an outlet.
7. **Auto Party Ledger:** All transactions update the party ledger automatically.
8. **Auto Outstanding:** Outstanding balance is auto-calculated in real time.
9. **Opening Balance Isolation:** Opening balance is maintained separately and immutably.
10. **Central SKU Master:** SKU/Product master managed centrally by Super Admin.
11. **Immutable Audit Trail:** All financial transactions require an immutable audit trail.
12. **Duplicate Prevention:** Enforce idempotency to prevent duplicate invoices/collections.
13. **Management Console:** Management can access consolidated company-wide data.
14. **A4 Printable Ledger:** Party ledger must be printable in standard ISO A4 format.
15. **1-Click Debtor List:** Single-click retrieval of debtor accounts with aging buckets.
16. **Canonical Masters:** Market/District/State/Outlet masters originate strictly from AUPL.
17. **Offline Support:** Full offline transaction entry for uninterrupted field use.
18. **Zero Duplicate Sync:** Deterministic deduplication guarantees no duplicate data after sync.

---

## 4. Salesman Daily 9-Step Workflow

```
[1. Login] ──► [2. View Assigned Outlets] ──► [3. Reach Outlet]
                                                     │
                                                     ▼
[6. Record Sale] ◄── [5. Outlet Dashboard] ◄── [4. GPS Check-In (<100m)]
       │
       ▼
[7. Record Collection] ──► [8. Update Ledger (Auto)] ──► [9. Check-Out]
```

---

## 5. Development Setup & Quickstart

### 5.1 Mobile App (Flutter)
```bash
# 1. Install dependencies
flutter pub get

# 2. Run static code analysis
flutter analyze

# 3. Execute unit tests
flutter test

# 4. Launch on Android device / emulator
flutter run
```

### 5.2 Firebase Cloud Functions & Emulator Suite
```bash
# 1. Navigate to functions directory
cd functions

# 2. Install dependencies
npm install

# 3. Start local Firebase Emulators (Auth, Firestore, Functions, Storage)
firebase emulators:start
```

---

## 6. Corporate Governance & Ownership

**Proprietary Software of ANSU UDYOG PRIVATE LIMITED (AUPL).**  
All rights reserved. Unauthorized copying, distribution, or decompilation of this application and its specifications is strictly prohibited.
