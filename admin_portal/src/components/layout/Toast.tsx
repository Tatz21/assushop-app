'use client';

import React from 'react';
import { useAdmin } from '@/context/AdminContext';

export default function Toast() {
  const { toast } = useAdmin();

  return (
    <div className={`toast-notification ${toast.visible ? 'show' : ''}`}>
      <i className="fa-solid fa-circle-check toast-icon"></i>
      <div className="toast-body">
        <span className="toast-title">{toast.title}</span>
        <span className="toast-message">{toast.message}</span>
      </div>
    </div>
  );
}
