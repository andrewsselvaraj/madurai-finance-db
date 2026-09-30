import { useState } from 'react';
import { api, useApi } from '../api.js';
import { useAuth } from '../auth.js';
import { EmptyRow, ErrorText, Loading, Modal, RoleBadge, StatusBadge } from '../components/ui.jsx';

export default function UsersPage() {
  const { me } = useAuth();
  const users = useApi('/users');
  const [showCreate, setShowCreate] = useState(false);
  const [error, setError] = useState(null);
  const dataEntry = me.dataEntryOperator;

  async function toggle(user) {
    setError(null);
    try {
      await api(`/users/${user.id}/toggle-status`, { method: 'POST' });
      users.reload();
    } catch (err) {
      setError(err.message);
    }
  }

  const helpText = dataEntry
    ? 'You can register new customers here. Staff accounts are managed by the Financier.'
    : (!me.canManageUsers ? 'Read-only view (Security monitors org users).' : '');

  return (
    <>
      <div className="view-header">
        <h2>{dataEntry ? 'Customers' : 'Users'}</h2>
        {me.canAddCustomer && (
          <button className="btn btn-primary" type="button" onClick={() => setShowCreate(true)}>
            + {dataEntry ? 'Add Customer' : 'New User'}
          </button>
        )}
      </div>
      {helpText && <p className="muted">{helpText}</p>}
      <ErrorText message={error || users.error} />
      {users.loading && !users.data ? <Loading /> : (
        <table className="data-table">
          <thead><tr><th>ID</th><th>Name</th><th>Email</th><th>Role</th><th>Status</th><th></th></tr></thead>
          <tbody>
            {users.data?.length === 0 && <EmptyRow colSpan={6}>No customers yet.</EmptyRow>}
            {users.data?.map(u => (
              <tr key={u.id}>
                <td>{u.id}</td>
                <td>{u.name}</td>
                <td>{u.email}</td>
                <td><RoleBadge roleId={u.roleId} roleName={u.roleName} /></td>
                <td><StatusBadge status={u.status} /></td>
                <td>
                  {u.canToggle && (
                    <button className="btn btn-small" type="button" onClick={() => toggle(u)}>
                      {u.status === 'ACTIVE' ? 'Disable' : 'Enable'}
                    </button>
                  )}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      )}
      {showCreate && (
        <CreateUserModal dataEntry={dataEntry} onClose={() => setShowCreate(false)}
                         onCreated={() => { setShowCreate(false); users.reload(); }} />
      )}
    </>
  );
}

function CreateUserModal({ dataEntry, onClose, onCreated }) {
  const roles = useApi(dataEntry ? null : '/roles');
  const [form, setForm] = useState({ name: '', email: '', roleId: '', password: 'test' });
  const [error, setError] = useState(null);
  const [busy, setBusy] = useState(false);
  const set = field => e => setForm(f => ({ ...f, [field]: e.target.value }));
  const roleId = form.roleId || roles.data?.[0]?.id || '';

  async function submit(e) {
    e.preventDefault();
    setBusy(true);
    setError(null);
    try {
      await api('/users', { method: 'POST', body: { ...form, roleId: dataEntry ? null : roleId } });
      onCreated();
    } catch (err) {
      setError(err.message);
      setBusy(false);
    }
  }

  return (
    <Modal title={dataEntry ? 'Add New Customer' : 'Create User'} onClose={onClose}>
      <form onSubmit={submit}>
        <label>Full Name <input value={form.name} onChange={set('name')} required maxLength={50} /></label>
        <label>Email <input type="email" value={form.email} onChange={set('email')} required maxLength={50} /></label>
        {dataEntry ? (
          <label>Role <input value="Customer" disabled /></label>
        ) : (
          <label>Role
            <select value={roleId} onChange={set('roleId')} required>
              {roles.data?.map(r => <option key={r.id} value={r.id}>{r.name}</option>)}
            </select>
          </label>
        )}
        <label>Temporary Password <input value={form.password} onChange={set('password')} required /></label>
        <ErrorText message={error || roles.error} />
        <div className="modal-actions">
          <button type="button" className="btn btn-ghost" onClick={onClose}>Cancel</button>
          <button type="submit" className="btn btn-primary" disabled={busy}>{dataEntry ? 'Add Customer' : 'Create'}</button>
        </div>
      </form>
    </Modal>
  );
}
