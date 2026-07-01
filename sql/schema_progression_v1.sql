-- =============================================================
-- เทพปกรณัม — schema_progression_v1.sql
-- Weapon Proficiency, Active Buffs, Deity Worship,
-- NPC Relationships, Hired NPCs, Bounties, Treasure Maps
-- รันหลัง schema_character_v1.sql และ schema_npc_v1.sql
-- =============================================================

-- ============================================================
-- player_weapon_proficiency
-- ============================================================

create table if not exists public.player_weapon_proficiency (
  player_id    uuid not null references public.players(id) on delete cascade,
  weapon_class text not null check (weapon_class in (
    'polearm','greatsword','bow','staff','sword','dagger',
    'wand','mace','crossbow','shield','catalyst'
  )),
  prof_level   int  not null default 0 check (prof_level >= 0),
  prof_exp     bigint not null default 0 check (prof_exp >= 0),
  updated_at   timestamptz not null default now(),
  primary key (player_id, weapon_class)
);

alter table public.player_weapon_proficiency enable row level security;
create policy "weapon_prof_own" on public.player_weapon_proficiency
  for all using (
    player_id in (select id from public.players where user_id = auth.uid())
  );

-- ============================================================
-- player_active_buffs  (จาก food/drink — expire server-side)
-- ============================================================

create table if not exists public.player_active_buffs (
  id            uuid   primary key default gen_random_uuid(),
  player_id     uuid   not null references public.players(id) on delete cascade,
  source_item_id uuid  references public.items(id),
  buff_stat     text   not null,   -- ชื่อ stat เช่น 'atk', 'hp_regen', 'def'
  buff_amount   float  not null,   -- ค่าที่บวกเพิ่ม (0.1 = 10% สำหรับ pct stats)
  applied_at    timestamptz not null default now(),
  expires_at    timestamptz         -- null = permanent (deity ability), ไม่ null = temporary buff
);

alter table public.player_active_buffs enable row level security;
create policy "active_buffs_own" on public.player_active_buffs
  for all using (
    player_id in (select id from public.players where user_id = auth.uid())
  );

create index if not exists idx_active_buffs_player_expires
  on public.player_active_buffs (player_id, expires_at);

-- ============================================================
-- deity_templates  (master data — server-defined)
-- ============================================================

create table if not exists public.deity_templates (
  id          uuid primary key default gen_random_uuid(),
  name_th     text not null unique,
  name_en     text not null unique,
  deity_type  text not null check (deity_type in (
    'agriculture','creation','destruction','war',
    'healing','food','trade','textile','primordial'
  )),
  description_th text,
  description_en text,
  sprite_path text
);

-- ============================================================
-- player_deity_worship
-- ============================================================

create table if not exists public.player_deity_worship (
  player_id         uuid not null references public.players(id) on delete cascade,
  deity_id          uuid not null references public.deity_templates(id),
  deity_level       int  not null default 0 check (deity_level >= 0),
  deity_exp         bigint not null default 0 check (deity_exp >= 0),
  worship_started_at timestamptz not null default now(),
  updated_at        timestamptz not null default now(),
  primary key (player_id, deity_id)
);

alter table public.player_deity_worship enable row level security;
create policy "deity_worship_own" on public.player_deity_worship
  for all using (
    player_id in (select id from public.players where user_id = auth.uid())
  );

-- ============================================================
-- deity_quests
-- ============================================================

create table if not exists public.deity_quests (
  id               uuid primary key default gen_random_uuid(),
  deity_id         uuid not null references public.deity_templates(id),
  name_th          text not null,
  name_en          text not null,
  requirements     jsonb not null default '[]'::jsonb,  -- [{type, target_id, amount}]
  reward_deity_exp int  not null default 0,
  reward_ability   text,          -- ability key ที่ปลดล็อก (null = ไม่มี ability reward)
  sort_order       int  not null default 0
);

-- ============================================================
-- player_deity_quest_log
-- ============================================================

create table if not exists public.player_deity_quest_log (
  id          uuid   primary key default gen_random_uuid(),
  player_id   uuid   not null references public.players(id) on delete cascade,
  quest_id    uuid   not null references public.deity_quests(id),
  status      text   not null check (status in ('active','completed','claimed')) default 'active',
  progress    jsonb  not null default '{}'::jsonb,
  completed_at timestamptz,
  claimed_at   timestamptz
);

alter table public.player_deity_quest_log enable row level security;
create policy "deity_quest_log_own" on public.player_deity_quest_log
  for all using (
    player_id in (select id from public.players where user_id = auth.uid())
  );

-- ============================================================
-- npc_relationships
-- ============================================================

