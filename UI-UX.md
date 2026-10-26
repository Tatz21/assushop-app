# AUPL Sales Team App — UI/UX Design Specifications (UI-UX.md)

**Company:** ANSU UDYOG PRIVATE LIMITED (AUPL)  
**Product:** AUPL Mobile Field App & Web Admin Portal  
**Document Version:** 1.0.0  

---

## 1. Field-First UX Principles

The mobile application is crafted specifically for field sales representatives traveling in demanding physical environments (motorcycles, crowded bazaars, direct sunlight, spotty cellular coverage, one-handed operation).

1. **One-Handed Reachability:** Primary action buttons (GPS Check-In, Record Sale, Record Collection, Print) are located within the bottom thumb-zone (bottom 35% of the screen).
2. **High-Contrast Sunlight Legibility:** Font weights of at least 500 (Medium) for body text and 600/700 (SemiBold/Bold) for financial metrics. Minimum contrast ratio of 4.5:1 against backgrounds.
3. **Large Tap Targets:** Minimum touch target size of $48 \times 48\text{ dp}$ (preferring $54\text{ dp}$) for form inputs, quantity steppers, and payment selector chips.
4. **Instant Visual Feedback & Haptics:** Subtle haptic confirmation on GPS check-in lock, order addition, payment submission, and offline sync triggers.
5. **Zero Ambiguity Numbers:** Indian Currency formatting (`₹1,25,000.00`), explicit credit vs. debit color coding (Green = Credit/Payment Received, Red = Debit/Outstanding Due).

---

## 2. Mobile App Screen Specifications

### 2.1 Screen 1: Splash & Authentication
* **Visual Identity:** AUPL corporate leaf emblem, company tagline *"Smart Tools for a Stronger Sales Team"*.
* **Form Controls:** 
  * Mobile Number (10 digits with `+91` prefix) + OTP verification OR Employee ID + Password.
  * Device Binding Indicator: Informs user that login is locked to their active device.
  * Loading state with progress indicator and offline cache check.

### 2.2 Screen 2: Home / Dashboard
* **Top Header:** 
  * Salesman Name, Employee ID, Assigned Territory badge (`Kanpur • Civil Lines`).
  * Live Sync Status indicator icon (Green = Synced, Amber = Syncing, Grey = Offline).
* **Metric Cards Grid (2x2 + 1 Spotlight):**
  * **Today's Sales:** Large bold value (e.g. `₹48,500`), subtext showing total orders booked.
  * **Today's Collection:** Total amount (e.g. `₹32,000`), breakdown pills:
    * `Cash: ₹20,000` | `UPI: ₹8,000` | `Cheque: ₹4,000`
  * **Visit Progress:** Circular progress indicator displaying `14 / 22 Outlets Visited` with percentage.
  * **Target Achievement:** Monthly sales & collection achievement gauge (`78% of Target`).
  * **Outstanding Spotlight:** Total pending market collection across assigned stores (`₹4,12,000`).
* **Quick Action FAB / Bottom Sheet:** Instant access to "Quick Visit", "Pending Collections", and "My Route".

### 2.3 Screen 3: Outlets Directory (Route & Geofencing)
* **Breadcrumb Filter:** `State (UP) > District (Kanpur) > Market (Civil Lines)`.
* **Search & View Toggle:** Instant search by store name or owner name; toggle between "All Assigned" and "Today's Route".
* **Outlet Card Component:**
  * Store Name (`Sharma Medical Store`), Outlet Code (`#AUPL-OUT-1042`).
  * Owner Name & Contact (`Rajesh Sharma • 98390xxxxx`).
  * Distance Badge: Calculated live relative to current device GPS (e.g., `📍 65m away`).
  * Geofence Status: 
    * Green Badge: *Within Range (<100m)*
    * Red Badge: *Out of Range (>100m)*
  * Outstanding Due Pill: `Outstanding: ₹18,400`.
  * Primary Action: **[Check-In]** button (Enabled only when within 100m radius; otherwise displays distance needed).

### 2.4 Screen 4: Outlet Details & Field Dashboard
* **Header:** Outlet Name, Address, Contact, and GPS Tagged Status.
* **Credit Health Card:** Credit Limit (`₹50,000`), Utilized (`₹18,400`), Available Credit (`₹31,600`).
* **Visit Banner:** Active Check-In Timer (e.g. `Checked In: 14 mins ago at 11:20 AM`).
* **Core Action Triad (Large Icon Buttons):**
  1. **Record Sale:** Opens SKU catalog order entry.
  2. **Record Collection:** Opens payment entry modal.
  3. **Party Ledger:** Opens mini-ledger & statement.
* **Order & Collection History Tabs:** Scrollable list of last 10 transactions with status and timestamps.
* **Footer Action:** **[Check-Out & Complete Visit]** with optional visit remarks input.

### 2.5 Screen 5: Sales Booking (SKU-Based)
* **Catalog Selector:** Searchable SKU list with thumbnail, SKU Code, Pack Size, MRP, and Standard Rate.
* **Line Item Stepper:** `[-] Quantity [+]` with quick input keypad.
* **Live Calculation Tray (Sticky Bottom):**
  * Subtotal: `₹12,500`
  * Discount (% or flat): `₹250`
  * GST / Tax (Auto-calculated): `₹612.50`
  * **Net Payable: `₹12,862.50`**
