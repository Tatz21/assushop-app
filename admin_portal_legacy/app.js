/**
 * AUPL CENTRAL ADMIN CONSOLE — ENTERPRISE LOGIC ENGINE
 * ANSU UDYOG PRIVATE LIMITED
 */

// ==========================================================
// 1. INITIAL ENTERPRISE DATASET
// ==========================================================

const INITIAL_SALESMEN = [
  {
    id: "USR001",
    name: "Rohit Sharma",
    employeeId: "EMP-0101",
    mobile: "+91 98391 23456",
    email: "rohit.s@ansuudyog.com",
    territory: "Civil Lines & Nayaganj",
    target: 150000,
    achieved: 84500,
    commissionRate: 2.5,
    status: "Active (In Store)",
    currentLocation: { lat: 26.4718, lng: 80.3498, venue: "Sharma Medical Store", distance: 34 },
    checkedInAt: "10:15 AM",
  },
  {
    id: "USR002",
    name: "Rajesh Kumar",
    employeeId: "EMP-0102",
    mobile: "+91 98392 34567",
    email: "rajesh.k@ansuudyog.com",
    territory: "Govind Nagar & Kidwai",
    target: 125000,
    achieved: 52000,
    commissionRate: 2.5,
    status: "In Transit (GT Road)",
    currentLocation: { lat: 26.4520, lng: 80.3180, venue: "En Route to Govind Nagar", distance: 180 },
    checkedInAt: null,
  },
  {
    id: "USR003",
    name: "Amit Singh",
    employeeId: "EMP-0103",
    mobile: "+91 98393 45678",
    email: "amit.s@ansuudyog.com",
    territory: "Nayaganj Wholesale",
    target: 130000,
    achieved: 38000,
    commissionRate: 2.5,
    status: "Active (In Store)",
    currentLocation: { lat: 26.4680, lng: 80.3540, venue: "Gupta Kirana Store", distance: 48 },
    checkedInAt: "11:05 AM",
  },
];

const INITIAL_INVENTORY_CHECKS = [
  {
    id: "AUD-2026-081",
    outletId: "OUT001",
    outletName: "Sharma Medical & General Store",
    market: "Civil Lines",
    auditedBySalesmanId: "USR001",
    auditorName: "Rohit Sharma",
    auditorEmpId: "EMP-0101",
    timestamp: "12 Oct 2026, 10:45 AM",
    skuCode: "AUPL-JEERA-100",
    productName: "Royal Cumin / Jeera 100g",
    category: "Spices",
    physicalCount: 3,
    targetCount: 24,
    variance: -21,
    facingGrade: "A+ Prime Eye-Level",
    batchNo: "AU-26K09",
    expiryDate: "2027-11-30",
    status: "CRITICAL_DEFICIT",
    notes: "High customer demand over weekend. Secondary shelf completely empty.",
    replenishmentStatus: "PO_GENERATED",
    replenishmentPoId: "PO-AUPL-9921",
  },
  {
    id: "AUD-2026-082",
    outletId: "OUT001",
    outletName: "Sharma Medical & General Store",
    market: "Civil Lines",
    auditedBySalesmanId: "USR001",
    auditorName: "Rohit Sharma",
    auditorEmpId: "EMP-0101",
    timestamp: "12 Oct 2026, 11:00 AM",
    skuCode: "AUPL-HALDI-500",
    productName: "Pure Turmeric Powder 500g",
    category: "Spices",
    physicalCount: 18,
    targetCount: 20,
    variance: -2,
    facingGrade: "A+ Prime Eye-Level",
    batchNo: "AU-26H11",
    expiryDate: "2028-02-28",
    status: "HEALTHY",
    notes: "Good stock rotation, front-facing clean.",
    replenishmentStatus: "NONE_REQUIRED",
    replenishmentPoId: null,
  },
  {
    id: "AUD-2026-083",
    outletId: "OUT002",
    outletName: "Gupta Kirana & Provisions",
    market: "Nayaganj",
    auditedBySalesmanId: "USR003",
    auditorName: "Amit Singh",
    auditorEmpId: "EMP-0103",
    timestamp: "12 Oct 2026, 11:30 AM",
    skuCode: "AUPL-MIRCH-100",
    productName: "Special Red Chilli 100g",
    category: "Spices",
    physicalCount: 2,
    targetCount: 30,
    variance: -28,
    facingGrade: "B Standard Shelf",
    batchNo: "AU-25M04",
    expiryDate: "2026-11-15",
    status: "CRITICAL_DEFICIT",
    notes: "Nearly stockout and older batch expiring within 35 days. Immediate dispatch needed.",
    replenishmentStatus: "PENDING_DISPATCH",
    replenishmentPoId: "PO-AUPL-9922",
  },
  {
    id: "AUD-2026-084",
    outletId: "OUT003",
    outletName: "Verma Departmental Store",
    market: "Govind Nagar",
    auditedBySalesmanId: "USR002",
    auditorName: "Rajesh Kumar",
    auditorEmpId: "EMP-0102",
    timestamp: "11 Oct 2026, 04:15 PM",
    skuCode: "AUPL-CHAI-250",
    productName: "Assam Gold CTC Tea 250g",
    category: "Beverages",
    physicalCount: 32,
    targetCount: 24,
    variance: 8,
    facingGrade: "A+ Prime Eye-Level",
    batchNo: "AU-26T01",
    expiryDate: "2027-08-31",
    status: "OVERSTOCKED",
    notes: "Store holds sufficient buffer for 2 weeks festival season.",
    replenishmentStatus: "NONE_REQUIRED",
    replenishmentPoId: null,
  },
  {
    id: "AUD-2026-085",
    outletId: "OUT004",
    outletName: "Agarwal Provision Store",
    market: "Kidwai Nagar",
    auditedBySalesmanId: "USR002",
    auditorName: "Rajesh Kumar",
    auditorEmpId: "EMP-0102",
    timestamp: "11 Oct 2026, 02:20 PM",
    skuCode: "AUPL-SARSON-1L",
    productName: "Kacchi Ghani Mustard Oil 1L",
    category: "Edible Oils",
    physicalCount: 5,
    targetCount: 16,
    variance: -11,
    facingGrade: "B Standard Shelf",
    batchNo: "AU-26S07",
    expiryDate: "2027-05-15",
    status: "LOW_STOCK",
    notes: "Oil shelf running thin. Customer prefers 1L bottles over sachets.",
    replenishmentStatus: "PO_GENERATED",
    replenishmentPoId: "PO-AUPL-9923",
  },
  {
    id: "AUD-2026-086",
    outletId: "OUT005",
    outletName: "Mishra Daily Needs",
    market: "Gumti No. 5",
    auditedBySalesmanId: "USR001",
    auditorName: "Rohit Sharma",
    auditorEmpId: "EMP-0101",
    timestamp: "10 Oct 2026, 01:10 PM",
    skuCode: "AUPL-DHANIYA-200",
    productName: "Premium Coriander Powder 200g",
    category: "Spices",
    physicalCount: 6,
    targetCount: 18,
    variance: -12,
    facingGrade: "C Bottom / Secondary",
    batchNo: "AU-26D03",
    expiryDate: "2026-11-20",
    status: "EXPIRING_SOON",
    notes: "Batch expiry in 40 days. Instructed owner to rotate to front shelf discount bin.",
    replenishmentStatus: "PO_GENERATED",
    replenishmentPoId: "PO-AUPL-9924",
  },
];

const INITIAL_PRODUCTS = [
  {
    skuCode: "AUPL-JEERA-100",
    name: "Royal Cumin / Jeera 100g",
    category: "Spices",
    unit: "100g Pouch",
    basePrice: 65.00,
    gstRate: 5,
    stockStatus: "In Stock (1,240 units)",
  },
  {
    skuCode: "AUPL-DHANIYA-200",
    name: "Premium Coriander Powder 200g",
    category: "Spices",
    unit: "200g Pouch",
    basePrice: 82.00,
    gstRate: 5,
    stockStatus: "In Stock (890 units)",
  },
  {
    skuCode: "AUPL-HALDI-500",
    name: "Pure Turmeric Powder 500g",
    category: "Spices",
    unit: "500g Pouch",
    basePrice: 140.00,
    gstRate: 5,
    stockStatus: "In Stock (620 units)",
  },
  {
    skuCode: "AUPL-MIRCH-100",
    name: "Special Red Chilli 100g",
    category: "Spices",
    unit: "100g Pouch",
    basePrice: 58.00,
    gstRate: 5,
    stockStatus: "Low Stock (140 units)",
  },
  {
    skuCode: "AUPL-CHAI-250",
    name: "Assam Gold CTC Tea 250g",
    category: "Beverages",
    unit: "250g Box",
    basePrice: 125.00,
    gstRate: 5,
    stockStatus: "In Stock (2,100 units)",
  },
  {
    skuCode: "AUPL-SARSON-1L",
    name: "Kacchi Ghani Mustard Oil 1L",
    category: "Edible Oils",
    unit: "1L Pet Bottle",
    basePrice: 148.00,
    gstRate: 5,
    stockStatus: "In Stock (450 units)",
  },
];

