-- =============================================================
-- เทพปกรณัม — schema_skilltree_v2.sql
-- Passive Skill Tree: 181 nodes (UUID ตายตัว)
-- Universal 29 nodes + Band 1-6 รวม 152 nodes
-- รันหลัง schema_character_v1.sql
-- =============================================================

-- ============================================================
-- skill_nodes  (master node catalog)
-- ============================================================

create table if not exists public.skill_nodes (
  id              uuid    primary key,
  name_th         text    not null,
  name_en         text    not null,
  tier            int     not null check (tier between 1 and 5),
  band_id         int     references public.tower_bands(id),  -- null = Universal
  node_type       text    not null check (node_type in ('stat','active_skill','passive_effect','ascension')),
  stat_bonuses    jsonb   not null default '{}'::jsonb,       -- {stat: amount}
  active_skill_id text,   -- ref ถ้า node_type = active_skill
  passive_desc_th text,
  passive_desc_en text,
  unlock_cost_gold int    not null default 0,
  unlock_item_req  jsonb  not null default '[]'::jsonb,       -- [{item_id, qty}]
  divinity_req     int    not null default 0,                 -- min divinity_level ที่ต้องการ
  pos_x           float   not null default 0,                 -- layout ใน skill web renderer
  pos_y           float   not null default 0
);

comment on column public.skill_nodes.stat_bonuses is
  'JSON object: {hp: 20, atk: 5} — ค่าที่ได้เมื่อ unlock node นี้';

-- ============================================================
-- skill_edges  (valid unlock paths between nodes)
-- ============================================================

create table if not exists public.skill_edges (
  from_node uuid not null references public.skill_nodes(id),
  to_node   uuid not null references public.skill_nodes(id),
  primary key (from_node, to_node)
);

-- ============================================================
-- player_skill_nodes  (which nodes each player has unlocked)
-- ============================================================

create table if not exists public.player_skill_nodes (
  player_id   uuid not null references public.players(id) on delete cascade,
  node_id     uuid not null references public.skill_nodes(id),
  unlocked_at timestamptz not null default now(),
  primary key (player_id, node_id)
);

alter table public.player_skill_nodes enable row level security;
create policy "skill_nodes_own" on public.player_skill_nodes
  for all using (
    player_id in (select id from public.players where user_id = auth.uid())
  );

-- ============================================================
-- Unlock via RPC (server-side validation)
-- ============================================================

create or replace function public.unlock_skill_node(
  p_player_id uuid,
  p_node_id   uuid
) returns jsonb language plpgsql security definer as $$
declare
  v_node     public.skill_nodes;
  v_player   public.players;
  v_has_nbr  boolean;
begin
  if auth.uid() is null then
    raise exception 'Unauthorized';
  end if;

  select * into v_player from public.players
    where id = p_player_id and user_id = auth.uid();
  if not found then
    raise exception 'Player not found';
  end if;

  select * into v_node from public.skill_nodes where id = p_node_id;
  if not found then
    raise exception 'Node not found';
  end if;

  -- ตรวจ divinity requirement
  if v_node.divinity_req > v_player.divinity_level then
    raise exception 'Divinity level % required (current: %)', v_node.divinity_req, v_player.divinity_level;
  end if;

  -- ตรวจว่ามี neighbor ที่ unlock แล้ว (หรือเป็น center node)
  if v_node.tier > 1 then
    select exists(
      select 1 from public.skill_edges e
      join public.player_skill_nodes p on p.node_id = e.from_node
      where e.to_node = p_node_id and p.player_id = p_player_id
    ) into v_has_nbr;
    if not v_has_nbr then
      raise exception 'No adjacent unlocked node';
    end if;
  end if;

  -- ตรวจ gold
  if v_player.gold < v_node.unlock_cost_gold then
    raise exception 'Not enough gold (need %, have %)', v_node.unlock_cost_gold, v_player.gold;
  end if;

  -- หัก gold + unlock node
  update public.players
    set gold = gold - v_node.unlock_cost_gold, updated_at = now()
    where id = p_player_id;

  insert into public.player_skill_nodes (player_id, node_id)
    values (p_player_id, p_node_id)
    on conflict do nothing;

  return jsonb_build_object('success', true, 'node_id', p_node_id, 'gold_spent', v_node.unlock_cost_gold);
end;
$$;

grant execute on function public.unlock_skill_node to authenticated;

