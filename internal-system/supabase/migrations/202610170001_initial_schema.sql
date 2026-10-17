-- Tshwane College Internal Operations Platform
-- Initial schema scaffold for review; not applied to any database.
-- Apply only to a dedicated development project after reviewing roles and policies.
-- RLS is enabled on every application table. Policies are deliberately conservative.
-- Device/network restrictions must be enforced by the hosting/identity gateway; SQL cannot identify an approved physical computer by itself.

create extension if not exists pgcrypto;

create type public.staff_role as enum ('admin', 'team_leader', 'agent', 'approver');
create type public.task_status as enum ('backlog', 'todo', 'in_progress', 'blocked', 'in_review', 'done', 'cancelled');
create type public.task_priority as enum ('low', 'normal', 'high', 'urgent');
create type public.social_stage as enum ('idea', 'drafting', 'awaiting_approval', 'approved', 'scheduled', 'published', 'rejected');

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text not null,
  role public.staff_role not null default 'agent',
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.tasks (
  id uuid primary key default gen_random_uuid(),
  title text not null check (length(trim(title)) between 1 and 200),
  description text,
  project text,
  status public.task_status not null default 'todo',
  priority public.task_priority not null default 'normal',
  assignee_id uuid references public.profiles(id) on delete set null,
  created_by uuid not null references public.profiles(id),
  due_at timestamptz,
  completed_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.task_comments (
  id uuid primary key default gen_random_uuid(),
  task_id uuid not null references public.tasks(id) on delete cascade,
  author_id uuid not null references public.profiles(id),
  body text not null check (length(trim(body)) between 1 and 5000),
  created_at timestamptz not null default now()
);

create table public.social_posts (
  id uuid primary key default gen_random_uuid(),
  title text not null check (length(trim(title)) between 1 and 200),
  platform text not null check (platform in ('facebook','instagram','tiktok','linkedin','youtube','other')),
  caption text,
  owner_id uuid references public.profiles(id) on delete set null,
  created_by uuid not null references public.profiles(id),
  planned_at timestamptz,
  stage public.social_stage not null default 'idea',
  approval_by uuid references public.profiles(id) on delete set null,
  approval_note text,
  published_url text,
  published_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.audit_events (
  id bigint generated always as identity primary key,
  actor_id uuid references public.profiles(id) on delete set null,
  action text not null,
  entity_type text not null,
  entity_id text not null,
  summary jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create index tasks_assignee_status_idx on public.tasks (assignee_id, status);
create index tasks_due_at_idx on public.tasks (due_at) where due_at is not null;
create index task_comments_task_created_idx on public.task_comments (task_id, created_at);
create index social_posts_stage_planned_idx on public.social_posts (stage, planned_at);
create index audit_events_created_idx on public.audit_events (created_at desc);

-- Role helper: use only for authorization decisions; never allow users to edit their own role.
create or replace function public.current_staff_role()
returns public.staff_role
language sql
stable
security definer
set search_path = ''
as $$
  select p.role
  from public.profiles p
  where p.id = (select auth.uid())
    and p.is_active = true
  limit 1
$$;

create or replace function public.is_active_staff()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.profiles p
    where p.id = (select auth.uid()) and p.is_active = true
  )
$$;

alter table public.profiles enable row level security;
alter table public.tasks enable row level security;
alter table public.task_comments enable row level security;
alter table public.social_posts enable row level security;
alter table public.audit_events enable row level security;

-- Profiles: active staff can view directory; only admins can change role/active state.
create policy "active staff can view profiles"
on public.profiles for select to authenticated
using (public.is_active_staff());

create policy "admins can insert profiles"
on public.profiles for insert to authenticated
with check (public.current_staff_role() = 'admin');

create policy "admins can update profiles"
on public.profiles for update to authenticated
using (public.current_staff_role() = 'admin')
with check (public.current_staff_role() = 'admin');

-- Tasks: managers see all; agents see tasks they created or are assigned.
create policy "staff can read permitted tasks"
on public.tasks for select to authenticated
using (
  public.is_active_staff()
  and (
    public.current_staff_role() in ('admin','team_leader')
    or assignee_id = (select auth.uid())
    or created_by = (select auth.uid())
  )
);

create policy "admins and team leaders create tasks"
on public.tasks for insert to authenticated
with check (
  public.is_active_staff()
  and public.current_staff_role() in ('admin','team_leader')
  and created_by = (select auth.uid())
);

create policy "admins and team leaders update tasks"
on public.tasks for update to authenticated
using (public.is_active_staff() and public.current_staff_role() in ('admin','team_leader'))
with check (public.is_active_staff() and public.current_staff_role() in ('admin','team_leader'));

create policy "assignees can update assigned task status fields"
on public.tasks for update to authenticated
using (public.is_active_staff() and assignee_id = (select auth.uid()))
with check (public.is_active_staff() and assignee_id = (select auth.uid()));

create policy "admins can delete tasks"
on public.tasks for delete to authenticated
using (public.current_staff_role() = 'admin');

-- Comments follow task visibility; author identity is the authenticated user.
create policy "staff can read comments on permitted tasks"
on public.task_comments for select to authenticated
using (exists (
  select 1 from public.tasks t
  where t.id = task_id and (
    public.current_staff_role() in ('admin','team_leader')
    or t.assignee_id = (select auth.uid())
    or t.created_by = (select auth.uid())
  )
));

create policy "staff can comment on permitted tasks"
on public.task_comments for insert to authenticated
with check (
  author_id = (select auth.uid())
  and exists (
    select 1 from public.tasks t
    where t.id = task_id and (
      public.current_staff_role() in ('admin','team_leader')
      or t.assignee_id = (select auth.uid())
      or t.created_by = (select auth.uid())
    )
  )
);

-- Social content: staff see assigned content; managers and approvers see all.
create policy "staff can read permitted social posts"
on public.social_posts for select to authenticated
using (
  public.is_active_staff()
  and (
    public.current_staff_role() in ('admin','team_leader','approver')
    or owner_id = (select auth.uid())
    or created_by = (select auth.uid())
  )
);

create policy "admins team leaders and agents create social posts"
on public.social_posts for insert to authenticated
with check (
  public.is_active_staff()
  and public.current_staff_role() in ('admin','team_leader','agent')
  and created_by = (select auth.uid())
);

create policy "content owners and managers update drafts"
on public.social_posts for update to authenticated
using (
  public.is_active_staff()
  and (
    public.current_staff_role() in ('admin','team_leader')
    or (owner_id = (select auth.uid()) and stage in ('idea','drafting','rejected'))
  )
)
with check (
  public.is_active_staff()
  and (
    public.current_staff_role() in ('admin','team_leader')
    or (owner_id = (select auth.uid()) and stage in ('idea','drafting','rejected'))
  )
);

create policy "approvers can update approval state"
on public.social_posts for update to authenticated
using (public.is_active_staff() and public.current_staff_role() = 'approver')
with check (public.is_active_staff() and public.current_staff_role() = 'approver');

create policy "admins can delete social posts"
on public.social_posts for delete to authenticated
using (public.current_staff_role() = 'admin');

-- Audit events are read-only to administrators and team leaders from the app.
-- Inserts should be emitted by trusted server-side code or database triggers only.
create policy "admins and team leaders can read audit events"
on public.audit_events for select to authenticated
using (public.is_active_staff() and public.current_staff_role() in ('admin','team_leader'));

-- Explicit grants: RLS remains the row-level guardrail.
grant usage on schema public to authenticated;
grant select on public.profiles, public.tasks, public.task_comments, public.social_posts, public.audit_events to authenticated;
grant insert, update on public.tasks, public.social_posts to authenticated;
grant insert on public.task_comments to authenticated;
grant insert, update on public.profiles to authenticated;
-- Deliberately no client grant to write audit_events.
