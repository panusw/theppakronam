-- =============================================================
-- เทพปกรณัม — schema_tower_v2.sql
-- Tower structure: bands → floors → camps (graph nodes)
-- รันหลัง schema_character_v1.sql
-- =============================================================

-- ============================================================
-- tower_bands  (6 pantheons)
-- ============================================================

create table if not exists public.tower_bands (
  id          int         primary key,
  name_th     text        not null,
  name_en     text        not null,
  pantheon    text        not null check (pantheon in ('thai','greek','norse','japanese','egyptian','primordial')),
  is_unlocked boolean     not null default false,
  unlocked_at timestamptz
);

-- Band 1 เปิดตั้งแต่ต้น, Band 2-6 ปิดรอ server-wide boss first kill
insert into public.tower_bands (id, name_th, name_en, pantheon, is_unlocked) values
  (1, 'แดนศรัทธาโบราณ',  'Ancient Faith Realm',    'thai',       true),
  (2, 'โอลิมปัส',         'Olympus',                'greek',      false),
  (3, 'ยิกดราซิล',        'Yggdrasil',              'norse',      false),
  (4, 'ทะเลทรายนิรันดร์', 'Eternal Desert',         'egyptian',   false),
  (5, 'ซากุระอนันต์',     'Eternal Sakura',         'japanese',   false),
  (6, 'ดินแดนต้นกำเนิด', 'Primordial Domain',       'primordial', false)
on conflict (id) do nothing;

-- ============================================================
-- tower_floors
-- ============================================================

create table if not exists public.tower_floors (
  id       uuid primary key default gen_random_uuid(),
  band_id  int  not null references public.tower_bands(id),
  floor_no int  not null,
  name_th  text,
  name_en  text,
  unique (band_id, floor_no)
);

-- Band 1: floors 1-9
insert into public.tower_floors (band_id, floor_no, name_th, name_en) values
  (1, 1, 'ทางเข้าศาล',       'Shrine Entrance'),
  (1, 2, 'ป่าศักดิ์สิทธิ์',  'Sacred Forest'),
  (1, 3, 'หุบเขาหมอก',        'Misty Valley'),
  (1, 4, 'ถ้ำนาค',            'Naga Cave'),
  (1, 5, 'ที่ราบสูง',         'Highland Plain'),
  (1, 6, 'ป้อมปราการโบราณ',  'Ancient Fortress'),
  (1, 7, 'ทะเลสาบมังกร',      'Dragon Lake'),
  (1, 8, 'หอบูชา',            'Worship Tower'),
  (1, 9, 'ห้องบัลลังก์',      'Throne Chamber')
on conflict (band_id, floor_no) do nothing;

-- ============================================================
-- tower_camps  (graph nodes — positions are grid coords for renderer)
-- ============================================================

create table if not exists public.tower_camps (
  id          uuid primary key default gen_random_uuid(),
  floor_id    uuid not null references public.tower_floors(id) on delete cascade,
  camp_type   text not null check (camp_type in (
                'spawn','normal','elite','mini_boss','checkpoint',
                'boss_gate','boss','resource','mystery','hunting_zone','hub')),
  name_th     text,
  name_en     text,
  pos_x       int  not null default 0,
  pos_y       int  not null default 0,
  energy_cost int  not null default 4,
  -- Boss gate unlock conditions (NULL = ไม่ใช่ boss_gate)
  gate_camps_pct      int,
  gate_miniboss_count int,
  gate_specific_camps uuid[]
);

comment on column public.tower_camps.energy_cost is
  'World Energy cost to enter: normal=4 elite=6 mini_boss=8 boss=10 resource/mystery=2';

-- Master data: RLS on + ให้ทุกคน (authenticated/anon) อ่านได้ แต่แก้ไขได้เฉพาะ server function
alter table public.tower_bands  enable row level security;
alter table public.tower_floors enable row level security;
alter table public.tower_camps  enable row level security;
create policy "bands_read_all"  on public.tower_bands  for select using (true);
create policy "floors_read_all" on public.tower_floors for select using (true);
create policy "camps_read_all"  on public.tower_camps  for select using (true);

-- ============================================================
-- camp_connections  (directed graph edges)
-- ============================================================

create table if not exists public.camp_connections (
  id        uuid primary key default gen_random_uuid(),
  from_camp uuid not null references public.tower_camps(id) on delete cascade,
  to_camp   uuid not null references public.tower_camps(id) on delete cascade,
  is_oneway boolean not null default false,
  unique (from_camp, to_camp)
);

