/* Madurai Finance - demo app logic (vanilla JS, no build step, no backend). */

/* ---------------------------------------------------------------------- */
/* Storage layer - localStorage acts as the "database", seeded from data.js */
/* ---------------------------------------------------------------------- */

const DB_KEYS = { users: 'mf_users', loans: 'mf_loans', collections: 'mf_collections', audit: 'mf_audit', session: 'mf_session' };

function seedIfEmpty() {
  if (!localStorage.getItem(DB_KEYS.users)) localStorage.setItem(DB_KEYS.users, JSON.stringify(SEED_USERS));
  if (!localStorage.getItem(DB_KEYS.loans)) localStorage.setItem(DB_KEYS.loans, JSON.stringify(SEED_LOANS));
  if (!localStorage.getItem(DB_KEYS.collections)) localStorage.setItem(DB_KEYS.collections, JSON.stringify(SEED_COLLECTIONS));
  if (!localStorage.getItem(DB_KEYS.audit)) localStorage.setItem(DB_KEYS.audit, JSON.stringify(SEED_AUDIT));
}

function resetDemoData() {
  localStorage.removeItem(DB_KEYS.users);
  localStorage.removeItem(DB_KEYS.loans);
  localStorage.removeItem(DB_KEYS.collections);
  localStorage.removeItem(DB_KEYS.audit);
  seedIfEmpty();
  navigate('dashboard');
}

const db = {
  get users() { return JSON.parse(localStorage.getItem(DB_KEYS.users) || '[]'); },
  set users(v) { localStorage.setItem(DB_KEYS.users, JSON.stringify(v)); },
  get loans() { return JSON.parse(localStorage.getItem(DB_KEYS.loans) || '[]'); },
  set loans(v) { localStorage.setItem(DB_KEYS.loans, JSON.stringify(v)); },
  get collections() { return JSON.parse(localStorage.getItem(DB_KEYS.collections) || '[]'); },
  set collections(v) { localStorage.setItem(DB_KEYS.collections, JSON.stringify(v)); },
  get audit() { return JSON.parse(localStorage.getItem(DB_KEYS.audit) || '[]'); },
  set audit(v) { localStorage.setItem(DB_KEYS.audit, JSON.stringify(v)); }
};

function nextSeqId(prefix, records, idField, padLen) {
  const nums = records.map(r => parseInt(String(r[idField]).replace(prefix, ''), 10)).filter(n => !isNaN(n));
  const next = (nums.length ? Math.max(...nums) : 0) + 1;
  return prefix + String(next).padStart(padLen, '0');
}
function genLoanId() { return nextSeqId('LOAN', db.loans, 'pk_loan_id', 3); }
function genCollId() { return nextSeqId('COLL', db.collections, 'pk_collection_id', 3); }
function genUserId() { return nextSeqId('USR', db.users, 'pk_user_id', 3); }
function genAuditId() { return nextSeqId('AUD', db.audit, 'pk_audit_id', 5); }