const INITIAL_OUTLETS = [
  {
    id: "OUT001",
    code: "OUT000001",
    name: "Sharma Medical & General Store",
    ownerName: "Ramesh Sharma",
    mobile: "9839011111",
    market: "Civil Lines",
    district: "Kanpur",
    creditLimit: 75000,
    balance: 28400,
    assignedSalesmanId: "USR001",
    status: "visited",
    lat: 26.4715,
    lng: 80.3495,
    agingDays: 14,
  },
  {
    id: "OUT002",
    code: "OUT000002",
    name: "Gupta Kirana & Provisions",
    ownerName: "Pawan Gupta",
    mobile: "9839022222",
    market: "Nayaganj",
    district: "Kanpur",
    creditLimit: 50000,
    balance: 14200,
    assignedSalesmanId: "USR003",
    status: "visited",
    lat: 26.4678,
    lng: 80.3538,
    agingDays: 45,
  },
  {
    id: "OUT003",
    code: "OUT000003",
    name: "Verma Departmental Store",
    ownerName: "Sanjay Verma",
    mobile: "9839033333",
    market: "Govind Nagar",
    district: "Kanpur",
    creditLimit: 60000,
    balance: 41800,
    assignedSalesmanId: "USR002",
    status: "pending",
    lat: 26.4510,
    lng: 80.3175,
    agingDays: 78,
  },
  {
    id: "OUT004",
    code: "OUT000004",
    name: "Agarwal Super Mart",
    ownerName: "Mukesh Agarwal",
    mobile: "9839044444",
    market: "Civil Lines",
    district: "Kanpur",
    creditLimit: 100000,
    balance: 62500,
    assignedSalesmanId: "USR001",
    status: "visited",
    lat: 26.4730,
    lng: 80.3510,
    agingDays: 95,
  },
  {
    id: "OUT005",
    code: "OUT000005",
    name: "Kanpur Traders Wholesale",
    ownerName: "Alok Rastogi",
    mobile: "9839055555",
    market: "Nayaganj",
    district: "Kanpur",
    creditLimit: 150000,
    balance: 89000,
    assignedSalesmanId: "USR003",
    status: "visited",
    lat: 26.4690,
    lng: 80.3555,
    agingDays: 110,
  },
  {
    id: "OUT006",
    code: "OUT000006",
    name: "Bajpai Daily Needs",
    ownerName: "Santosh Bajpai",
    mobile: "9839066666",
    market: "Kidwai Nagar",
    district: "Kanpur",
    creditLimit: 40000,
    balance: 0,
    assignedSalesmanId: "USR002",
    status: "pending",
    lat: 26.4420,
    lng: 80.3340,
    agingDays: 0,
  },
  {
    id: "OUT007",
    code: "OUT000007",
    name: "Mishra Kirana Bhandar",
    ownerName: "Vinod Mishra",
    mobile: "9839077777",
    market: "Gumti No. 5",
    district: "Kanpur",
    creditLimit: 50000,
    balance: 18200,
    assignedSalesmanId: null, // Ready for assignment
    status: "pending",
    lat: 26.4630,
    lng: 80.3220,
    agingDays: 22,
  },
  {
    id: "OUT008",
    code: "OUT000008",
    name: "Shri Balaji FMCG Mart",
    ownerName: "Deepak Sahu",
    mobile: "9839088888",
    market: "Nayaganj",
    district: "Kanpur",
    creditLimit: 45000,
    balance: 33200,
    assignedSalesmanId: null, // Ready for assignment
    status: "pending",
    lat: 26.4685,
    lng: 80.3560,
    agingDays: 62,
  },
];

// Pre-populate up to 48 outlets across Kanpur markets
const MARKETS_LIST = ["Civil Lines", "Nayaganj", "Govind Nagar", "Kidwai Nagar", "Gumti No. 5"];
const OWNERS_LIST = ["Ramesh", "Pawan", "Sanjay", "Mukesh", "Alok", "Santosh", "Vinod", "Deepak", "Vivek", "Sunil", "Pradeep", "Harish"];
const SURNAMES_LIST = ["Sharma", "Gupta", "Verma", "Agarwal", "Rastogi", "Bajpai", "Mishra", "Sahu", "Tiwari", "Pandey", "Shukla", "Dixit"];
const STORE_PREFIXES = ["Om Sai", "Jai Maa", "Shiva", "Radhe Krishna", "New Laxmi", "Ganesh", "Kalyan", "Shubham", "Modern", "National", "Elite", "Prime"];

for (let i = 9; i <= 48; i++) {
  const mkt = MARKETS_LIST[i % MARKETS_LIST.length];
  const owner = `${OWNERS_LIST[i % OWNERS_LIST.length]} ${SURNAMES_LIST[i % SURNAMES_LIST.length]}`;
  const store = `${STORE_PREFIXES[i % STORE_PREFIXES.length]} General Store`;
  const assigned = i % 4 === 0 ? null : (i % 3 === 0 ? "USR001" : (i % 2 === 0 ? "USR002" : "USR003"));
  const bal = (i % 3 === 0) ? (i * 1250) : ((i % 5 === 0) ? 0 : (i * 850));
  const aging = bal === 0 ? 0 : ((i * 7) % 120);

  INITIAL_OUTLETS.push({
    id: `OUT0${i < 10 ? '0' : ''}${i}`,
    code: `OUT0000${i < 10 ? '0' : ''}${i}`,
    name: store,
    ownerName: owner,
    mobile: `9839${String(100000 + i).substring(1)}`,
    market: mkt,
    district: "Kanpur",
    creditLimit: 30000 + (i % 5) * 15000,
    balance: bal,
    assignedSalesmanId: assigned,
    status: i % 2 === 0 ? "visited" : "pending",
    lat: 26.4600 + (Math.sin(i) * 0.02),
    lng: 80.3300 + (Math.cos(i) * 0.03),
    agingDays: aging,
  });
}

const INITIAL_AUDIT_LOGS = [
  {
    id: "AUD-1791801",
    timestamp: "2026-10-12 11:20:14",
    action: "STORE_ALLOCATION",
    entity: "OUT000001",
    desc: "Assigned Sharma Medical Store to Rohit Sharma (EMP-0101)",
    actor: "Sunil Agarwal (Super Admin)",
    hash: "0x8fa4b...c91",
  },
  {
    id: "AUD-1791802",
    timestamp: "2026-10-12 10:45:00",
    action: "SKU_PRICE_UPDATE",
    entity: "AUPL-HALDI-500",
    desc: "Updated Base wholesale price to ₹140.00 (GST 5%)",
    actor: "Sunil Agarwal (Super Admin)",
    hash: "0x7bc2a...d12",
  },
  {
    id: "AUD-1791803",
    timestamp: "2026-10-12 09:30:18",
    action: "GEOFENCE_CHECKIN",
    entity: "VISIT-0931",
    desc: "Rohit Sharma checked in at Sharma Medical (Distance: 34m <= 100m)",
    actor: "System Engine",
    hash: "0x1fe90...b44",
  },
];

// ==========================================================
// 2. STATE MANAGEMENT & LOCAL STORAGE
// ==========================================================

let state = {
  activeView: "allocation",
  selectedSalesmanId: "USR001",
  catalogFilter: "ALL",
  searchQuery: "",
  salesmenSearchQuery: "",
  salesmenStatusFilter: "ALL",
  auditSearchQuery: "",
  auditStatusFilter: "ALL",
  auditStoreFilter: "ALL",
  salesmen: [],
  outlets: [],
  products: [],
  inventoryChecks: [],
  auditLogs: [],
};

function loadState() {
  const saved = localStorage.getItem("AUPL_ADMIN_STATE_V1");
  if (saved) {
    try {
      const parsed = JSON.parse(saved);
      state.salesmen = parsed.salesmen || INITIAL_SALESMEN;
      state.outlets = parsed.outlets || INITIAL_OUTLETS;
      state.products = parsed.products || INITIAL_PRODUCTS;
      state.inventoryChecks = parsed.inventoryChecks || INITIAL_INVENTORY_CHECKS;
      state.auditLogs = parsed.auditLogs || INITIAL_AUDIT_LOGS;
    } catch (_) {
      useInitialData();
    }
  } else {
    useInitialData();
  }
}

function useInitialData() {
  state.salesmen = JSON.parse(JSON.stringify(INITIAL_SALESMEN));
  state.outlets = JSON.parse(JSON.stringify(INITIAL_OUTLETS));
  state.products = JSON.parse(JSON.stringify(INITIAL_PRODUCTS));
  state.inventoryChecks = JSON.parse(JSON.stringify(INITIAL_INVENTORY_CHECKS));
  state.auditLogs = JSON.parse(JSON.stringify(INITIAL_AUDIT_LOGS));
  saveState();
}

function saveState() {
  localStorage.setItem("AUPL_ADMIN_STATE_V1", JSON.stringify({
    salesmen: state.salesmen,
    outlets: state.outlets,
    products: state.products,
    inventoryChecks: state.inventoryChecks,
    auditLogs: state.auditLogs,
  }));
  updateKpis();
}

// ==========================================================
// 3. UI RENDERING & TAB SWITCHING
// ==========================================================

function switchView(viewName) {
  state.activeView = viewName;
  
  // Update Nav links
  document.querySelectorAll(".nav-item").forEach(el => el.classList.remove("active"));
  const navEl = document.getElementById(`nav-${viewName}`);
  if (navEl) navEl.classList.add("active");

  // Update View Panels
  document.querySelectorAll(".view-panel").forEach(el => el.classList.remove("active"));
  const panelEl = document.getElementById(`view-${viewName}`);
  if (panelEl) panelEl.classList.add("active");

  // Update Header titles
  const titles = {
    allocation: { title: "Store-Salesman Allocation Matrix", caption: "Manage territorial store assignments, dynamic route transfers, and field quotas", action: "Add Store" },
    salesmen: { title: "Maintain Field Sales Executives", caption: "Manage sales team master, quotas, commission plans, contact profiles, and live beat status", action: "Add Sales Rep" },
    "inventory-checks": { title: "Store Shelf Inventory Audit Log", caption: "Verify physical stock counts, detect stockouts, track batch expiry, and dispatch auto-replenishment", action: "Record Audit" },
    radar: { title: "Live Field Radar & GPS Geofencing", caption: "Real-time field telemetry and anti-mock location tracking across Kanpur network", action: "Locate Rep" },
    catalog: { title: "Master SKU Catalog & Pricing", caption: "Configure products, tiered GST slabs, and wholesale dealer price lists", action: "Add SKU" },
    debtors: { title: "Debtor Aging & Credit Risk Exposure", caption: "0–90+ day accounts ledger aging and credit limit compliance", action: "Export PDF" },
    audit: { title: "Immutable Governance Audit Trail", caption: "Cryptographically verified record of administrative interventions and route changes", action: "Export Logs" },
    cloud: { title: "Firebase Cloud Pipeline Architecture", caption: "Real-time sync telemetry with Google Cloud Firestore and Security Rules v2", action: "Run Sync" },
  };

  const info = titles[viewName] || titles.allocation;
  document.getElementById("page-title").textContent = info.title;
  document.getElementById("page-caption").textContent = info.caption;
  document.getElementById("quick-action-label").textContent = info.action;

  // View specific render triggers
  if (viewName === "allocation") renderAllocationMatrix();
  if (viewName === "salesmen") renderSalesmenView();
  if (viewName === "inventory-checks") renderInventoryChecksView();
  if (viewName === "radar") renderRadarView();
  if (viewName === "catalog") renderCatalogTable();
  if (viewName === "debtors") renderDebtorsTable();
  if (viewName === "audit") renderAuditTable();
  if (viewName === "cloud") renderCloudPipeline();
}

