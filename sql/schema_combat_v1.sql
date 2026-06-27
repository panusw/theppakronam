-- =============================================================
-- เทพปกรณัม — schema_combat_v1.sql
-- รันหลัง schema_tower_v2.sql และ schema_core_v2.sql
-- =============================================================

-- ============================================================
-- enemy_templates  (master data — read-only for clients)
-- ============================================================

create table if not exists public.enemy_templates (
  id                    uuid    primary key default gen_random_uuid(),
  name_th               text    not null,
  name_en               text    not null,
  band_id               int     references public.tower_bands(id),
  camp_types            text[]  not null default '{"normal"}',
  hp                    int     not null default 50,
  atk                   int     not null default 8,
  defense               int     not null default 3,
  spd                   int     not null default 6,
  energy                int     not null default 10,
  energy_regen          int     not null default 1,
  hp_regen              int     not null default 0,
  crit_rate             float   not null default 0.05,
  crit_dmg              float   not null default 0.50,
  ai_archetype          text    not null default 'berserker',
  durability_damage_mult float  not null default 1.0,
  is_capturable         boolean not null default true,
  capture_base_rate     float   not null default 0.20,
  sprite_path           text,
  created_at            timestamptz not null default now()
);

alter table public.enemy_templates enable row level security;
create policy "enemy_templates_read_all" on public.enemy_templates
  for select using (true);

-- ============================================================
-- enemy_patterns  (per-turn action probability table)
-- ============================================================

create table if not exists public.enemy_patterns (
  id              uuid    primary key default gen_random_uuid(),
  enemy_id        uuid    not null references public.enemy_templates(id) on delete cascade,
  phase_index     int     not null default 0,  -- 0 = all phases, 1+ = specific phase
  action_type     text    not null,             -- 'attack'/'heavy_attack'/'defend'/'heal'/'taunt'
  weight          int     not null default 10,
  energy_cost     int     not null default 0,
  damage_mult     float   not null default 1.0,
  unique (enemy_id, phase_index, action_type)
);

alter table public.enemy_patterns enable row level security;
create policy "enemy_patterns_read_all" on public.enemy_patterns
  for select using (true);

-- ============================================================
-- boss_templates  (boss-specific config)
-- ============================================================

create table if not exists public.boss_templates (
  id              text    primary key,    -- 'boss_band1' / 'miniboss_band1_naga'
  name_th         text    not null,
  name_en         text    not null,
  base_enemy_id   uuid    references public.enemy_templates(id),
  min_phases      int     not null default 2,
  enrage_turn     int,                    -- null = no enrage
  created_at      timestamptz not null default now()
);

alter table public.boss_templates enable row level security;
create policy "boss_templates_read_all" on public.boss_templates
  for select using (true);

-- ============================================================
-- boss_phases
-- ============================================================

create table if not exists public.boss_phases (
  id              uuid    primary key default gen_random_uuid(),
  boss_id         text    not null references public.boss_templates(id) on delete cascade,
  phase_index     int     not null,       -- 0-based
  phase_name      text    not null,
  trigger_hp_pct  numeric not null,       -- transitions when HP drops below this (0.0-1.0)
  atk_mult        float   not null default 1.0,
  spd_mult        float   not null default 1.0,
  new_patterns    text[],                 -- additional action_types available in this phase
  phase_message   text,                   -- shown in combat log when phase triggers
  unique (boss_id, phase_index)
);

alter table public.boss_phases enable row level security;
create policy "boss_phases_read_all" on public.boss_phases
  for select using (true);

-- ============================================================
-- boss_drop_table
-- ============================================================

create table if not exists public.boss_drop_table (
  boss_id           text    not null references public.boss_templates(id),
  difficulty        text    not null default 'normal',
  guaranteed_rarity text    not null default 'rare',
  legendary_chance  numeric not null default 0.10,
  mythic_chance     numeric not null default 0.01,
  bonus_gems        int     not null default 0,
  unique (boss_id, difficulty)
);