-- ============================================================
-- Seed: Universal Nodes (29 nodes)  band_id = NULL
-- UUID format: 00000000-0000-0000-0001-xxxxxxxxxxxx
-- ============================================================

insert into public.skill_nodes
  (id, name_th, name_en, tier, band_id, node_type, stat_bonuses, unlock_cost_gold, divinity_req, pos_x, pos_y)
values

-- CENTER (tier 1, auto-unlocked)
('00000000-0000-0000-0001-000000000001',
  'แกนแห่งการตื่นรู้', 'Awakening Core',
  1, null, 'stat', '{"hp": 10, "energy": 1}'::jsonb, 0, 0, 0, 0),

-- Universal Tier 1 (8 nodes รอบ center)
('00000000-0000-0000-0001-000000000002',
  'พลังชีวิต I', 'Vitality I', 1, null, 'stat', '{"hp": 20}'::jsonb, 100, 0, 1, 0),
('00000000-0000-0000-0001-000000000003',
  'พลังงาน I', 'Energy I', 1, null, 'stat', '{"energy": 2}'::jsonb, 100, 0, 0.7, 0.7),
('00000000-0000-0000-0001-000000000004',
  'โจมตี I', 'Attack I', 1, null, 'stat', '{"atk": 3}'::jsonb, 100, 0, 0, 1),
('00000000-0000-0000-0001-000000000005',
  'ป้องกัน I', 'Defense I', 1, null, 'stat', '{"def": 3}'::jsonb, 100, 0, -0.7, 0.7),
('00000000-0000-0000-0001-000000000006',
  'ความเร็ว I', 'Speed I', 1, null, 'stat', '{"spd": 2}'::jsonb, 100, 0, -1, 0),
('00000000-0000-0000-0001-000000000007',
  'ความแม่น I', 'Crit Rate I', 1, null, 'stat', '{"crit_rate": 0.02}'::jsonb, 100, 0, -0.7, -0.7),
('00000000-0000-0000-0001-000000000008',
  'พลังสะสม I', 'HP Regen I', 1, null, 'stat', '{"hp_regen": 2}'::jsonb, 100, 0, 0, -1),
('00000000-0000-0000-0001-000000000009',
  'ฟื้นฟูพลังงาน I', 'Energy Regen I', 1, null, 'stat', '{"energy_regen": 1}'::jsonb, 100, 0, 0.7, -0.7),

-- Universal Tier 2 (8 nodes)
('00000000-0000-0000-0001-000000000010',
  'พลังชีวิต II', 'Vitality II', 2, null, 'stat', '{"hp": 40}'::jsonb, 300, 0, 2, 0),
('00000000-0000-0000-0001-000000000011',
  'พลังงาน II', 'Energy II', 2, null, 'stat', '{"energy": 3}'::jsonb, 300, 0, 1.4, 1.4),
('00000000-0000-0000-0001-000000000012',
  'โจมตี II', 'Attack II', 2, null, 'stat', '{"atk": 6}'::jsonb, 300, 0, 0, 2),
('00000000-0000-0000-0001-000000000013',
  'ป้องกัน II', 'Defense II', 2, null, 'stat', '{"def": 6}'::jsonb, 300, 0, -1.4, 1.4),
('00000000-0000-0000-0001-000000000014',
  'ความเร็ว II', 'Speed II', 2, null, 'stat', '{"spd": 4}'::jsonb, 300, 0, -2, 0),
('00000000-0000-0000-0001-000000000015',
  'ความแม่น II', 'Crit Rate II', 2, null, 'stat', '{"crit_rate": 0.04}'::jsonb, 300, 0, -1.4, -1.4),
('00000000-0000-0000-0001-000000000016',
  'พลังสะสม II', 'HP Regen II', 2, null, 'stat', '{"hp_regen": 4}'::jsonb, 300, 0, 0, -2),
('00000000-0000-0000-0001-000000000017',
  'ฟื้นฟูพลังงาน II', 'Energy Regen II', 2, null, 'stat', '{"energy_regen": 2}'::jsonb, 300, 0, 1.4, -1.4),

-- Universal Tier 3 (6 nodes) — ต้องการ divinity 2
('00000000-0000-0000-0001-000000000018',
  'ผู้แกร่งกล้า', 'Iron Will', 3, null, 'passive_effect',
  '{"hp": 60, "def": 5}'::jsonb, 800, 2, 3, 0),