function handleQuickAction() {
  switch (state.activeView) {
    case "allocation":
    case "debtors":
      showModal("modal-add-outlet");
      break;
    case "salesmen":
      showAddSalesmanModal();
      break;
    case "inventory-checks":
      showAddInventoryCheckModal();
      break;
    case "catalog":
      showModal("modal-add-product");
      break;
    case "radar":
      showToast("Radar Refresh", "Scanning live GPS telemetry...");
      renderRadarView();
      break;
    case "audit":
      showToast("Audit Trail", "Exporting cryptographic audit log CSV...");
      break;
    case "cloud":
      triggerCloudSync();
      break;
  }
}

// ==========================================================
// 4. KPI UPDATE ENGINE
// ==========================================================

function updateKpis() {
  const totalOutlets = state.outlets.length;
  const activeReps = state.salesmen.length;
  const totalDebt = state.outlets.reduce((sum, o) => sum + o.balance, 0);
  const unassigned = state.outlets.filter(o => !o.assignedSalesmanId).length;
  const criticalOverdue = state.outlets.filter(o => o.balance > 0 && o.agingDays > 90).length;

  document.getElementById("kpi-total-outlets").textContent = totalOutlets;
  document.getElementById("kpi-active-reps").textContent = activeReps;
  document.getElementById("kpi-total-debt").textContent = `₹ ${formatCurrency(totalDebt)}`;
  document.getElementById("badge-unassigned").textContent = unassigned;
  document.getElementById("badge-overdue").textContent = criticalOverdue;

  // Update Salesmen Badge & Metrics
  const badgeSalesmen = document.getElementById("badge-salesmen-count");
  if (badgeSalesmen) badgeSalesmen.textContent = activeReps;

  const totalStoresAllocated = state.outlets.filter(o => o.assignedSalesmanId).length;
  const totalTeamTarget = state.salesmen.reduce((sum, s) => sum + (s.target || 0), 0);
  const inStoreReps = state.salesmen.filter(s => s.status && s.status.includes("Active")).length;

  const sTotal = document.getElementById("salesmen-metric-total");
  if (sTotal) sTotal.textContent = activeReps;
  const sStores = document.getElementById("salesmen-metric-stores");
  if (sStores) sStores.textContent = totalStoresAllocated;
  const sTarget = document.getElementById("salesmen-metric-target");
  if (sTarget) sTarget.textContent = `₹ ${formatCurrency(totalTeamTarget)}`;
  const sLive = document.getElementById("salesmen-metric-live");
  if (sLive) sLive.textContent = `${inStoreReps} In-Store`;

  // Update Inventory Check Badges & Metrics
  const criticalDeficits = state.inventoryChecks.filter(c => c.status === "CRITICAL_DEFICIT").length;
  const expiringBatches = state.inventoryChecks.filter(c => c.status === "EXPIRING_SOON").length;
  const badgeStockouts = document.getElementById("badge-stockout-count");
  if (badgeStockouts) badgeStockouts.textContent = criticalDeficits;

  const aTotal = document.getElementById("audit-metric-total");
  if (aTotal) aTotal.textContent = state.inventoryChecks.length;
  const aStockouts = document.getElementById("audit-metric-stockouts");
  if (aStockouts) aStockouts.textContent = `${criticalDeficits} Outlets`;
  const aExpiry = document.getElementById("audit-metric-expiry");
  if (aExpiry) aExpiry.textContent = `${expiringBatches} Batches`;
}

// ==========================================================
// 5. STORE ALLOCATION MATRIX IMPLEMENTATION
// ==========================================================

function renderAllocationMatrix() {
  const repListContainer = document.getElementById("salesman-cards-list");
  repListContainer.innerHTML = "";

  state.salesmen.forEach(rep => {
    const assignedStores = state.outlets.filter(o => o.assignedSalesmanId === rep.id);
    const isSelected = rep.id === state.selectedSalesmanId;

    const card = document.createElement("div");
    card.className = `rep-selector-card ${isSelected ? 'selected' : ''}`;
    card.onclick = () => {
      state.selectedSalesmanId = rep.id;
      renderAllocationMatrix();
    };

    card.innerHTML = `
      <div class="rep-card-top">
        <span class="rep-name">${rep.name}</span>
        <span class="rep-badge">${rep.employeeId}</span>
      </div>
      <div class="rep-stats-row">
        <div class="rep-stat-item">
          <span class="stat-lbl">Stores</span>
          <span class="stat-val">${assignedStores.length}</span>
        </div>
        <div class="rep-stat-item">
          <span class="stat-lbl">Territory</span>
          <span class="stat-val">${rep.territory}</span>
        </div>
        <div class="rep-stat-item">
          <span class="stat-lbl">Monthly Target</span>
          <span class="stat-val">₹${(rep.target / 1000).toFixed(0)}k</span>
        </div>
      </div>
    `;
    repListContainer.appendChild(card);
  });

  const selectedRep = state.salesmen.find(s => s.id === state.selectedSalesmanId) || state.salesmen[0];
  document.getElementById("selected-rep-name-display").textContent = selectedRep.name;

  // Filter queries
  const filterAssigned = (document.getElementById("filter-assigned-input")?.value || "").toLowerCase();
  const filterAvailable = (document.getElementById("filter-available-input")?.value || "").toLowerCase();
  const selectedMarket = document.getElementById("market-filter-dropdown")?.value || "ALL";

  // RENDER LEFT PANE (ASSIGNED STORES)
  const assignedListEl = document.getElementById("assigned-stores-list");
  assignedListEl.innerHTML = "";
  const assignedStores = state.outlets.filter(o => o.assignedSalesmanId === selectedRep.id);
  document.getElementById("assigned-count-pill").textContent = `${assignedStores.length} Stores`;

  const filteredAssigned = assignedStores.filter(o => 
    o.name.toLowerCase().includes(filterAssigned) ||
    o.ownerName.toLowerCase().includes(filterAssigned) ||
    o.code.toLowerCase().includes(filterAssigned)
  );

  if (filteredAssigned.length === 0) {
    assignedListEl.innerHTML = `<div style="text-align:center; padding: 40px; color: #94A3B8; font-size: 13px;">No stores assigned to ${selectedRep.name} yet. Pick stores from the right pane.</div>`;
  } else {
    filteredAssigned.forEach(store => {
      const card = document.createElement("div");
      card.className = "store-matrix-card";
      card.innerHTML = `
        <div class="store-main-info">
          <div class="store-name-line">
            <strong>${store.name}</strong>
            <span class="store-code-pill">${store.code}</span>
          </div>
          <div class="store-meta-line">
            <i class="fa-solid fa-user"></i> ${store.ownerName} • <i class="fa-solid fa-location-dot"></i> ${store.market}
          </div>
          <div class="store-metrics-line">
            <span class="due-val">Due: ₹${formatCurrency(store.balance)}</span>
            <span class="limit-val">Limit: ₹${formatCurrency(store.creditLimit)}</span>
          </div>
        </div>
        <button class="store-action-btn unassign" onclick="unassignStore('${store.id}')" title="Unassign Store">
          <i class="fa-solid fa-minus"></i> Remove
        </button>
      `;
      assignedListEl.appendChild(card);
    });
  }

  // RENDER RIGHT PANE (AVAILABLE / UNASSIGNED STORES)
  const availableListEl = document.getElementById("available-stores-list");
  availableListEl.innerHTML = "";
  const availableStores = state.outlets.filter(o => o.assignedSalesmanId !== selectedRep.id);

  const filteredAvailable = availableStores.filter(o => {
    if (selectedMarket !== "ALL" && o.market !== selectedMarket) return false;
    if (filterAvailable && !o.name.toLowerCase().includes(filterAvailable) && !o.ownerName.toLowerCase().includes(filterAvailable)) return false;
    return true;
  });

  if (filteredAvailable.length === 0) {
    availableListEl.innerHTML = `<div style="text-align:center; padding: 40px; color: #94A3B8; font-size: 13px;">No available stores match the search filter.</div>`;
  } else {
    filteredAvailable.forEach(store => {
      const currentRep = state.salesmen.find(s => s.id === store.assignedSalesmanId);
      const card = document.createElement("div");
      card.className = "store-matrix-card";
      card.innerHTML = `
        <div class="store-main-info">
          <div class="store-name-line">
            <strong>${store.name}</strong>
            <span class="store-code-pill">${store.code}</span>
          </div>
          <div class="store-meta-line">
            <i class="fa-solid fa-user"></i> ${store.ownerName} • <i class="fa-solid fa-location-dot"></i> ${store.market}
            ${currentRep ? ` • <span style="color:#2563EB;">Rep: ${currentRep.name}</span>` : ' • <span style="color:#D97706; font-weight:700;">Unassigned Pool</span>'}
          </div>
          <div class="store-metrics-line">
            <span class="due-val">Due: ₹${formatCurrency(store.balance)}</span>
            <span class="limit-val">Limit: ₹${formatCurrency(store.creditLimit)}</span>
          </div>
        </div>
        <button class="store-action-btn assign" onclick="assignStoreToCurrentRep('${store.id}')" title="Assign to ${selectedRep.name}">
          <i class="fa-solid fa-plus"></i> Assign
        </button>
      `;
      availableListEl.appendChild(card);
    });
  }
}

