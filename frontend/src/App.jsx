import { useCallback, useEffect, useMemo, useState } from 'react';
import { Navigate, NavLink, Route, Routes, useNavigate } from 'react-router-dom';
import { api, setUnauthorizedHandler } from './api.js';
import { AuthContext, useAuth } from './auth.js';
import { can } from './format.js';
import { Forbidden, Loading, RoleBadge } from './components/ui.jsx';
import LoginPage from './pages/LoginPage.jsx';
import DashboardPage from './pages/DashboardPage.jsx';
import UsersPage from './pages/UsersPage.jsx';
import LoansPage from './pages/LoansPage.jsx';
import CollectionsPage from './pages/CollectionsPage.jsx';
import AuditPage from './pages/AuditPage.jsx';
import ReportsPage from './pages/ReportsPage.jsx';

export default function App() {
  const [me, setMe] = useState(undefined); // undefined = checking session, null = logged out
  const navigate = useNavigate();

  useEffect(() => {
    setUnauthorizedHandler(() => setMe(null));
    api('/auth/me').then(setMe, () => setMe(null));
  }, []);

  const logout = useCallback(async () => {
    try { await api('/auth/logout', { method: 'POST' }); } catch { /* session already gone */ }
    setMe(null);
    navigate('/');
  }, [navigate]);

  const auth = useMemo(() => ({ me, logout }), [me, logout]);

  if (me === undefined) return <Loading />;
  if (me === null) return <LoginPage onLogin={user => { setMe(user); navigate('/'); }} />;

  return (
    <AuthContext.Provider value={auth}>
      <Shell />
    </AuthContext.Provider>
  );
}

function navItems(me) {
  const items = [{ to: '/', label: 'Dashboard' }];
  if (me.canViewUsers) items.push({ to: '/users', label: me.dataEntryOperator ? 'Customers' : 'Users' });
  if (can(me, 'LOAN_DISBURSEMENT', 'VIEW')) items.push({ to: '/loans', label: 'Loan Disbursement' });
  if (can(me, 'COLLECTION', 'VIEW')) items.push({ to: '/collections', label: 'Collection' });
  if (can(me, 'AUDIT', 'VIEW')) items.push({ to: '/audit', label: 'Audit' });
  items.push({ to: '/reports', label: 'Reports' });
  return items;
}

function Shell() {
  const { me, logout } = useAuth();
  const guard = (allowed, element) => (allowed ? element : <Forbidden />);

  return (
    <div className="shell">
      <header className="topbar">
        <div className="topbar-brand"><span className="brand-badge">MF</span> {me.orgName}</div>
        <div className="topbar-user">
          <div className="user-chip">
            <span className="user-name">{me.name}</span>
            <RoleBadge roleId={me.roleId} roleName={me.roleName} />
          </div>
          <button className="btn btn-ghost" type="button" onClick={logout}>Log Out</button>
        </div>
      </header>
      <div className="shell-body">
        <nav className="sidebar">
          {navItems(me).map(i => (
            <NavLink key={i.to} to={i.to} end className={({ isActive }) => `nav-item${isActive ? ' active' : ''}`}>
              {i.label}
            </NavLink>
          ))}
        </nav>
        <main className="content">
          <Routes>
            <Route path="/" element={<DashboardPage />} />
            <Route path="/dashboard" element={<Navigate to="/" replace />} />
            <Route path="/users" element={guard(me.canViewUsers, <UsersPage />)} />
            <Route path="/loans" element={guard(can(me, 'LOAN_DISBURSEMENT', 'VIEW'), <LoansPage />)} />
            <Route path="/collections" element={guard(can(me, 'COLLECTION', 'VIEW'), <CollectionsPage />)} />
            <Route path="/audit" element={guard(can(me, 'AUDIT', 'VIEW'), <AuditPage />)} />
            <Route path="/reports" element={<ReportsPage />} />
            <Route path="*" element={<Navigate to="/" replace />} />
          </Routes>
        </main>
      </div>
    </div>
  );
}
