'use client';

import React from 'react';
import { useAdmin } from '@/context/AdminContext';

// Layout components
import Sidebar from '@/components/layout/Sidebar';
import Topbar from '@/components/layout/Topbar';
import KpiBanner from '@/components/layout/KpiBanner';
import Toast from '@/components/layout/Toast';

// View panels
import StoreAllocationMatrix from '@/components/allocation/StoreAllocationMatrix';
import MaintainSalesPersons from '@/components/salesmen/MaintainSalesPersons';
import InventoryCheckResults from '@/components/inventory/InventoryCheckResults';
import LiveFieldRadar from '@/components/radar/LiveFieldRadar';
import ProductCatalog from '@/components/catalog/ProductCatalog';
import DebtorAging from '@/components/debtors/DebtorAging';
import AuditTrail from '@/components/audit/AuditTrail';
import CloudPipeline from '@/components/cloud/CloudPipeline';

// Modals
import SalesmanScorecardModal from '@/components/salesmen/SalesmanScorecardModal';
import AddSalesmanModal from '@/components/salesmen/AddSalesmanModal';
import EditSalesmanModal from '@/components/salesmen/EditSalesmanModal';
import AddAuditModal from '@/components/inventory/AddAuditModal';
import AuditSlipModal from '@/components/inventory/AuditSlipModal';
import AddProductModal from '@/components/catalog/AddProductModal';
import AddStoreModal from '@/components/modals/AddStoreModal';
import ReassignRouteModal from '@/components/modals/ReassignRouteModal';
import BulkMarketModal from '@/components/modals/BulkMarketModal';
import A4StatementModal from '@/components/debtors/A4StatementModal';

export default function Home() {
  const { activeView } = useAdmin();

  return (
    <div className="app-layout">
      {/* Sidebar Navigation */}
      <Sidebar />

      {/* Main Content Area */}
      <main className="main-content">
        <Topbar />
        <KpiBanner />

        {activeView === 'allocation' && <StoreAllocationMatrix />}
        {activeView === 'salesmen' && <MaintainSalesPersons />}
        {activeView === 'inventory-checks' && <InventoryCheckResults />}
        {activeView === 'radar' && <LiveFieldRadar />}
        {activeView === 'catalog' && <ProductCatalog />}
        {activeView === 'debtors' && <DebtorAging />}
        {activeView === 'audit' && <AuditTrail />}
        {activeView === 'cloud' && <CloudPipeline />}
      </main>

      {/* Global Modals */}
      <SalesmanScorecardModal />
      <AddSalesmanModal />
      <EditSalesmanModal />
      <AddAuditModal />
      <AuditSlipModal />
      <AddProductModal />
      <AddStoreModal />
      <ReassignRouteModal />
      <BulkMarketModal />
      <A4StatementModal />

      {/* Live Toast Notifications */}
      <Toast />
    </div>
  );
}