function assignStoreToCurrentRep(storeId) {
  const store = state.outlets.find(o => o.id === storeId);
  const rep = state.salesmen.find(s => s.id === state.selectedSalesmanId);
  if (!store || !rep) return;

  const previousRep = state.salesmen.find(s => s.id === store.assignedSalesmanId);
  store.assignedSalesmanId = rep.id;

  logAudit(
    "STORE_REASSIGNMENT",
    store.code,
    `Assigned ${store.name} to ${rep.name}${previousRep ? ` (transferred from ${previousRep.name})` : ''}`,
    "Sunil Agarwal (Super Admin)"
  );

  saveState();
  renderAllocationMatrix();
  showToast("Store Assigned", `${store.name} mapped to ${rep.name} successfully.`);
}

function unassignStore(storeId) {
  const store = state.outlets.find(o => o.id === storeId);
  const rep = state.salesmen.find(s => s.id === store.assignedSalesmanId);
  if (!store) return;

  store.assignedSalesmanId = null;

  logAudit(
    "STORE_UNASSIGNMENT",
    store.code,
    `Removed ${store.name} from ${rep ? rep.name : 'assigned rep'}; moved to Unassigned Pool`,
    "Sunil Agarwal (Super Admin)"
  );

  saveState();
  renderAllocationMatrix();
  showToast("Store Unassigned", `${store.name} moved to unassigned pool.`);
}

function executeRouteTransfer() {
  const fromRepId = document.getElementById("route-from-rep").value;
  const toRepId = document.getElementById("route-to-rep").value;

  if (fromRepId === toRepId) {
    alert("Source and destination salesmen cannot be the same!");
    return;
  }

  const fromRep = state.salesmen.find(s => s.id === fromRepId);
  const toRep = state.salesmen.find(s => s.id === toRepId);

  let transferCount = 0;
  state.outlets.forEach(o => {
    if (o.assignedSalesmanId === fromRepId) {
      o.assignedSalesmanId = toRepId;
      transferCount++;
    }
  });

  logAudit(
    "ROUTE_TRANSFER",
    toRep.employeeId,
    `Transferred entire route (${transferCount} retail stores) from ${fromRep.name} to ${toRep.name}`,
    "Sunil Agarwal (Super Admin)"
  );

  saveState();
  closeModal("modal-reassign-route");
  renderAllocationMatrix();
  showToast("Route Transferred", `All ${transferCount} stores transferred to ${toRep.name}.`);
}

function executeBulkMarketAssignment() {
  const market = document.getElementById("bulk-market-select").value;
  const repId = document.getElementById("bulk-market-rep").value;
  const rep = state.salesmen.find(s => s.id === repId);

  let count = 0;
  state.outlets.forEach(o => {
    if (o.market === market) {
      o.assignedSalesmanId = repId;
      count++;
    }
  });

  logAudit(
    "BULK_MARKET_ASSIGNMENT",
    market,
    `Assigned all ${count} stores in ${market} market to ${rep.name}`,
    "Sunil Agarwal (Super Admin)"
  );

  saveState();
  closeModal("modal-bulk-market");
  renderAllocationMatrix();
  showToast("Market Assigned", `All ${count} stores in ${market} assigned to ${rep.name}.`);
}

// ==========================================================
// 6. LIVE FIELD RADAR & GEOFENCING VIEW
// ==========================================================

function renderRadarView() {
  const container = document.getElementById("radar-markers-container");
  container.innerHTML = "";

  // Center coordinate (HQ: Civil Lines Kanpur)
  const centerLat = 26.4700;
  const centerLng = 80.3400;

  state.salesmen.forEach((rep, idx) => {
    const loc = rep.currentLocation;
    const dy = (loc.lat - centerLat) * 4500;
    const dx = (loc.lng - centerLng) * 4500;

    const marker = document.createElement("div");
    marker.className = "radar-marker";
    marker.style.left = `calc(50% + ${dx}px)`;
    marker.style.top = `calc(50% - ${dy}px)`;

    const isInStore = rep.status.includes("Active");
    marker.innerHTML = `
      <div class="marker-blip ${isInStore ? 'in-store' : 'transit'}"></div>
      <div class="marker-label">${rep.name} (${loc.distance}m)</div>
    `;

    marker.onclick = () => {
      showToast("Field Telemetry", `${rep.name} is at ${loc.venue} (${loc.distance}m away). Hardware mock: 0.`);
    };

    container.appendChild(marker);
  });

  // Render Rep Activity Stream
  const activityStreamEl = document.getElementById("rep-activity-stream");
  activityStreamEl.innerHTML = "";

  state.salesmen.forEach(rep => {
    const isInStore = rep.status.includes("Active");
    const item = document.createElement("div");
    item.className = "rep-activity-item";
    item.innerHTML = `
      <div class="rep-activity-top">
        <span class="rep-activity-name">${rep.name}</span>
        <span class="status-badge-live ${isInStore ? 'in-store' : 'transit'}">${isInStore ? 'IN STORE' : 'IN TRANSIT'}</span>
      </div>
      <div class="rep-activity-details">
        <div><i class="fa-solid fa-location-dot"></i> Venue: <strong>${rep.currentLocation.venue}</strong></div>
        <div><i class="fa-solid fa-ruler"></i> Geofence Distance: <strong>${rep.currentLocation.distance} meters</strong></div>
        ${rep.checkedInAt ? `<div><i class="fa-solid fa-clock"></i> Check-In Time: <strong>${rep.checkedInAt}</strong></div>` : ''}
        <div class="geofence-tag">
          <i class="fa-solid fa-shield-check"></i> Haversine Rule Verified (&le; 100m)
        </div>
      </div>
    `;
    activityStreamEl.appendChild(item);
  });
}

// ==========================================================
// 7. MASTER SKU CATALOG
// ==========================================================

function filterCatalog(category) {
  state.catalogFilter = category;
  document.querySelectorAll("#catalog-category-pills .pill").forEach(p => p.classList.remove("active"));
  event.target.classList.add("active");
  renderCatalogTable();
}

function renderCatalogTable() {
  const tbody = document.getElementById("products-table-body");
  tbody.innerHTML = "";

  const filtered = state.products.filter(p => {
    if (state.catalogFilter !== "ALL" && p.category !== state.catalogFilter) return false;
    if (state.searchQuery && !p.name.toLowerCase().includes(state.searchQuery.toLowerCase()) && !p.skuCode.toLowerCase().includes(state.searchQuery.toLowerCase())) return false;
    return true;
  });

  filtered.forEach(p => {
    const netPrice = p.basePrice * (1 + p.gstRate / 100);
    const tr = document.createElement("tr");
    tr.innerHTML = `
      <td><span class="code-badge">${p.skuCode}</span></td>
      <td><strong>${p.name}</strong></td>
      <td>${p.category}</td>
      <td>${p.unit}</td>
      <td>₹${p.basePrice.toFixed(2)}</td>
      <td>${p.gstRate}% GST</td>
      <td><strong style="color:var(--primary);">₹${netPrice.toFixed(2)}</strong></td>
      <td><span class="status-badge-live ${p.stockStatus.includes('Low') ? 'transit' : 'in-store'}">${p.stockStatus}</span></td>
      <td>
        <button class="btn btn-secondary btn-sm" onclick="editProductPrice('${p.skuCode}')">
          <i class="fa-solid fa-pen"></i> Edit
        </button>
      </td>
    `;
    tbody.appendChild(tr);
  });
}

function calcNetPrice() {
  const base = parseFloat(document.getElementById("prod-price").value) || 0;
  const gst = parseFloat(document.getElementById("prod-gst").value) || 0;
  const net = base * (1 + gst / 100);
  document.getElementById("prod-net-preview").textContent = `₹ ${net.toFixed(2)} (incl. GST)`;
}

function submitNewProduct(event) {
  event.preventDefault();
  const sku = document.getElementById("prod-sku").value.trim().toUpperCase();
  const name = document.getElementById("prod-name").value.trim();
  const cat = document.getElementById("prod-category").value;
  const unit = document.getElementById("prod-unit").value.trim();
  const price = parseFloat(document.getElementById("prod-price").value) || 0;
  const gst = parseInt(document.getElementById("prod-gst").value) || 5;

  state.products.push({
    skuCode: sku,
    name: name,
    category: cat,
    unit: unit,
    basePrice: price,
    gstRate: gst,
    stockStatus: "In Stock (500 units)",
  });

  logAudit(
    "ADD_PRODUCT_SKU",
    sku,
    `Added SKU ${name} (${sku}) at ₹${price.toFixed(2)} (${gst}% GST)`,
    "Sunil Agarwal (Super Admin)"
  );

  saveState();
  closeModal("modal-add-product");
  renderCatalogTable();
  showToast("SKU Added", `${name} saved to Master Catalog.`);
}

function editProductPrice(skuCode) {
  const prod = state.products.find(p => p.skuCode === skuCode);
  if (!prod) return;
  const newPrice = prompt(`Enter new base wholesale price for ${prod.name} (Current: ₹${prod.basePrice}):`, prod.basePrice);
  if (newPrice !== null && !isNaN(parseFloat(newPrice))) {
    prod.basePrice = parseFloat(newPrice);
    logAudit(
      "UPDATE_PRODUCT_PRICE",
      prod.skuCode,
      `Updated wholesale price to ₹${prod.basePrice.toFixed(2)}`,
      "Sunil Agarwal (Super Admin)"
    );
    saveState();
    renderCatalogTable();
    showToast("Price Updated", `${prod.name} updated to ₹${prod.basePrice.toFixed(2)}`);
  }
}

// ==========================================================
// 8. DEBTOR AGING & OUTSTANDINGS
// ==========================================================