function todayISO() { return new Date().toISOString().slice(0, 10); }
function nowDT() { return new Date().toISOString().slice(0, 19).replace('T', ' '); }
function addMonths(dateStr, months) {
  const d = new Date(dateStr);
  d.setMonth(d.getMonth() + months);
  return d.toISOString().slice(0, 10);
}
function fmtCurrency(n) {
  if (n === null || n === undefined) return '—';
  return '₹' + Number(n).toLocaleString('en-IN', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
}
function fmtDate(d) { return d ? d : '—'; }
function escapeHtml(s) {
  return String(s == null ? '' : s).replace(/[&<>"']/g, c => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]));
}

function logAudit(user, action, details) {
  const audit = db.audit;
  audit.unshift({ pk_audit_id: genAuditId(), org_id: ORG.pk_org_id, datetime: nowDT(), user_id: user.pk_user_id, user_name: user.user_name, action, details });
  db.audit = audit;
}

/* ---------------------------------------------------------------------- */
/* Permission engine - driven entirely by ROLE_PERMISSION_MAPPING          */
/* ---------------------------------------------------------------------- */

function roleOf(user) { return ROLES.find(r => r.pk_role_id === user.user_role_id); }
function moduleCodeToId(code) { return MODULES.find(m => m.module_code === code).pk_module_id; }
function permCodeToId(code) { return PERMISSIONS.find(p => p.permission_code === code).pk_permission_id; }

function can(user, moduleCode, permCode) {
  const moduleId = MODULES.find(m => m.module_code === moduleCode)?.pk_module_id;
  const permId = PERMISSIONS.find(p => p.permission_code === permCode)?.pk_permission_id;
  if (!moduleId || !permId) return false;
  return ROLE_PERMISSION_MAPPING.some(m =>
    m.map_org_id === user.user_org_id &&
    m.map_role_id === user.user_role_id &&
    m.map_module_id === moduleId &&
    m.map_permission_id === permId
  );
}

// "User Management" has no module in the schema (Madurai Finance's role
// matrix only covers Loan Disbursement / Collection / Audit). For this demo
// we extend Financier (branch head) with full manage rights, Security with
// read-only visibility, and Data Entry Operator with the narrow ability to
// register new customers only (no other roles, no status changes).
function canManageUsers(user) { return roleOf(user).role_name === 'Financier'; }
function canAddCustomer(user) { return ['Financier', 'Data Entry Operator'].includes(roleOf(user).role_name); }
function canViewUsers(user) { return ['Financier', 'Security', 'Data Entry Operator'].includes(roleOf(user).role_name); }
function isDataEntryOperator(user) { return roleOf(user).role_name === 'Data Entry Operator'; }

/* ---------------------------------------------------------------------- */
/* Auth                                                                    */
/* ---------------------------------------------------------------------- */

function getSession() {
  const id = localStorage.getItem(DB_KEYS.session);
  if (!id) return null;
  const user = db.users.find(u => u.pk_user_id === id && u.status === 'ACTIVE');
  return user || null;
}

function login(email, password) {
  const user = db.users.find(u => u.user_email.toLowerCase() === email.trim().toLowerCase());
  if (!user) return { ok: false, error: 'No account found for that email.' };
  if (user.status !== 'ACTIVE') return { ok: false, error: 'This account is disabled. Contact your administrator.' };
  if (user.password !== password) return { ok: false, error: 'Incorrect password.' };
  localStorage.setItem(DB_KEYS.session, user.pk_user_id);
  logAudit(user, 'LOGIN', `${user.user_name} logged in`);
  return { ok: true };
}

function logout() {
  const user = getSession();
  if (user) logAudit(user, 'LOGOUT', `${user.user_name} logged out`);
  localStorage.removeItem(DB_KEYS.session);
  navigate('dashboard');
}

/* ---------------------------------------------------------------------- */
/* Router / render                                                         */
/* ---------------------------------------------------------------------- */

const state = { view: 'dashboard' };

function navigate(view) { state.view = view; render(); }

function render() {
  const root = document.getElementById('app-root');
  const user = getSession();
  if (!user) { root.innerHTML = renderLogin(); bindLoginEvents(); return; }
  root.innerHTML = renderShell(user);
  const content = document.getElementById('view-content');
  content.innerHTML = renderView(state.view, user);
  bindShellEvents(user);
  bindViewEvents(state.view, user);
}

/* ---- Login screen ---- */

function renderLogin() {
  const quickLogins = SEED_USERS.map(u => {
    const role = ROLES.find(r => r.pk_role_id === u.user_role_id);
    return `<button class="quick-login" data-email="${u.user_email}" type="button">
      <span class="ql-role">${role.role_name}</span>
      <span class="ql-name">${u.user_name}</span>
    </button>`;
  }).join('');

  return `
  <div class="login-screen">
    <div class="login-card">
      <div class="login-brand">
        <div class="brand-badge">MF</div>
        <h1>Madurai Finance</h1>
        <p class="muted">Loan Disbursement &middot; Collection &middot; Audit</p>
      </div>
      <form id="login-form">
        <label>Email
          <input type="email" name="email" placeholder="ravi.kumar@maduraifinance.com" required autocomplete="username" />
        </label>
        <label>Password
          <input type="password" name="password" placeholder="test" required autocomplete="current-password" />
        </label>
        <div id="login-error" class="error-text" hidden></div>
        <button type="submit" class="btn btn-primary btn-block">Log In</button>
      </form>
      <div class="login-divider"><span>Quick demo login</span></div>
      <div class="quick-login-grid">${quickLogins}</div>
      <p class="muted small">All demo accounts use password <code>test</code>.</p>
    </div>
  </div>`;
}

function bindLoginEvents() {
  document.getElementById('login-form').addEventListener('submit', e => {
    e.preventDefault();
    const fd = new FormData(e.target);
    const res = login(fd.get('email'), fd.get('password'));
    if (!res.ok) {
      const err = document.getElementById('login-error');
      err.textContent = res.error;
      err.hidden = false;
      return;
    }
    render();
  });
  document.querySelectorAll('.quick-login').forEach(btn => {
    btn.addEventListener('click', () => {
      document.querySelector('#login-form [name="email"]').value = btn.dataset.email;
      document.querySelector('#login-form [name="password"]').value = 'test';
    });
  });
}

/* ---- Shell (header + sidebar) ---- */

function renderShell(user) {
  const role = roleOf(user);
  const items = [{ key: 'dashboard', label: 'Dashboard', show: true }];
  if (canViewUsers(user)) items.push({ key: 'users', label: isDataEntryOperator(user) ? 'Customers' : 'Users', show: true });
  if (can(user, 'LOAN_DISBURSEMENT', 'VIEW')) items.push({ key: 'loans', label: 'Loan Disbursement', show: true });
  if (can(user, 'COLLECTION', 'VIEW')) items.push({ key: 'collections', label: 'Collection', show: true });
  if (can(user, 'AUDIT', 'VIEW')) items.push({ key: 'audit', label: 'Audit', show: true });
  items.push({ key: 'reports', label: 'Reports', show: true });

  const nav = items.map(i =>
    `<button class="nav-item ${state.view === i.key ? 'active' : ''}" data-nav="${i.key}" type="button">${i.label}</button>`
  ).join('');

  return `
  <div class="shell">
    <header class="topbar">
      <div class="topbar-brand"><span class="brand-badge">MF</span> Madurai Finance</div>
      <div class="topbar-user">
        <div class="user-chip">
          <span class="user-name">${escapeHtml(user.user_name)}</span>
          <span class="role-badge role-${role.pk_role_id}">${role.role_name}</span>
        </div>
        <button id="logout-btn" class="btn btn-ghost" type="button">Log Out</button>
      </div>
    </header>
    <div class="shell-body">
      <nav class="sidebar">${nav}</nav>
      <main id="view-content" class="content"></main>
    </div>
  </div>
  <div id="modal-root"></div>`;
}

function bindShellEvents(user) {
  document.getElementById('logout-btn').addEventListener('click', logout);
  document.querySelectorAll('.nav-item').forEach(btn => btn.addEventListener('click', () => navigate(btn.dataset.nav)));
}

/* ---------------------------------------------------------------------- */
/* View router                                                             */
/* ---------------------------------------------------------------------- */

function renderView(view, user) {
  switch (view) {
    case 'users': return canViewUsers(user) ? renderUsersView(user) : renderForbidden();
    case 'loans': return can(user, 'LOAN_DISBURSEMENT', 'VIEW') ? renderLoansView(user) : renderForbidden();
    case 'collections': return can(user, 'COLLECTION', 'VIEW') ? renderCollectionsView(user) : renderForbidden();
    case 'audit': return can(user, 'AUDIT', 'VIEW') ? renderAuditView(user) : renderForbidden();
    case 'reports': return renderReportsView(user);
    case 'dashboard':
    default: return renderDashboardView(user);
  }
}

function bindViewEvents(view, user) {
  switch (view) {
    case 'users': return bindUsersEvents(user);
    case 'loans': return bindLoansEvents(user);
    case 'collections': return bindCollectionsEvents(user);
    case 'reports': return bindReportsEvents(user);
  }
}

function renderForbidden() {
  return `<div class="empty-state"><h2>Access restricted</h2><p class="muted">Your role does not have permission to view this module.</p></div>`;
}

/* ---- Domain helpers ---- */

function loanOutstanding(loan) {
  if (loan.status === 'PENDING' || loan.status === 'APPROVED' || loan.status === 'REJECTED') return null;
  const collected = db.collections.filter(c => c.collection_loan_id === loan.pk_loan_id && c.status === 'SUCCESS')
    .reduce((sum, c) => sum + Number(c.collection_amount), 0);
  return Math.max(0, Number(loan.loan_amount) - collected);
}
function userName(id) { const u = db.users.find(u => u.pk_user_id === id); return u ? u.user_name : id; }
function statusBadge(status) { return `<span class="badge badge-${status}">${status}</span>`; }

/* ---------------------------------------------------------------------- */
/* Dashboard                                                                */
/* ---------------------------------------------------------------------- */

function renderDashboardView(user) {
  const role = roleOf(user);
  const loans = db.loans;
  const collections = db.collections;
  const visibleLoans = role.role_name === 'Customer' ? loans.filter(l => l.loan_user_id === user.pk_user_id) : loans;
  const visibleColls = role.role_name === 'Customer' ? collections.filter(c => c.collection_user_id === user.pk_user_id) : collections;

  const totalDisbursed = visibleLoans.filter(l => ['DISBURSED', 'CLOSED'].includes(l.status)).reduce((s, l) => s + Number(l.loan_amount), 0);
  const totalOutstanding = visibleLoans.reduce((s, l) => s + (loanOutstanding(l) || 0), 0);
  const totalCollected = visibleColls.filter(c => c.status === 'SUCCESS').reduce((s, c) => s + Number(c.collection_amount), 0);
  const activeLoans = visibleLoans.filter(l => l.status === 'DISBURSED').length;

  const cards = [
    { label: 'Total Disbursed', value: fmtCurrency(totalDisbursed) },
    { label: 'Outstanding', value: fmtCurrency(totalOutstanding) },
    { label: 'Total Collected', value: fmtCurrency(totalCollected) },
    { label: 'Active Loans', value: activeLoans }
  ];
  if (isDataEntryOperator(user)) cards.push({ label: 'Customers', value: db.users.filter(u => roleOf(u).role_name === 'Customer').length });
  else if (canViewUsers(user)) cards.push({ label: 'Org Users', value: db.users.length });

  const recentAudit = db.audit.slice(0, 6).map(a =>
    `<li><span class="audit-time">${a.datetime}</span> <strong>${escapeHtml(a.user_name)}</strong> — ${escapeHtml(a.details)}</li>`
  ).join('') || '<li class="muted">No activity yet.</li>';

  return `
  <div class="view-header"><h2>Dashboard</h2><p class="muted">Welcome back, ${escapeHtml(user.user_name)} (${role.role_name})</p></div>
  <div class="card-grid">
    ${cards.map(c => `<div class="stat-card"><div class="stat-value">${c.value}</div><div class="stat-label">${c.label}</div></div>`).join('')}
  </div>
  <div class="panel">
    <h3>Recent Activity</h3>
    <ul class="audit-list">${recentAudit}</ul>
  </div>`;
}

/* ---------------------------------------------------------------------- */
/* Users                                                                    */
/* ---------------------------------------------------------------------- */

function renderUsersView(user) {
  const dataEntry = isDataEntryOperator(user);
  const visibleUsers = dataEntry ? db.users.filter(u => roleOf(u).role_name === 'Customer') : db.users;
  const rows = visibleUsers.map(u => {
    const role = roleOf(u);
    return `<tr>
      <td>${u.pk_user_id}</td>
      <td>${escapeHtml(u.user_name)}</td>
      <td>${escapeHtml(u.user_email)}</td>
      <td><span class="role-badge role-${role.pk_role_id}">${role.role_name}</span></td>
      <td>${statusBadge(u.status)}</td>
      <td>${canManageUsers(user) && u.pk_user_id !== user.pk_user_id
        ? `<button class="btn btn-small" data-action="toggle-user" data-id="${u.pk_user_id}">${u.status === 'ACTIVE' ? 'Disable' : 'Enable'}</button>`
        : ''}</td>
    </tr>`;
  }).join('') || `<tr><td colspan="6" class="muted">No customers yet.</td></tr>`;

  const helpText = dataEntry
    ? 'You can register new customers here. Staff accounts are managed by the Financier.'
    : (!canManageUsers(user) ? 'Read-only view (Security monitors org users).' : '');

  return `
  <div class="view-header">
    <h2>${dataEntry ? 'Customers' : 'Users'}</h2>
    ${canAddCustomer(user) ? `<button class="btn btn-primary" data-action="new-user">+ ${dataEntry ? 'Add Customer' : 'New User'}</button>` : ''}
  </div>
  ${helpText ? `<p class="muted">${helpText}</p>` : ''}
  <table class="data-table">
    <thead><tr><th>ID</th><th>Name</th><th>Email</th><th>Role</th><th>Status</th><th></th></tr></thead>
    <tbody>${rows}</tbody>
  </table>`;
}

function bindUsersEvents(user) {
  document.querySelectorAll('[data-action="toggle-user"]').forEach(btn => {
    btn.addEventListener('click', () => {
      const users = db.users;
      const target = users.find(u => u.pk_user_id === btn.dataset.id);
      target.status = target.status === 'ACTIVE' ? 'DISABLED' : 'ACTIVE';
      db.users = users;
      logAudit(user, 'UPDATE_USER_STATUS', `Set ${target.user_name} (${target.pk_user_id}) to ${target.status}`);
      render();
    });
  });
  const newBtn = document.querySelector('[data-action="new-user"]');
  if (newBtn) newBtn.addEventListener('click', () => openUserModal(user));
}

function openUserModal(user) {
  const dataEntry = isDataEntryOperator(user);
  const customerRoleId = ROLES.find(r => r.role_name === 'Customer').pk_role_id;
  const roleField = dataEntry
    ? `<label>Role <input value="Customer" disabled /><input type="hidden" name="user_role_id" value="${customerRoleId}" /></label>`
    : `<label>Role <select name="user_role_id">${ROLES.map(r => `<option value="${r.pk_role_id}">${r.role_name}</option>`).join('')}</select></label>`;

  showModal(dataEntry ? 'Add New Customer' : 'Create User', `
    <form id="user-form">
      <label>Full Name <input name="user_name" required /></label>
      <label>Email <input type="email" name="user_email" required /></label>
      ${roleField}
      <label>Temporary Password <input name="password" value="test" required /></label>
      <div id="user-form-error" class="error-text" hidden></div>
      <div class="modal-actions">
        <button type="button" class="btn btn-ghost" data-action="close-modal">Cancel</button>
        <button type="submit" class="btn btn-primary">${dataEntry ? 'Add Customer' : 'Create'}</button>
      </div>
    </form>`);
  document.getElementById('user-form').addEventListener('submit', e => {
    e.preventDefault();
    const fd = new FormData(e.target);
    const email = fd.get('user_email').trim().toLowerCase();
    if (db.users.some(u => u.user_email.toLowerCase() === email)) {
      const err = document.getElementById('user-form-error');
      err.textContent = 'A user with that email already exists.';
      err.hidden = false;
      return;
    }
    const users = db.users;
    const newUser = {
      pk_user_id: genUserId(), user_org_id: user.user_org_id, user_name: fd.get('user_name').trim(),
      password: fd.get('password'), user_email: fd.get('user_email').trim(), user_role_id: fd.get('user_role_id'), status: 'ACTIVE'
    };
    users.push(newUser);
    db.users = users;
    logAudit(user, 'CREATE_USER', `Created user ${newUser.user_name} (${roleOf(newUser).role_name})`);
    closeModal();
    render();
  });
}

/* ---------------------------------------------------------------------- */
/* Loan Disbursement                                                        */
/* ---------------------------------------------------------------------- */

function renderLoansView(user) {
  const role = roleOf(user);
  const isCustomer = role.role_name === 'Customer';
  const isSecurity = role.role_name === 'Security';
  const loans = (isCustomer ? db.loans.filter(l => l.loan_user_id === user.pk_user_id) : db.loans)
    .slice().sort((a, b) => b.pk_loan_id.localeCompare(a.pk_loan_id));

  const rows = loans.map(l => {
    const outstanding = loanOutstanding(l);
    const actions = [];
    if (can(user, 'LOAN_DISBURSEMENT', 'APPROVE') && l.status === 'PENDING') {
      actions.push(`<button class="btn btn-small btn-primary" data-action="approve-loan" data-id="${l.pk_loan_id}">Approve</button>`);
      actions.push(`<button class="btn btn-small btn-danger" data-action="reject-loan" data-id="${l.pk_loan_id}">Reject</button>`);
    }
    if (can(user, 'LOAN_DISBURSEMENT', 'DISBURSE') && l.status === 'APPROVED') {
      actions.push(`<button class="btn btn-small btn-primary" data-action="disburse-loan" data-id="${l.pk_loan_id}">Disburse</button>`);
    }
    if (can(user, 'LOAN_DISBURSEMENT', 'RECEIVE') && l.loan_user_id === user.pk_user_id && l.status === 'DISBURSED' && !l.received) {
      actions.push(`<button class="btn btn-small" data-action="receive-loan" data-id="${l.pk_loan_id}">Acknowledge Receipt</button>`);
    }
    if (l.received) actions.push(`<span class="badge badge-DISBURSED">Received</span>`);

    return `<tr>
      <td>${l.pk_loan_id}</td>
      <td>${escapeHtml(userName(l.loan_user_id))}</td>
      <td>${fmtCurrency(l.loan_amount)}</td>
      <td>${l.interest_rate}%</td>
      <td>${l.tenure_months}mo</td>
      <td>${fmtCurrency(outstanding)}</td>
      <td>${statusBadge(l.status)}${isSecurity ? ' <span class="badge badge-MONITOR">MONITOR</span>' : ''}</td>
      <td class="actions-cell">${actions.join(' ')}</td>
    </tr>`;
  }).join('') || `<tr><td colspan="8" class="muted">No loans yet.</td></tr>`;

  return `
  <div class="view-header">
    <h2>Loan Disbursement</h2>
    ${can(user, 'LOAN_DISBURSEMENT', 'CREATE') ? `<button class="btn btn-primary" data-action="new-loan">+ New Loan Application</button>` : ''}
  </div>
  <table class="data-table">
    <thead><tr><th>ID</th><th>Customer</th><th>Amount</th><th>Rate</th><th>Tenure</th><th>Outstanding</th><th>Status</th><th>Actions</th></tr></thead>
    <tbody>${rows}</tbody>
  </table>`;
}

function bindLoansEvents(user) {
  const newBtn = document.querySelector('[data-action="new-loan"]');
  if (newBtn) newBtn.addEventListener('click', () => openLoanModal(user));

  document.querySelectorAll('[data-action="approve-loan"]').forEach(btn => btn.addEventListener('click', () => {
    const loans = db.loans;
    const loan = loans.find(l => l.pk_loan_id === btn.dataset.id);
    loan.status = 'APPROVED';
    loan.approval_date = todayISO();
    db.loans = loans;
    logAudit(user, 'APPROVE_LOAN', `Approved loan ${loan.pk_loan_id} for ${userName(loan.loan_user_id)}`);
    render();
  }));
  document.querySelectorAll('[data-action="reject-loan"]').forEach(btn => btn.addEventListener('click', () => {
    const loans = db.loans;
    const loan = loans.find(l => l.pk_loan_id === btn.dataset.id);
    loan.status = 'REJECTED';
    db.loans = loans;
    logAudit(user, 'REJECT_LOAN', `Rejected loan ${loan.pk_loan_id} for ${userName(loan.loan_user_id)}`);
    render();
  }));
  document.querySelectorAll('[data-action="disburse-loan"]').forEach(btn => btn.addEventListener('click', () => {
    const loans = db.loans;
    const loan = loans.find(l => l.pk_loan_id === btn.dataset.id);
    loan.status = 'DISBURSED';
    loan.disbursement_date = todayISO();
    loan.due_date = addMonths(loan.disbursement_date, loan.tenure_months);
    db.loans = loans;
    logAudit(user, 'DISBURSE_LOAN', `Disbursed ${fmtCurrency(loan.loan_amount)} for loan ${loan.pk_loan_id} to ${userName(loan.loan_user_id)}`);
    render();
  }));
  document.querySelectorAll('[data-action="receive-loan"]').forEach(btn => btn.addEventListener('click', () => {
    const loans = db.loans;
    const loan = loans.find(l => l.pk_loan_id === btn.dataset.id);
    loan.received = true;
    db.loans = loans;
    logAudit(user, 'RECEIVE_LOAN', `${user.user_name} acknowledged receipt of loan ${loan.pk_loan_id}`);
    render();
  }));
}

function openLoanModal(user) {
  const customers = db.users.filter(u => roleOf(u).role_name === 'Customer' && u.status === 'ACTIVE');
  const options = customers.map(c => `<option value="${c.pk_user_id}">${escapeHtml(c.user_name)}</option>`).join('');
  showModal('New Loan Application', `
    <form id="loan-form">
      <label>Customer <select name="loan_user_id" required>${options || '<option disabled>No customers found</option>'}</select></label>
      <label>Amount (₹) <input type="number" name="loan_amount" min="1" step="0.01" required /></label>
      <label>Interest Rate (%) <input type="number" name="interest_rate" min="0" step="0.01" value="10" required /></label>
      <label>Tenure (months) <input type="number" name="tenure_months" min="1" value="12" required /></label>
      <label>Purpose <input name="purpose" placeholder="e.g. Personal loan" /></label>
      <div class="modal-actions">
        <button type="button" class="btn btn-ghost" data-action="close-modal">Cancel</button>
        <button type="submit" class="btn btn-primary">Submit Application</button>
      </div>
    </form>`);
  document.getElementById('loan-form').addEventListener('submit', e => {
    e.preventDefault();
    const fd = new FormData(e.target);
    const loans = db.loans;
    const newLoan = {
      pk_loan_id: genLoanId(), loan_org_id: user.user_org_id, loan_user_id: fd.get('loan_user_id'),
      loan_amount: Number(fd.get('loan_amount')), interest_rate: Number(fd.get('interest_rate')),
      tenure_months: Number(fd.get('tenure_months')), purpose: fd.get('purpose') || null,
      application_date: todayISO(), approval_date: null, disbursement_date: null, due_date: null, status: 'PENDING'
    };
    loans.push(newLoan);
    db.loans = loans;
    logAudit(user, 'CREATE_LOAN', `Created loan ${newLoan.pk_loan_id} (${fmtCurrency(newLoan.loan_amount)}) for ${userName(newLoan.loan_user_id)}`);
    closeModal();
    render();
  });
}

/* ---------------------------------------------------------------------- */
/* Collection                                                               */
/* ---------------------------------------------------------------------- */

function renderCollectionsView(user) {
  const role = roleOf(user);
  const isCustomer = role.role_name === 'Customer';
  const isSecurity = role.role_name === 'Security';
  const colls = (isCustomer ? db.collections.filter(c => c.collection_user_id === user.pk_user_id) : db.collections)
    .slice().sort((a, b) => b.pk_collection_id.localeCompare(a.pk_collection_id));

  const rows = colls.map(c => `<tr>
    <td>${c.pk_collection_id}</td>
    <td>${c.collection_loan_id}</td>
    <td>${escapeHtml(userName(c.collection_user_id))}</td>
    <td>${fmtCurrency(c.collection_amount)}</td>
    <td>${c.collection_date}</td>
    <td>${c.payment_mode}</td>
    <td>${escapeHtml(c.reference_no || '—')}</td>
    <td>${escapeHtml(userName(c.collected_by_user_id))}</td>
    <td>${statusBadge(c.status)}${isSecurity ? ' <span class="badge badge-MONITOR">MONITOR</span>' : ''}</td>
  </tr>`).join('') || `<tr><td colspan="9" class="muted">No collections yet.</td></tr>`;

  const collectableLoans = db.loans.filter(l => l.status === 'DISBURSED' && (loanOutstanding(l) || 0) > 0);

  return `
  <div class="view-header">
    <h2>Collection</h2>
    ${can(user, 'COLLECTION', 'COLLECT') ? `<button class="btn btn-primary" data-action="new-collection" ${collectableLoans.length ? '' : 'disabled'}>+ Record Collection</button>` : ''}
  </div>
  <table class="data-table">
    <thead><tr><th>ID</th><th>Loan</th><th>Customer</th><th>Amount</th><th>Date</th><th>Mode</th><th>Reference</th><th>Collected By</th><th>Status</th></tr></thead>
    <tbody>${rows}</tbody>
  </table>`;
}

function bindCollectionsEvents(user) {
  const newBtn = document.querySelector('[data-action="new-collection"]');
  if (newBtn) newBtn.addEventListener('click', () => openCollectionModal(user));
}

function openCollectionModal(user) {
  const loans = db.loans.filter(l => l.status === 'DISBURSED' && (loanOutstanding(l) || 0) > 0);
  const options = loans.map(l => `<option value="${l.pk_loan_id}">${l.pk_loan_id} — ${escapeHtml(userName(l.loan_user_id))} (Outstanding ${fmtCurrency(loanOutstanding(l))})</option>`).join('');
  showModal('Record Collection', `
    <form id="collection-form">
      <label>Loan <select name="collection_loan_id" required>${options}</select></label>
      <label>Amount (₹) <input type="number" name="collection_amount" min="0.01" step="0.01" required /></label>
      <label>Date <input type="date" name="collection_date" value="${todayISO()}" required /></label>
      <label>Payment Mode
        <select name="payment_mode">
          <option value="CASH">Cash</option>
          <option value="UPI">UPI</option>
          <option value="BANK_TRANSFER">Bank Transfer</option>
          <option value="CHEQUE">Cheque</option>
          <option value="CARD">Card</option>
        </select>
      </label>
      <label>Reference No. <input name="reference_no" placeholder="optional" /></label>
      <label>Remarks <input name="remarks" placeholder="optional" /></label>
      <div id="collection-form-error" class="error-text" hidden></div>
      <div class="modal-actions">
        <button type="button" class="btn btn-ghost" data-action="close-modal">Cancel</button>
        <button type="submit" class="btn btn-primary">Record Payment</button>
      </div>
    </form>`);
  document.getElementById('collection-form').addEventListener('submit', e => {
    e.preventDefault();
    const fd = new FormData(e.target);
    const loan = db.loans.find(l => l.pk_loan_id === fd.get('collection_loan_id'));
    const amount = Number(fd.get('collection_amount'));
    const outstanding = loanOutstanding(loan);
    if (amount > outstanding) {
      const err = document.getElementById('collection-form-error');
      err.textContent = `Amount exceeds outstanding balance of ${fmtCurrency(outstanding)}.`;
      err.hidden = false;
      return;
    }
    const collections = db.collections;
    const newColl = {
      pk_collection_id: genCollId(), collection_org_id: user.user_org_id, collection_loan_id: loan.pk_loan_id,
      collection_user_id: loan.loan_user_id, collection_amount: amount, collection_date: fd.get('collection_date'),
      payment_mode: fd.get('payment_mode'), reference_no: fd.get('reference_no') || null,
      collected_by_user_id: user.pk_user_id, remarks: fd.get('remarks') || null, status: 'SUCCESS'
    };
    collections.push(newColl);
    db.collections = collections;
    logAudit(user, 'COLLECT', `Collected ${fmtCurrency(amount)} against loan ${loan.pk_loan_id} (${newColl.payment_mode})`);

    if (amount >= outstanding) {
      const loans = db.loans;
      const l = loans.find(l => l.pk_loan_id === loan.pk_loan_id);
      l.status = 'CLOSED';
      db.loans = loans;
      logAudit(user, 'CLOSE_LOAN', `Loan ${loan.pk_loan_id} fully repaid and closed`);
    }
    closeModal();
    render();
  });
}

/* ---------------------------------------------------------------------- */
/* Audit                                                                    */
/* ---------------------------------------------------------------------- */

function renderAuditView(user) {
  const rows = db.audit.map(a => `<tr>
    <td>${a.datetime}</td>
    <td>${escapeHtml(a.user_name)}</td>
    <td><span class="badge badge-AUDIT">${a.action.replace(/_/g, ' ')}</span></td>
    <td>${escapeHtml(a.details)}</td>
  </tr>`).join('') || `<tr><td colspan="4" class="muted">No audit entries yet.</td></tr>`;

  return `
  <div class="view-header"><h2>Audit Trail</h2><p class="muted">${roleOf(user).role_name === 'Security' ? 'Full monitoring access.' : 'Read-only activity log.'}</p></div>
  <table class="data-table">
    <thead><tr><th>Timestamp</th><th>User</th><th>Action</th><th>Details</th></tr></thead>
    <tbody>${rows}</tbody>
  </table>`;
}

/* ---------------------------------------------------------------------- */
/* Reports                                                                  */
/* ---------------------------------------------------------------------- */

function renderReportsView(user) {
  const role = roleOf(user).role_name;
  if (role === 'Financier') return reportLoanPortfolio();
  if (role === 'Collection Agent') return reportCollectionPerformance();
  if (role === 'Security') return reportLoanPortfolio() + reportCollectionPerformance();
  if (role === 'Customer') return reportCustomerStatement(user);
  if (role === 'Data Entry Operator') return reportLoanPortfolio();
  return '<p class="muted">No reports available.</p>';
}
function bindReportsEvents() {}

function bar(label, value, max) {
  const pct = max > 0 ? Math.round((value / max) * 100) : 0;
  return `<div class="bar-row">
    <div class="bar-label">${escapeHtml(label)}</div>
    <div class="bar-track"><div class="bar-fill" style="width:${pct}%"></div></div>
    <div class="bar-value">${fmtCurrency(value)}</div>
  </div>`;
}

function reportLoanPortfolio() {
  const loans = db.loans;
  const byStatus = {};
  loans.forEach(l => { byStatus[l.status] = (byStatus[l.status] || 0) + Number(l.loan_amount); });
  const max = Math.max(1, ...Object.values(byStatus));
  const rows = loans.map(l => `<tr>
    <td>${l.pk_loan_id}</td><td>${escapeHtml(userName(l.loan_user_id))}</td>
    <td>${fmtCurrency(l.loan_amount)}</td><td>${fmtCurrency(loanOutstanding(l))}</td><td>${statusBadge(l.status)}</td>
  </tr>`).join('');

  return `
  <div class="panel">
    <h3>Loan Portfolio Report</h3>
    <div class="bars">${Object.entries(byStatus).map(([s, v]) => bar(s, v, max)).join('')}</div>
    <table class="data-table">
      <thead><tr><th>Loan</th><th>Customer</th><th>Amount</th><th>Outstanding</th><th>Status</th></tr></thead>
      <tbody>${rows}</tbody>
    </table>
  </div>`;
}

function reportCollectionPerformance() {
  const colls = db.collections.filter(c => c.status === 'SUCCESS');
  const byMode = {};
  colls.forEach(c => { byMode[c.payment_mode] = (byMode[c.payment_mode] || 0) + Number(c.collection_amount); });
  const max = Math.max(1, ...Object.values(byMode));
  const byAgent = {};
  colls.forEach(c => { const n = userName(c.collected_by_user_id); byAgent[n] = (byAgent[n] || 0) + Number(c.collection_amount); });

  return `
  <div class="panel">
    <h3>Collection Performance Report</h3>
    <p class="muted">Total collected: <strong>${fmtCurrency(colls.reduce((s, c) => s + Number(c.collection_amount), 0))}</strong></p>
    <h4>By Payment Mode</h4>
    <div class="bars">${Object.entries(byMode).map(([m, v]) => bar(m, v, max)).join('')}</div>
    <h4>By Collection Agent</h4>
    <div class="bars">${Object.entries(byAgent).map(([a, v]) => bar(a, v, Math.max(1, ...Object.values(byAgent)))).join('')}</div>
  </div>`;
}

function reportCustomerStatement(user) {
  const loans = db.loans.filter(l => l.loan_user_id === user.pk_user_id);
  const colls = db.collections.filter(c => c.collection_user_id === user.pk_user_id);
  const loanRows = loans.map(l => `<tr><td>${l.pk_loan_id}</td><td>${fmtCurrency(l.loan_amount)}</td><td>${fmtCurrency(loanOutstanding(l))}</td><td>${statusBadge(l.status)}</td></tr>`).join('') || `<tr><td colspan="4" class="muted">No loans.</td></tr>`;
  const collRows = colls.map(c => `<tr><td>${c.collection_date}</td><td>${c.collection_loan_id}</td><td>${fmtCurrency(c.collection_amount)}</td><td>${c.payment_mode}</td></tr>`).join('') || `<tr><td colspan="4" class="muted">No payments yet.</td></tr>`;

  return `
  <div class="panel">
    <h3>My Statement</h3>
    <h4>Loans</h4>
    <table class="data-table"><thead><tr><th>Loan</th><th>Amount</th><th>Outstanding</th><th>Status</th></tr></thead><tbody>${loanRows}</tbody></table>
    <h4>Payment History</h4>
    <table class="data-table"><thead><tr><th>Date</th><th>Loan</th><th>Amount</th><th>Mode</th></tr></thead><tbody>${collRows}</tbody></table>
  </div>`;
}

/* ---------------------------------------------------------------------- */
/* Modal helper                                                             */
/* ---------------------------------------------------------------------- */

function showModal(title, bodyHtml) {
  document.getElementById('modal-root').innerHTML = `
    <div class="modal-overlay" data-action="close-modal">
      <div class="modal-card" data-stop>
        <div class="modal-header"><h3>${title}</h3><button class="modal-close" data-action="close-modal">&times;</button></div>
        <div class="modal-body">${bodyHtml}</div>
      </div>
    </div>`;
  document.querySelectorAll('[data-action="close-modal"]').forEach(el => el.addEventListener('click', closeModal));
  document.querySelector('[data-stop]').addEventListener('click', e => e.stopPropagation());
}
function closeModal() { document.getElementById('modal-root').innerHTML = ''; }

/* ---------------------------------------------------------------------- */
/* Init                                                                     */
/* ---------------------------------------------------------------------- */

seedIfEmpty();
render();
