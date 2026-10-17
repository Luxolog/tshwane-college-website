# Operations Runbook — Internal Operations Platform

This runbook is a checklist for the future production owner. No production service or backup schedule is configured by this repository commit.

## Daily checks
- Check application availability and authentication errors.
- Check database/storage health, capacity, and failed scheduled jobs.
- Confirm the most recent successful database backup and independent file/export backup.
- Review unusual sign-in attempts, repeated failures, and privilege changes.
- Escalate any missing backup or suspected account compromise to the designated administrator.

## Account lifecycle
1. Management approves a staff member and role.
2. Administrator invites a unique named account; do not share passwords.
3. Require MFA where supported and provide only the minimum role needed.
4. On departure or role change, disable access promptly, revoke active sessions/tokens where supported, and review assigned tasks and content.
5. Do not store passwords, recovery codes, API tokens, or database credentials in GitHub.

## Backup policy
- Database: automated daily backups on a production tier that explicitly includes them.
- Independent copy: schedule a server-side encrypted export to separate private storage.
- Files: back up private object storage separately; database backup alone is not enough for uploaded files.
- Retention: management to approve retention based on operational and privacy requirements.
- Monitoring: alert the designated administrator if a backup fails or is older than 24 hours.

## Restore test (monthly, isolated environment)
1. Announce the test and identify a designated operator and reviewer.
2. Choose a known backup and record its timestamp.
3. Restore into a separate recovery project/environment, never over production.
4. Verify login works for test accounts, expected tables/row counts are present, relationships and recent changes are consistent, and required files can be retrieved from their separate backup.
5. Run role-access tests for administrator, team leader, agent, approver, and unauthenticated visitor.
6. Record start/end time, recovery point, errors, validation results and sign-off.
7. Delete the temporary recovery environment securely after approval, following the provider's documented process.

## Incident response
- Suspected account/device compromise: disable the account or revoke sessions, notify the designated administrator, preserve relevant logs, and rotate affected credentials.
- Suspected data exposure: restrict access first, preserve evidence, notify college management/privacy lead, and follow the college incident response and legal obligations.
- Failed restore: do not claim recovery is complete; preserve the failed test evidence and resolve before production approval.

## Initial targets for approval
- RPO: no more than 24 hours of changes lost.
- RTO: restore core task/social workflows within one business day.
These are proposed targets, not service guarantees. Confirm they meet college requirements before launch.
