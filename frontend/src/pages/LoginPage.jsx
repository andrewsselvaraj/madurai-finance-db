import { useState } from 'react';
import { api, useApi } from '../api.js';
import { ErrorText } from '../components/ui.jsx';

export default function LoginPage({ onLogin }) {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState(null);
  const [busy, setBusy] = useState(false);
  const demo = useApi('/auth/demo-accounts');

  async function submit(e) {
    e.preventDefault();
    setBusy(true);
    setError(null);
    try {
      onLogin(await api('/auth/login', { method: 'POST', body: { email, password } }));
    } catch (err) {
      setError(err.message);
      setBusy(false);
    }
  }

  return (
    <div className="login-screen">
      <div className="login-card">
        <div className="login-brand">
          <div className="brand-badge">MF</div>
          <h1>Madurai Finance</h1>
          <p className="muted">Loan Disbursement &middot; Collection &middot; Audit</p>
        </div>
        <form className="login-form" onSubmit={submit}>
          <label>Email
            <input type="email" value={email} onChange={e => setEmail(e.target.value)}
                   placeholder="ravi.kumar@maduraifinance.com" required autoComplete="username" />
          </label>
          <label>Password
            <input type="password" value={password} onChange={e => setPassword(e.target.value)}
                   required autoComplete="current-password" />
          </label>
          <ErrorText message={error} />
          <button type="submit" className="btn btn-primary btn-block" disabled={busy}>
            {busy ? 'Logging in…' : 'Log In'}
          </button>
        </form>

        {demo.data?.length > 0 && (
          <>
            <div className="login-divider"><span>Quick demo login</span></div>
            <div className="quick-login-grid">
              {demo.data.map(a => (
                <button key={a.email} className="quick-login" type="button"
                        onClick={() => { setEmail(a.email); setPassword('test'); }}>
                  <span className="ql-role">{a.roleName}</span>
                  <span className="ql-name">{a.name}</span>
                </button>
              ))}
            </div>
            <p className="muted small">All demo accounts use password <code>test</code>.</p>
          </>
        )}
      </div>
    </div>
  );
}
