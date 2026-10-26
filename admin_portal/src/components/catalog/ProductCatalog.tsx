'use client';

import React, { useState, useMemo } from 'react';
import { useAdmin } from '@/context/AdminContext';
import { Product } from '@/types';

export default function ProductCatalog() {
  const { products, globalSearch, openModal, addProduct, logAudit, showToast } = useAdmin();
  const [categoryFilter, setCategoryFilter] = useState('ALL');

  const filteredProducts = useMemo(() => {
    const q = globalSearch.toLowerCase().trim();
    return products.filter(p => {
      const matchesCategory = categoryFilter === 'ALL' || p.category === categoryFilter;
      const matchesQuery = !q || p.name.toLowerCase().includes(q) || p.skuCode.toLowerCase().includes(q);
      return matchesCategory && matchesQuery;
    });
  }, [products, categoryFilter, globalSearch]);

  const handleEditPrice = (product: Product) => {
    const newPriceStr = prompt(
      `Enter new base wholesale price for ${product.name} (Current: ₹${product.basePrice}):`,
      product.basePrice.toString()
    );
    if (newPriceStr !== null && !isNaN(parseFloat(newPriceStr))) {
      const newPrice = parseFloat(newPriceStr);
      addProduct({
        ...product,
        basePrice: newPrice,
      });
      logAudit(
        'UPDATE_PRODUCT_PRICE',
        product.skuCode,
        `Updated wholesale price to ₹${newPrice.toFixed(2)}`,
        'Sunil Agarwal (Super Admin)'
      );
      showToast('Price Updated', `${product.name} updated to ₹${newPrice.toFixed(2)}`);
    }
  };

  return (
    <section className="view-panel active" id="view-catalog">
      <div className="catalog-container">
        <div className="catalog-toolbar">
          <div className="category-pills" id="catalog-category-pills">
            <button
              className={`pill ${categoryFilter === 'ALL' ? 'active' : ''}`}
              onClick={() => setCategoryFilter('ALL')}
            >
              All Products ({products.length})
            </button>
            <button
              className={`pill ${categoryFilter === 'Spices' ? 'active' : ''}`}
              onClick={() => setCategoryFilter('Spices')}
            >
              Pure Spices
            </button>
            <button
              className={`pill ${categoryFilter === 'Beverages' ? 'active' : ''}`}
              onClick={() => setCategoryFilter('Beverages')}
            >
              Beverages
            </button>
            <button
              className={`pill ${categoryFilter === 'Personal Care' ? 'active' : ''}`}
              onClick={() => setCategoryFilter('Personal Care')}
            >
              Personal Care
            </button>
            <button
              className={`pill ${categoryFilter === 'Edible Oils' ? 'active' : ''}`}
              onClick={() => setCategoryFilter('Edible Oils')}
            >
              Edible Oils
            </button>
          </div>
          <button className="btn btn-primary btn-sm" onClick={() => openModal('modal-add-product')}>
            <i className="fa-solid fa-plus"></i> Add New SKU
          </button>
        </div>

        <div className="table-card">
          <table className="data-table" id="products-table">
            <thead>
              <tr>
                <th>SKU Code</th>
                <th>Product Name</th>
                <th>Category</th>
                <th>Unit</th>
                <th>Base Price (₹)</th>
                <th>GST Rate</th>
                <th>Net Billing (₹)</th>
                <th>Stock Status</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody id="products-table-body">
              {filteredProducts.map(p => {
                const netPrice = p.basePrice * (1 + p.gstRate / 100);
                return (
                  <tr key={p.skuCode}>
                    <td>
                      <span className="code-badge">{p.skuCode}</span>
                    </td>
                    <td>
                      <strong>{p.name}</strong>
                    </td>
                    <td>{p.category}</td>
                    <td>{p.unit}</td>
                    <td>₹{p.basePrice.toFixed(2)}</td>
                    <td>{p.gstRate}% GST</td>
                    <td>
                      <strong style={{ color: 'var(--primary)' }}>₹{netPrice.toFixed(2)}</strong>
                    </td>
                    <td>
                      <span
                        className={`status-badge-live ${
                          p.stockStatus.includes('Low') ? 'transit' : 'in-store'
                        }`}
                      >
                        {p.stockStatus}
                      </span>
                    </td>
                    <td>
                      <button className="btn btn-secondary btn-sm" onClick={() => handleEditPrice(p)}>
                        <i className="fa-solid fa-pen"></i> Edit
                      </button>
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>
      </div>
    </section>
  );
}
