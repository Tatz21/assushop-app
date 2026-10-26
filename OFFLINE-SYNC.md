# AUPL Sales Team App — Offline-First Architecture & Sync Engine (OFFLINE-SYNC.md)

**Company:** ANSU UDYOG PRIVATE LIMITED (AUPL)  
**Strategy:** Outbox Pattern with Serverless Event Sourcing & Client Idempotency  
**Document Version:** 1.0.0  

---

## 1. Offline Philosophy & Architecture

Field sales executives frequently operate in dense wholesale markets, basements, and semi-rural distribution belts with erratic or nonexistent cellular signals. 

To satisfy **Rule 17 & 18: Offline transaction entry for field use & No duplicate data after sync**, the application adopts a strict **Local-First / Offline-First** paradigm:

```
┌────────────────────────────────────────────────────────────────────────┐
│                        AUPL OFFLINE-FIRST PIPELINE                     │
│                                                                        │
│   [ Salesman Action (Check-in, Sale, Collection) ]                     │
│                           │                                            │
│                           ▼                                            │
│         [ 1. Commit to Local SQLite Transaction ]                      │
│         - Immediate UI update (Optimistic Rendering)                  │
│         - Local running ledger recalculated                            │
│                           │                                            │
│                           ▼                                            │
│         [ 2. Enqueue into Local Outbox Table ]                         │
│         - Generates Client UUID v4 (Idempotency Key)                   │
│         - Sets status = 'PENDING'                                      │
│                           │                                            │
│              ┌────────────┴────────────┐                               │
│              ▼                         ▼                               │
│     [ No Internet ❌ ]           [ Internet Restored 📶 ]              │
│     - Stays cached in SQLite    - Connectivity listener wakes engine   │
│     - Shows "Pending Sync"      - Dispatches FIFO Outbox Batches       │
│                                        │                               │
│                                        ▼                               │
│                         [ 3. Server Idempotency Check ]                │
│                         - docRef(idempotencyKey).exists?               │
│                         - Atomic Firestore Transaction                 │
│                         - Ledger Balance Reconciliation                │
│                                        │                               │
│                                        ▼                               │
│                         [ 4. Mark Outbox as 'SYNCED' ]                 │
│                         - Refresh local cache with server state        │
└────────────────────────────────────────────────────────────────────────┘
```

---

## 2. Local Outbox Queue Schema & Data Model

The `sync_outbox` table in SQLite is the persistent engine holding offline actions awaiting cloud transmission:

```sql
CREATE TABLE sync_outbox (
    outbox_id TEXT PRIMARY KEY,          -- UUID v4 generated on device
    operation_type TEXT NOT NULL,         -- 'CHECK_IN', 'SALE_INVOICE', 'COLLECTION', 'CHECK_OUT'
    entity_id TEXT NOT NULL,             -- Unique invoiceId, visitId, or collectionId
    idempotency_key TEXT NOT NULL,       -- Matches entity_id
    payload_json TEXT NOT NULL,          -- Serialized JSON payload
    created_at TEXT NOT NULL,            -- ISO-8601 device timestamp
    sync_status TEXT DEFAULT 'PENDING',  -- 'PENDING' | 'SYNCING' | 'SYNCED' | 'FAILED'
    retry_count INTEGER DEFAULT 0,
    last_error TEXT,
    last_attempt_at TEXT
);
```

---

## 3. Duplicate Prevention & Conflict Resolution

### 3.1 Why Traditional "Last-Write-Wins" Fails for Accounting
In standard CRUD architectures, two offline devices updating the same customer record simultaneously overwrite each other's balances. For financial applications, this causes lost money.

### 3.2 The AUPL Solution: Immutable Event Append-Only Architecture
1. **Never Overwrite Balances Directly:** Neither mobile nor web overwrites an outlet's balance directly. Instead, they emit discrete, immutable financial events (`SALE_INVOICE_CREATED`, `PAYMENT_COLLECTED`).
2. **Server-Side Deterministic Sequencing:** When Cloud Functions receive outbox events, they process them in chronological order inside a Firestore `runTransaction()` block, deriving the true running balance.
3. **Client-Side Idempotency Keys:** Every invoice and payment receives an immutable client-generated UUID v4 before hitting the local database. When transmitted to the server:
   - If the server has already processed that UUID (e.g., due to an interrupted connection), it returns `HTTP 200 (Already Committed)`.
   - The sync engine marks the local outbox item as `SYNCED` without creating a duplicate invoice or double-charging.

---

## 4. Connectivity Monitoring & Sync Pulse Engine

1. **Reactive Network Listener:** Uses Flutter `connectivity_plus` to listen for network state transitions (`none` $\to$ `mobile` or `wifi`).
2. **Heartbeat Socket Ping:** Network connection triggers a lightweight DNS/ping check (e.g., querying Google 8.8.8.8 or Firebase ping endpoint) to verify true WAN connectivity behind captive portals.
3. **FIFO Batch Dispatch:**
   - Outbox items are dequeued in strict chronological order (`ORDER BY created_at ASC`).
   - Grouped into batches of up to 25 items per payload.
   - Sent to the `syncBatchOutbox` Cloud Function.
4. **Exponential Backoff:** If the sync fails due to network timeout or 5xx server errors:
   $$\text{Backoff Delay} = \min(60, 2^{\text{retry\_count}} \times 2) \text{ seconds}$$
   The item is retried automatically up to 5 times.

---

## 5. UI Status Indication & Sync Indicators

To ensure complete operational confidence for the salesman:
* **Global Header Pill:**
  * 🟢 **All Synced:** Everything backed up to AUPL cloud.
  * 🟠 **Syncing (3):** Three transactions actively uploading.
  * ⚪ **Offline (5 Pending):** 5 transactions safely stored locally; awaiting signal.
* **Transaction Tile Badges:**
  * Displays a small clock icon `⏳ Pending Sync` until confirmed by the server, transitioning to a green checkmark `✔️ Synced`.
