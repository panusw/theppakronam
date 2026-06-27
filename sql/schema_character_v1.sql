-- =============================================================
-- เทพปกรณัม — schema_character_v1.sql
-- รันไฟล์นี้ใน Supabase Dashboard > SQL Editor
-- =============================================================

-- ============================================================
-- Table: players  (one row per character slot, max 3 per auth user)
-- ============================================================

create table if not exists public.players (
  id              uuid         primary key default gen_random_uuid(),
  user_id         uuid         not null references auth.users(id) on delete cascade,

  -- Identity
  name            text         not null check (char_length(trim(name)) between 1 and 24),
  appearance      jsonb        not null default '{}',
  difficulty      text         not null default 'normal'
                               check (difficulty in ('normal','hard','ascendant','eternal')),
  char_type       text         not null default 'online'
                               check (char_type in ('online','offline')),
  is_guest        boolean      not null default false,
  guest_device_id text,
  death_locked    boolean      not null default false,

  -- Progression
  divinity_level  int          not null default 0  check (divinity_level between 0 and 10),
  divinity_exp    int          not null default 0  check (divinity_exp >= 0),

  -- Tower position
  current_band    int          not null default 1,
  current_floor   int          not null default 1,
  current_camp_id uuid,

  -- Survival
  hunger          numeric(5,2) not null default 100 check (hunger  between 0 and 100),
  thirst          numeric(5,2) not null default 100 check (thirst  between 0 and 100),
  fatigue         numeric(5,2) not null default 100 check (fatigue between 0 and 100),

  -- Energy
  world_energy    int          not null default 100 check (world_energy  between 0 and 100),
  battle_energy   int          not null default 10  check (battle_energy between 0 and 10),

  -- Economy
  gold            int          not null default 0   check (gold >= 0),
  gems            int          not null default 0   check (gems >= 0),
  gacha_pity      int          not null default 0   check (gacha_pity between 0 and 50),

  -- Badges (FK เพิ่มทีหลังเมื่อมี achievements table)
  badge_slot_1    uuid,
  badge_slot_2    uuid,
  badge_slot_3    uuid,

  -- Band travel cooldown
  band_travel_cooldown_until timestamptz,

  -- Soft delete
  deleted_at      timestamptz,

  created_at      timestamptz  not null default now(),
  updated_at      timestamptz  not null default now()
);

comment on table public.players is 'Character slots — max 3 active per auth user';

-- ============================================================
-- RLS
-- ============================================================

alter table public.players enable row level security;

create policy "players_select_own"
  on public.players for select
  using (auth.uid() = user_id);

create policy "players_update_own"
  on public.players for update
  using (auth.uid() = user_id);

-- Insert only allowed via create_character() RPC (security definer)
-- No direct insert policy intentionally

-- ============================================================
-- Trigger: updated_at
-- ============================================================

create or replace function public.set_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger players_set_updated_at
  before update on public.players
  for each row execute function public.set_updated_at();

-- ============================================================
-- View: active_characters  (ซ่อน soft-deleted rows)
-- ============================================================

create or replace view public.active_characters as
  select * from public.players
  where deleted_at is null;

-- ============================================================
-- Function: create_character
-- เรียกจาก CharacterCreator.gd → SupabaseClient.call_rpc("create_character", {...})
-- Parameters ต้องตรงกับที่ Godot ส่งมา
-- ============================================================

create or replace function public.create_character(
  p_player_id  uuid,   -- auth.users.id  (= GameState.player_id)
  p_name       text,
  p_appearance jsonb
)
returns public.players
language plpgsql
security definer
set search_path = public
as $$
declare
  v_count      int;
  v_new_player public.players;
begin
  -- ตรวจว่า caller เป็น user คนเดียวกัน
  if auth.uid() is null or auth.uid() != p_player_id then
    raise exception 'Unauthorized' using errcode = 'PGRST301';
  end if;

  -- ตรวจชื่อ
  if char_length(trim(p_name)) = 0 then
    raise exception 'Name cannot be empty';
  end if;

  -- ตรวจ slot limit (max 3 active per account)
  select count(*) into v_count
    from public.players
   where user_id    = p_player_id
     and deleted_at is null;

  if v_count >= 3 then
    raise exception 'Character slot limit reached (max 3)';
  end if;

  -- สร้าง character
  insert into public.players (user_id, name, appearance)
  values (p_player_id, trim(p_name), p_appearance)
  returning * into v_new_player;

  return v_new_player;
end;
$$;

grant execute on function public.create_character(uuid, text, jsonb) to authenticated;