alter table public.boss_drop_table enable row level security;
create policy "boss_drop_table_read_all" on public.boss_drop_table
  for select using (true);

-- ============================================================
-- combat_sessions  (per-battle log)
-- ============================================================

create table if not exists public.combat_sessions (
  id                uuid    primary key default gen_random_uuid(),
  player_id         uuid    not null references public.players(id) on delete cascade,
  camp_id           uuid    references public.tower_camps(id),
  enemy_template_id uuid    references public.enemy_templates(id),
  enemy_name        text    not null,
  difficulty        text    not null default 'normal',
  status            text    not null default 'active',
  -- 'active' | 'win' | 'lose' | 'fled' | 'capture_success' | 'capture_failed'
  party_id          uuid,
  is_party_combat   boolean not null default false,
  loot_mode         text    not null default 'personal',  -- 'personal'|'roll'|'ffa'
  action_window_sec int     not null default 15,          -- party mode only
  player_hp_start   int     not null,
  player_hp_end     int,
  player_en_start   int     not null,
  player_en_end     int,
  enemy_hp_start    int     not null,
  enemy_hp_end      int,
  turns_taken       int     not null default 0,
  items_dropped     uuid[]  default '{}',
  started_at        timestamptz not null default now(),
  ended_at          timestamptz
);

alter table public.combat_sessions enable row level security;
create policy "combat_sessions_own" on public.combat_sessions
  for all using (
    player_id in (select id from public.players where user_id = auth.uid())
  );

-- ============================================================
-- combat_action_log  (turn-by-turn log)
-- ============================================================

create table if not exists public.combat_action_log (
  id              uuid    primary key default gen_random_uuid(),
  session_id      uuid    not null references public.combat_sessions(id) on delete cascade,
  turn_number     int     not null,
  actor           text    not null,       -- 'player' | enemy name_en
  action_type     text    not null,
  -- 'attack'|'attack_miss'|'skill'|'item'|'flee_attempt'|'flee_success'|'capture_attempt'|'capture_success'
  skill_node_id   uuid    references public.skill_nodes(id),
  item_id         uuid    references public.items(id),
  damage_dealt    int,
  damage_received int,
  is_crit         boolean not null default false,
  is_miss         boolean not null default false,
  hp_after        int     not null,
  energy_after    int     not null,
  dice_roll       int,
  logged_at       timestamptz not null default now()
);

create index if not exists idx_combat_log_session
  on public.combat_action_log (session_id, turn_number);

alter table public.combat_action_log enable row level security;
create policy "combat_log_own" on public.combat_action_log
  for select using (
    session_id in (
      select id from public.combat_sessions
      where player_id in (select id from public.players where user_id = auth.uid())
    )
  );

-- ============================================================
-- player_status_effects  (active buffs/debuffs)
-- ============================================================

create table if not exists public.player_status_effects (
  id          uuid    primary key default gen_random_uuid(),
  player_id   uuid    not null references public.players(id) on delete cascade,
  session_id  uuid    references public.combat_sessions(id) on delete cascade,
  effect_type text    not null,
  magnitude   float   not null default 1.0,
  turns_left  int,
  source      text,   -- 'enemy_skill' | 'item' | 'skill_node'
  applied_at  timestamptz not null default now()
);

alter table public.player_status_effects enable row level security;
create policy "status_effects_own" on public.player_status_effects
  for all using (
    player_id in (select id from public.players where user_id = auth.uid())
  );

-- ============================================================
-- party_combat_members  (future — party system Phase 3)
-- ============================================================

create table if not exists public.party_combat_members (
  session_id    uuid    not null references public.combat_sessions(id) on delete cascade,
  player_id     uuid    not null references public.players(id),
  join_order    int     not null default 0,
  is_downed     boolean not null default false,
  loot_received jsonb   default '[]'::jsonb,
  primary key (session_id, player_id)
);

