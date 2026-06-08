-- profiles table
create table profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  role text not null check (role in ('agency_owner', 'caregiver')),
  full_name text,
  created_at timestamptz default now()
);

-- RLS
alter table profiles enable row level security;

create policy "Users can read own profile"
  on profiles for select
  using (auth.uid() = id);

create policy "Users can update own profile"
  on profiles for update
  using (auth.uid() = id);

-- Auto-create profile on signup (defaults to agency_owner)
-- Caregiver accounts are created programmatically in Phase 4
create or replace function handle_new_user()
returns trigger as $$
begin
  insert into profiles (id, role)
  values (new.id, 'agency_owner');
  return new;
end;
$$ language plpgsql security definer;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure handle_new_user();
