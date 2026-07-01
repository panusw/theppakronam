-- =============================================================
-- เทพปกรณัม — schema_core_v2.sql
-- Items, inventory, equipment, stat cache
-- รันหลัง schema_character_v1.sql
-- =============================================================

-- ============================================================
-- items  (master catalog — server-defined)
-- ============================================================

create table if not exists public.items (
  id          uuid primary key default gen_random_uuid(),
  name_th     text not null,
  name_en     text not null,
  item_type   text not null check (item_type in (
                'weapon','armor','accessory',
                'skill_node','rune','ore',
                'consumable','material','food','trap','seed','blueprint')),
  rarity      text not null check (rarity in (
                'common','uncommon','rare','epic','legendary','mythic')),
  description_th text,
  description_en text,
  base_value  int  not null default 10,  -- gold value เมื่อขาย NPC
  is_stackable boolean not null default false,
  max_stack   int  not null default 1,

  -- Weapon fields (null สำหรับ item ที่ไม่ใช่ weapon)
  weapon_class text check (weapon_class in (
    'polearm','greatsword','bow','staff','sword','dagger',
    'wand','mace','crossbow','shield','catalyst'
  )),

  -- Food fields (ไม่มี hunger/thirst — buff เท่านั้น)
  is_food          boolean not null default false,
  food_buff_effects jsonb,  -- [{stat, amount, duration_sec}] — duration_sec=0 คือ instant

  -- Durability (weapon/armor)
  max_durability int not null default 0,  -- 0 = ไม่มี durability system (consumable/material)

  sprite_path text
);

-- ============================================================
-- player_items  (player inventory)
-- ============================================================

create table if not exists public.player_items (
  id               uuid    primary key default gen_random_uuid(),
  player_id        uuid    not null references public.players(id) on delete cascade,
  item_id          uuid    not null references public.items(id),
  quantity         int     not null default 1 check (quantity >= 1),
  is_identified    boolean not null default true,
  durability       int,          -- null = consumable/material (ไม่มีค่า), 0 = broken
  affixes          jsonb   not null default '[]'::jsonb,  -- [{stat, amount}]
  storage_type     text    not null check (storage_type in ('bag','stash','hotbar')) default 'bag',
  acquired_at      timestamptz not null default now()
);

alter table public.player_items enable row level security;
create policy "items_own" on public.player_items
  for all using (
    player_id in (select id from public.players where user_id = auth.uid())
  );

create index if not exists idx_player_items_player on public.player_items (player_id);

-- ============================================================
-- player_equipment  (equipped gear slots)
-- ============================================================

create table if not exists public.player_equipment (
  player_id       uuid primary key references public.players(id) on delete cascade,
  weapon_main_id  uuid references public.player_items(id),
  weapon_off_id   uuid references public.player_items(id),
  head_id         uuid references public.player_items(id),
  chest_id        uuid references public.player_items(id),
  legs_id         uuid references public.player_items(id),
  boots_id        uuid references public.player_items(id),
  gloves_id       uuid references public.player_items(id),
  accessory1_id   uuid references public.player_items(id),
  accessory2_id   uuid references public.player_items(id),
  badge1_id       uuid references public.player_items(id),
  badge2_id       uuid references public.player_items(id),
  badge3_id       uuid references public.player_items(id)
);

alter table public.player_equipment enable row level security;
create policy "equip_own" on public.player_equipment
  for all using (
    player_id in (select id from public.players where user_id = auth.uid())
  );

-- Create empty equipment row when player is created
create or replace function public.init_player_equipment()
returns trigger language plpgsql security definer as $$
begin
  insert into public.player_equipment (player_id) values (new.id)
  on conflict do nothing;
  return new;
end;
$$;

drop trigger if exists trg_init_equipment on public.players;
create trigger trg_init_equipment
  after insert on public.players
  for each row execute function public.init_player_equipment();

-- ============================================================
-- player_stat_cache  (computed stats — refreshed server-side)
-- ============================================================

create table if not exists public.player_stat_cache (
  player_id       uuid    primary key references public.players(id) on delete cascade,
  hp              int     not null default 100,
  hp_max          int     not null default 100,
  energy          int     not null default 10,
  energy_max      int     not null default 10,
  atk             int     not null default 5,
  def             int     not null default 2,
  spd             int     not null default 5,
  crit_rate       float   not null default 0.05,
  crit_dmg        float   not null default 1.5,
  fire_dmg        float   not null default 0.0,
  ice_dmg         float   not null default 0.0,
  lightning_dmg   float   not null default 0.0,
  all_dmg         float   not null default 0.0,
  cooldown_reduce float   not null default 0.0,
  hp_regen        int     not null default 0,
  energy_regen    int     not null default 0,
  updated_at      timestamptz not null default now()
);

alter table public.player_stat_cache enable row level security;
create policy "stat_cache_own" on public.player_stat_cache
  for select using (
    player_id in (select id from public.players where user_id = auth.uid())
  );

