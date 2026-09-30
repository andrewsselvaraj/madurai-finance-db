import { useEffect } from 'react';
import { fmtCurrency } from '../format.js';

export function StatusBadge({ status }) {
  return <span className={`badge badge-${status}`}>{status}</span>;
}

export function RoleBadge({ roleId, roleName }) {
  return <span className={`role-badge role-${roleId}`}>{roleName}</span>;
}

export function ErrorText({ message }) {
  if (!message) return null;
  return <div className="error-text alert" role="alert">{message}</div>;
}

export function Loading() {
  return <div className="loading">Loading…</div>;
}

export function Forbidden() {
  return (
    <div className="empty-state">
      <h2>Access restricted</h2>
      <p className="muted">Your role does not have permission to view this module.</p>
    </div>
  );
}

export function EmptyRow({ colSpan, children }) {
  return <tr><td colSpan={colSpan} className="muted">{children}</td></tr>;
}

export function Modal({ title, onClose, children }) {
  useEffect(() => {
    const onKey = e => { if (e.key === 'Escape') onClose(); };
    window.addEventListener('keydown', onKey);
    return () => window.removeEventListener('keydown', onKey);
  }, [onClose]);

  return (
    <div className="modal-overlay" onClick={onClose}>
      <div className="modal-card" role="dialog" aria-modal="true" aria-label={title} onClick={e => e.stopPropagation()}>
        <div className="modal-header">
          <h3>{title}</h3>
          <button className="modal-close" type="button" aria-label="Close" onClick={onClose}>&times;</button>
        </div>
        <div className="modal-body">{children}</div>
      </div>
    </div>
  );
}

/** Horizontal bar chart of {label, amount} buckets. */
export function Bars({ buckets }) {
  const max = Math.max(1, ...buckets.map(b => Number(b.amount)));
  return (
    <div className="bars">
      {buckets.map(b => (
        <div className="bar-row" key={b.label}>
          <div className="bar-label">{b.label}</div>
          <div className="bar-track">
            <div className="bar-fill" style={{ width: `${Math.round((Number(b.amount) / max) * 100)}%` }} />
          </div>
          <div className="bar-value">{fmtCurrency(b.amount)}</div>
        </div>
      ))}
    </div>
  );
}