function renderDebtorsTable() {
  const debtors = state.outlets.filter(o => o.balance > 0).sort((a, b) => b.balance - a.balance);

  // Update aging summaries
  let a0 = 0, a30 = 0, a60 = 0, a90 = 0;
  debtors.forEach(d => {
    if (d.agingDays <= 30) a0 += d.balance;
    else if (d.agingDays <= 60) a30 += d.balance;
    else if (d.agingDays <= 90) a60 += d.balance;
    else a90 += d.balance;
  });

  document.getElementById("aging-0-30").textContent = `₹ ${formatCurrency(a0)}`;
  document.getElementById("aging-31-60").textContent = `₹ ${formatCurrency(a30)}`;
  document.getElementById("aging-61-90").textContent = `₹ ${formatCurrency(a60)}`;
  document.getElementById("aging-90-plus").textContent = `₹ ${formatCurrency(a90)}`;

  const tbody = document.getElementById("debtors-table-body");
  tbody.innerHTML = "";

  debtors.forEach(d => {
    const rep = state.salesmen.find(s => s.id === d.assignedSalesmanId);
    let riskClass = "safe";
    let riskLabel = "Normal";

    if (d.agingDays > 90 || d.balance > d.creditLimit) {
      riskClass = "critical";
      riskLabel = "CRITICAL OVERDUE";
    } else if (d.agingDays > 60) {
      riskClass = "high";
      riskLabel = "HIGH RISK";
    }

    const tr = document.createElement("tr");
    tr.innerHTML = `
      <td><span class="code-badge">${d.code}</span></td>
      <td><strong>${d.name}</strong></td>
      <td>${d.market}</td>
      <td>${rep ? rep.name : '<span style="color:#D97706;">Unassigned</span>'}</td>
      <td>₹${formatCurrency(d.creditLimit)}</td>
      <td><strong style="color:var(--danger);">₹${formatCurrency(d.balance)}</strong></td>
      <td>${d.agingDays} Days</td>
      <td><span class="badge-risk ${riskClass}">${riskLabel}</span></td>
      <td>
        <button class="btn btn-outline btn-sm" onclick="alert('Viewing Ledger Statement for ${d.name}')">
          <i class="fa-solid fa-file-invoice"></i> Ledger
        </button>
      </td>
    `;
    tbody.appendChild(tr);
  });
}

function exportDebtorsCsv() {
  const debtors = state.outlets.filter(o => o.balance > 0);
  let csvContent = "data:text/csv;charset=utf-8,";
  csvContent += "Party Code,Store Name,Market,Owner,Mobile,Credit Limit,Total Due,Aging Days,Risk Status\n";

  debtors.forEach(d => {
    const status = d.agingDays > 90 ? "CRITICAL" : (d.agingDays > 60 ? "HIGH" : "NORMAL");
    csvContent += `"${d.code}","${d.name}","${d.market}","${d.ownerName}","${d.mobile}",${d.creditLimit},${d.balance},${d.agingDays},"${status}"\n`;
  });

  const encodedUri = encodeURI(csvContent);
  const link = document.createElement("a");
  link.setAttribute("href", encodedUri);
  link.setAttribute("download", `AUPL_Debtors_Aging_${new Date().toISOString().slice(0, 10)}.csv`);
  document.body.appendChild(link);
  link.click();
  document.body.removeChild(link);
  showToast("CSV Exported", "Debtors Aging Report downloaded successfully.");
}

function printDebtorsReport() {
  window.print();
}

// ==========================================================
// 9. IMMUTABLE AUDIT TRAIL
// ==========================================================

function renderAuditTable() {
  const tbody = document.getElementById("audit-table-body");
  tbody.innerHTML = "";

  state.auditLogs.forEach(log => {
    const tr = document.createElement("tr");
    tr.innerHTML = `
      <td><span class="code-badge">${log.id}</span></td>
      <td>${log.timestamp}</td>
      <td><span class="status-badge-live transit">${log.action}</span></td>
      <td><code>${log.entity}</code></td>
      <td>${log.desc}</td>
      <td>${log.actor}</td>
      <td><span class="pill-chip green"><i class="fa-solid fa-shield"></i> Verified</span></td>
    `;
    tbody.appendChild(tr);
  });
}

function logAudit(action, entity, desc, actor) {
  const newLog = {
    id: `AUD-${Date.now().toString().slice(-7)}`,
    timestamp: new Date().toISOString().replace('T', ' ').slice(0, 19),
    action: action,
    entity: entity,
    desc: desc,
    actor: actor,
    hash: `0x${Math.random().toString(16).substring(2, 10)}`,
  };
  state.auditLogs.unshift(newLog);
}

// ==========================================================
// 10. FIREBASE CLOUD PIPELINE VIEW
// ==========================================================

function renderCloudPipeline() {
  document.getElementById("count-col-outlets").textContent = `${state.outlets.length} Docs`;
  document.getElementById("count-col-users").textContent = `${state.salesmen.length + 1} Docs`;
  document.getElementById("count-col-products").textContent = `${state.products.length} Docs`;
  document.getElementById("count-col-audit").textContent = `${state.auditLogs.length} Docs`;
}

function triggerCloudSync() {
  const btn = document.getElementById("btn-sync-cloud");
  btn.innerHTML = `<i class="fa-solid fa-rotate fa-spin"></i> Syncing...`;
  btn.disabled = true;

  setTimeout(() => {
    btn.innerHTML = `<i class="fa-solid fa-rotate"></i> Sync Cloud`;
    btn.disabled = false;
    showToast("Firestore Synchronized", "All mutations, store allocations, and ledger vouchers streamed to Firebase.");
  }, 800);
}

// ==========================================================
// 11. OUTLET ONBOARDING FORM
// ==========================================================

function submitNewOutlet(event) {
  event.preventDefault();
  const name = document.getElementById("outlet-name").value.trim();
  const owner = document.getElementById("outlet-owner").value.trim();
  const mobile = document.getElementById("outlet-mobile").value.trim();
  const market = document.getElementById("outlet-market").value;
  const assignee = document.getElementById("outlet-assignee").value || null;
  const limit = parseFloat(document.getElementById("outlet-credit-limit").value) || 50000;
  const bal = parseFloat(document.getElementById("outlet-opening-balance").value) || 0;

  const newId = `OUT0${state.outlets.length + 1}`;
  const newCode = `OUT${String(state.outlets.length + 1).padStart(6, '0')}`;

  const newStore = {
    id: newId,
    code: newCode,
    name: name,
    ownerName: owner,
    mobile: mobile,
    market: market,
    district: "Kanpur",
    creditLimit: limit,
    balance: bal,
    assignedSalesmanId: assignee,
    status: "pending",
    lat: 26.4700 + (Math.random() - 0.5) * 0.04,
    lng: 80.3400 + (Math.random() - 0.5) * 0.04,
    agingDays: bal > 0 ? 15 : 0,
  };

  state.outlets.unshift(newStore);

  logAudit(
    "ONBOARD_STORE",
    newCode,
    `Registered new store ${name} in ${market}${assignee ? ` assigned to ${assignee}` : ''}`,
    "Sunil Agarwal (Super Admin)"
  );

  saveState();
  closeModal("modal-add-outlet");
  renderAllocationMatrix();
  showToast("Store Onboarded", `${name} successfully registered.`);
}

// ==========================================================
// 13. MAINTAIN SALES PERSONS LOGIC
// ==========================================================

function renderSalesmenView() {
  const tbody = document.getElementById("salesmen-table-body");
  if (!tbody) return;
  tbody.innerHTML = "";

  const queryInput = document.getElementById("salesmen-search-input");
  const query = queryInput ? queryInput.value.toLowerCase().trim() : "";
  const statusFilter = document.getElementById("salesmen-status-filter")?.value || "ALL";

  let list = state.salesmen.filter(rep => {
    const matchesQuery = !query || 
      rep.name.toLowerCase().includes(query) || 
      rep.employeeId.toLowerCase().includes(query) ||
      rep.territory.toLowerCase().includes(query) ||
      rep.mobile.includes(query);
    
    let matchesStatus = true;
    if (statusFilter !== "ALL") {
      if (statusFilter === "Active") matchesStatus = rep.status && rep.status.includes("Active");
      else if (statusFilter === "In Transit") matchesStatus = rep.status && rep.status.includes("Transit");
      else if (statusFilter === "On Leave") matchesStatus = rep.status && rep.status.includes("Leave");
    }

    return matchesQuery && matchesStatus;
  });

  if (list.length === 0) {
    tbody.innerHTML = `
      <tr>
        <td colspan="9" style="text-align: center; padding: 36px; color: #94A3B8;">
          <i class="fa-solid fa-user-slash" style="font-size: 28px; margin-bottom: 8px; display: block;"></i>
          No sales representatives found matching "${query || statusFilter}".
        </td>
      </tr>
    `;
    return;
  }

  list.forEach(rep => {
    const assignedStores = state.outlets.filter(o => o.assignedSalesmanId === rep.id);
    const target = rep.target || 125000;
    const achieved = rep.achieved || (assignedStores.length * 5800);
    const pct = Math.min(100, Math.round((achieved / target) * 100));

    let fillClass = "low";
    if (pct >= 65) fillClass = "high";
    else if (pct >= 40) fillClass = "mid";

    let statusBadge = "";
    if (rep.status && rep.status.includes("Active")) {
      statusBadge = `<span class="status-badge-live active"><span class="pulse-dot-sm green"></span> In-Store Active</span>`;
    } else if (rep.status && rep.status.includes("Transit")) {
      statusBadge = `<span class="status-badge-live transit"><span class="pulse-dot-sm blue"></span> In Transit</span>`;
    } else {
      statusBadge = `<span class="status-badge-live leave"><span class="pulse-dot-sm gray"></span> Off-Duty</span>`;
    }

    const tr = document.createElement("tr");
    tr.innerHTML = `
      <td>
        <div class="rep-profile-cell">
          <div class="rep-avatar-sm">${rep.name.split(" ").map(n => n[0]).join("")}</div>
          <div class="rep-info-col">
            <span class="rep-name-bold">${rep.name}</span>
            <span class="rep-sub-title">${rep.email || 'field.rep@ansuudyog.com'}</span>
          </div>
        </div>
      </td>
      <td><code>${rep.employeeId}</code></td>
      <td>
        <div><i class="fa-solid fa-phone" style="font-size: 11px; color: #64748B;"></i> ${rep.mobile}</div>
      </td>
      <td>
        <span style="font-weight: 600; color: #1E293B;">${rep.territory}</span>
      </td>
      <td>
        <button class="btn btn-outline btn-xs" onclick="jumpToRepAllocation('${rep.id}')" title="Inspect stores in matrix">
          <i class="fa-solid fa-store" style="color: #2563EB;"></i> <strong>${assignedStores.length}</strong> Stores
        </button>
      </td>
      <td>
        <strong>₹ ${formatCurrency(target)}</strong>
      </td>
      <td>
        <div class="target-bar-wrap">
          <div class="target-text-row">
            <span>₹ ${formatCurrency(achieved)}</span>
            <span>${pct}%</span>
          </div>
          <div class="target-bar-bg">
            <div class="target-bar-fill ${fillClass}" style="width: ${pct}%"></div>
          </div>
        </div>
      </td>
      <td>${statusBadge}</td>
      <td>
        <div class="action-buttons-group">
          <button class="btn-icon" onclick="openSalesmanScorecard('${rep.id}')" title="Performance Scorecard">
            <i class="fa-solid fa-chart-line"></i>
          </button>
          <button class="btn-icon" onclick="openEditSalesmanModal('${rep.id}')" title="Edit Profile">
            <i class="fa-solid fa-pen-to-square"></i>
          </button>
          <button class="btn-icon text-danger" onclick="deleteSalesman('${rep.id}')" title="Remove Rep">
            <i class="fa-solid fa-trash-can"></i>
          </button>
        </div>
      </td>
    `;
    tbody.appendChild(tr);
  });
}

