# AUPL Sales Team App — Push & In-App Notifications (NOTIFICATIONS.md)

**Company:** ANSU UDYOG PRIVATE LIMITED (AUPL)  
**Provider:** Firebase Cloud Messaging (FCM) v1 API  
**Document Version:** 1.0.0  

---

## 1. Notification Architecture Overview

The system uses **Firebase Cloud Messaging (FCM)** to keep field representatives informed of route updates, target milestones, store reassignments, and financial clearances in real time.

```
┌────────────────────────────────────────────────────────────────────────┐
│                      AUPL NOTIFICATION DISPATCHER                      │
│                                                                        │
│   [ Cloud Functions / Triggers ] ───► [ Firebase Cloud Messaging v1 ]  │
│                                                     │                  │
│                        ┌────────────────────────────┴─────────────┐    │
│                        ▼                                          ▼    │
│            Direct User Token Push                        FCM Topics    │
│            (e.g., Target Alerts, Reassignment)         (Territory Push)│
│                        │                                          │    │
│                        └──────────────────────┬───────────────────┘    │
│                                               ▼                        │
│                                   ANDROID DEVICE (FLUTTER)             │
│                                   - Foreground: In-App Snackbar / HUD  │
│                                   - Background: System Tray Channels   │
└────────────────────────────────────────────────────────────────────────┘
```

---

## 2. Android Notification Channels (API 26+)

To adhere to Android guidelines and allow users fine-grained notification management, the app registers 4 dedicated notification channels:

| Channel ID | Channel Name | Importance | Sound & Vibration | Purpose |
|---|---|---|---|---|
| `aupl_territory_updates` | Route & Store Assignments | High (Heads-up) | Custom chime, vibrate | Real-time alerts when Admin assigns new stores to the salesman's route. |
| `aupl_target_alerts` | Sales & Collection Targets | Default | Standard sound | Morning route briefings, daily target progress, and milestone achievements. |
| `aupl_finance_alerts` | Ledger & Cheque Status | High | Standard sound | Alerts when submitted cheques are cleared or bounced by head office. |
| `aupl_security_alerts` | Security & Sessions | Max (Urgent) | Urgent alert | Immediate alert when a new device login terminates an active session. |

---

## 3. FCM Notification Payload Schemas

### 3.1 Store Assignment Alert (Triggers Silent Background Sync)
Sent when an administrator assigns stores to the representative:
```json
{
  "message": {
    "token": "fcm_token_device_abc123",
    "notification": {
      "title": "New Stores Assigned 🏬",
      "body": "Management assigned 4 new retail outlets in Civil Lines to your route."
    },
    "data": {
      "type": "STORE_ASSIGNMENT_UPDATE",
      "marketId": "mkt_civil_lines",
      "action": "TRIGGER_BACKGROUND_SYNC",
      "click_action": "FLUTTER_NOTIFICATION_CLICK"
    },
    "android": {
      "priority": "HIGH",
      "notification": {
        "channel_id": "aupl_territory_updates",
        "icon": "ic_notification_store",
        "color": "#1B5E20"
      }
    }
  }
}
```

### 3.2 Cheque Clearance / Bounce Alert
Sent when head office finance reconciles an instrument:
```json
{
  "message": {
    "token": "fcm_token_device_abc123",
    "notification": {
      "title": "Cheque Cleared ✅",
      "body": "Cheque #40291 from Sharma Medical Store (₹15,000) has cleared. Party ledger updated."
    },
    "data": {
      "type": "FINANCIAL_LEDGER_UPDATE",
      "outletId": "out_1042",
      "collectionId": "c8a42b10-67c2-4011-8be3-5813f8c05e32",
      "status": "APPROVED"
    },
    "android": {
      "priority": "HIGH",
      "notification": {
        "channel_id": "aupl_finance_alerts"
      }
    }
  }
}
```

---

## 4. Broadcast Topics

* `/topics/all_salesmen`: Company-wide announcements, new SKU launches, and pricing revisions.
* `/topics/district_{districtId}`: District-specific notifications dispatched by regional Area Managers.
* `/topics/app_maintenance`: Maintenance alerts and mandated app version upgrades.