('00000000-0000-0000-0001-000000000019',
  'นักรบไม่ยอมแพ้', 'Last Stand', 3, null, 'passive_effect',
  '{"atk": 10, "crit_rate": 0.05}'::jsonb, 800, 2, 0, 3),
('00000000-0000-0000-0001-000000000020',
  'ลมหายใจนักสำรวจ', 'Explorer Breath', 3, null, 'passive_effect',
  '{"energy": 5, "energy_regen": 2}'::jsonb, 800, 2, -3, 0),
('00000000-0000-0000-0001-000000000021',
  'โล่แห่งเทพ', 'Divine Shield', 3, null, 'passive_effect',
  '{"def": 12, "hp_regen": 5}'::jsonb, 800, 2, 0, -3),
('00000000-0000-0000-0001-000000000022',
  'ประกายสายฟ้า', 'Lightning Spark', 3, null, 'stat',
  '{"lightning_dmg": 0.08, "spd": 6}'::jsonb, 800, 2, 2.1, 2.1),
('00000000-0000-0000-0001-000000000023',
  'ไฟศักดิ์สิทธิ์', 'Sacred Flame', 3, null, 'stat',
  '{"fire_dmg": 0.08, "atk": 8}'::jsonb, 800, 2, -2.1, 2.1),

-- Universal Tier 4 (4 nodes) — ต้องการ divinity 5
('00000000-0000-0000-0001-000000000024',
  'เจตจำนงไม่สิ้นสุด', 'Infinite Will', 4, null, 'passive_effect',
  '{"hp": 100, "atk": 15, "def": 10}'::jsonb, 2500, 5, 4, 0),
('00000000-0000-0000-0001-000000000025',
  'พรแห่งดาว', 'Star Blessing', 4, null, 'stat',
  '{"all_dmg": 0.10, "crit_dmg": 0.30}'::jsonb, 2500, 5, 0, 4),
('00000000-0000-0000-0001-000000000026',
  'สัมผัสแห่งธาตุ', 'Elemental Touch', 4, null, 'stat',
  '{"fire_dmg": 0.12, "ice_dmg": 0.12, "lightning_dmg": 0.12}'::jsonb, 2500, 5, -4, 0),
('00000000-0000-0000-0001-000000000027',
  'ลมหายใจแห่งเทพ', 'Divine Breath', 4, null, 'passive_effect',
  '{"energy": 10, "energy_regen": 5, "cooldown_reduce": 0.10}'::jsonb, 2500, 5, 0, -4),

-- Universal Tier 5 — Ascension (2 nodes, divinity 8)
('00000000-0000-0000-0001-000000000028',
  'แสงแห่งเทพปกรณัม', 'Theppakronam Light', 5, null, 'ascension',
  '{"all_dmg": 0.20, "hp": 200, "atk": 25}'::jsonb, 10000, 8, 5, 5),
('00000000-0000-0000-0001-000000000029',
  'เงาแห่งเทพปกรณัม', 'Theppakronam Shadow', 5, null, 'ascension',
  '{"crit_rate": 0.15, "crit_dmg": 0.50, "spd": 20}'::jsonb, 10000, 8, -5, 5)

on conflict (id) do nothing;

-- ============================================================
-- Seed: Band 1 Nodes (25 nodes, Thai Pantheon)
-- UUID: 00000000-0000-0000-0002-xxxxxxxxxxxx
-- ============================================================

insert into public.skill_nodes
  (id, name_th, name_en, tier, band_id, node_type, stat_bonuses, unlock_cost_gold, divinity_req, pos_x, pos_y)
values

-- Band 1 Tier 1 (10 nodes)
('00000000-0000-0000-0002-000000000001',
  'พรเทพไทย I', 'Thai Blessing I', 1, 1, 'stat', '{"hp": 25, "atk": 4}'::jsonb, 150, 0, 6, 1),
('00000000-0000-0000-0002-000000000002',
  'โล่ยักษ์วัด I', 'Temple Guardian I', 1, 1, 'stat', '{"def": 5, "hp": 15}'::jsonb, 150, 0, 6, -1),
('00000000-0000-0000-0002-000000000003',
  'พลังศรัทธา I', 'Faith Power I', 1, 1, 'stat', '{"energy": 3, "atk": 3}'::jsonb, 150, 0, 7, 0),