alter table public.camp_connections enable row level security;
create policy "connections_read_all" on public.camp_connections for select using (true);

-- ============================================================
-- player_camp_state
-- ============================================================

create table if not exists public.player_camp_state (
  id          uuid        primary key default gen_random_uuid(),
  player_id   uuid        not null references public.players(id) on delete cascade,
  camp_id     uuid        not null references public.tower_camps(id) on delete cascade,
  is_visited  boolean     not null default false,
  is_cleared  boolean     not null default false,
  cleared_at  timestamptz,
  unique (player_id, camp_id)
);

alter table public.player_camp_state enable row level security;
create policy "camp_state_own" on public.player_camp_state
  for all using (
    player_id in (select id from public.players where user_id = auth.uid())
  );

-- ============================================================
-- server_boss_kills  (server-wide — band unlock trigger)
-- ============================================================

create table if not exists public.server_boss_kills (
  camp_id     uuid  not null references public.tower_camps(id),
  difficulty  text  not null check (difficulty in ('normal','hard','ascendant','eternal')),
  killed_at   timestamptz not null default now(),
  first_player_id uuid references public.players(id),
  primary key (camp_id, difficulty)
);

-- server_boss_kills: ทุกคนอ่านได้ (server-wide unlock status), เขียนได้เฉพาะ server function
alter table public.server_boss_kills enable row level security;
create policy "boss_kills_read_all" on public.server_boss_kills for select using (true);

-- ============================================================
-- boss_clear_records  (Hall of Fame)
-- ============================================================

create table if not exists public.boss_clear_records (
  id          uuid primary key default gen_random_uuid(),
  camp_id     uuid not null references public.tower_camps(id),
  player_id   uuid not null references public.players(id),
  difficulty  text not null,
  clear_time_sec int,
  score       int  not null default 0,
  cleared_at  timestamptz not null default now()
);

alter table public.boss_clear_records enable row level security;
create policy "boss_records_read_all" on public.boss_clear_records for select using (true);

-- ============================================================
-- bestiary_monsters
-- ============================================================

create table if not exists public.bestiary_monsters (
  id          uuid primary key default gen_random_uuid(),
  band_id     int  not null references public.tower_bands(id),
  name_th     text not null,
  name_en     text not null,
  rarity      text not null check (rarity in ('common','uncommon','rare','epic','legendary','mythic')),
  hp          int  not null default 10,
  atk         int  not null default 1,
  def         int  not null default 0,
  spd         int  not null default 1,
  durability_damage_mult numeric(3,1) not null default 1.0,
  capture_item_rarity text,
  lore_th     text,
  lore_en     text
);

alter table public.bestiary_monsters enable row level security;
create policy "bestiary_read_all" on public.bestiary_monsters for select using (true);

create table if not exists public.player_monsters (
  id          uuid primary key default gen_random_uuid(),
  player_id   uuid not null references public.players(id) on delete cascade,
  monster_id  uuid not null references public.bestiary_monsters(id),
  captured_at timestamptz not null default now(),
  unique (player_id, monster_id)
);

alter table public.player_monsters enable row level security;
create policy "monsters_own" on public.player_monsters
  for all using (
    player_id in (select id from public.players where user_id = auth.uid())
  );

-- ============================================================
-- divinity_exp_log
-- ============================================================

create table if not exists public.divinity_exp_log (
  id          uuid primary key default gen_random_uuid(),
  player_id   uuid not null references public.players(id) on delete cascade,
  source      text not null, -- 'ascension_node','boss_kill','quest','daily'
  amount      int  not null,
  logged_at   timestamptz not null default now()
);

alter table public.divinity_exp_log enable row level security;
create policy "divinity_log_own" on public.divinity_exp_log
  for select using (
    player_id in (select id from public.players where user_id = auth.uid())
  );

-- ============================================================
-- band_ascension_log  (band travel history)
-- ============================================================

create table if not exists public.band_ascension_log (
  id            uuid primary key default gen_random_uuid(),
  player_id     uuid not null references public.players(id) on delete cascade,
  from_band     int  not null,
  to_band       int  not null,
  exp_cost      int  not null,
  logged_at     timestamptz not null default now()
);

alter table public.band_ascension_log enable row level security;
create policy "ascension_log_own" on public.band_ascension_log
  for all using (
    player_id in (select id from public.players where user_id = auth.uid())
  );

-- ============================================================
-- auto_hunt_sessions
-- ============================================================

