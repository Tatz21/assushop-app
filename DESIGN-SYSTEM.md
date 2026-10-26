# AUPL Sales Team App — Design System Specification (DESIGN-SYSTEM.md)

**Company:** ANSU UDYOG PRIVATE LIMITED (AUPL)  
**System Name:** AUPL Design Token System (A-Design)  
**Document Version:** 1.0.0  

---

## 1. Brand Identity & Visual Language

The visual system of the **AUPL Sales Team Ecosystem** conveys industrial reliability, field precision, and enterprise trust. It combines AUPL's brand leaf green (growth and productivity) with deep corporate navy (stability, governance, financial rigor) and high-contrast slate surfaces.

```
┌────────────────────────────────────────────────────────────────────────┐
│                        AUPL CORE BRAND PALETTE                         │
│                                                                        │
│   [ #1B5E20 ]        [ #0F2537 ]        [ #F8FAFC ]        [ #DC2626 ] │
│   AUPL Green         AUPL Navy          Slate White        Debit Alert │
│   (Growth/Success)   (Corporate Core)   (Clean Canvas)     (Dues/Alert)│
└────────────────────────────────────────────────────────────────────────┘
```

---

## 2. Color Tokens

### 2.1 Brand & Neutral Tokens
| Token Name | Hex Code | Material / Tailwind Equivalent | Usage & Semantic Purpose |
|---|---|---|---|
| `aupl-green-900` | `#1B5E20` | `green-900` | Primary brand identity, successful transactions, checked-in badges. |
| `aupl-green-700` | `#2E7D32` | `green-700` | Interactive buttons, floating action buttons (FABs), positive KPI chips. |
| `aupl-green-50` | `#E8F5E9` | `green-50` | Light backgrounds for success cards, collection receipts, verified tags. |
| `aupl-navy-900` | `#0F2537` | `slate-900` | App bars, sidebar navigation in Admin, major display headings. |
| `aupl-navy-800` | `#1E293B` | `slate-800` | Secondary headers, card titles, high-emphasis text. |
| `aupl-navy-100` | `#F1F5F9` | `slate-100` | App background, disabled input backgrounds, table header rows. |
| `aupl-surface` | `#FFFFFF` | `white` | Card backgrounds, dialogs, bottom sheets, form field fills. |
| `aupl-border` | `#E2E8F0` | `slate-200` | Card borders, table dividers, input borders. |

### 2.2 Financial & Operational Semantic Tokens
| Token Name | Hex Code | Semantic Role | Rule & Meaning |
|---|---|---|---|
| `financial-debit` | `#DC2626` | Debit / Dues / Invoices | Increases party debt. Outstanding balance, overdue tag, cancel action. |
| `financial-credit` | `#16A34A` | Credit / Collections / Receipts | Decreases party debt. Payments collected, cash received, approved. |
| `operational-pending`| `#D97706` | In-Progress / Cheque Clearing | Pending collections, visits planned but not checked-in, draft orders. |
| `geofence-in-range` | `#059669` | Within 100m geofence | Check-in enabled; green pulsing indicator. |
| `geofence-out-range`| `#EA580C` | Out of geofence range | Check-in locked; distance counter displayed. |
| `sync-synced` | `#22C55E` | Offline engine synced | All outbox items committed to Cloud Firestore. |
| `sync-pending` | `#F59E0B` | Offline engine pending | Outbox items cached locally; awaiting internet or sync pulse. |

---

## 3. Typography Scale (Inter / Roboto)

The typography is optimized for quick readability on mobile touchscreens and high-density tabular data in the web admin portal.

| Style Token | Font Family | Size (sp/px) | Weight | Line Height | Application |
|---|---|---|---|---|---|
| `Display.Lg` | Inter / Outfit | 28 | 700 (Bold) | 34 | Financial Grand Totals, Ledger Current Balance. |
| `Heading.Lg` | Inter | 22 | 600 (SemiBold) | 28 | Screen Titles, Modal Titles. |
| `Heading.Md` | Inter | 18 | 600 (SemiBold) | 24 | Card Headers, Store Name in List. |
| `Heading.Sm` | Inter | 16 | 600 (SemiBold) | 22 | Section Titles, Outlet Code, Table Column Headers. |
| `Body.Lg` | Inter | 16 | 400 (Regular) | 24 | Primary form fields, long descriptions. |
| `Body.Md` | Inter | 14 | 500 (Medium) | 20 | Default list text, address, contact numbers. |
| `Body.Sm` | Inter | 12 | 400 (Regular) | 16 | Timestamps, distance labels, secondary meta tags. |
| `Caption` | Inter | 11 | 600 (SemiBold) | 14 | Badges, status chips, micro-labels (UPPERCASE). |
| `Currency.Mono` | JetBrains Mono / Inter | 18 | 700 (Bold) | 22 | Tabular invoice rows, financial debit/credit columns. |