* **Confirmation Dialog:** Summarizes order lines, updates party balance preview, and commits to local SQLite with instant printable invoice preview.

### 2.6 Screen 6: Collection Recording
* **Amount Due Reminder:** Highlights current party outstanding (`₹18,400`).
* **Amount Received Input:** Huge currency field with quick chips (`+₹1,000`, `+₹5,000`, `Full Outstanding`).
* **Payment Mode Segmented Control:**
  * **Cash:** Quick receipt generation; denomination count (optional).
  * **UPI:** Dynamic AUPL UPI QR code display; mandatory Transaction Reference ID (UTR) input field.
  * **Cheque:** Cheque Number, Bank Name, Branch, Cheque Date, and optional cheque photo capture.
* **Auto-Post Switch:** Pre-checked *"Auto-update in Party Ledger"*.
* **Submit Action:** Generates signed collection receipt with instant WhatsApp share and Bluetooth print options.

### 2.7 Screen 7: Party Ledger (Mini-Ledger & A4 Print)
* **Balance Header:** Opening Balance (`₹10,000`), Total Sales (`+₹45,000`), Total Collections (`-₹36,600`), Current Outstanding (`₹18,400`).
* **Transaction Timeline:** Chronological list showing Date, Voucher Type (`INV-104`, `RCP-89`), Debit (Red), Credit (Green), and Running Balance.
* **Bottom Toolbar:**
  * **[Print A4 Statement]**: Spools formatted A4 document.
  * **[Export PDF]**: Generates downloadable PDF.
  * **[Share Statement]**: Direct share via WhatsApp / Email to store owner.

### 2.8 Screen 8: Reports & Debtors List
* **Tabbed Interface:**
  1. **Sales Report:** Filter by Date Range, SKU, and Market.
  2. **Collection Report:** Mode-wise breakdown (Cash vs UPI vs Cheque).
  3. **Debtors / Aging:** Sorted by outstanding balance with color-coded aging tags (`0-30d`, `31-60d`, `60+d`).
  4. **Visit Report:** Visited vs Missed outlets with GPS verification timestamps.

---

## 3. Web Admin Portal UX & Layout Architecture

```
┌───────────────────────────────────────────────────────────────────────────────────┐
│ AUPL ADMIN CONSOLE  [Search stores, salesmen...]           🔔 (3)  [Admin Profile]│
├─────────────────┬─────────────────────────────────────────────────────────────────┤
│ 📊 Dashboard    │ 🏠 Dashboard > Territory Assignment Matrix                       │
│ 🗺️ Live Tracking │ ┌─────────────────────────────────────────────────────────────┐ │
│ 👥 Salesmen     │ │ SELECT SALESMAN: [ Rajesh Kumar (ID: AUPL-SM-004)        ▼] │ │
│ 🏬 Stores/Master│ └─────────────────────────────────────────────────────────────┘ │
│ 📦 SKU Catalog  │                                                                 │
│ 📑 Ledgers & A4 │ ┌──────────────────────────────┬──────────────────────────────┐ │
│ 💰 Collections  │ │ AVAILABLE STORES (Kanpur)    │ ASSIGNED STORES (Rajesh K.)  │ │
│ 🛡️ Audit Trail  │ │ [Search available...]        │ [24 Stores Allocated]        │ │
│ ⚙️ Settings     │ │ [ ] Gupta Traders (Civil L.) │ [x] Sharma Medical Store     │ │
│                 │ │ [ ] New Life Meds (Civil L.) │ [x] City Pharma (Civil L.)   │ │
│                 │ │ [ ] Verma Provisions (Mall)  │ [x] Anand Medical Agency     │ │
│                 │ │                              │                              │ │
│                 │ │ [  Assign Selected  ▶  ]     │ [  ◀  Remove Selected  ]     │ │
│                 │ └──────────────────────────────┴──────────────────────────────┘ │
│                 │ [Save Allocation Changes]  [Export Route Sheet (A4 PDF)]        │
└─────────────────┴─────────────────────────────────────────────────────────────────┘
```

### 3.1 Store-to-Salesman Assignment Matrix
* **Target Workflow:** Selecting a salesman from a reactive dropdown and managing his store portfolio across States, Districts, Markets, or individual Outlets.
* **Dual-Pane Transfer Box:** Left pane lists unassigned or transferable stores; right pane lists currently assigned stores. Includes batch selection and route sequencing.
* **Territory Workload Indicator:** Real-time counter showing assigned stores, average daily visit capacity, and geographical spread radius.
* **Reassignment Wizard:** Bulk transfer of all stores from Salesman A to Salesman B upon route rotation or personnel transition with automated audit logging.

### 3.2 Live Geospatial Operations Center
* Full-screen interactive map displaying color-coded outlet pins:
  * 🟢 Visited & GPS Verified (Check-in time + Sale amount on hover)
  * 🟡 In-Progress (Currently checked-in)
  * 🔴 Unvisited / Pending
* Breadcrumb path trace of salesman's route throughout the day to detect route deviations.

### 3.3 Financial Ledger & Consolidated Aging Center
* Company-wide Master Debtor Sheet filterable by State, District, Market, or Salesman.
* One-click batch generation of A4 printable ledgers for monthly party reconciliations.
