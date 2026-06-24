# Madurai Finance - Database Schema

## Tables
| Table | Purpose |
|---|---|
| `org_info` | Organisation / Tenant details |
| `role_master` | Roles defined per organisation |
| `module_master` | System-wide modules |
| `permission_master` | Action verbs (VIEW, CREATE, etc.) |
| `role_permission_mapping` | Role ↔ Module ↔ Permission matrix |
| `user_info` | User profiles |

## Modules
| ID | Name | Code |
|---|---|---|
| MOD001 | Loan Disbursement | LOAN_DISBURSEMENT |
| MOD002 | Collection | COLLECTION |
| MOD003 | Audit | AUDIT |

## Roles & Permissions Matrix
| Role | Loan Disbursement | Collection | Audit |
|---|---|---|---|
| Financier | VIEW, CREATE, APPROVE, DISBURSE | — | VIEW |
| Collection Agent | — | VIEW, COLLECT | VIEW |
| Customer | VIEW, RECEIVE | VIEW | — |
| Security | VIEW, MONITOR | VIEW, MONITOR | VIEW, MONITOR |

## Setup
```sql
-- 1. Run schema first
source schema.sql

-- 2. Then seed data
source seed_data.sql
```