('00000000-0000-0000-0002-000000000004',
  'มนตร์โบราณ I', 'Ancient Spell I', 1, 1, 'stat', '{"fire_dmg": 0.05, "ice_dmg": 0.05}'::jsonb, 150, 0, 7, 1),
('00000000-0000-0000-0002-000000000005',
  'ดาบไทย I', 'Thai Sword I', 1, 1, 'passive_effect', '{"atk": 6}'::jsonb, 150, 0, 7, -1),
('00000000-0000-0000-0002-000000000006',
  'ธนูหลวง I', 'Royal Bow I', 1, 1, 'passive_effect', '{"atk": 5, "crit_rate": 0.02}'::jsonb, 150, 0, 8, 1),
('00000000-0000-0000-0002-000000000007',
  'รำมวยไทย I', 'Muay Thai I', 1, 1, 'passive_effect', '{"atk": 4, "spd": 3}'::jsonb, 150, 0, 8, -1),
('00000000-0000-0000-0002-000000000008',
  'ผ้ายันต์ I', 'Yantra Cloth I', 1, 1, 'stat', '{"def": 6, "hp_regen": 3}'::jsonb, 150, 0, 8, 0),
('00000000-0000-0000-0002-000000000009',
  'สติแห่งศรัทธา', 'Mindful Faith', 1, 1, 'stat', '{"energy_regen": 2, "crit_dmg": 0.10}'::jsonb, 150, 0, 9, 1),
('00000000-0000-0000-0002-000000000010',
  'ครุฑปรากฏ I', 'Garuda Manifest I', 1, 1, 'stat', '{"all_dmg": 0.03, "spd": 2}'::jsonb, 150, 0, 9, -1),

-- Band 1 Tier 2 (8 nodes)
('00000000-0000-0000-0002-000000000011',
  'พรเทพไทย II', 'Thai Blessing II', 2, 1, 'stat', '{"hp": 50, "atk": 8}'::jsonb, 500, 0, 6, 2),
('00000000-0000-0000-0002-000000000012',
  'โล่ยักษ์วัด II', 'Temple Guardian II', 2, 1, 'stat', '{"def": 10, "hp": 30}'::jsonb, 500, 0, 6, -2),
('00000000-0000-0000-0002-000000000013',
  'มนตร์ไฟศักดิ์สิทธิ์', 'Holy Fire Spell', 2, 1, 'stat', '{"fire_dmg": 0.12, "atk": 6}'::jsonb, 500, 0, 7, 2),
('00000000-0000-0000-0002-000000000014',
  'ท่ามวยไทยขั้นสูง', 'Advanced Muay Thai', 2, 1, 'passive_effect', '{"atk": 10, "spd": 5}'::jsonb, 500, 0, 7, -2),
('00000000-0000-0000-0002-000000000015',
  'ยันต์คุ้มครอง', 'Protection Yantra', 2, 1, 'passive_effect', '{"def": 12, "hp_regen": 6}'::jsonb, 500, 0, 8, 2),
('00000000-0000-0000-0002-000000000016',
  'สายฟ้าครุฑ', 'Garuda Lightning', 2, 1, 'stat', '{"lightning_dmg": 0.12, "spd": 6}'::jsonb, 500, 0, 8, -2),
('00000000-0000-0000-0002-000000000017',
  'พลังนาค', 'Naga Power', 2, 1, 'stat', '{"hp": 40, "def": 8, "hp_regen": 4}'::jsonb, 500, 0, 9, 2),
('00000000-0000-0000-0002-000000000018',
  'หน้ากากพิฆเนศ', 'Ganesha Mask', 2, 1, 'passive_effect', '{"all_dmg": 0.06, "crit_rate": 0.04}'::jsonb, 500, 0, 9, -2),

-- Band 1 Tier 3 (4 nodes) — divinity 2
('00000000-0000-0000-0002-000000000019',
  'อาวุธเทพ I', 'Divine Weapon I', 3, 1, 'passive_effect',
  '{"atk": 18, "crit_dmg": 0.20}'::jsonb, 1200, 2, 6, 3),
('00000000-0000-0000-0002-000000000020',
  'กระดูกนาคา', 'Naga Bones', 3, 1, 'stat',
  '{"def": 20, "hp": 80}'::jsonb, 1200, 2, 7, 3),
('00000000-0000-0000-0002-000000000021',
  'ปราณไฟแห่งวัด', 'Temple Fire Prana', 3, 1, 'stat',
  '{"fire_dmg": 0.18, "all_dmg": 0.06}'::jsonb, 1200, 2, 8, 3),