alter table public.party_combat_members enable row level security;
create policy "party_combat_own" on public.party_combat_members
  for select using (
    player_id in (select id from public.players where user_id = auth.uid())
  );

-- ============================================================
-- party_loot_rolls  (future — party loot roll Phase 3)
-- ============================================================

create table if not exists public.party_loot_rolls (
  id          uuid    primary key default gen_random_uuid(),
  session_id  uuid    not null references public.combat_sessions(id) on delete cascade,
  player_id   uuid    not null references public.players(id),
  item_id     uuid    references public.items(id),
  roll_value  int     not null,
  won_roll    boolean not null default false,
  rolled_at   timestamptz not null default now()
);

alter table public.party_loot_rolls enable row level security;
create policy "loot_rolls_own" on public.party_loot_rolls
  for select using (
    player_id in (select id from public.players where user_id = auth.uid())
  );

-- ============================================================
-- Seed: Band 1 enemy_templates (Thai Pantheon)
-- ============================================================

insert into public.enemy_templates
  (name_th, name_en, band_id, camp_types, hp, atk, defense, spd, energy, energy_regen,
   crit_rate, crit_dmg, ai_archetype, durability_damage_mult, is_capturable, capture_base_rate)
values
  -- Normal enemies
  ('หมูป่า',        'Wild Boar',       1, '{"normal","hunting_zone"}',
   45,  7, 2, 8, 6,  1, 0.05, 0.50, 'berserker',  1.0, true,  0.25),
  ('นาคน้อย',      'Small Naga',      1, '{"normal"}',
   40,  9, 3, 5, 8,  1, 0.08, 0.60, 'trickster',  1.0, true,  0.25),
  ('ยักษ์เล็ก',    'Small Giant',     1, '{"normal","elite"}',
   65,  8, 6, 4, 6,  1, 0.04, 0.50, 'tank',        1.0, true,  0.20),
  ('ลิงเทวะ',      'Divine Monkey',   1, '{"normal"}',
   35, 11, 2, 9, 8,  1, 0.10, 0.55, 'trickster',  1.0, true,  0.30),

  -- Elite enemies
  ('ทหารเก่า',     'Old Guard',       1, '{"elite"}',
   90, 14, 8, 7, 10, 1, 0.07, 0.55, 'tactician',  1.5, true,  0.15),
  ('ผีรักษาการณ์', 'Ghost Sentinel',  1, '{"elite","mystery"}',
   70, 16, 4, 10,8,  1, 0.12, 0.60, 'trickster',  1.5, true,  0.10),
  ('ช้างทหาร',     'War Elephant',    1, '{"elite"}',
   130,12, 12,4, 8,  1, 0.04, 0.50, 'tank',        2.0, true,  0.10),

  -- Mini-boss (not capturable)
  ('นาคราช',       'Naga King',       1, '{"mini_boss"}',
   200,18, 10,7, 15, 2, 0.10, 0.60, 'tactician',  2.0, false, 0.0),
  ('ยักษ์ทองคำ',   'Golden Giant',    1, '{"mini_boss"}',
   260,22, 16,4, 12, 2, 0.06, 0.55, 'berserker',  2.5, false, 0.0),

  -- Boss (not capturable)
  ('มหายักษ์ทรนง', 'Mahayak Thoranong',1,'{"boss"}',
   500,25, 15,5, 20, 3, 0.08, 0.60, 'tactician',  3.0, false, 0.0),

  -- Resource camp / mystery
  ('ตะขาบยักษ์',   'Giant Centipede', 1, '{"resource","mystery"}',
   55,  8, 3, 7, 6,  1, 0.06, 0.50, 'berserker',  1.0, true,  0.35),
  ('หมาป่า',       'Forest Wolf',     1, '{"hunting_zone","normal"}',
   50, 10, 2, 10,6,  1, 0.08, 0.50, 'berserker',  1.0, true,  0.35)

on conflict do nothing;

-- ============================================================
-- Seed: Boss templates (Band 1)
-- ============================================================

