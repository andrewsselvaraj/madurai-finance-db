import { useApi } from '../api.js';
import { useAuth } from '../auth.js';
import { EmptyRow, ErrorText, Loading } from '../components/ui.jsx';

export default function AuditPage() {
  const { me } = useAuth();
  const audit = useApi('/audit');

  return (
    <>
      <div className="view-header">
        <h2>Audit Trail</h2>
        <p className="muted">{me.roleName === 'Security' ? 'Full monitoring access.' : 'Read-only activity log.'}</p>
      </div>
      <ErrorText message={audit.error} />
      {audit.loading && !audit.data ? <Loading /> : (
        <table className="data-table">
          <thead><tr><th>Timestamp</th><th>User</th><th>Action</th><th>Details</th></tr></thead>
          <tbody>
            {audit.data?.length === 0 && <EmptyRow colSpan={4}>No audit entries yet.</EmptyRow>}
            {audit.data?.map(a => (
              <tr key={a.id}>
                <td>{a.datetime}</td>
                <td>{a.userName}</td>
                <td><span className="badge badge-AUDIT">{a.action.replace(/_/g, ' ')}</span></td>
                <td>{a.details}</td>
              </tr>
            ))}
          </tbody>
        </table>
      )}
    </>
  );
}