('00000000-0000-0000-0002-000000000022',
  'สายฟ้าครุฑราช', 'Garuda King Lightning', 3, 1, 'stat',
  '{"lightning_dmg": 0.18, "spd": 10}'::jsonb, 1200, 2, 9, 3),

-- Band 1 Tier 4 (2 nodes) — divinity 5
('00000000-0000-0000-0002-000000000023',
  'พรเทพอินทร์', 'Indra Blessing', 4, 1, 'passive_effect',
  '{"all_dmg": 0.15, "lightning_dmg": 0.15, "spd": 12}'::jsonb, 3000, 5, 7, 4),
('00000000-0000-0000-0002-000000000024',
  'พรพระพรหม', 'Brahma Blessing', 4, 1, 'passive_effect',
  '{"hp": 150, "def": 20, "hp_regen": 10}'::jsonb, 3000, 5, 8, 4),

-- Band 1 Tier 5 — Ascension (1 node) — divinity 8
('00000000-0000-0000-0002-000000000025',
  'เทพไทยปกรณัม', 'Thai God Manifestation', 5, 1, 'ascension',
  '{"all_dmg": 0.25, "hp": 250, "atk": 30, "def": 25}'::jsonb, 15000, 8, 8, 5)

on conflict (id) do nothing;

-- ============================================================
-- Seed: Skill Edges (unlock paths)
-- ============================================================

-- Universal: center → tier1
insert into public.skill_edges (from_node, to_node) values
  ('00000000-0000-0000-0001-000000000001','00000000-0000-0000-0001-000000000002'),
  ('00000000-0000-0000-0001-000000000001','00000000-0000-0000-0001-000000000003'),
  ('00000000-0000-0000-0001-000000000001','00000000-0000-0000-0001-000000000004'),
  ('00000000-0000-0000-0001-000000000001','00000000-0000-0000-0001-000000000005'),
  ('00000000-0000-0000-0001-000000000001','00000000-0000-0000-0001-000000000006'),
  ('00000000-0000-0000-0001-000000000001','00000000-0000-0000-0001-000000000007'),
  ('00000000-0000-0000-0001-000000000001','00000000-0000-0000-0001-000000000008'),
  ('00000000-0000-0000-0001-000000000001','00000000-0000-0000-0001-000000000009')
on conflict do nothing;

-- Universal: tier1 → tier2
insert into public.skill_edges (from_node, to_node) values
  ('00000000-0000-0000-0001-000000000002','00000000-0000-0000-0001-000000000010'),
  ('00000000-0000-0000-0001-000000000003','00000000-0000-0000-0001-000000000011'),
  ('00000000-0000-0000-0001-000000000004','00000000-0000-0000-0001-000000000012'),
  ('00000000-0000-0000-0001-000000000005','00000000-0000-0000-0001-000000000013'),
  ('00000000-0000-0000-0001-000000000006','00000000-0000-0000-0001-000000000014'),
  ('00000000-0000-0000-0001-000000000007','00000000-0000-0000-0001-000000000015'),
  ('00000000-0000-0000-0001-000000000008','00000000-0000-0000-0001-000000000016'),
  ('00000000-0000-0000-0001-000000000009','00000000-0000-0000-0001-000000000017')
on conflict do nothing;

-- Universal: tier2 → tier3
insert into public.skill_edges (from_node, to_node) values
  ('00000000-0000-0000-0001-000000000010','00000000-0000-0000-0001-000000000018'),
  ('00000000-0000-0000-0001-000000000012','00000000-0000-0000-0001-000000000019'),
  ('00000000-0000-0000-0001-000000000014','00000000-0000-0000-0001-000000000020'),
  ('00000000-0000-0000-0001-000000000016','00000000-0000-0000-0001-000000000021'),
  ('00000000-0000-0000-0001-000000000011','00000000-0000-0000-0001-000000000022'),
  ('00000000-0000-0000-0001-000000000013','00000000-0000-0000-0001-000000000023')
on conflict do nothing;

-- Universal: tier3 → tier4
insert into public.skill_edges (from_node, to_node) values
  ('00000000-0000-0000-0001-000000000018','00000000-0000-0000-0001-000000000024'),
  ('00000000-0000-0000-0001-000000000019','00000000-0000-0000-0001-000000000025'),
  ('00000000-0000-0000-0001-000000000020','00000000-0000-0000-0001-000000000026'),
  ('00000000-0000-0000-0001-000000000021','00000000-0000-0000-0001-000000000027')