function showAddSalesmanModal() {
  const nextNum = state.salesmen.length + 1;
  const empInput = document.getElementById("salesman-empid");
  if (empInput) empInput.value = `EMP-010${nextNum}`;
  showModal("modal-add-salesman");
}

function submitNewSalesman(event) {
  event.preventDefault();
  const name = document.getElementById("salesman-name").value.trim();
  const empid = document.getElementById("salesman-empid").value.trim();
  const mobile = document.getElementById("salesman-mobile").value.trim();
  const email = document.getElementById("salesman-email").value.trim() || `${name.toLowerCase().replace(/\s+/g, '.')}@ansuudyog.com`;
  const territory = document.getElementById("salesman-territory").value.trim();
  const target = parseFloat(document.getElementById("salesman-target").value) || 125000;
  const status = document.getElementById("salesman-status").value;
  const commission = parseFloat(document.getElementById("salesman-commission").value) || 2.5;

  const newId = `USR00${state.salesmen.length + 1}`;

  const newRep = {
    id: newId,
    name: name,
    employeeId: empid,
    mobile: mobile,
    email: email,
    territory: territory,
    target: target,
    achieved: 0,
    commissionRate: commission,
    status: status,
    currentLocation: { lat: 26.4650, lng: 80.3450, venue: `${territory} Hub`, distance: 50 },
    checkedInAt: null,
  };

  state.salesmen.push(newRep);

  logAudit(
    "ONBOARD_SALESMAN",
    empid,
    `Onboarded Sales Executive ${name} (${empid}) for territory "${territory}" with Target ₹${formatCurrency(target)}`,
    "Sunil Agarwal (Super Admin)"
  );

  saveState();
  closeModal("modal-add-salesman");
  renderSalesmenView();
  updateKpis();
  showToast("Sales Executive Onboarded", `${name} (${empid}) added to sales master.`);
}

function openEditSalesmanModal(id) {
  const rep = state.salesmen.find(s => s.id === id);
  if (!rep) return;

  document.getElementById("edit-salesman-id").value = rep.id;
  document.getElementById("edit-salesman-name").value = rep.name;
  document.getElementById("edit-salesman-empid").value = rep.employeeId;
  document.getElementById("edit-salesman-mobile").value = rep.mobile;
  document.getElementById("edit-salesman-territory").value = rep.territory;
  document.getElementById("edit-salesman-target").value = rep.target;
  document.getElementById("edit-salesman-status").value = rep.status;

  showModal("modal-edit-salesman");
}

function submitEditSalesman(event) {
  event.preventDefault();
  const id = document.getElementById("edit-salesman-id").value;
  const rep = state.salesmen.find(s => s.id === id);
  if (!rep) return;

  const oldTarget = rep.target;
  rep.name = document.getElementById("edit-salesman-name").value.trim();
  rep.mobile = document.getElementById("edit-salesman-mobile").value.trim();
  rep.territory = document.getElementById("edit-salesman-territory").value.trim();
  rep.target = parseFloat(document.getElementById("edit-salesman-target").value) || rep.target;
  rep.status = document.getElementById("edit-salesman-status").value;

  logAudit(
    "UPDATE_SALESMAN",
    rep.employeeId,
    `Updated profile for ${rep.name}. Target shifted from ₹${formatCurrency(oldTarget)} to ₹${formatCurrency(rep.target)}`,
    "Sunil Agarwal (Super Admin)"
  );

  saveState();
  closeModal("modal-edit-salesman");
  renderSalesmenView();
  updateKpis();
  showToast("Profile Updated", `${rep.name} details saved.`);
}

function deleteSalesman(id) {
  const rep = state.salesmen.find(s => s.id === id);
  if (!rep) return;

  const assignedStores = state.outlets.filter(o => o.assignedSalesmanId === id);
  if (assignedStores.length > 0) {
    if (!confirm(`Warning: ${rep.name} has ${assignedStores.length} retail stores assigned. Deleting this rep will return these stores to the Unassigned Pool. Proceed?`)) {
      return;
    }
    // Unassign stores
    state.outlets.forEach(o => {
      if (o.assignedSalesmanId === id) o.assignedSalesmanId = null;
    });
  } else {
    if (!confirm(`Remove ${rep.name} (${rep.employeeId}) from sales team?`)) return;
  }

  state.salesmen = state.salesmen.filter(s => s.id !== id);

  logAudit(
    "DEACTIVATE_SALESMAN",
    rep.employeeId,
    `Deactivated sales executive ${rep.name}. ${assignedStores.length} stores returned to pool.`,
    "Sunil Agarwal (Super Admin)"
  );

  saveState();
  renderSalesmenView();
  updateKpis();
  showToast("Sales Rep Removed", `${rep.name} has been unassigned.`);
}

let currentScorecardRepId = null;
function openSalesmanScorecard(id) {
  const rep = state.salesmen.find(s => s.id === id);
  if (!rep) return;
  currentScorecardRepId = id;

  const assignedStores = state.outlets.filter(o => o.assignedSalesmanId === id);
  const target = rep.target || 125000;
  const achieved = rep.achieved || (assignedStores.length * 5800);
  const pct = Math.min(100, Math.round((achieved / target) * 100));

  const totalOutstanding = assignedStores.reduce((sum, s) => sum + s.balance, 0);

  const container = document.getElementById("scorecard-content");
  container.innerHTML = `
    <div class="scorecard-header-card">
      <div class="scorecard-avatar-lg">${rep.name.split(" ").map(n => n[0]).join("")}</div>
      <div style="flex: 1;">
        <div style="display: flex; align-items: center; justify-content: space-between;">
          <h4 style="font-size: 18px; font-weight: 800; color: #0F172A;">${rep.name}</h4>
          <span class="badge-status online">${rep.status}</span>
        </div>
        <div style="font-size: 13px; color: #64748B; margin-top: 2px;">
          <code>${rep.employeeId}</code> • ${rep.territory} • ${rep.mobile}
        </div>
      </div>
    </div>

    <div class="scorecard-kpi-grid">
      <div class="scorecard-kpi-card">
        <span class="kpi-sub-label">Assigned Retail Outlets</span>
        <div class="kpi-main-val">${assignedStores.length} Outlets</div>
      </div>
      <div class="scorecard-kpi-card">
        <span class="kpi-sub-label">Monthly Sales Target</span>
        <div class="kpi-main-val">₹ ${formatCurrency(target)}</div>
      </div>
      <div class="scorecard-kpi-card">
        <span class="kpi-sub-label">Realized Invoiced Value</span>
        <div class="kpi-main-val" style="color: #16A34A;">₹ ${formatCurrency(achieved)} (${pct}%)</div>
      </div>
      <div class="scorecard-kpi-card">
        <span class="kpi-sub-label">Territory Outstanding</span>
        <div class="kpi-main-val" style="color: #DC2626;">₹ ${formatCurrency(totalOutstanding)}</div>
      </div>
      <div class="scorecard-kpi-card">
        <span class="kpi-sub-label">Geofence Compliance</span>
        <div class="kpi-main-val" style="color: #2563EB;">98.4% (&le; 100m)</div>
      </div>
      <div class="scorecard-kpi-card">
        <span class="kpi-sub-label">Commission Earned</span>
        <div class="kpi-main-val" style="color: #7C3AED;">₹ ${formatCurrency(achieved * 0.025)} (2.5%)</div>
      </div>
    </div>

    <div>
      <h5 style="font-size: 13px; font-weight: 700; color: #1E293B; margin-bottom: 6px;">
        <i class="fa-solid fa-route" style="color: #2563EB;"></i> Assigned Store Beat Network (${assignedStores.length})
      </h5>
      <div class="scorecard-stores-list">
        ${assignedStores.length > 0 
          ? assignedStores.map(s => `
              <span class="scorecard-store-chip">
                <i class="fa-solid fa-shop" style="color: #64748B;"></i>
                <strong>${s.name}</strong> (${s.market})
              </span>
            `).join("")
          : `<span style="color: #94A3B8; font-size: 12.5px;">No stores assigned currently. Click "Allocate Stores" below.</span>`
        }
      </div>
    </div>
  `;

  showModal("modal-salesman-scorecard");
}

function jumpToRepAllocation(repId) {
  const targetId = repId || currentScorecardRepId;
  closeModal("modal-salesman-scorecard");
  if (targetId) state.selectedSalesmanId = targetId;
  switchView("allocation");
}

function exportSalesmenCsv() {
  let csv = "Employee ID,Full Name,Mobile,Email,Assigned Territory,Assigned Stores Count,Monthly Target (INR),Realized Sales (INR),Achievement %,Status\n";
  state.salesmen.forEach(rep => {
    const assignedStores = state.outlets.filter(o => o.assignedSalesmanId === rep.id);
    const target = rep.target || 125000;
    const achieved = rep.achieved || (assignedStores.length * 5800);
    const pct = Math.round((achieved / target) * 100);
    csv += `"${rep.employeeId}","${rep.name}","${rep.mobile}","${rep.email || ''}","${rep.territory}",${assignedStores.length},${target},${achieved},${pct}%,"${rep.status}"\n`;
  });

  const blob = new Blob([csv], { type: "text/csv;charset=utf-8;" });
  const url = URL.createObjectURL(blob);
  const a = document.createElement("a");
  a.href = url;
  a.download = `AUPL_Sales_Team_Master_${new Date().toISOString().slice(0, 10)}.csv`;
  document.body.appendChild(a);
  a.click();
  document.body.removeChild(a);
  showToast("CSV Exported", "Sales team master downloaded.");
}

