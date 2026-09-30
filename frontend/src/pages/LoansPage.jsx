import { useState } from 'react';
import { api, useApi } from '../api.js';
import { useAuth } from '../auth.js';
import { can, fmtCurrency } from '../format.js';
import { EmptyRow, ErrorText, Loading, Modal, StatusBadge } from '../components/ui.jsx';

const ACTION_BUTTONS = {
  APPROVE: { label: 'Approve', className: 'btn btn-small btn-primary', path: 'approve' },
  REJECT: { label: 'Reject', className: 'btn btn-small btn-danger', path: 'reject' },
  DISBURSE: { label: 'Disburse', className: 'btn btn-small btn-primary', path: 'disburse' },
  RECEIVE: { label: 'Acknowledge Receipt', className: 'btn btn-small', path: 'receive' }
};

export default function LoansPage() {
  const { me } = useAuth();
  const loans = useApi('/loans');
  const [showCreate, setShowCreate] = useState(false);
  const [error, setError] = useState(null);
  const [busyId, setBusyId] = useState(null);
  const monitoring = me.roleName === 'Security';

  async function runAction(loan, action) {
    setError(null);
    setBusyId(loan.id);
    try {
      await api(`/loans/${loan.id}/${ACTION_BUTTONS[action].path}`, { method: 'POST' });
      loans.reload();
    } catch (err) {
      setError(err.message);
    } finally {
      setBusyId(null);
    }
  }

  return (
    <>
      <div className="view-header">
        <h2>Loan Disbursement</h2>
        {can(me, 'LOAN_DISBURSEMENT', 'CREATE') && (
          <button className="btn btn-primary" type="button" onClick={() => setShowCreate(true)}>+ New Loan Application</button>
        )}
      </div>
      <ErrorText message={error || loans.error} />
      {loans.loading && !loans.data ? <Loading /> : (
        <table className="data-table">
          <thead>
            <tr><th>ID</th><th>Customer</th><th>Amount</th><th>Rate</th><th>Tenure</th><th>Outstanding</th><th>Status</th><th>Actions</th></tr>
          </thead>
          <tbody>
            {loans.data?.length === 0 && <EmptyRow colSpan={8}>No loans yet.</EmptyRow>}
            {loans.data?.map(l => (
              <tr key={l.id}>
                <td>{l.id}</td>
                <td>{l.customerName}</td>
                <td>{fmtCurrency(l.amount)}</td>
                <td>{l.interestRate}%</td>
                <td>{l.tenureMonths}mo</td>
                <td>{fmtCurrency(l.outstanding)}</td>
                <td>
                  <StatusBadge status={l.status} />
                  {monitoring && <> <span className="badge badge-MONITOR">MONITOR</span></>}
                </td>
                <td className="actions-cell">
                  {l.actions.map(a => (
                    <button key={a} className={ACTION_BUTTONS[a].className} type="button"
                            disabled={busyId === l.id} onClick={() => runAction(l, a)}>
                      {ACTION_BUTTONS[a].label}
                    </button>
                  ))}
                  {l.receivedDate && <span className="badge badge-DISBURSED">Received</span>}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      )}
      {showCreate && (
        <CreateLoanModal onClose={() => setShowCreate(false)}
                         onCreated={() => { setShowCreate(false); loans.reload(); }} />
      )}
    </>
  );
}

function CreateLoanModal({ onClose, onCreated }) {
  const customerList = useApi('/loans/customers');
  const customers = customerList.data || [];
  const [form, setForm] = useState({ customerId: '', amount: '', interestRate: '10', tenureMonths: '12', purpose: '' });
  const [error, setError] = useState(null);
  const [busy, setBusy] = useState(false);
  const set = field => e => setForm(f => ({ ...f, [field]: e.target.value }));
  const customerId = form.customerId || customers[0]?.id || '';

  async function submit(e) {
    e.preventDefault();
    setBusy(true);
    setError(null);
    try {
      await api('/loans', {
        method: 'POST',
        body: {
          customerId,
          amount: Number(form.amount),
          interestRate: Number(form.interestRate),
          tenureMonths: Number(form.tenureMonths),
          purpose: form.purpose || null
        }
      });
      onCreated();
    } catch (err) {
      setError(err.message);
      setBusy(false);
    }
  }

  return (
    <Modal title="New Loan Application" onClose={onClose}>
      <form onSubmit={submit}>
        <label>Customer
          <select value={customerId} onChange={set('customerId')} required>
            {customers.length === 0 && <option value="" disabled>No customers found</option>}
            {customers.map(c => <option key={c.id} value={c.id}>{c.name}</option>)}
          </select>
        </label>
        <label>Amount (₹) <input type="number" min="1" step="0.01" value={form.amount} onChange={set('amount')} required /></label>
        <label>Interest Rate (%) <input type="number" min="0" step="0.01" value={form.interestRate} onChange={set('interestRate')} required /></label>
        <label>Tenure (months) <input type="number" min="1" value={form.tenureMonths} onChange={set('tenureMonths')} required /></label>
        <label>Purpose <input value={form.purpose} onChange={set('purpose')} placeholder="e.g. Personal loan" maxLength={255} /></label>
        <ErrorText message={error || customerList.error} />
        <div className="modal-actions">
          <button type="button" className="btn btn-ghost" onClick={onClose}>Cancel</button>
          <button type="submit" className="btn btn-primary" disabled={busy || !customerId}>Submit Application</button>
        </div>
      </form>
    </Modal>
  );
}
