export type ViewType = 
  | 'allocation'
  | 'salesmen'
  | 'inventory-checks'
  | 'radar'
  | 'catalog'
  | 'debtors'
  | 'audit'
  | 'cloud';

export interface LocationCoordinates {
  lat: number;
  lng: number;
  venue: string;
  distance: number;
}

export interface Salesman {
  id: string;
  name: string;
  employeeId: string;
  mobile: string;
  email: string;
  territory: string;
  target: number;
  achieved: number;
  commissionRate: number;
  status: 'Active (In Store)' | 'In Transit (GT Road)' | 'On Leave' | string;
  currentLocation: LocationCoordinates;
  checkedInAt: string | null;
}

export interface Outlet {
  id: string;
  code: string;
  name: string;
  ownerName: string;
  mobile: string;
  market: string;
  district: string;
  creditLimit: number;
  balance: number;
  assignedSalesmanId: string | null;
  status: 'visited' | 'pending' | 'in_progress';
  lat: number;
  lng: number;
  agingDays: number;
}

export interface Product {
  skuCode: string;
  name: string;
  category: string;
  unit: string;
  basePrice: number;
  gstRate: number;
  stockStatus: string;
}

export type AuditStatus = 
  | 'CRITICAL_DEFICIT'
  | 'LOW_STOCK'
  | 'HEALTHY'
  | 'EXPIRING_SOON'
  | 'OVERSTOCKED';

export interface InventoryCheck {
  id: string;
  outletId: string;
  outletName: string;
  market: string;
  auditedBySalesmanId: string;
  auditorName: string;
  auditorEmpId: string;
  timestamp: string;
  skuCode: string;
  productName: string;
  category: string;
  physicalCount: number;
  targetCount: number;
  variance: number;
  facingGrade: string;
  batchNo: string;
  expiryDate: string;
  status: AuditStatus;
  notes: string;
  replenishmentStatus: 'NONE_REQUIRED' | 'PENDING_DISPATCH' | 'PO_GENERATED';
  replenishmentPoId: string | null;
}

export interface AuditLog {
  id: string;
  timestamp: string;
  action: string;
  entity: string;
  desc: string;
  actor: string;
  hash: string;
}