insert into public.boss_templates (id, name_th, name_en)
values
  ('miniboss_band1_naga',  'นาคราช',       'Naga King'),
  ('miniboss_band1_giant', 'ยักษ์ทองคำ',   'Golden Giant'),
  ('boss_band1',           'มหายักษ์ทรนง', 'Mahayak Thoranong')
on conflict do nothing;

-- Boss phases: Mahayak Thoranong (3 phases)
insert into public.boss_phases (boss_id, phase_index, phase_name, trigger_hp_pct, atk_mult, spd_mult, phase_message)
values
  ('boss_band1', 0, 'ยักษ์โกรธ',     1.00, 1.0, 1.0,
   '⚠ มหายักษ์เผชิญหน้า! ระวังการโจมตีหนัก!'),
  ('boss_band1', 1, 'ยักษ์บ้าคลั่ง', 0.60, 1.4, 1.2,
   '💢 มหายักษ์โกรธจัด! ATK และ SPD เพิ่มขึ้น!'),
  ('boss_band1', 2, 'ยักษ์สิ้นสุด',  0.25, 1.8, 1.5,
   '🔥 มหายักษ์ปลดปล่อยพลังสุดท้าย! รับมือด้วยความระวัง!')
on conflict do nothing;

-- Mini-boss phases: Naga King (2 phases)
insert into public.boss_phases (boss_id, phase_index, phase_name, trigger_hp_pct, atk_mult, spd_mult, phase_message)
values
  ('miniboss_band1_naga', 0, 'นาคบ่นเบา', 1.00, 1.0, 1.0,
   '🐍 นาคราชโถมเข้าโจมตี!'),
  ('miniboss_band1_naga', 1, 'นาคพิโรธ', 0.50, 1.5, 1.3,
   '💢 นาคราชแผ่พิษ! ระวัง!')
on conflict do nothing;

-- Boss drop table
insert into public.boss_drop_table (boss_id, difficulty, guaranteed_rarity, legendary_chance, mythic_chance, bonus_gems)
values
  ('boss_band1', 'normal',    'epic',      0.15, 0.02, 50),
  ('boss_band1', 'hard',      'epic',      0.25, 0.05, 100),
  ('boss_band1', 'ascendant', 'legendary', 0.40, 0.10, 200),
  ('miniboss_band1_naga',  'normal', 'rare', 0.10, 0.01, 0),
  ('miniboss_band1_giant', 'normal', 'rare', 0.10, 0.01, 0)
on conflict do nothing;

-- ============================================================
-- RPC: log_combat_session  (client logs outcome server-side)
-- ============================================================

create or replace function public.log_combat_session(
  p_player_id         uuid,
  p_camp_id           uuid,
  p_enemy_template_id uuid,
  p_enemy_name        text,
  p_status            text,
  p_player_hp_start   int,
  p_player_hp_end     int,
  p_player_en_start   int,
  p_player_en_end     int,
  p_enemy_hp_start    int,
  p_enemy_hp_end      int,
  p_turns_taken       int
) returns uuid language plpgsql security definer as $$
declare
  v_session_id uuid;
begin
  if auth.uid() is null then
    raise exception 'Unauthorized';
  end if;
  if not exists (
    select 1 from public.players
    where id = p_player_id and user_id = auth.uid()
  ) then
    raise exception 'Player not found';
  end if;

  insert into public.combat_sessions (
    player_id, camp_id, enemy_template_id, enemy_name, status,
    player_hp_start, player_hp_end, player_en_start, player_en_end,
    enemy_hp_start, enemy_hp_end, turns_taken, ended_at
  ) values (
    p_player_id, p_camp_id, p_enemy_template_id, p_enemy_name, p_status,
    p_player_hp_start, p_player_hp_end, p_player_en_start, p_player_en_end,
    p_enemy_hp_start, p_enemy_hp_end, p_turns_taken, now()
  ) returning id into v_session_id;

  return v_session_id;
end;
$$;

grant execute on function public.log_combat_session to authenticated;
