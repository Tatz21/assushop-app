# AUPL Sales Team App — Authentication & Authorization (AUTH.md)

**Company:** ANSU UDYOG PRIVATE LIMITED (AUPL)  
**Security Standard:** Role-Based Access Control (RBAC) + Device Hardware Binding  
**Document Version:** 1.0.0  

---

## 1. Authentication Architecture

The system implements a dual-mode authentication strategy powered by **Firebase Authentication** and augmented with **Firebase Custom Claims** for fine-grained role authorization.

```
┌────────────────────────────────────────────────────────────────────────┐
│                     AUPL AUTHENTICATION GATEWAY                        │
│                                                                        │
│   [ FIELD SALESMAN (MOBILE) ]            [ MANAGEMENT & ADMIN (WEB) ]  │
│         │                                             │                │
│         ▼                                             ▼                │
│   Phone Number + 6-digit OTP              Corporate Email + Password   │
│   + Hardware Device ID Verification       + Multi-Factor Auth (MFA)    │
│         │                                             │                │
│         └───────────────────────┬─────────────────────┘                │
│                                 ▼                                      │
│                  FIREBASE AUTH + CUSTOM CLAIMS                         │
│                  - role: SUPER_ADMIN | AREA_MGR | SALESMAN             │
│                  - hardwareDeviceId: "xyz..."                          │
│                  - assignedMarkets: ["mkt_civil_lines", ...]           │
└────────────────────────────────────────────────────────────────────────┘
```

---

## 2. Role-Based Access Control (RBAC) Matrix

To fulfill **Rule 1 & 2: Salesman can only access assigned areas/outlets & Cannot access another employee's data**:

| Feature / Domain | Super Admin (HO) | Area / District Manager | Field Salesman |
|---|:---:|:---:|:---:|
| **Manage States / Districts / Markets** | Full CRUD | Read-Only | Read-Only (Assigned Only) |
| **Manage Product / SKU Price Master** | Full CRUD | Read-Only | Read-Only |
| **Assign Salesman to Stores / Markets** | Full Access | Territory Scoped | Denied |
| **View Other Salesmen's Data** | Yes (Consolidated) | Yes (In His District) | **Strictly Denied** |
| **Mark GPS Visit / Check-In** | Denied (Web only) | Denied | **Allowed (Within 100m)** |
| **Record SKU Sale Order** | Manual Override | Denied | **Allowed (Assigned Store)** |
| **Record Payment Collection** | Manual Adjust | Review / Approve Chq | **Allowed (Assigned Store)** |
| **View Party Mini-Ledger** | All Outlets | District Outlets | Assigned Outlets Only |
| **Print / Export A4 Ledger Statement** | Allowed | Allowed | Allowed |
| **View Company Debtors Aging (>90d)** | Full Company | District Scope | Assigned Stores Only |
| **Inspect System Audit Logs** | Full Access | Denied | Denied |

---

## 3. Device Binding & Single Active Session Enforcement

To prevent account sharing, unauthorized proxy check-ins, or simultaneous multi-device logins (**Rule 6: Secure Login — Each salesman unique**):

1. **Hardware Fingerprint Extraction:**
   - During mobile login, the app reads the persistent Android Hardware Identifier (`ANDROID_ID`) or a secure UUID generated inside Android Keystore (`hardware_device_id`).
2. **Session Verification on Login:**
   - Upon successful OTP verification, the Cloud Function checks `users/{userId}.currentSession.deviceId`.
   - If a mismatch is detected, the app presents a blocking security modal:
     > *"You are currently logged in on another device (Samsung Galaxy A32). Do you want to terminate that session and register this device?"*
3. **Session Invalidation:**
   - When confirmed, the backend updates `currentSession.deviceId` to the new device and bumps `currentSession.sessionVersion`.
   - The previous device listening to the user document stream immediately detects the session invalidation, purges local session tokens, and returns to the login screen.

---

## 4. Custom Claims Token Payload

When a user signs in or when their assignment changes, a Cloud Function automatically embeds custom claims into their Firebase JWT:

```json
{
  "iss": "https://securetoken.google.com/ansushop-production",
  "aud": "ansushop-production",
  "auth_time": 1791804000,
  "user_id": "uid_rajesh_004",
  "sub": "uid_rajesh_004",
  "email": "rajesh.k@ansushop.com",
  "phone_number": "+919839012345",
  "role": "SALESMAN",
  "employeeId": "AUPL-SM-004",
  "stateIds": ["state_up"],
  "districtIds": ["dist_kanpur"],
  "marketIds": ["mkt_civil_lines", "mkt_mall_road"],
  "deviceId": "dev_id_81726a45b",
  "sessionVersion": 3
}
```

---

## 5. Offline Auth & Session Cache Policy

* **Local Token Storage:** The Firebase ID token and refresh token are stored in Android `EncryptedSharedPreferences`.
* **Offline Access:** If a salesman enters a dead network zone while already authenticated, the local app retains authorization state against the local SQLite database.
* **Session Expiry Policy:** Offline credentials remain valid for up to 7 days without an internet handshake, after which a fresh online handshake is mandated before new transactions can be initiated.