create table if not exists public.npc_relationships (
  player_id          uuid not null references public.players(id) on delete cascade,
  npc_template_id    uuid not null references public.npc_templates(id),
  relationship_level int  not null default 0 check (relationship_level between 0 and 10),
  relationship_exp   int  not null default 0 check (relationship_exp >= 0),
  last_interaction   timestamptz,
  updated_at         timestamptz not null default now(),
  primary key (player_id, npc_template_id)
);

alter table public.npc_relationships enable row level security;
create policy "npc_rel_own" on public.npc_relationships
  for all using (
    player_id in (select id from public.players where user_id = auth.uid())
  );

-- ============================================================
-- hired_npcs
-- ============================================================

create table if not exists public.hired_npcs (
  id               uuid primary key default gen_random_uuid(),
  player_id        uuid not null references public.players(id) on delete cascade,
  npc_template_id  uuid not null references public.npc_templates(id),
  hire_type        text not null check (hire_type in (
    'field_worker','combat_companion','guard','merchant','crafter'
  )),
  daily_wage       int  not null default 0 check (daily_wage >= 0),  -- gold/day
  hired_at         timestamptz not null default now(),
  hired_until      timestamptz,  -- null = indefinite (จ่ายรายวัน)
  assignment_data  jsonb not null default '{}'::jsonb  -- บริบทงานที่มอบหมาย
);

alter table public.hired_npcs enable row level security;
create policy "hired_npcs_own" on public.hired_npcs
  for all using (
    player_id in (select id from public.players where user_id = auth.uid())
  );

-- ============================================================
-- bounties
-- ============================================================

create table if not exists public.bounties (
  id            uuid  primary key default gen_random_uuid(),
  poster_id     uuid  not null references public.players(id) on delete cascade,
  target_type   text  not null check (target_type in ('player','npc','monster')),
  target_player_id uuid references public.players(id),
  target_npc_id    uuid references public.npc_templates(id),
  target_monster_key text,  -- key จาก bestiary_monsters
  reward_gold   int   not null check (reward_gold > 0),
  status        text  not null check (status in ('open','claimed','expired','cancelled')) default 'open',
  claimed_by    uuid  references public.players(id),
  claimed_at    timestamptz,
  expires_at    timestamptz,
  created_at    timestamptz not null default now()
);

alter table public.bounties enable row level security;

create policy "bounties_select" on public.bounties
  for select using (true);  -- ทุกคนเห็น bounty board

create policy "bounties_insert_own" on public.bounties
  for insert with check (auth.uid() = (
    select user_id from public.players where id = poster_id
  ));

create policy "bounties_update_own" on public.bounties
  for update using (auth.uid() = (
    select user_id from public.players where id = poster_id
  ));

-- ============================================================
-- treasure_maps
-- ============================================================

create table if not exists public.treasure_maps (
  id              uuid primary key default gen_random_uuid(),
  owner_player_id uuid not null references public.players(id) on delete cascade,
  source_type     text not null check (source_type in ('quest','story','npc_gift','drop','purchase')),
  location_data   jsonb not null default '{}'::jsonb,  -- {band, floor, camp_id, hint_th, hint_en}
  reward_data     jsonb not null default '{}'::jsonb,  -- {gold, items:[{item_id, quantity}]}
  is_found        boolean not null default false,
  found_at        timestamptz,
  acquired_at     timestamptz not null default now()
);

alter table public.treasure_maps enable row level security;
create policy "treasure_maps_own" on public.treasure_maps
  for all using (
    owner_player_id in (select id from public.players where user_id = auth.uid())
  );

-- ============================================================
-- Seed data: deity_templates
-- ============================================================

insert into public.deity_templates (name_th, name_en, deity_type, description_th) values
  ('พระแม่โพสพ',      'Phra Mae Phosop',    'agriculture', 'เทพีแห่งข้าวและพืชผล — เพิ่ม farming yield และ crop speed'),
  ('พระวิษณุกรรม',    'Phra Witsanukam',    'creation',    'เทพแห่งงานช่าง — เพิ่ม crafting quality และ blueprint unlock'),
  ('พระอิศวร',        'Phra Isuan',         'primordial',  'เทพแห่งการสร้างและทำลาย — เพิ่ม ATK และ DEF พร้อมกัน'),
  ('พระอินทร์',       'Phra In',            'war',         'เทพแห่งสายฟ้าและสงคราม — เพิ่ม lightning_dmg และ battle_energy'),
  ('พระพุทธเจ้า',     'Phra Phuttha Chao',  'healing',     'เทพแห่งการรักษา — เพิ่ม hp_regen และ ลด cooldown'),
  ('แม่ย่านาง',       'Mae Ya Nang',        'food',        'เทพีแห่งเรือและการเดินทาง — เพิ่ม world_energy และ harvest rate'),
  ('พระพิฆเนศ',       'Phra Phikanet',      'trade',       'เทพแห่งการค้าขายและโชค — เพิ่ม gold drop และ merchant discount')
on conflict do nothing;
