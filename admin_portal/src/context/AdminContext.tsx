'use client';

import React, { createContext, useContext, useState, useEffect } from 'react';
import { ViewType, Salesman, Outlet, Product, InventoryCheck, AuditLog } from '@/types';
import { INITIAL_SALESMEN, INITIAL_OUTLETS, INITIAL_PRODUCTS, INITIAL_INVENTORY_CHECKS, INITIAL_AUDIT_LOGS } from '@/lib/mockData';
import { formatCurrency } from '@/lib/utils';

interface ToastData {
  title: string;
  message: string;
  visible: boolean;
}

interface AdminContextType {
  activeView: ViewType;
  setActiveView: (view: ViewType) => void;
  selectedSalesmanId: string;
  setSelectedSalesmanId: (id: string) => void;
  globalSearch: string;
  setGlobalSearch: (query: string) => void;
  salesmen: Salesman[];
  outlets: Outlet[];
  products: Product[];
  inventoryChecks: InventoryCheck[];
  auditLogs: AuditLog[];
  
  // Modals management
  activeModal: string | null;
  modalPayload: any;
  openModal: (modalId: string, payload?: any) => void;
  closeModal: () => void;
  
  // Toast
  toast: ToastData;
  showToast: (title: string, message: string) => void;
  
  // Mutations
  addSalesman: (data: Partial<Salesman>) => void;
  updateSalesman: (id: string, data: Partial<Salesman>) => void;
  deleteSalesman: (id: string) => void;
  addOutlet: (data: Partial<Outlet>) => void;
  assignStore: (outletId: string, salesmanId: string | null) => void;
  reassignEntireRoute: (fromRepId: string, toRepId: string) => void;
  bulkAssignMarket: (market: string, toRepId: string) => void;
  addProduct: (product: Product) => void;
  addInventoryCheck: (data: any) => void;
  triggerReplenishmentOrder: (checkId: string) => void;
  resolveAuditDiscrepancy: (checkId: string) => void;
  logAudit: (action: string, entity: string, desc: string, actor?: string) => void;
}

const AdminContext = createContext<AdminContextType | undefined>(undefined);

const STORAGE_KEY = 'AUPL_ADMIN_NEXT_V1';

