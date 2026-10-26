'use client';

import React, { useState } from 'react';
import { useAdmin } from '@/context/AdminContext';

export default function AddProductModal() {
  const { activeModal, closeModal, addProduct } = useAdmin();

  const [sku, setSku] = useState('');
  const [name, setName] = useState('');
  const [category, setCategory] = useState('Spices');
  const [unit, setUnit] = useState('100g Pouch');
  const [price, setPrice] = useState<number | ''>(75);
  const [gst, setGst] = useState<number>(18);

  if (activeModal !== 'modal-add-product') {
    return null;
  }

  const baseVal = typeof price === 'number' ? price : 0;
  const netPrice = baseVal * (1 + gst / 100);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!sku.trim() || !name.trim() || typeof price !== 'number') return;

    addProduct({
      skuCode: sku.trim().toUpperCase(),
      name: name.trim(),
      category,
      unit: unit.trim(),
      basePrice: price,
      gstRate: gst,
      stockStatus: 'In Stock (500 units)',
    });

    setSku('');
    setName('');
    setPrice(75);
  };

  return (
    <div className="modal-backdrop active" id="modal-add-product">
      <div className="modal-card">
        <div className="modal-header">
          <h3>
            <i className="fa-solid fa-box-open"></i> Add Master SKU Product
          </h3>
          <button className="modal-close" onClick={closeModal}>
            &times;
          </button>
        </div>
        <form id="form-add-product" onSubmit={handleSubmit}>
          <div className="form-grid">
            <div className="form-group">
              <label>SKU Code *</label>
              <input
                type="text"
                id="prod-sku"
                placeholder="e.g. AUPL-GARAM-100"
                required
                value={sku}
                onChange={e => setSku(e.target.value)}
              />
            </div>
            <div className="form-group">
              <label>Product Name *</label>
              <input
                type="text"
                id="prod-name"
                placeholder="e.g. Royal Garam Masala 100g"
                required
                value={name}
                onChange={e => setName(e.target.value)}
              />
            </div>
            <div className="form-group">
              <label>Category *</label>
              <select
                id="prod-category"
                required
                value={category}
                onChange={e => setCategory(e.target.value)}
              >
                <option value="Spices">Pure Spices</option>
                <option value="Beverages">Beverages</option>
                <option value="Personal Care">Personal Care</option>
                <option value="Edible Oils">Edible Oils</option>
              </select>
            </div>
            <div className="form-group">
              <label>Unit / Pack Size</label>
              <input
                type="text"
                id="prod-unit"
                placeholder="e.g. 100g Pouch"
                required
                value={unit}
                onChange={e => setUnit(e.target.value)}
              />
            </div>
            <div className="form-group">
              <label>Base Price (₹ Excl. GST) *</label>
              <input
                type="number"
                id="prod-price"
                placeholder="e.g. 75.00"
                step="0.5"
                required
                value={price}
                onChange={e => setPrice(e.target.value === '' ? '' : parseFloat(e.target.value))}
              />
            </div>
            <div className="form-group">
              <label>GST Rate *</label>
              <select
                id="prod-gst"
                value={gst}
                onChange={e => setGst(parseInt(e.target.value))}
              >
                <option value={5}>5% GST</option>
                <option value={12}>12% GST</option>
                <option value={18}>18% GST</option>
              </select>
            </div>
            <div className="form-group full-width">
              <div className="calc-preview-card">
                <span>Calculated Net Billing Price:</span>
                <strong id="prod-net-preview">₹ {netPrice.toFixed(2)} (incl. GST)</strong>
              </div>
            </div>
          </div>
          <div className="modal-footer">
            <button type="button" className="btn btn-secondary" onClick={closeModal}>
              Cancel
            </button>
            <button type="submit" className="btn btn-primary">
              <i className="fa-solid fa-plus"></i> Save to Master Catalog
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
