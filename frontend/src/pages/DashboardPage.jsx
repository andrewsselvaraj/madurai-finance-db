import { useApi } from '../api.js';
import { useAuth } from '../auth.js';
import { fmtCurrency } from '../format.js';
import { ErrorText, Loading } from '../components/ui.jsx';

export default function DashboardPage() {
  const { me } = useAuth();
  const { data, error, loading } = useApi('/dashboard');

  return (
    <>
      <div className="view-header">
        <h2>Dashboard</h2>
        <p className="muted">Welcome back, {me.name} ({me.roleName})</p>
      </div>
      <ErrorText message={error} />
      {loading && !data ? <Loading /> : data && (
        <>
          <div className="card-grid">
            {data.cards.map(c => (
              <div className="stat-card" key={c.label}>
                <div className="stat-value">{c.format === 'currency' ? fmtCurrency(c.value) : c.value}</div>
                <div className="stat-label">{c.label}</div>
              </div>
            ))}
          </div>
          <div className="panel">
            <h3>Recent Activity</h3>
            <ul className="audit-list">
              {data.recentActivity.length === 0 && <li className="muted">No activity yet.</li>}
              {data.recentActivity.map(a => (
                <li key={a.id}>
                  <span className="audit-time">{a.datetime}</span> <strong>{a.userName}</strong> — {a.details}
                </li>
              ))}
            </ul>
          </div>
        </>
      )}
    </>
  );
}