---

## 4. Spacing, Elevation & Corner Radii

### 4.1 Spacing Scale
* `space-2`: 2dp (micro-padding, badge insets)
* `space-4`: 4dp (tight grouping)
* `space-8`: 8dp (standard element margin)
* `space-12`: 12dp (card inner padding, input inner padding)
* `space-16`: 16dp (standard screen padding, container gutters)
* `space-20`: 20dp (card separation)
* `space-24`: 24dp (section dividers)
* `space-32`: 32dp (header separation)

### 4.2 Elevation Tokens
* `elevation-none`: 0dp (flat bordered cards)
* `elevation-sm`: 2dp (default card elevation, list tiles)
* `elevation-md`: 4dp (active cards, dropdown menus)
* `elevation-lg`: 8dp (bottom navigation bar, floating action buttons)
* `elevation-modal`: 16dp (bottom sheets, alert dialogs)

### 4.3 Corner Radii
* `radius-sm`: 6dp (buttons, text inputs, table headers)
* `radius-md`: 10dp (cards, metric widgets, modals)
* `radius-lg`: 16dp (bottom sheets top corners, dialog containers)
* `radius-pill`: 999dp (status badges, payment mode selector chips)

---

## 5. UI Component Specifications

### 5.1 Geofence Proximity Badge
```
[ In Range: 🟢 42m away ]    vs    [ Out of Range: 🟠 185m away ]
```
* **Active State (<100m):** Background `#DCFCE7`, Border `#86EFAC`, Text `#15803D`. Pulsing emerald ring icon.
* **Inactive State (>100m):** Background `#FFEDD5`, Border `#FDBA74`, Text `#C2410C`. Static pin icon showing exact distance to travel.

### 5.2 SKU Order Entry Stepper
* Height: 44dp.
* Minus Button (`[-]`): 44x44dp square, slate background. Disabled when quantity = 0.
* Quantity Display: 60dp width, bold centered font (`Display: 12`). Direct tap opens numeric keyboard.
* Plus Button (`[+]`): 44x44dp square, AUPL Green background with white icon.

### 5.3 Payment Mode Selection Chips
Horizontal radio group: `[ Cash ]`, `[ UPI ]`, `[ Cheque ]`.
* **Selected:** Background `#0F2537` (Navy), Text `#FFFFFF`, Checkmark icon.
* **Unselected:** Background `#F1F5F9`, Border `#CBD5E1`, Text `#475569`.

---

## 6. A4 Printable Document Standards (Party Ledger & Invoice)

To satisfy **Rule 14 & 15: Party ledger must be printable in A4 format & Debtor list in one click**:

* **Canvas Dimensions:** ISO A4 ($210\text{ mm} \times 297\text{ mm}$ / $595.28\text{ pt} \times 841.89\text{ pt}$).
* **Margins:** Top/Bottom: 24pt, Left/Right: 28pt.
* **Document Header:**
  * Top Left: ANSU UDYOG PRIVATE LIMITED logo + CIN/GSTIN + Registered Corporate Address.
  * Top Right: Document Title (`PARTY STATEMENT OF ACCOUNT`), Date of Issue, Period Range (`From: 01-Oct-2026 To: 12-Oct-2026`).
* **Party Profile Section:**
  * Outlet Code, Outlet Name, Proprietor Name, Full Address, Contact Number, Credit Limit.
* **Transaction Table Grid:**
  * Column 1: Date (dd-MM-yyyy)
  * Column 2: Particulars / Voucher Type (`Sales Invoice #INV-104`, `Cash Collection #RCP-88`)
  * Column 3: Reference No.
  * Column 4: Debit (₹) [Invoices]
  * Column 5: Credit (₹) [Payments / Returns]
  * Column 6: Running Balance (₹)
* **Footer Section:**
  * Total Debits, Total Credits, Net Current Outstanding in bold box.
  * Standard Legal Terms & Computer-generated document disclaimer.
  * Official seal and authorized signature line for ANSU UDYOG PRIVATE LIMITED.