-- Create default stat cache on player creation
create or replace function public.init_player_stat_cache()
returns trigger language plpgsql security definer as $$
begin
  insert into public.player_stat_cache (player_id) values (new.id)
  on conflict do nothing;
  return new;
end;
$$;

drop trigger if exists trg_init_stat_cache on public.players;
create trigger trg_init_stat_cache
  after insert on public.players
  for each row execute function public.init_player_stat_cache();

-- ============================================================
-- Gacha pool seed data
-- ============================================================

-- ตัวอย่าง items สำหรับ gacha pool (เพิ่มเติมได้ใน Game Design §56)
insert into public.items (name_th, name_en, item_type, rarity, base_value, is_stackable, max_stack, max_durability) values
  -- Skill nodes (gacha drop)
  ('โหนดพลังงาน I',    'Energy Node I',      'skill_node', 'common',    50,  true, 99, 0),
  ('โหนดโจมตี I',      'Attack Node I',      'skill_node', 'common',    50,  true, 99, 0),
  ('โหนดป้องกัน I',    'Defense Node I',     'skill_node', 'common',    50,  true, 99, 0),
  ('โหนดความเร็ว I',   'Speed Node I',       'skill_node', 'uncommon',  150, true, 99, 0),
  ('โหนดวิกฤต I',      'Crit Node I',        'skill_node', 'uncommon',  150, true, 99, 0),
  ('โหนดแห่งไฟ',       'Fire Node',          'skill_node', 'rare',      500, true, 99, 0),
  ('โหนดมหาพลัง',      'Grand Power Node',   'skill_node', 'epic',     2000, true, 99, 0),
  -- Runes
  ('รูนแสง I',          'Light Rune I',       'rune', 'common',    30,  true, 20, 0),
  ('รูนมืด I',          'Dark Rune I',        'rune', 'uncommon',  100, true, 20, 0),
  ('รูนไฟ',             'Fire Rune',          'rune', 'rare',      400, true, 10, 0),
  -- Ore
  ('แร่ทองแดง',         'Copper Ore',         'ore',  'common',    20,  true, 50, 0),
  ('แร่เงิน',           'Silver Ore',         'ore',  'uncommon',  80,  true, 50, 0),
  ('แร่ทอง',            'Gold Ore',           'ore',  'rare',      300, true, 30, 0),
  ('แร่มิทริล',         'Mithril Ore',        'ore',  'epic',     1200, true, 10, 0),
  -- Weapons (gacha)
  ('ดาบโบราณ',          'Ancient Sword',      'weapon', 'uncommon', 200, false, 1, 80),
  ('หอกผี',             'Ghost Spear',        'weapon', 'rare',     800, false, 1, 100),
  ('คันธนูลม',          'Wind Bow',           'weapon', 'rare',     900, false, 1, 90),
  ('คทาดาว',            'Star Staff',         'weapon', 'epic',    3500, false, 1, 120),
  -- Consumables
  ('ยาฟื้นฟูเล็ก',      'Small Potion',       'consumable', 'common',  30,  true, 20, 0),
  ('ยาฟื้นฟูกลาง',      'Medium Potion',      'consumable', 'uncommon',90,  true, 10, 0),
  ('ยาฟื้นฟูใหญ่',      'Large Potion',       'consumable', 'rare',   250,  true, 5,  0),
  -- Food
  ('ข้าวต้ม',           'Rice Porridge',      'food', 'common',  20,  true, 5, 0),
  ('ปลาย่าง',           'Grilled Fish',       'food', 'common',  40,  true, 3, 0),
  ('ข้าวผัด',           'Fried Rice',         'food', 'uncommon',80,  true, 3, 0)
on conflict do nothing;

-- อัปเดต food_buff_effects สำหรับ food items
update public.items set
  is_food = true,
  food_buff_effects = '[{"stat":"hp_regen","amount":3,"duration_sec":300}]'::jsonb
where item_type = 'food' and name_en = 'Rice Porridge';

update public.items set
  is_food = true,
  food_buff_effects = '[{"stat":"atk","amount":0.1,"duration_sec":300},{"stat":"hp_flat","amount":10,"duration_sec":0}]'::jsonb
where item_type = 'food' and name_en = 'Grilled Fish';

update public.items set
  is_food = true,
  food_buff_effects = '[{"stat":"atk","amount":0.05,"duration_sec":600},{"stat":"def","amount":0.05,"duration_sec":600}]'::jsonb
where item_type = 'food' and name_en = 'Fried Rice';

-- อัปเดต weapon_class (column อยู่ใน INSERT แต่ positional values ไม่ match — fix ด้วย UPDATE)
update public.items set weapon_class = 'sword'  where name_en = 'Ancient Sword';
update public.items set weapon_class = 'polearm' where name_en = 'Ghost Spear';
update public.items set weapon_class = 'bow'    where name_en = 'Wind Bow';
update public.items set weapon_class = 'staff'  where name_en = 'Star Staff';
