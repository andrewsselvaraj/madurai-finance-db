# Madurai Finance

Role-based loan management app: **Spring Boot 3 (Java 17) API** + **React 18 (Vite) UI**
on the `etfdb_dev` MySQL schema.

```
backend/    Spring Boot API (JPA, Spring Security session auth)
frontend/   React SPA (Vite, react-router)
app/        Legacy vanilla-JS demo (localStorage only) — superseded, kept for reference
*.sql       Original schema / seed / phpMyAdmin dumps
```

## Run it (dev)

Prerequisites: JDK 17+, Maven 3.9+, Node 18+.

```bash
# 1. API on http://localhost:8080 — in-memory H2 seeded with the demo data
cd backend
mvn spring-boot:run

# 2. UI on http://localhost:5173 — proxies /api to :8080
cd frontend
npm install
npm run dev
```

Demo logins (password `test`): Financier `ravi.kumar@maduraifinance.com`,
Collection Agent `priya.devi@…`, Customer `murugan.k@…`, Security `suresh.v@…`,
Data Entry Operator `kavitha.m@…`.

### Against MySQL (etfdb_dev)

```sql
source etfdb_dev.sql
source backend/db/mysql/app_additions.sql   -- audit_log table, loan_info.received_date, Data Entry Operator role/user
```

```bash
cd backend
DB_USERNAME=root DB_PASSWORD=secret mvn spring-boot:run -Dspring-boot.run.profiles=mysql
```

`DB_URL` defaults to `jdbc:mysql://localhost:3306/etfdb_dev`.

### Single deployable jar

```bash
cd frontend && npm run build      # writes into backend/src/main/resources/static
cd ../backend && mvn package      # target/madurai-finance-0.1.0.jar serves UI + API on :8080
```

### Tests

```bash
cd backend && mvn test
```

## API

All endpoints are under `/api`, JSON in/out, errors as `{"error": "..."}`. Auth is a session cookie.

| Method | Path | Who |
|---|---|---|
| POST | `/auth/login` `{email, password}` | anyone |
| POST | `/auth/logout` | logged in |
| GET | `/auth/me` | logged in — user, role, `permissions` (`MODULE:PERM`) |
| GET | `/auth/demo-accounts` | anyone (configured by `app.demo-accounts`) |
| GET | `/dashboard`, `/reports` | logged in (content depends on role) |
| GET / POST | `/users`, POST `/users/{id}/toggle-status`, GET `/roles` | Financier (manage), Security (view), DEO (customers only) |
| GET / POST | `/loans`, GET `/loans/customers` | `LOAN_DISBURSEMENT` VIEW / CREATE |
| POST | `/loans/{id}/approve` · `/reject` · `/disburse` · `/receive` | APPROVE · APPROVE · DISBURSE · RECEIVE |
| GET / POST | `/collections`, GET `/collections/collectable-loans` | `COLLECTION` VIEW / COLLECT |
| GET | `/audit` | `AUDIT` VIEW |

Customers only ever see their own loans and payments. Every write is recorded in `audit_log`.

## Database

### Tables
| Table | Purpose |
|---|---|
| `org_info` | Organisation / Tenant details |
| `role_master` | Roles defined per organisation |
| `module_master` | System-wide modules |
| `permission_master` | Action verbs (VIEW, CREATE, etc.) |
| `role_permission_mapping` | Role ↔ Module ↔ Permission matrix |
| `user_info` | User profiles |
| `loan_info` | Loans given to customers |
| `loan_collection` | Repayments collected against loans |
| `audit_log` | Activity trail (added by `app_additions.sql`) |

### Modules
| ID | Name | Code |
|---|---|---|
| MOD001 | Loan Disbursement | LOAN_DISBURSEMENT |
| MOD002 | Collection | COLLECTION |
| MOD003 | Audit | AUDIT |

### Roles & Permissions Matrix
| Role | Loan Disbursement | Collection | Audit |
|---|---|---|---|
| Financier | VIEW, CREATE, APPROVE, DISBURSE | — | VIEW |
| Collection Agent | — | VIEW, COLLECT | VIEW |
| Customer | VIEW, RECEIVE | VIEW | — |
| Security | VIEW, MONITOR | VIEW, MONITOR | VIEW, MONITOR |
| Data Entry Operator | VIEW, CREATE | — | — |

### Passwords
`user_info.password` rows from the dump are plain text. The API accepts them as-is and stores
new users' passwords as `{bcrypt}…` hashes; re-hash existing rows before any real deployment.