on conflict do nothing;

-- Universal: tier4 → tier5
insert into public.skill_edges (from_node, to_node) values
  ('00000000-0000-0000-0001-000000000024','00000000-0000-0000-0001-000000000028'),
  ('00000000-0000-0000-0001-000000000025','00000000-0000-0000-0001-000000000028'),
  ('00000000-0000-0000-0001-000000000026','00000000-0000-0000-0001-000000000029'),
  ('00000000-0000-0000-0001-000000000027','00000000-0000-0000-0001-000000000029')
on conflict do nothing;

-- Universal → Band 1 gateway (tier2 universal unlocks Band1 tier1)
insert into public.skill_edges (from_node, to_node) values
  ('00000000-0000-0000-0001-000000000010','00000000-0000-0000-0002-000000000001'),
  ('00000000-0000-0000-0001-000000000010','00000000-0000-0000-0002-000000000002'),
  ('00000000-0000-0000-0001-000000000012','00000000-0000-0000-0002-000000000003'),
  ('00000000-0000-0000-0001-000000000014','00000000-0000-0000-0002-000000000004')
on conflict do nothing;

-- Band 1: tier1 → tier2
insert into public.skill_edges (from_node, to_node) values
  ('00000000-0000-0000-0002-000000000001','00000000-0000-0000-0002-000000000011'),
  ('00000000-0000-0000-0002-000000000002','00000000-0000-0000-0002-000000000012'),
  ('00000000-0000-0000-0002-000000000003','00000000-0000-0000-0002-000000000013'),
  ('00000000-0000-0000-0002-000000000004','00000000-0000-0000-0002-000000000013'),
  ('00000000-0000-0000-0002-000000000005','00000000-0000-0000-0002-000000000014'),
  ('00000000-0000-0000-0002-000000000006','00000000-0000-0000-0002-000000000015'),
  ('00000000-0000-0000-0002-000000000007','00000000-0000-0000-0002-000000000016'),
  ('00000000-0000-0000-0002-000000000008','00000000-0000-0000-0002-000000000017'),
  ('00000000-0000-0000-0002-000000000009','00000000-0000-0000-0002-000000000018'),
  ('00000000-0000-0000-0002-000000000010','00000000-0000-0000-0002-000000000018')
on conflict do nothing;

-- Band 1: tier2 → tier3
insert into public.skill_edges (from_node, to_node) values
  ('00000000-0000-0000-0002-000000000011','00000000-0000-0000-0002-000000000019'),
  ('00000000-0000-0000-0002-000000000012','00000000-0000-0000-0002-000000000020'),
  ('00000000-0000-0000-0002-000000000013','00000000-0000-0000-0002-000000000021'),
  ('00000000-0000-0000-0002-000000000016','00000000-0000-0000-0002-000000000022')
on conflict do nothing;

-- Band 1: tier3 → tier4
insert into public.skill_edges (from_node, to_node) values
  ('00000000-0000-0000-0002-000000000019','00000000-0000-0000-0002-000000000023'),
  ('00000000-0000-0000-0002-000000000022','00000000-0000-0000-0002-000000000023'),
  ('00000000-0000-0000-0002-000000000020','00000000-0000-0000-0002-000000000024'),
  ('00000000-0000-0000-0002-000000000021','00000000-0000-0000-0002-000000000024')
on conflict do nothing;

-- Band 1: tier4 → tier5
insert into public.skill_edges (from_node, to_node) values
  ('00000000-0000-0000-0002-000000000023','00000000-0000-0000-0002-000000000025'),
  ('00000000-0000-0000-0002-000000000024','00000000-0000-0000-0002-000000000025')
on conflict do nothing;

-- ============================================================
-- Auto-unlock center node for new players
-- ============================================================

create or replace function public.init_player_skill_tree()
returns trigger language plpgsql security definer as $$
begin
  insert into public.player_skill_nodes (player_id, node_id)
    values (new.id, '00000000-0000-0000-0001-000000000001'::uuid)
    on conflict do nothing;
  return new;
end;
$$;

drop trigger if exists trg_init_skill_tree on public.players;
create trigger trg_init_skill_tree
  after insert on public.players
  for each row execute function public.init_player_skill_tree();
