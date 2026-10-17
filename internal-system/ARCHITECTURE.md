# Tshwane College Internal Operations Platform — Architecture & Delivery Plan

## Status
Planning and development scaffold only. This repository is currently **public**. Do not commit credentials, secrets, real staff/student data, private posts, or operational records here. A branch in a public repository is public too.

The existing public college website and `student-portal/` are out of scope and must remain unchanged. Work stays on `internal-operations-prototype` until reviewed. No production deployment, live database, or access policy has been configured by this change.

## Confirmed requirements
- Team size: 16–50 staff
- Access: approved office computers and authorised accounts only
- Daily backups and a tested recovery procedure
- Flexible budget where needed for reliability/security
- Functional areas: overview, task board, social media planning, agents/workload, reports
- Roles: Management/Administrator, Team Leader, Staff Member/Agent, Approver

## Proposed architecture
1. **Private application hosting** — serve the app behind an access gateway. Do not publish the operational app on GitHub Pages.
2. **Identity** — managed authentication with individual accounts, MFA where supported, invitation-only onboarding, prompt offboarding, and no shared logins.
3. **Device/network gate** — enforce approved devices at the identity provider or reverse proxy (managed-device compliance or client certificates) and permit access only from the college LAN or a college-managed VPN. An IP allowlist alone is not proof that a device is approved.
4. **Database** — managed PostgreSQL (Supabase is the initial candidate), with Row Level Security (RLS) on every exposed table and least-privilege grants.
5. **Application permissions** — role-based access enforced in both server-side actions and database policies. UI hiding is not security.
6. **Audit trail** — record task/post status changes, assignment changes, approvals, role changes and administrative actions; prevent ordinary users from editing audit history.
7. **Files** — private object storage only, with access policies and a retention policy.
8. **Operations** — daily backups, separate off-site/exported backup for critical data, documented restore steps, and scheduled restore tests.
9. **Integrations** — add email notifications and official social platform APIs only after approval, credentials management and permission review.

## Proposed permission matrix
| Capability | Management/Admin | Team Leader | Agent | Approver |
|---|---|---|---|---|
| Manage users and roles | Yes | No | No | No |
| View all tasks/workload | Yes | Yes | Assigned tasks; optionally team tasks | Tasks assigned for review |
| Create/assign tasks | Yes | Yes | No by default | No by default |
| Update assigned task | Yes | Yes | Yes | Only if assigned |
| Create/edit social drafts | Yes | Yes | Yes, where assigned | No by default |
| Approve/reject content | Yes | Optional if granted | No | Yes |
| View management reports | Yes | Yes | Own workload only | Approval queue/report |
| Read audit history | Yes | Limited team scope if authorised | No | Approval actions only if authorised |

Permissions should be configurable to match the college's actual reporting structure.

## Implementation stages
### Stage 1 — foundation (next)
- Keep this work on the separate branch.
- Add database migration, policy-test checklist, environment-variable template and operational runbook.
- Create a **private** repository or otherwise move this code into a private source repository before real internal workflows are added.
- Create separate development and production backend projects; use fictional test data in development only.
- Configure approved-device enforcement, authentication, RLS and role assignment.
- Verify deny-by-default access with positive and negative tests.

### Stage 2 — workflow
- Replace browser-local storage with authenticated shared database operations.
- Add task comments, assignment history, due-date notifications and audit records.
- Add social content calendar, approval/rejection comments and publication log.
- Add management dashboards and export controls.

### Stage 3 — production readiness
- Configure private hosting and TLS.
- Configure daily backups and independent export/off-site backup for critical records.
- Test restore to a separate recovery environment and record results.
- Test staff onboarding/offboarding, role boundaries, session expiry and lost-device response.
- Review privacy, retention and incident response requirements with college management before using real data.

## Backup and recovery baseline
- Managed PostgreSQL paid production tier with automatic daily backups; confirm retention in the chosen plan before sign-off.
- Nightly logical export to a separate private storage location, encrypted in transit and at rest; keep backup credentials out of the repository.
- Back up uploaded objects separately; database backups generally contain object metadata, not the object contents.
- Suggested initial targets: Recovery Point Objective (RPO) 24 hours maximum and Recovery Time Objective (RTO) 1 business day maximum, subject to management approval.
- Monthly restore exercise to an isolated recovery project; record backup date, restore duration, row/file counts, validation checks and reviewer. Do not test restoration over production.
- Restrict backup access to designated administrators; log and review restore/export activity.

## Acceptance checklist before real use
- [ ] Source repository private; no secrets or real records in Git history
- [ ] Production app not hosted on GitHub Pages
- [ ] Approved-device and office-network/VPN gate verified from an unapproved device/network
- [ ] MFA enabled where supported; invitation-only accounts and offboarding tested
- [ ] RLS enabled on every exposed table and access tests pass for anonymous, agent, approver, team leader and administrator
- [ ] Service-role/database credentials stored only in server-side secret storage
- [ ] Audit trail cannot be modified by ordinary users
- [ ] Daily backup confirmed; object storage separately covered
- [ ] Restore test completed and signed off
- [ ] College-approved privacy, retention and incident-response rules documented

## Important deployment note
The current prototype stores data in each browser's localStorage and has no authentication or shared backend. It is not suitable for operational use. The SQL migration in this branch is a starting schema for review, not a live database change. Do not enter confidential information until the controls above have been configured and tested.