export function AdminProvider({ children }: { children: React.ReactNode }) {
  const [activeView, setActiveView] = useState<ViewType>('allocation');
  const [selectedSalesmanId, setSelectedSalesmanId] = useState<string>('USR001');
  const [globalSearch, setGlobalSearch] = useState<string>('');
  
  const [salesmen, setSalesmen] = useState<Salesman[]>(INITIAL_SALESMEN);
  const [outlets, setOutlets] = useState<Outlet[]>(INITIAL_OUTLETS);
  const [products, setProducts] = useState<Product[]>(INITIAL_PRODUCTS);
  const [inventoryChecks, setInventoryChecks] = useState<InventoryCheck[]>(INITIAL_INVENTORY_CHECKS);
  const [auditLogs, setAuditLogs] = useState<AuditLog[]>(INITIAL_AUDIT_LOGS);

  const [activeModal, setActiveModal] = useState<string | null>(null);
  const [modalPayload, setModalPayload] = useState<any>(null);

  const [toast, setToast] = useState<ToastData>({ title: '', message: '', visible: false });

  // Load from local storage
  useEffect(() => {
    try {
      const saved = localStorage.getItem(STORAGE_KEY);
      if (saved) {
        const parsed = JSON.parse(saved);
        if (parsed.salesmen) setSalesmen(parsed.salesmen);
        if (parsed.outlets) setOutlets(parsed.outlets);
        if (parsed.products) setProducts(parsed.products);
        if (parsed.inventoryChecks) setInventoryChecks(parsed.inventoryChecks);
        if (parsed.auditLogs) setAuditLogs(parsed.auditLogs);
      }
    } catch (_) {
      // Ignore parse error
    }
  }, []);

  // Sync to local storage
  const syncState = (
    newSalesmen = salesmen,
    newOutlets = outlets,
    newProducts = products,
    newChecks = inventoryChecks,
    newLogs = auditLogs
  ) => {
    try {
      localStorage.setItem(STORAGE_KEY, JSON.stringify({
        salesmen: newSalesmen,
        outlets: newOutlets,
        products: newProducts,
        inventoryChecks: newChecks,
        auditLogs: newLogs,
      }));
    } catch (_) {}
  };

  const showToast = (title: string, message: string) => {
    setToast({ title, message, visible: true });
    setTimeout(() => {
      setToast(prev => ({ ...prev, visible: false }));
    }, 3500);
  };

  const openModal = (modalId: string, payload: any = null) => {
    setActiveModal(modalId);
    setModalPayload(payload);
  };

  const closeModal = () => {
    setActiveModal(null);
    setModalPayload(null);
  };

  const logAudit = (action: string, entity: string, desc: string, actor = 'Sunil Agarwal (Super Admin)') => {
    const now = new Date();
    const dateStr = now.toISOString().replace('T', ' ').slice(0, 19);
    const hash = `0x${Math.random().toString(16).substring(2, 7)}...${Math.random().toString(16).substring(2, 5)}`;
    const newLog: AuditLog = {
      id: `AUD-${Date.now().toString().slice(-7)}`,
      timestamp: dateStr,
      action,
      entity,
      desc,
      actor,
      hash,
    };
    const updated = [newLog, ...auditLogs];
    setAuditLogs(updated);
    syncState(salesmen, outlets, products, inventoryChecks, updated);
  };

  // Salesmen operations
  const addSalesman = (data: Partial<Salesman>) => {
    const newId = `USR00${salesmen.length + 1}`;
    const newRep: Salesman = {
      id: newId,
      name: data.name || 'Sales Executive',
      employeeId: data.employeeId || `EMP-010${salesmen.length + 1}`,
      mobile: data.mobile || '+91 98390 00000',
      email: data.email || `${(data.name || 'rep').toLowerCase().replace(/\s+/g, '.')}@ansuudyog.com`,
      territory: data.territory || 'Kanpur East',
      target: data.target || 125000,
      achieved: 0,
      commissionRate: data.commissionRate || 2.5,
      status: data.status || 'Active (In Store)',
      currentLocation: { lat: 26.465, lng: 80.345, venue: `${data.territory || 'Kanpur'} Hub`, distance: 50 },
      checkedInAt: null,
    };

    const updated = [...salesmen, newRep];
    setSalesmen(updated);
    logAudit('ONBOARD_SALESMAN', newRep.employeeId, `Onboarded Sales Executive ${newRep.name} (${newRep.employeeId}) for territory "${newRep.territory}" with Target ₹${formatCurrency(newRep.target)}`);
    syncState(updated, outlets, products, inventoryChecks, auditLogs);
    closeModal();
    showToast('Sales Executive Onboarded', `${newRep.name} added to sales master.`);
  };

  const updateSalesman = (id: string, data: Partial<Salesman>) => {
    const target = salesmen.find(s => s.id === id);
    if (!target) return;
    const oldTarget = target.target;

    const updated = salesmen.map(s => (s.id === id ? { ...s, ...data } : s));
    setSalesmen(updated);
    logAudit('UPDATE_SALESMAN', target.employeeId, `Updated profile for ${target.name}. Target shifted from ₹${formatCurrency(oldTarget)} to ₹${formatCurrency(data.target || oldTarget)}`);
    syncState(updated, outlets, products, inventoryChecks, auditLogs);
    closeModal();
    showToast('Profile Updated', `${target.name} details saved.`);
  };

  const deleteSalesman = (id: string) => {
    const target = salesmen.find(s => s.id === id);
    if (!target) return;

    const assignedStores = outlets.filter(o => o.assignedSalesmanId === id);
    let updatedOutlets = outlets;
    if (assignedStores.length > 0) {
      updatedOutlets = outlets.map(o => (o.assignedSalesmanId === id ? { ...o, assignedSalesmanId: null } : o));
      setOutlets(updatedOutlets);
    }

    const updatedSalesmen = salesmen.filter(s => s.id !== id);
    setSalesmen(updatedSalesmen);
    logAudit('DEACTIVATE_SALESMAN', target.employeeId, `Deactivated sales executive ${target.name}. ${assignedStores.length} stores returned to unassigned pool.`);
    syncState(updatedSalesmen, updatedOutlets, products, inventoryChecks, auditLogs);
    showToast('Sales Rep Removed', `${target.name} has been removed.`);
  };

  // Outlet assignment
  const assignStore = (outletId: string, salesmanId: string | null) => {
    const store = outlets.find(o => o.id === outletId);
    if (!store) return;
    const rep = salesmen.find(s => s.id === salesmanId);

    const updated = outlets.map(o => (o.id === outletId ? { ...o, assignedSalesmanId: salesmanId } : o));
    setOutlets(updated);
    logAudit(
      'STORE_ASSIGNMENT',
      store.code,
      salesmanId
        ? `Assigned store "${store.name}" to salesman ${rep?.name || salesmanId}`
        : `Unassigned store "${store.name}" (returned to pool)`
    );
    syncState(salesmen, updated, products, inventoryChecks, auditLogs);
    showToast('Store Allocation Updated', salesmanId ? `Assigned to ${rep?.name}` : 'Returned to Available Pool');
  };

  const reassignEntireRoute = (fromRepId: string, toRepId: string) => {
    const fromRep = salesmen.find(s => s.id === fromRepId);
    const toRep = salesmen.find(s => s.id === toRepId);
    if (!fromRep || !toRep) return;

    const count = outlets.filter(o => o.assignedSalesmanId === fromRepId).length;
    const updated = outlets.map(o => (o.assignedSalesmanId === fromRepId ? { ...o, assignedSalesmanId: toRepId } : o));
    setOutlets(updated);
    logAudit('ROUTE_BATCH_TRANSFER', `${fromRep.employeeId}->${toRep.employeeId}`, `Atomic transfer of all ${count} stores from ${fromRep.name} to ${toRep.name}`);
    syncState(salesmen, updated, products, inventoryChecks, auditLogs);
    closeModal();
    showToast('Route Transferred', `Transferred ${count} stores to ${toRep.name}.`);
  };

  const bulkAssignMarket = (market: string, toRepId: string) => {
    const rep = salesmen.find(s => s.id === toRepId);
    if (!rep) return;

    let count = 0;
    const updated = outlets.map(o => {
      if (o.market === market) {
        count++;
        return { ...o, assignedSalesmanId: toRepId };
      }
      return o;
    });

    setOutlets(updated);
    logAudit('BULK_MARKET_ASSIGN', market, `Assigned all ${count} outlets in "${market}" market area to ${rep.name}`);
    syncState(salesmen, updated, products, inventoryChecks, auditLogs);
    closeModal();
    showToast('Market Assigned', `Assigned ${count} stores in ${market} to ${rep.name}.`);
  };

  const addOutlet = (data: Partial<Outlet>) => {
    const newId = `OUT0${outlets.length + 1}`;
    const newCode = `OUT${String(outlets.length + 1).padStart(6, '0')}`;
    const newStore: Outlet = {
      id: newId,
      code: newCode,
      name: data.name || 'New Retail Store',
      ownerName: data.ownerName || 'Proprietor',
      mobile: data.mobile || '9839000000',
      market: data.market || 'Civil Lines',
      district: 'Kanpur',
      creditLimit: data.creditLimit || 50000,
      balance: data.balance || 0,
      assignedSalesmanId: data.assignedSalesmanId || null,
      status: 'pending',
      lat: 26.47 + (Math.random() - 0.5) * 0.04,
      lng: 80.34 + (Math.random() - 0.5) * 0.04,
      agingDays: (data.balance || 0) > 0 ? 15 : 0,
    };

    const updated = [newStore, ...outlets];
    setOutlets(updated);
    logAudit('ONBOARD_STORE', newCode, `Registered new store ${newStore.name} in ${newStore.market}${newStore.assignedSalesmanId ? ` assigned to rep` : ''}`);
    syncState(salesmen, updated, products, inventoryChecks, auditLogs);
    closeModal();
    showToast('Store Onboarded', `${newStore.name} successfully registered.`);
  };

  const addProduct = (product: Product) => {
    const updated = [...products, product];
    setProducts(updated);
    logAudit('ADD_PRODUCT_SKU', product.skuCode, `Added new SKU: ${product.name} at ₹${product.basePrice.toFixed(2)} (${product.gstRate}% GST)`);
    syncState(salesmen, outlets, updated, inventoryChecks, auditLogs);
    closeModal();
    showToast('SKU Registered', `${product.name} saved to catalog.`);
  };

  // Inventory Checks
  const addInventoryCheck = (data: any) => {
    const store = outlets.find(o => o.id === data.outletId) || { name: 'Retail Store', market: 'Kanpur' };
    const rep = salesmen.find(s => s.id === data.auditedBySalesmanId) || { name: 'Sales Rep', employeeId: 'EMP-0100' };
    const prod = products.find(p => p.skuCode === data.skuCode) || { name: 'Product', category: 'FMCG' };

    const physical = Number(data.physicalCount) || 0;
    const target = Number(data.targetCount) || 24;
    const variance = physical - target;

    let status: any = 'HEALTHY';
    if (variance <= -15) status = 'CRITICAL_DEFICIT';
    else if (variance < 0) status = 'LOW_STOCK';
    else if (variance > 10) status = 'OVERSTOCKED';

    const newId = `AUD-2026-0${80 + inventoryChecks.length + 1}`;
    const now = new Date();
    const timeStr = `${now.getDate()} Oct 2026, ${now.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}`;

    const newCheck: InventoryCheck = {
      id: newId,
      outletId: data.outletId,
      outletName: store.name,
      market: store.market,
      auditedBySalesmanId: data.auditedBySalesmanId,
      auditorName: rep.name,
      auditorEmpId: rep.employeeId,
      timestamp: timeStr,
      skuCode: data.skuCode,
      productName: prod.name,
      category: prod.category,
      physicalCount: physical,
      targetCount: target,
      variance,
      facingGrade: data.facingGrade || 'A+ Prime Eye-Level',
      batchNo: data.batchNo || 'AU-26K09',
      expiryDate: data.expiryDate || '2027-12-31',
      status,
      notes: data.notes || 'Audited during scheduled beat visit.',
      replenishmentStatus: variance < 0 ? 'PENDING_DISPATCH' : 'NONE_REQUIRED',
      replenishmentPoId: variance < 0 ? `PO-AUPL-99${80 + inventoryChecks.length}` : null,
    };

    const updated = [newCheck, ...inventoryChecks];
    setInventoryChecks(updated);
    logAudit('STORE_INVENTORY_AUDIT', newId, `Audit logged at ${store.name} by ${rep.name} for ${prod.name}: Count ${physical}/${target} (${status})`);
    syncState(salesmen, outlets, products, updated, auditLogs);
    closeModal();
    showToast('Audit Result Recorded', `Inspection ${newId} saved.`);
  };

  const triggerReplenishmentOrder = (checkId: string) => {
    const chk = inventoryChecks.find(c => c.id === checkId);
    if (!chk) return;

    const poNumber = `PO-AUPL-${Math.floor(1000 + Math.random() * 9000)}`;
    const updated = inventoryChecks.map(c =>
      c.id === checkId ? { ...c, replenishmentStatus: 'PO_GENERATED' as const, replenishmentPoId: poNumber } : c
    );

    setInventoryChecks(updated);
    logAudit('REPLENISHMENT_ORDER_GENERATED', poNumber, `Auto-PO triggered from Audit ${chk.id} for ${chk.outletName}: 2 Cartons (${Math.abs(chk.variance)} units) of ${chk.productName}`);
    syncState(salesmen, outlets, products, updated, auditLogs);
    showToast('Replenishment Dispatched', `Purchase Order ${poNumber} sent to Kanpur warehouse.`);
  };

  const resolveAuditDiscrepancy = (checkId: string) => {
    const chk = inventoryChecks.find(c => c.id === checkId);
    if (!chk) return;

    const updated = inventoryChecks.map(c =>
      c.id === checkId ? { ...c, status: 'HEALTHY' as const, variance: 0, physicalCount: c.targetCount } : c
    );

    setInventoryChecks(updated);
    logAudit('RESOLVE_AUDIT_TICKET', chk.id, `Discrepancy resolved for ${chk.outletName} (${chk.productName}). Store confirmed restocked.`);
    syncState(salesmen, outlets, products, updated, auditLogs);
    showToast('Ticket Resolved', `Audit ${chk.id} marked as resolved and healthy.`);
  };

  return (
    <AdminContext.Provider
      value={{
        activeView,
        setActiveView,
        selectedSalesmanId,
        setSelectedSalesmanId,
        globalSearch,
        setGlobalSearch,
        salesmen,
        outlets,
        products,
        inventoryChecks,
        auditLogs,
        activeModal,
        modalPayload,
        openModal,
        closeModal,
        toast,
        showToast,
        addSalesman,
        updateSalesman,
        deleteSalesman,
        addOutlet,
        assignStore,
        reassignEntireRoute,
        bulkAssignMarket,
        addProduct,
        addInventoryCheck,
        triggerReplenishmentOrder,
        resolveAuditDiscrepancy,
        logAudit,
      }}
    >
      {children}
    </AdminContext.Provider>
  );
}

export function useAdmin() {
  const context = useContext(AdminContext);
  if (!context) {
    throw new Error('useAdmin must be used within an AdminProvider');
  }
  return context;
}