create table if not exists public.auto_hunt_sessions (
  id            uuid primary key default gen_random_uuid(),
  player_id     uuid not null references public.players(id) on delete cascade,
  camp_id       uuid references public.tower_camps(id),
  duration_min  int  not null,
  started_at    timestamptz not null default now(),
  ended_at      timestamptz,
  end_reason    text, -- 'completed','recalled_hp','recalled_energy','recalled_inventory'
  kills         int  not null default 0,
  items_gained  int  not null default 0
);

alter table public.auto_hunt_sessions enable row level security;
create policy "autohunt_own" on public.auto_hunt_sessions
  for all using (
    player_id in (select id from public.players where user_id = auth.uid())
  );

-- ============================================================
-- weather_pool  (seed data Band 1)
-- ============================================================

create table if not exists public.weather_pool (
  id          uuid primary key default gen_random_uuid(),
  band_id     int  not null references public.tower_bands(id),
  season      text,  -- null = ทุกฤดู
  weather     text  not null,
  weight      int   not null default 10,
  duration_min_hr int not null default 2,
  duration_max_hr int not null default 6
);

alter table public.weather_pool enable row level security;
create policy "weather_read_all" on public.weather_pool for select using (true);

insert into public.weather_pool (band_id, season, weather, weight, duration_min_hr, duration_max_hr) values
  (1, null,         'clear',        30, 2, 6),
  (1, null,         'cloudy',       20, 2, 4),
  (1, 'วัสสาน',    'light_rain',   25, 2, 4),
  (1, 'วัสสาน',    'heavy_rain',   15, 1, 3),
  (1, 'วัสสาน',    'thunderstorm',  5, 1, 2),
  (1, null,         'fog',          10, 1, 3),
  (1, 'คิมหันต์',  'heat_wave',    20, 2, 5),
  (1, 'เหมันต์',   'cloudy',       15, 3, 6)
on conflict do nothing;

-- ============================================================
-- Seed: Band 1 Camp Layout
-- (สร้าง camps + connections สำหรับ floor 1-9 ของ Band 1)
-- ============================================================

do $$
declare
  f1  uuid; f2  uuid; f3  uuid; f4  uuid; f5  uuid;
  f6  uuid; f7  uuid; f8  uuid; f9  uuid;

  -- floor 1
  c_spawn    uuid; c_f1n1 uuid; c_f1n2 uuid; c_f1hub uuid;
  -- floor 2
  c_f2n1 uuid; c_f2n2 uuid; c_f2e1 uuid; c_f2chk uuid;
  -- floor 3
  c_f3n1 uuid; c_f3res uuid; c_f3mys uuid;
  -- floor 4
  c_f4e1 uuid; c_f4mb uuid; c_f4chk uuid;
  -- floor 5
  c_f5n1 uuid; c_f5n2 uuid; c_f5hub uuid;
  -- floor 6
  c_f6n1 uuid; c_f6e1 uuid; c_f6e2 uuid;
  -- floor 7
  c_f7mys uuid; c_f7hunt uuid; c_f7res uuid;
  -- floor 8
  c_f8mb1 uuid; c_f8mb2 uuid; c_f8gate uuid;
  -- floor 9
  c_f9boss uuid;
