import { useState } from 'react';
import { api, useApi } from '../api.js';
import { useAuth } from '../auth.js';
import { can, fmtCurrency, todayISO } from '../format.js';
import { EmptyRow, ErrorText, Loading, Modal, StatusBadge } from '../components/ui.jsx';

const PAYMENT_MODES = [
  ['CASH', 'Cash'], ['UPI', 'UPI'], ['BANK_TRANSFER', 'Bank Transfer'], ['CHEQUE', 'Cheque'], ['CARD', 'Card']
];

export default function CollectionsPage() {
  const { me } = useAuth();
  const canCollect = can(me, 'COLLECTION', 'COLLECT');
  const collections = useApi('/collections');
  const collectable = useApi(canCollect ? '/collections/collectable-loans' : null);
  const [showCreate, setShowCreate] = useState(false);
  const monitoring = me.roleName === 'Security';

  return (
    <>
      <div className="view-header">
        <h2>Collection</h2>
        {canCollect && (
          <button className="btn btn-primary" type="button" disabled={!collectable.data?.length}
                  onClick={() => setShowCreate(true)}>+ Record Collection</button>
        )}
      </div>
      <ErrorText message={collections.error || collectable.error} />
      {collections.loading && !collections.data ? <Loading /> : (
        <table className="data-table">
          <thead>
            <tr><th>ID</th><th>Loan</th><th>Customer</th><th>Amount</th><th>Date</th><th>Mode</th><th>Reference</th><th>Collected By</th><th>Status</th></tr>
          </thead>
          <tbody>
            {collections.data?.length === 0 && <EmptyRow colSpan={9}>No collections yet.</EmptyRow>}
            {collections.data?.map(c => (
              <tr key={c.id}>
                <td>{c.id}</td>
                <td>{c.loanId}</td>
                <td>{c.customerName}</td>
                <td>{fmtCurrency(c.amount)}</td>
                <td>{c.date}</td>
                <td>{c.paymentMode}</td>
                <td>{c.referenceNo || '—'}</td>
                <td>{c.collectedByName || '—'}</td>
                <td>
                  <StatusBadge status={c.status} />
                  {monitoring && <> <span className="badge badge-MONITOR">MONITOR</span></>}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      )}
      {showCreate && (
        <RecordCollectionModal loans={collectable.data || []} onClose={() => setShowCreate(false)}
                               onCreated={() => { setShowCreate(false); collections.reload(); collectable.reload(); }} />
      )}
    </>
  );
}

function RecordCollectionModal({ loans, onClose, onCreated }) {
  const [form, setForm] = useState({
    loanId: loans[0]?.id || '', amount: '', date: todayISO(), paymentMode: 'CASH', referenceNo: '', remarks: ''
  });
  const [error, setError] = useState(null);
  const [busy, setBusy] = useState(false);
  const set = field => e => setForm(f => ({ ...f, [field]: e.target.value }));

  async function submit(e) {
    e.preventDefault();
    setBusy(true);
    setError(null);
    try {
      await api('/collections', { method: 'POST', body: { ...form, amount: Number(form.amount) } });
      onCreated();
    } catch (err) {
      setError(err.message);
      setBusy(false);
    }
  }

  return (
    <Modal title="Record Collection" onClose={onClose}>
      <form onSubmit={submit}>
        <label>Loan
          <select value={form.loanId} onChange={set('loanId')} required>
            {loans.map(l => (
              <option key={l.id} value={l.id}>{l.id} — {l.customerName} (Outstanding {fmtCurrency(l.outstanding)})</option>
            ))}
          </select>
        </label>
        <label>Amount (₹) <input type="number" min="0.01" step="0.01" value={form.amount} onChange={set('amount')} required /></label>
        <label>Date <input type="date" value={form.date} onChange={set('date')} required /></label>
        <label>Payment Mode
          <select value={form.paymentMode} onChange={set('paymentMode')}>
            {PAYMENT_MODES.map(([value, label]) => <option key={value} value={value}>{label}</option>)}
          </select>
        </label>
        <label>Reference No. <input value={form.referenceNo} onChange={set('referenceNo')} placeholder="optional" maxLength={100} /></label>
        <label>Remarks <input value={form.remarks} onChange={set('remarks')} placeholder="optional" maxLength={255} /></label>
        <ErrorText message={error} />
        <div className="modal-actions">
          <button type="button" className="btn btn-ghost" onClick={onClose}>Cancel</button>
          <button type="submit" className="btn btn-primary" disabled={busy}>Record Payment</button>
        </div>
      </form>
    </Modal>
  );
}
