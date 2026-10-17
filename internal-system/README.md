# Tshwane College Internal Operations Prototype

A separate demo module for internal task coordination, social media planning, workload allocation and progress monitoring.

## Open the demo
After GitHub Pages deploys the branch/site, open:
`/internal-system/`

## Included in this prototype
- Management dashboard with task and social pipeline summaries
- Task creation, assignment, priorities, due dates and status updates
- Social post planner with platform, owner, planned date, approval/publishing stage and content brief
- Agent list and workload indicators
- Progress reporting and CSV export
- Responsive layout for desktop and mobile
- Browser-local persistence using localStorage

## Important limitations
This is a **front-end demonstration only**. GitHub Pages serves static files. Changes are saved only in the browser and are not shared with other agents or devices. The demo has no secure authentication, server-side database, audit log, email notifications, file storage or live social media integrations. Do not enter confidential student, staff or institutional data.

Before real use, connect a secure backend/database and implement role-based access (management, agent, approver), shared records, audit history, backups, privacy controls and notifications. Social publishing/analytics integrations should be added only after the college authorises the accounts and API access.

## Demo data
The dashboard starts with fictional sample tasks and agents. Changes can be cleared for a clean demo by clearing this site's local storage in the browser.