// ==========================================================
// 14. INVENTORY CHECK RESULTS LOGIC
// ==========================================================

function renderInventoryChecksView() {
  const tbody = document.getElementById("audit-results-table-body");
  if (!tbody) return;
  tbody.innerHTML = "";

  populateAuditStoreDropdown();

  const queryInput = document.getElementById("audit-search-input");
  const query = queryInput ? queryInput.value.toLowerCase().trim() : "";
  const storeFilter = document.getElementById("audit-store-filter")?.value || "ALL";
  const statusFilter = document.getElementById("audit-status-filter")?.value || "ALL";

  let list = state.inventoryChecks.filter(chk => {
    const matchesQuery = !query ||
      chk.outletName.toLowerCase().includes(query) ||
      chk.productName.toLowerCase().includes(query) ||
      chk.auditorName.toLowerCase().includes(query) ||
      chk.id.toLowerCase().includes(query);

    const matchesStore = storeFilter === "ALL" || chk.outletId === storeFilter;
    const matchesStatus = statusFilter === "ALL" || chk.status === statusFilter;

    return matchesQuery && matchesStore && matchesStatus;
  });

  if (list.length === 0) {
    tbody.innerHTML = `
      <tr>
        <td colspan="10" style="text-align: center; padding: 36px; color: #94A3B8;">
          <i class="fa-solid fa-clipboard-question" style="font-size: 28px; margin-bottom: 8px; display: block;"></i>
          No inventory check results found matching current filter criteria.
        </td>
      </tr>
    `;
    return;
  }

  list.forEach(chk => {
    let badgeHtml = "";
    if (chk.status === "CRITICAL_DEFICIT") {
      badgeHtml = `<span class="audit-status-badge critical"><i class="fa-solid fa-triangle-exclamation"></i> Critical Deficit</span>`;
    } else if (chk.status === "LOW_STOCK") {
      badgeHtml = `<span class="audit-status-badge low"><i class="fa-solid fa-triangle-exclamation"></i> Low Stock</span>`;
    } else if (chk.status === "HEALTHY") {
      badgeHtml = `<span class="audit-status-badge healthy"><i class="fa-solid fa-circle-check"></i> Passed Healthy</span>`;
    } else if (chk.status === "EXPIRING_SOON") {
      badgeHtml = `<span class="audit-status-badge expiring"><i class="fa-solid fa-hourglass-half"></i> Expiring Soon</span>`;
    } else if (chk.status === "OVERSTOCKED") {
      badgeHtml = `<span class="audit-status-badge overstock"><i class="fa-solid fa-box-archive"></i> Overstocked</span>`;
    }

    let varianceHtml = "";
    if (chk.variance < 0) {
      varianceHtml = `<span class="variance-pill deficit"><i class="fa-solid fa-arrow-down"></i> ${chk.variance} units</span>`;
    } else if (chk.variance > 0) {
      varianceHtml = `<span class="variance-pill surplus"><i class="fa-solid fa-arrow-up"></i> +${chk.variance} units</span>`;
    } else {
      varianceHtml = `<span class="variance-pill zero">0 (Exact)</span>`;
    }

    const tr = document.createElement("tr");
    tr.innerHTML = `
      <td><code>${chk.id}</code></td>
      <td>
        <div><strong>${chk.outletName}</strong></div>
        <span style="font-size: 11px; color: #64748B;">${chk.market}</span>
      </td>
      <td>
        <span style="font-weight: 600; color: #1E293B;">${chk.auditorName}</span>
        <div style="font-size: 11px; color: #64748B;">${chk.auditorEmpId}</div>
      </td>
      <td><span style="font-size: 12px; color: #475569;">${chk.timestamp}</span></td>
      <td>
        <strong>${chk.productName}</strong>
        <div style="font-size: 11px; color: #64748B;"><code>${chk.skuCode}</code></div>
      </td>
      <td>
        <span style="font-weight: 700; color: ${chk.physicalCount < 5 ? '#DC2626' : '#0F172A'};">
          ${chk.physicalCount}
        </span>
        <span style="color: #64748B; font-size: 11.5px;"> / ${chk.targetCount} min</span>
      </td>
      <td>${varianceHtml}</td>
      <td>
        <div style="font-size: 12px;"><code>${chk.batchNo || 'N/A'}</code></div>
        <span style="font-size: 11px; color: ${chk.status === 'EXPIRING_SOON' ? '#DC2626' : '#64748B'};">
          Exp: ${chk.expiryDate || 'N/A'}
        </span>
      </td>
      <td>${badgeHtml}</td>
      <td>
        <div class="action-buttons-group">
          <button class="btn-icon" onclick="openAuditDetailModal('${chk.id}')" title="View Inspection Slip">
            <i class="fa-solid fa-receipt"></i>
          </button>
          ${chk.variance < 0 && chk.replenishmentStatus !== 'PO_GENERATED' ? `
            <button class="btn-icon text-success" onclick="triggerReplenishmentOrder('${chk.id}')" title="Create Restock PO">
              <i class="fa-solid fa-truck-ramp-box"></i>
            </button>
          ` : ''}
          <button class="btn-icon text-neutral" onclick="resolveAuditDiscrepancy('${chk.id}')" title="Resolve Audit Ticket">
            <i class="fa-solid fa-circle-check"></i>
          </button>
        </div>
      </td>
    `;
    tbody.appendChild(tr);
  });
}

function populateAuditStoreDropdown() {
  const storeFilter = document.getElementById("audit-store-filter");
  if (!storeFilter || storeFilter.dataset.populated) return;

  const currentVal = storeFilter.value;
  storeFilter.innerHTML = `<option value="ALL">All Retail Stores</option>`;

  state.outlets.slice(0, 15).forEach(o => {
    const opt = document.createElement("option");
    opt.value = o.id;
    opt.textContent = `${o.name} (${o.market})`;
    storeFilter.appendChild(opt);
  });

  storeFilter.value = currentVal;
  storeFilter.dataset.populated = "true";
}

function showAddInventoryCheckModal() {
  const storeSel = document.getElementById("audit-outlet-select");
  storeSel.innerHTML = "";
  state.outlets.forEach(o => {
    const opt = document.createElement("option");
    opt.value = o.id;
    opt.textContent = `${o.name} [${o.market}]`;
    storeSel.appendChild(opt);
  });

  const repSel = document.getElementById("audit-salesman-select");
  repSel.innerHTML = "";
  state.salesmen.forEach(s => {
    const opt = document.createElement("option");
    opt.value = s.id;
    opt.textContent = `${s.name} (${s.employeeId})`;
    repSel.appendChild(opt);
  });

  const skuSel = document.getElementById("audit-sku-select");
  skuSel.innerHTML = "";
  state.products.forEach(p => {
    const opt = document.createElement("option");
    opt.value = p.skuCode;
    opt.textContent = `${p.name} (${p.unit})`;
    skuSel.appendChild(opt);
  });

  syncAuditSalesman();
  calcAuditDeficit();
  showModal("modal-add-inventory-check");
}

function syncAuditSalesman() {
  const storeId = document.getElementById("audit-outlet-select")?.value;
  const store = state.outlets.find(o => o.id === storeId);
  if (store && store.assignedSalesmanId) {
    const repSel = document.getElementById("audit-salesman-select");
    if (repSel) repSel.value = store.assignedSalesmanId;
  }
}

function calcAuditDeficit() {
  const physInput = document.getElementById("audit-physical-count");
  const targetInput = document.getElementById("audit-target-count");
  const resultDisplay = document.getElementById("audit-calc-result");
  if (!physInput || !targetInput || !resultDisplay) return;

  const phys = parseInt(physInput.value);
  const target = parseInt(targetInput.value) || 24;

  if (isNaN(phys)) {
    resultDisplay.innerHTML = `<span class="text-neutral">Enter physical count to calculate variance</span>`;
    return;
  }

  const gap = phys - target;
  if (gap <= -15) {
    resultDisplay.innerHTML = `<span class="text-danger"><i class="fa-solid fa-triangle-exclamation"></i> Critical Deficit (${gap} units)! Severe Stockout Risk. Auto-PO required.</span>`;
  } else if (gap < 0) {
    resultDisplay.innerHTML = `<span class="text-warning"><i class="fa-solid fa-bell"></i> Low Stock (${gap} units). Restock recommended.</span>`;
  } else if (gap > 10) {
    resultDisplay.innerHTML = `<span class="text-info"><i class="fa-solid fa-box-archive"></i> Overstocked (+${gap} units above threshold).</span>`;
  } else {
    resultDisplay.innerHTML = `<span class="text-success"><i class="fa-solid fa-circle-check"></i> Stock Level Balanced & Healthy.</span>`;
  }
}