begin
  -- ดึง floor IDs
  select id into f1 from public.tower_floors where band_id=1 and floor_no=1;
  select id into f2 from public.tower_floors where band_id=1 and floor_no=2;
  select id into f3 from public.tower_floors where band_id=1 and floor_no=3;
  select id into f4 from public.tower_floors where band_id=1 and floor_no=4;
  select id into f5 from public.tower_floors where band_id=1 and floor_no=5;
  select id into f6 from public.tower_floors where band_id=1 and floor_no=6;
  select id into f7 from public.tower_floors where band_id=1 and floor_no=7;
  select id into f8 from public.tower_floors where band_id=1 and floor_no=8;
  select id into f9 from public.tower_floors where band_id=1 and floor_no=9;

  -- Floor 1
  insert into public.tower_camps (floor_id, camp_type, name_th, name_en, pos_x, pos_y, energy_cost)
    values (f1,'spawn',    'จุดเริ่มต้น',   'Starting Point',  0, 0, 0) returning id into c_spawn;
  insert into public.tower_camps (floor_id, camp_type, name_th, name_en, pos_x, pos_y, energy_cost)
    values (f1,'normal',   'ชายป่า',        'Forest Edge',     1, 0, 4) returning id into c_f1n1;
  insert into public.tower_camps (floor_id, camp_type, name_th, name_en, pos_x, pos_y, energy_cost)
    values (f1,'normal',   'ลำธาร',         'Stream',          2, 0, 4) returning id into c_f1n2;
  insert into public.tower_camps (floor_id, camp_type, name_th, name_en, pos_x, pos_y, energy_cost)
    values (f1,'hub',      'หมู่บ้านศาล',   'Shrine Village',  3, 0, 2) returning id into c_f1hub;

  -- Floor 2
  insert into public.tower_camps (floor_id, camp_type, name_th, name_en, pos_x, pos_y, energy_cost)
    values (f2,'normal',   'ทางป่า',        'Forest Path',     0, 1, 4) returning id into c_f2n1;
  insert into public.tower_camps (floor_id, camp_type, name_th, name_en, pos_x, pos_y, energy_cost)
    values (f2,'normal',   'ลานหิน',        'Stone Plaza',     1, 1, 4) returning id into c_f2n2;
  insert into public.tower_camps (floor_id, camp_type, name_th, name_en, pos_x, pos_y, energy_cost)
    values (f2,'elite',    'กองทหารเก่า',   'Old Guard Post',  2, 1, 6) returning id into c_f2e1;
  insert into public.tower_camps (floor_id, camp_type, name_th, name_en, pos_x, pos_y, energy_cost)
    values (f2,'checkpoint','ด่านพักแรม',   'Waypoint',        3, 1, 0) returning id into c_f2chk;

  -- Floor 3
  insert into public.tower_camps (floor_id, camp_type, name_th, name_en, pos_x, pos_y, energy_cost)
    values (f3,'normal',   'สวนโบราณ',      'Ancient Garden',  0, 2, 4) returning id into c_f3n1;
  insert into public.tower_camps (floor_id, camp_type, name_th, name_en, pos_x, pos_y, energy_cost)
    values (f3,'resource', 'แร่ศักดิ์สิทธิ์','Sacred Mine',    1, 2, 2) returning id into c_f3res;
  insert into public.tower_camps (floor_id, camp_type, name_th, name_en, pos_x, pos_y, energy_cost)
    values (f3,'mystery',  'แสงลึกลับ',     'Strange Light',   2, 2, 2) returning id into c_f3mys;

  -- Floor 4
  insert into public.tower_camps (floor_id, camp_type, name_th, name_en, pos_x, pos_y, energy_cost)
    values (f4,'elite',    'หอสังเกตการณ์', 'Watchtower',      0, 3, 6) returning id into c_f4e1;
  insert into public.tower_camps (floor_id, camp_type, name_th, name_en, pos_x, pos_y, energy_cost)
    values (f4,'mini_boss','นาคราช',        'Naga King',       1, 3, 8) returning id into c_f4mb;
  insert into public.tower_camps (floor_id, camp_type, name_th, name_en, pos_x, pos_y, energy_cost)
    values (f4,'checkpoint','ฐานพักทัพ',    'Base Camp',       2, 3, 0) returning id into c_f4chk;

  -- Floor 5
  insert into public.tower_camps (floor_id, camp_type, name_th, name_en, pos_x, pos_y, energy_cost)
    values (f5,'normal',   'ทุ่งหญ้า',      'Grassland',       0, 4, 4) returning id into c_f5n1;
  insert into public.tower_camps (floor_id, camp_type, name_th, name_en, pos_x, pos_y, energy_cost)
    values (f5,'normal',   'ซากวัด',        'Ruined Temple',   1, 4, 4) returning id into c_f5n2;
  insert into public.tower_camps (floor_id, camp_type, name_th, name_en, pos_x, pos_y, energy_cost)
    values (f5,'hub',      'ค่ายกลาง',      'Mid Camp',        2, 4, 2) returning id into c_f5hub;

  -- Floor 6
  insert into public.tower_camps (floor_id, camp_type, name_th, name_en, pos_x, pos_y, energy_cost)
    values (f6,'normal',   'หนองน้ำ',       'Swamp',           0, 5, 4) returning id into c_f6n1;
  insert into public.tower_camps (floor_id, camp_type, name_th, name_en, pos_x, pos_y, energy_cost)
    values (f6,'elite',    'กองทัพผี',      'Ghost Army',      1, 5, 6) returning id into c_f6e1;
  insert into public.tower_camps (floor_id, camp_type, name_th, name_en, pos_x, pos_y, energy_cost)
    values (f6,'elite',    'ป้อมสีดำ',      'Dark Fort',       2, 5, 6) returning id into c_f6e2;

  -- Floor 7
  insert into public.tower_camps (floor_id, camp_type, name_th, name_en, pos_x, pos_y, energy_cost)
    values (f7,'mystery',  'ประตูมิติ',     'Dimensional Gate',0, 6, 2) returning id into c_f7mys;
  insert into public.tower_camps (floor_id, camp_type, name_th, name_en, pos_x, pos_y, energy_cost)
    values (f7,'hunting_zone','เขตล่าสัตว์','Hunting Zone',    1, 6, 2) returning id into c_f7hunt;
  insert into public.tower_camps (floor_id, camp_type, name_th, name_en, pos_x, pos_y, energy_cost)
    values (f7,'resource', 'ป่าสมุนไพร',   'Herb Forest',     2, 6, 2) returning id into c_f7res;

  -- Floor 8
  insert into public.tower_camps (floor_id, camp_type, name_th, name_en, pos_x, pos_y, energy_cost)
    values (f8,'mini_boss','ครุฑพัน',       'Garuda Bound',    0, 7, 8) returning id into c_f8mb1;
  insert into public.tower_camps (floor_id, camp_type, name_th, name_en, pos_x, pos_y, energy_cost)
    values (f8,'mini_boss','ยักษ์ทองคำ',   'Golden Giant',    1, 7, 8) returning id into c_f8mb2;
  insert into public.tower_camps (
    floor_id, camp_type, name_th, name_en, pos_x, pos_y, energy_cost,
    gate_camps_pct, gate_miniboss_count)
    values (f8,'boss_gate','ประตูบัลลังก์','Throne Gate', 2, 7, 0, 60, 2)
    returning id into c_f8gate;

  -- Floor 9
  insert into public.tower_camps (floor_id, camp_type, name_th, name_en, pos_x, pos_y, energy_cost)
    values (f9,'boss','มหายักษ์ทรนง','Mahayak Thoranong', 0, 8, 10) returning id into c_f9boss;

  -- ============================================================
  -- Connections (directed: player moves from → to)
  -- ============================================================

  -- Floor 1
  insert into public.camp_connections (from_camp, to_camp) values
    (c_spawn, c_f1n1), (c_f1n1, c_f1n2), (c_f1n2, c_f1hub);

  -- Floor 1 → 2
  insert into public.camp_connections (from_camp, to_camp) values
    (c_f1hub, c_f2n1), (c_f1hub, c_f2n2);

  -- Floor 2
  insert into public.camp_connections (from_camp, to_camp) values
    (c_f2n1, c_f2e1), (c_f2n2, c_f2e1), (c_f2e1, c_f2chk);

  -- Floor 2 → 3
  insert into public.camp_connections (from_camp, to_camp) values
    (c_f2chk, c_f3n1), (c_f2chk, c_f3mys);

  -- Floor 3
  insert into public.camp_connections (from_camp, to_camp) values
    (c_f3n1, c_f3res), (c_f3res, c_f4e1), (c_f3mys, c_f4e1);

  -- Floor 4
  insert into public.camp_connections (from_camp, to_camp) values
    (c_f4e1, c_f4mb), (c_f4mb, c_f4chk);

  -- Floor 4 → 5
  insert into public.camp_connections (from_camp, to_camp) values
    (c_f4chk, c_f5n1), (c_f4chk, c_f5n2);

  -- Floor 5
  insert into public.camp_connections (from_camp, to_camp) values
    (c_f5n1, c_f5hub), (c_f5n2, c_f5hub);

  -- Floor 5 → 6
  insert into public.camp_connections (from_camp, to_camp) values
    (c_f5hub, c_f6n1), (c_f5hub, c_f6e1);

  -- Floor 6
  insert into public.camp_connections (from_camp, to_camp) values
    (c_f6n1, c_f6e2), (c_f6e1, c_f6e2);

  -- Floor 6 → 7
  insert into public.camp_connections (from_camp, to_camp) values
    (c_f6e2, c_f7mys), (c_f6e2, c_f7hunt), (c_f6e2, c_f7res);

  -- Floor 7 → 8
  insert into public.camp_connections (from_camp, to_camp) values
    (c_f7mys, c_f8mb1), (c_f7hunt, c_f8mb2), (c_f7res, c_f8mb2);

  -- Floor 8
  insert into public.camp_connections (from_camp, to_camp) values
    (c_f8mb1, c_f8gate), (c_f8mb2, c_f8gate);

  -- Floor 8 → 9
  insert into public.camp_connections (from_camp, to_camp) values
    (c_f8gate, c_f9boss);

end;
$$;