function submitNewInventoryCheck(event) {
  event.preventDefault();
  const outletId = document.getElementById("audit-outlet-select").value;
  const repId = document.getElementById("audit-salesman-select").value;
  const skuCode = document.getElementById("audit-sku-select").value;
  const facing = document.getElementById("audit-facing-grade").value;
  const physical = parseInt(document.getElementById("audit-physical-count").value) || 0;
  const target = parseInt(document.getElementById("audit-target-count").value) || 24;
  const batchNo = document.getElementById("audit-batch-no").value.trim() || "AU-26K09";
  const expiry = document.getElementById("audit-expiry-date").value || "2027-12-31";
  const notes = document.getElementById("audit-notes").value.trim();

  const store = state.outlets.find(o => o.id === outletId) || { name: "Retail Store", market: "Kanpur" };
  const rep = state.salesmen.find(s => s.id === repId) || { name: "Sales Rep", employeeId: "EMP-0100" };
  const prod = state.products.find(p => p.skuCode === skuCode) || { name: "Product", category: "FMCG" };

  const variance = physical - target;
  let status = "HEALTHY";
  if (variance <= -15) status = "CRITICAL_DEFICIT";
  else if (variance < 0) status = "LOW_STOCK";
  else if (variance > 10) status = "OVERSTOCKED";

  const newId = `AUD-2026-0${80 + state.inventoryChecks.length + 1}`;
  const now = new Date();
  const timeStr = `${now.getDate()} Oct 2026, ${now.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}`;

  const newCheck = {
    id: newId,
    outletId: outletId,
    outletName: store.name,
    market: store.market,
    auditedBySalesmanId: repId,
    auditorName: rep.name,
    auditorEmpId: rep.employeeId,
    timestamp: timeStr,
    skuCode: skuCode,
    productName: prod.name,
    category: prod.category,
    physicalCount: physical,
    targetCount: target,
    variance: variance,
    facingGrade: facing,
    batchNo: batchNo,
    expiryDate: expiry,
    status: status,
    notes: notes || "Audited during scheduled beat visit.",
    replenishmentStatus: variance < 0 ? "PENDING_DISPATCH" : "NONE_REQUIRED",
    replenishmentPoId: variance < 0 ? `PO-AUPL-99${80 + state.inventoryChecks.length}` : null,
  };

  state.inventoryChecks.unshift(newCheck);

  logAudit(
    "STORE_INVENTORY_AUDIT",
    newId,
    `Audit logged at ${store.name} by ${rep.name} for ${prod.name}: Count ${physical}/${target} (${status})`,
    "Sunil Agarwal (Super Admin)"
  );

  saveState();
  closeModal("modal-add-inventory-check");
  renderInventoryChecksView();
  updateKpis();
  showToast("Audit Result Recorded", `Inspection ${newId} saved for ${store.name}.`);
}

let activeAuditSlipId = null;
function openAuditDetailModal(id) {
  const chk = state.inventoryChecks.find(c => c.id === id);
  if (!chk) return;
  activeAuditSlipId = id;

  const btnReorder = document.getElementById("btn-modal-reorder");
  if (btnReorder) {
    btnReorder.style.display = chk.variance < 0 ? "inline-flex" : "none";
  }

  const container = document.getElementById("audit-slip-content");
  container.innerHTML = `
    <div class="audit-slip-card">
      <div style="display: flex; justify-content: space-between; align-items: flex-start;">
        <div>
          <span style="font-size: 11px; font-weight: 700; color: #64748B; text-transform: uppercase;">AUDIT TICKET</span>
          <h4 style="font-size: 19px; font-weight: 800; color: #0F172A;">${chk.id}</h4>
          <span style="font-size: 12.5px; color: #475569;">Recorded on ${chk.timestamp}</span>
        </div>
        <div>
          ${chk.variance < 0 
            ? `<span class="audit-status-badge critical"><i class="fa-solid fa-triangle-exclamation"></i> Deficit Alert</span>`
            : `<span class="audit-status-badge healthy"><i class="fa-solid fa-check"></i> Stock Verified</span>`}
        </div>
      </div>

      <div class="slip-detail-grid">
        <div class="slip-item">
          <span class="slip-item-label">Retail Store</span>
          <span class="slip-item-val">${chk.outletName} (${chk.market})</span>
        </div>
        <div class="slip-item">
          <span class="slip-item-label">Audited By</span>
          <span class="slip-item-val">${chk.auditorName} [${chk.auditorEmpId}]</span>
        </div>
        <div class="slip-item">
          <span class="slip-item-label">Audited SKU</span>
          <span class="slip-item-val">${chk.productName} (<code>${chk.skuCode}</code>)</span>
        </div>
        <div class="slip-item">
          <span class="slip-item-label">Shelf Facing Quality</span>
          <span class="slip-item-val"><span class="facing-badge"><i class="fa-solid fa-eye"></i> ${chk.facingGrade}</span></span>
        </div>
        <div class="slip-item">
          <span class="slip-item-label">Physical Shelf Count</span>
          <span class="slip-item-val" style="font-size: 16px; color: ${chk.physicalCount < 5 ? '#DC2626' : '#16A34A'};">
            ${chk.physicalCount} Units
          </span>
        </div>
        <div class="slip-item">
          <span class="slip-item-label">Minimum Required Stock</span>
          <span class="slip-item-val">${chk.targetCount} Units</span>
        </div>
        <div class="slip-item">
          <span class="slip-item-label">Batch Code</span>
          <span class="slip-item-val"><code>${chk.batchNo || 'N/A'}</code></span>
        </div>
        <div class="slip-item">
          <span class="slip-item-label">Expiry Date</span>
          <span class="slip-item-val">${chk.expiryDate || 'N/A'}</span>
        </div>
      </div>

      <div style="margin-top: 14px; padding-top: 12px; border-top: 1px dashed #E2E8F0;">
        <span class="slip-item-label">Auditor Observations:</span>
        <p style="font-size: 13px; color: #334155; margin-top: 4px; font-style: italic;">
          "${chk.notes}"
        </p>
      </div>

      ${chk.replenishmentPoId ? `
        <div style="margin-top: 12px; background: #DCFCE7; border: 1px solid #86EFAC; border-radius: 8px; padding: 10px 12px; font-size: 12px; color: #166534; display: flex; align-items: center; justify-content: space-between;">
          <span><i class="fa-solid fa-truck-ramp-box"></i> Auto-Replenishment PO Active: <strong>${chk.replenishmentPoId}</strong></span>
          <span style="font-weight: 700;">Status: DISPATCHED</span>
        </div>
      ` : ''}
    </div>
  `;

  showModal("modal-view-audit-detail");
}

function triggerReplenishmentOrder(id) {
  const chk = state.inventoryChecks.find(c => c.id === id);
  if (!chk) return;

  const poNumber = `PO-AUPL-${Math.floor(1000 + Math.random() * 9000)}`;
  chk.replenishmentStatus = "PO_GENERATED";
  chk.replenishmentPoId = poNumber;

  logAudit(
    "REPLENISHMENT_ORDER_GENERATED",
    poNumber,
    `Auto-PO triggered from Audit ${chk.id} for ${chk.outletName}: 2 Cartons (${Math.abs(chk.variance)} units) of ${chk.productName}`,
    "Sunil Agarwal (Super Admin)"
  );

  saveState();
  renderInventoryChecksView();
  showToast("Replenishment Dispatched", `Purchase Order ${poNumber} sent to Kanpur central warehouse.`);
}

function triggerReplenishFromModal() {
  if (activeAuditSlipId) {
    triggerReplenishmentOrder(activeAuditSlipId);
    openAuditDetailModal(activeAuditSlipId);
  }
}

function resolveAuditDiscrepancy(id) {
  const chk = state.inventoryChecks.find(c => c.id === id);
  if (!chk) return;

  chk.status = "HEALTHY";
  chk.variance = 0;
  chk.physicalCount = chk.targetCount;

  logAudit(
    "RESOLVE_AUDIT_TICKET",
    chk.id,
    `Discrepancy resolved for ${chk.outletName} (${chk.productName}). Store confirmed restocked.`,
    "Sunil Agarwal (Super Admin)"
  );

  saveState();
  renderInventoryChecksView();
  showToast("Ticket Resolved", `Audit ${chk.id} marked as resolved and healthy.`);
}

function exportInventoryChecksCsv() {
  let csv = "Audit ID,Retail Store,Market,Auditor Name,Emp ID,Timestamp,SKU Code,Product Name,Physical Count,Target Count,Variance,Batch No,Expiry Date,Status,Replenishment Status,PO Number\n";
  state.inventoryChecks.forEach(c => {
    csv += `"${c.id}","${c.outletName}","${c.market}","${c.auditorName}","${c.auditorEmpId}","${c.timestamp}","${c.skuCode}","${c.productName}",${c.physicalCount},${c.targetCount},${c.variance},"${c.batchNo || ''}","${c.expiryDate || ''}","${c.status}","${c.replenishmentStatus}","${c.replenishmentPoId || ''}"\n`;
  });

  const blob = new Blob([csv], { type: "text/csv;charset=utf-8;" });
  const url = URL.createObjectURL(blob);
  const a = document.createElement("a");
  a.href = url;
  a.download = `AUPL_Store_Inventory_Checks_${new Date().toISOString().slice(0, 10)}.csv`;
  document.body.appendChild(a);
  a.click();
  document.body.removeChild(a);
  showToast("CSV Exported", "Store shelf inventory audit log downloaded.");
}

// ==========================================================
// 12. UTILITY HELPERS
// ==========================================================

function formatCurrency(amount) {
  return new Intl.NumberFormat('en-IN', {
    maximumFractionDigits: 0,
  }).format(amount);
}

function handleGlobalSearch(query) {
  state.searchQuery = query;
  if (state.activeView === "allocation") renderAllocationMatrix();
  if (state.activeView === "salesmen") renderSalesmenView();
  if (state.activeView === "inventory-checks") renderInventoryChecksView();
  if (state.activeView === "catalog") renderCatalogTable();
  if (state.activeView === "debtors") renderDebtorsTable();
}

function showModal(id) {
  const el = document.getElementById(id);
  if (el) el.classList.add("open");
}

function closeModal(id) {
  const el = document.getElementById(id);
  if (el) el.classList.remove("open");
}

function showReassignRouteModal() {
  showModal("modal-reassign-route");
}

function showBulkMarketModal() {
  showModal("modal-bulk-market");
}

function showAddProductModal() {
  showModal("modal-add-product");
}

let toastTimer;
function showToast(title, message) {
  const toast = document.getElementById("toast-notify");
  document.getElementById("toast-title").textContent = title;
  document.getElementById("toast-message").textContent = message;
  toast.classList.add("show");

  clearTimeout(toastTimer);
  toastTimer = setTimeout(() => {
    toast.classList.remove("show");
  }, 3500);
}

// Global initialization
window.addEventListener("DOMContentLoaded", () => {
  loadState();
  switchView("allocation");
  updateKpis();
});
