# CLAUDE.md — เทพปกรณัม (Theppakronam)
> อ่านไฟล์นี้ก่อนทำงานทุกครั้ง

---

## สรุปโปรเจกต์ใน 3 ประโยค

เทพปกรณัม (Tower of Convergence) คือ PC RPG แนว open-class + gacha + ATB combat + life simulation
ผู้เล่นรับบทเป็น "ผู้ท้าชิงนิรนาม" ไต่หอเทวภพ 6 อาณาจักร สุ่ม gacha รับ item/weapon/armor/skill node บูชาเทพหลายองค์
ไม่มี fixed class — class ถูกกำหนดโดย weapon ที่ equip, มี weapon proficiency แยกต่างหาก, ปลดล็อก passive skill tree + deity ascension จนกลายเป็นเทพหลายประเภทผสมกันได้

---

## Stack ที่ใช้

| Layer | Technology |
|---|---|
| Game engine | **Godot 4.7** (GDScript) |
| Backend / DB | **Supabase** (PostgreSQL + REST API) |
| Art style | 16-bit pixel art — **Sunnyside World** (danieldiggle) เป็น asset หลัก |
| Target platform | PC (Windows / Mac) |

> ห้ามใช้ React หรือ JavaScript สำหรับ game logic — prototype_v2.jsx ใช้เป็น reference เท่านั้น

> **Asset source หลัก**: [Sunnyside World by danieldiggle](https://danieldiggle.itch.io/sunnyside)
> License: commercial OK, ห้าม resell/AI training
> Character sprites: body_base / outfit_base / hair_01-07 (7 hairstyles, animated)
> Palette swap ผ่าน `character_palette.gdshader` — 3 layers: Body / Outfit / Hair

---

## โครงสร้าง Godot Project (เป้าหมาย)

```
theppakronam/
├── CLAUDE.md
├── HANDOVER.md
├── project.godot
├── addons/
├── _source/              # Aseprite source files (.gdignore — Godot ไม่ import)
├── assets/
│   ├── sprites/
│   │   ├── character/
│   │   │   ├── human/    # Sunnyside Human — แบ่ง action folder: IDLE/ WALK/ ATTACK/ ฯลฯ
│   │   │   │             # naming: {hairstyle}_{action}_strip{N}.png
│   │   │   │             # base_idle_strip9.png = body (no hair), bowlhair_idle_strip9.png = hair layer
│   │   │   └── parts/    # chara_0..15.png — character combination atlas
│   │   ├── enemies/
│   │   │   ├── goblin/
│   │   │   └── skeleton/
│   │   ├── environment/  # animals/ crops/ decorations/ farm/ leaves/ minerals/ plants/ props/ rocks/ trees/
│   │   └── vfx/
│   ├── palettes/         # ว่าง — palette texture สร้างจาก CharacterColors.gd ตอน runtime
│   │   ├── skin/
│   │   ├── hair/
│   │   └── outfit/
│   ├── shaders/
│   │   └── character_palette.gdshader  # color-match approach (ทำงานกับ RGB sprite)
│   ├── tilesets/
│   ├── audio/
│   └── fonts/
├── scenes/
│   ├── main_menu.tscn
│   ├── character_select.tscn  # เลือก/ลบ/สร้าง character slot
│   ├── character_creator.tscn # ออกแบบตัวละคร
│   ├── world_map.tscn    # TileMap / Node2D graph แทน canvas
│   ├── combat.tscn       # ATB combat scene
│   ├── gacha_ui.tscn
│   ├── skill_web.tscn    # passive skill tree
│   ├── inventory.tscn
│   ├── bestiary.tscn
│   └── hud.tscn          # CanvasLayer overlay
├── scripts/
│   ├── autoload/
│   │   ├── GameState.gd       # singleton — player data, current session
│   │   ├── SupabaseClient.gd  # singleton — HTTP calls to Supabase
│   │   ├── TimeManager.gd     # game time / day-night / season
│   │   ├── AudioManager.gd
│   │   └── CharacterColors.gd # singleton — palette presets + runtime texture builder
│   ├── combat/
│   │   ├── ATBCombat.gd          # turn queue, action resolution
│   │   ├── CombatEntity.gd       # base class สำหรับ player + enemy
│   │   ├── BossEntity.gd         # phase system, boss mechanics
│   │   ├── EnemyFieldAI.gd       # field map AI (patrol/chase/detect)
│   │   ├── EnemyCombatAI.gd      # ATB combat AI (archetype-based)
│   │   ├── EnemyGroup.gd         # multi-enemy coordination
│   │   └── MinigameDice.gd       # d20 minigame (flee/capture)
│   ├── systems/
│   │   ├── GachaEngine.gd        # pity, rarity weights, pool sampling
│   │   ├── StatCalculator.gd     # base + equip + skill nodes → effective stat
│   │   ├── SkillTreeGraph.gd     # graph traversal, unlock validation
│   │   ├── EnergyManager.gd      # world energy + battle energy
│   │   ├── DurabilityManager.gd  # decay rules per enemy type
│   │   ├── ProficiencyManager.gd # life skill EXP + rarity scaling
│   │   ├── EcosystemManager.gd   # population tick
│   │   └── TreasuryManager.gd    # town gold flow
│   └── ui/
│       ├── GachaPanel.gd
│       ├── SkillWebRenderer.gd
│       ├── FriendListPanel.gd
│       └── ToastManager.gd
└── sql/                  # Supabase schemas (reference)
    ├── schema_core_v2.sql
    ├── schema_tower_v2.sql
    └── schema_skilltree_v2.sql
```

---

## Core Game Systems

### 1. Gacha (GachaEngine.gd)
- สุ่ม: `skill_node / weapon / armor / rune / ore` — **ไม่มีตัวละคร**
- Pity: ทุก 50 pulls การันตี `epic+` (reset counter เมื่อได้ epic/legendary/mythic)
- Rarity weights: common 45% / uncommon 25% / rare 18% / epic 9% / legendary 2.7% / mythic 0.3%
- Cost: 100 gems / pull, 900 gems / x10
- Logic reference: `doGacha()` ใน prototype_v2.jsx

### 2. Passive Skill Tree (SkillTreeGraph.gd)
- Graph-based web — center node ปลดล็อกอัตโนมัติ
- 5 tiers: tier 1 (stat ล้วน) → tier 5 (ascension node)
- Node structure: `stat_bonus` + `active_skill` + `passive_effect` (3 ส่วนครบ)
- **181 nodes** ครบทุก Band (Universal 29 + Band 1-6 รวม 152 nodes) — ดู §54
- ปลดล็อกได้เมื่อ: มี neighbor ที่ unlock แล้ว + มี gold + มี item (tier 2+)
- Ascension node (tier 5) → `Divinity EXP +200`
- Divinity max = 10 → กลายเป็น "เทพปกรณัม"
- Seed data: schema_skilltree_v2.sql (UUID ตายตัว)

### 3. Character Progression (3 tracks แยกกัน)

```
① Char Level (1–∞)
   EXP จาก combat / quest / life activity
   → เพิ่ม base HP, base ATK, base DEF ตาม level table

② Weapon Proficiency (แยกต่างหากต่อ weapon_class)
   ใช้ sword → sword_prof EXP เพิ่ม, ใช้ bow → bow_prof EXP เพิ่ม
   → เพิ่ม damage multiplier + unlock weapon-specific active skills
   → ตอน equip weapon class ใด = active class นั้น (no fixed class)

③ Divinity Level (0–10)
   จาก skill tree ascension node / boss kill / deity quest
   → unlock title + passive special ability
   → สามารถเป็นเทพหลายประเภทพร้อมกันได้ (ตาม deity worship)
```

### 3b. Stat Calculation (StatCalculator.gd)
```
effective_stat = char_level_base_stat          (จาก level table)
              + weapon_proficiency_bonus        (จาก proficiency level ของ weapon_class ที่ equip)
              + divinity_bonus                  (per divinity_level)
              + equipment_bonus                 (รวม set bonus + affix + card/gem)
              + active_buff_bonus               (จาก food/drink ที่ยังไม่หมดเวลา)
              + Σ(unlocked_skill_node_bonuses)
```
คำนวณฝั่ง server (Supabase function) เท่านั้น — cache ใน `player_stat_cache`

### 4. ATB Combat (ATBCombat.gd)
- FF7-style: แต่ละ unit มี SPD ชาร์จ ATB bar ของตัวเอง
- Actions: Attack (miss chance ถ้า SPD < enemy) / Skill (energy cost) / Item (HOT) / Flee / Capture
- **2 Energy types**: ⚡ World Energy (travel) / 🔋 Battle Energy (combat) — base 10 ทั้งคู่
- Exhausted (battle energy = 0): ATK miss +15%, DEF +10% damage รับ, Skill/Flee greyed out
- Flee: base 20%, SPD bonus, dice d20 optional — fail → drop ถุงเงิน rand(1-10)% gold
- Capture: แสดงเมื่อ enemy HP < 10%, ต้องมี Capture Item (rarity), dice d20 บังคับ
- Gold: **ไม่ drop จาก monster** — จาก Treasure Chest / ถุงเงิน / ขาย NPC
- Item drop: 1-9 items (Unidentified) จาก camp.item_drop_pool
- **Party ATB Sync (§53)**: Shared timeline, individual action window 8-15 วิ, resolve ตาม SPD order

### 5. Tower Map
- หอเทวภพ: Band → Floor → Camp (graph node)
- Band 1 (thai): floor 1–9, แดนศรัทธาโบราณ
- Band 2+ (greek/norse/japanese/egyptian/primordial): unlock server-wide เมื่อ boss first kill
- Camp types: spawn / normal / elite / mini_boss / checkpoint / boss_gate / boss / resource / mystery / hunting_zone / hub
- World Energy cost: normal 4 / elite 6 / mini_boss 8 / boss 10 / resource 2 / mystery 2
- Boss Gate: เปิดเมื่อครบ **2 ใน 3** เงื่อนไข (camps_cleared_pct / mini_bosses_killed / specific_camps)

### 6. Food & Buff System
- **ไม่มี Hunger/Thirst/Fatigue** — ตัดออกทั้งหมด
- อาหาร/เครื่องดื่ม → ให้ **temporary buff** เท่านั้น (duration เป็นวินาที real-time)
- Buff stacking: stat คนละประเภทซ้อนได้, stat เดียวกัน = ใช้ค่าสูงสุด (ไม่ stack)
- ตัวอย่าง buff: `atk +15% / 300s`, `hp_regen +5 / 600s`, `crit_rate +0.1 / 180s`
- เก็บไว้ใน `player_active_buffs` table — expire server-side

### 6b. NPC Relationship & Hiring
- **NPC Relationship level (0–10)** ต่อ NPC template แต่ละตัว
- เพิ่มจาก: ทำ quest ให้ NPC / ให้ของขวัญ / ซื้อขายบ่อย
- **Unlock rewards** ตาม level: สูตร craft / สูตรอาหาร / แผนที่สมบัติ / discount / ability พิเศษ
- **NPC Hiring**: จ้าง NPC ทำงานให้ — ค่าจ้างเป็น gold/วัน
  - `field_worker` — ทำงานในสวน/ฟาร์ม
  - `combat_companion` — ร่วมปาร์ตี้ล่ามอนสเตอร์
  - `guard` — ป้องกันอาณาเขต / รับ wave attack
  - `merchant` — ดูแลร้านค้า / ซื้อขายอัตโนมัติ
  - `crafter` — craft item ตามคำสั่งที่วางไว้

### 6c. Deity Worship System
- เลือกบูชาเทพได้ **หลายองค์** (ไม่จำกัด แต่ EXP แต่ละองค์แยกกัน)
- เทพแต่ละองค์มี **Deity Quest** ชุดของตัวเอง → สำเร็จ = Deity EXP
- Deity EXP ครบ threshold → ปลดล็อก **Deity Ability** และเพิ่ม stat bonus
- Deity types (สามารถผสมกันได้):
  `เทพกสิกรรม / เทพผู้สร้าง / เทพผู้ทำลาย / เทพสงคราม / เทพแห่งการรักษา`
  `เทพแห่งอาหาร / เทพแห่งการค้าขาย / เทพสิ่งทอ / ศิวะเทพ (ผสมสร้าง+ทำลาย)` ฯลฯ

### 7. Character Creator (character_creator.tscn)
- แสดงก่อนเข้าเกมครั้งแรก (หลัง register) และที่ Character Select
- Sunnyside assets: 7 hairstyles (animated), palette swap สำหรับ hair color / skin tone / outfit color
- Palette swap ทำด้วย `character_palette.gdshader` บน 3 sprite layers: Body, Outfit, Hair
- 1 account มีได้ 3 character slots — แต่ละ slot = save file แยกกัน
- ลบตัวละคร: soft delete (`deleted_at`) + confirm 2 ขั้น (modal + พิมพ์ชื่อ)
- Asset source: https://danieldiggle.itch.io/sunnyside

### 7b. Supabase Connection (SupabaseClient.gd)
- ใช้ Godot `HTTPRequest` node — REST API
- ทุก stat-sensitive operation → server-side Supabase function
- Client ส่ง action → server validate → return result

### 8. UI Design Principles (RO-style)

**Layout หลัก** (always visible, ไม่ขึ้นกับ scene):
- **HP/Battle Energy bars** — มุมล่างซ้าย, แสดงตลอดเวลา
- **Hotbar (slots 1–0)** — ด้านล่างกลาง, เหมือน RO action bar
- **Mini-map** — มุมขวาบน
- **Chat box** — มุมล่างขวา (party/global/whisper tabs)
- **Char Level + Divinity Level** — แสดงใกล้ HP bar

**Windows** (floating, draggable, closable):
| Window | เปิดด้วย |
|---|---|
| Status (stat) | Alt+A |
| Inventory (grid) | Alt+E |
| Equipment | Alt+Q |
| Skill Tree | Alt+S |
| NPC Relationship | UI button |
| Deity Worship | UI button |
| Collection Book | UI button |

**Inventory**: grid-based, drag-and-drop ระหว่าง slots, stack items คนละ stack ได้
**Hotbar**: drag item/skill จาก window มาวาง, กด 1-0 ใช้งาน
**NPC dialog**: modal กลางจอ แสดง NPC portrait + relationship bar + options
**Windows ซ้อนกันได้** — Z-order ตาม click ล่าสุด (like RO)

---

## Enum & Constant Reference

```gdscript
# Rarity
const RARITY = ["common","uncommon","rare","epic","legendary","mythic"]
const RARITY_TH = {"common":"ธรรมดา","uncommon":"ไม่ธรรมดา","rare":"หายาก",
                   "epic":"มหากาพย์","legendary":"ตำนาน","mythic":"เทพปกรณัม"}
const RARITY_WEIGHTS = {"common":45,"uncommon":25,"rare":18,"epic":9,"legendary":2.7,"mythic":0.3}

# Divinity titles (index = divinity_level)
const DIVINITY_TITLES = [
  "ผู้ท้าชิง","ผู้แสวงหา","นักสำรวจ","ขุนศึก","วีรบุรุษ",
  "เซียน","ผู้รู้แจ้ง","เทพบุตร","เทพเจ้า","เทพสูงสุด","เทพปกรณัม"
]

# Pantheons
const PANTHEONS = ["thai","greek","norse","japanese","egyptian","primordial"]

# Stat types
const STATS = ["hp","energy","atk","def","spd","crit_rate","crit_dmg",
               "fire_dmg","ice_dmg","lightning_dmg","all_dmg","cooldown_reduce",
               "hp_regen","energy_regen"]

# Energy types
const WORLD_ENERGY_BASE = 100   # ⚡ travel
const BATTLE_ENERGY_BASE = 10   # 🔋 combat

# Weapon classes
const WEAPON_CLASSES = ["polearm","greatsword","bow","staff","sword","dagger","wand","mace","crossbow","shield","catalyst"]

# Colors (ใช้สำหรับ render)
const COLOR_RARITY = {
  "common": Color("#9d97b8"), "uncommon": Color("#4fae6e"),
  "rare": Color("#3f8fe0"), "epic": Color("#a060e0"),
  "legendary": Color("#e0a030"), "mythic": Color("#e0512f")
}
```

---

## Design Decisions (ตัดสินใจแล้ว ห้ามเปลี่ยน)

| หัวข้อ | การตัดสินใจ |
|---|---|
| Gacha unit | **Item เท่านั้น** — ไม่มีตัวละคร |
| Class system | **ไม่มี fixed class** — weapon ที่ equip กำหนด active class ทันที |
| Weapon proficiency | แยกต่างหากต่อ weapon_class — เพิ่มจากการใช้งาน |
| Char progression | **3 tracks**: Char Level + Weapon Proficiency + Divinity Level |
| Deity | บูชาได้หลายองค์, Deity Quest → Deity EXP → ability + stat, ผสมประเภทเทพได้ |
| Food/Drink | **Buff เท่านั้น** — ไม่มี Hunger/Thirst/Fatigue ในเกม |
| Survival | **ตัดออก** — ไม่มี hunger/thirst/fatigue ทุกกรณี |
| Ascension | Divinity Level 0-10 + Deity types (ผสมกันได้) |
| Element system | **ไม่มี weakness system** — ใช้ stat type (fire_dmg ฯลฯ) + elemental resistance per enemy |
| Combat | **ATB** — Attack (miss if SPD<) / Skill (energy) / Item / Flee / Capture |
| Auto-tool | เครื่องมือเหมาะสมถูกเลือกอัตโนมัติ (ไม่ต้องกดเลือก) ตามบริบท (ตัดไม้/ทุบหิน/ต่อสู้) |
| NPC Relationship | level 0-10 ต่อ NPC — unlock สูตร/แผนที่/discount/ability |
| NPC Hiring | จ้าง NPC ทำงานด้วย gold/วัน — field_worker/combat/guard/merchant/crafter |
| Monster wave | มอนสเตอร์โจมตี wave ตามเวลากำหนด — NPC guard ช่วยป้องกันได้ |
| Treasure hunt | แผนที่สมบัติจาก quest/story/NPC relationship → ล่าสมบัติ |
| Bounty | ตั้งค่าหัว/รับค่าหัว — target: player / NPC บางตัว / monster |
| Collection | สมุด collection ครบทุก item/card/ore/monster/NPC |
| Gold | **ไม่ drop จาก monster** — จาก Treasure Chest / ถุงเงิน / ขาย NPC |
| Monster | สะสมเป็น bestiary (collector) — ไม่ได้ใช้ต่อสู้ |
| Guild | Feature flag ปิดอยู่ — เปิด Phase 3 |
| Progression gate | Band unlock = server-wide boss first kill / Skill node tier 3-5 ต้องการ divinity_level 2-8 |
| Boss Gate | ต้องครบ **2 ใน 3** เงื่อนไข |
| Boss Phases | Mini-boss ≥ 2 phases, Boss ≥ 3 phases — data-driven ผ่าน boss_templates |
| Enemy AI | 5 archetypes (Berserker/Tactician/Support/Trickster/Tank), elemental resistance, night modifier |
| Durability | Weapon เสื่อมเมื่อ hit โดน, Armor เมื่อรับ damage > 0, ×enemy_type_mult |
| Difficulty | Normal / Hard / Ascendant / **Eternal Path** (hardcore one-life) |
| Offline/Online | แยก slot — Offline (local) / Guest (anonymous cloud) / Account (cloud ถาวร) |
| Auth | Username+Password / Google / Facebook / Steam / Apple / Discord (Supabase OAuth) |
| Multiplayer | **Friend Session** (ENet P2P + room code) + **Server List** (dedicated) |
| Hardcore marketplace | **Eternal-only** ซื้อขายได้ — normal อ่านราคาได้แต่ซื้อขายไม่ได้ |
| Save | Offline = local encrypt, Guest = anonymous cloud, Account = cloud |
| Upgrade/Refine fail | 3 penalty tiers (60%/30%/10%) — Guarantee Stone ข้ามทุก tier |
| Skill | **Combat Skill** (weapon proficiency) แยกจาก **Life Skill** — EXP pool แยก |
| Tool × Skill | item/tool rarity สูง + skill ต่ำ = ผลไม่เต็ม (ทุก Life Skill) |
| Gold sink | Repair Loop (mandatory) + NPC hiring + Town Treasury passive burn |
| Time | Day/Night ทุก 1 ชม. real time, ฤดูกาลตาม Pantheon แต่ละ Band |
| Building | Grid-based ใน camp field map, shared server, Raid Mode opt-in |
| NPC service | ทุก skill NPC ทำได้ ผู้เล่นทำได้เช่นกัน ถ้า Life Skill level เพียงพอ |

---

## Schema Files (อย่าแก้โดยไม่จำเป็น)

> ⚠️ **Schema ที่ต้องอัปเดต** (ยังไม่ได้รัน migration):
> - `schema_character_v1.sql` — ลบ hunger/thirst/fatigue, เพิ่ม char_level/char_exp
> - `schema_core_v2.sql` — ลบ food_hunger_restore/food_thirst_restore, เพิ่ม food_buff_effects JSONB; ลบ food_state/spoilage_timer จาก player_items
> - `schema_progression_v1.sql` — **ไฟล์ใหม่** (ยังไม่สร้าง)

| File | Tables หลัก | สถานะ |
|---|---|---|
| schema_core_v2.sql | players, items (**ลบ food_hunger/thirst_restore → เพิ่ม food_buff_effects JSONB**), player_items (**ลบ food_state/spoilage_timer**), player_equipment | ⚠️ ต้องอัปเดต |
| schema_character_v1.sql | accounts, players (**เพิ่ม char_level INT, char_exp BIGINT; ลบ hunger/thirst/fatigue**), active_characters view | ⚠️ ต้องอัปเดต |
| schema_progression_v1.sql | player_weapon_proficiency, player_active_buffs, deity_templates, player_deity_worship, deity_quests, npc_relationships, hired_npcs, bounties, treasure_maps | ❌ ยังไม่สร้าง |
| schema_tower_v2.sql | tower_bands, tower_floors, tower_camps, camp_connections, player_camp_state, battle_logs, bestiary_monsters, player_monsters, server_boss_kills, boss_clear_records, band_ascension_log, divinity_exp_log, auto_hunt_sessions, weather_pool | ✅ ใช้งานได้ |
| schema_skilltree_v2.sql | seed data 181 nodes (UUID ตายตัว) ครบทุก Band tier 1-5 | ✅ ใช้งานได้ |
| schema_combat_v1.sql | combat_sessions, combat_action_log, player_status_effects, party_combat_members, party_loot_rolls, boss_templates, boss_phases, boss_drop_table, enemy_templates, enemy_patterns | ✅ ใช้งานได้ |
| schema_upgrade_v1.sql | upgrade_attempts | ✅ ใช้งานได้ |
| schema_marketplace_v1.sql | marketplace_listings (Eternal-only) | ✅ ใช้งานได้ |
| schema_crafting_v1.sql | crafting_recipes, crafting_recipe_inputs, player_proficiency, camp_buildings, farm_plots, tamed_animals, treasure_spots, merchant_catalog, npc_services, achievements, player_achievements, mystery_events, player_mystery_log | ✅ ใช้งานได้ |
| schema_social_v1.sql | friendships, friend_requests, player_notifications, player_blocks, room_codes, player_stash, quests, player_daily_stats, player_weekly_stats, leaderboard_history, player_reward_queue, guilds, guild_members, guild_stash_items, guild_stash_log, guild_quests | ✅ ใช้งานได้ |
| schema_world_v1.sql | world_time_config, get_game_time(), weather_pool, game_news, player_news_read | ✅ ใช้งานได้ |
| schema_npc_v1.sql | npc_templates, camp_npcs, player_crimes, player_threat, player_reputation, jail_sentences, npc_damage_log, town_treasury, treasury_log | ✅ ใช้งานได้ |
| schema_ecosystem_v1.sql | floor_species, species_relations, ecosystem_log, run_ecosystem_tick() | ✅ ใช้งานได้ |

---

## สถานะการออกแบบ

**GAME_DESIGN.md §1-§66 ครบทุก 66 ระบบ — Gap Analysis 100% ✅ พร้อม implement**

sessions ล่าสุดที่ออกแบบเพิ่ม:
- §51 Boss Mechanics, §52 Enemy AI, §53 Party ATB Sync (ครบสมบูรณ์)
- §54 Skill Node Pool (181 nodes), §55 NPC Shop, §56 Recipe List (125 recipes)
- §57 Auto-Hunt (slider 15นาที-12ชม.), §58 Food Spoilage, §59 Trap/Watchtower
- §60 Achievements (63), §61 Analytics, §62 Weather, §63 Mystery Camp
- §64 Guild (Phase 3, feature flag ปิด), §65 Daily/Weekly Leaderboard, §66 In-Game News
- **Combat Skills (§26)**: swordsmanship, polearm_mastery, archery, crossbow, staffcraft, unarmed
- **Life Skills (§27)**: smithing, carpentry, masonry, alchemy, cooking, tailoring, repair, upgrade, woodcutting, mining, foraging, fishing, scavenging, farming, animal_handling, hunting, construction, trading, naturalist

---

## Reference Files

| File | ใช้ทำอะไร |
|---|---|
| **GAME_DESIGN.md** | **Game Design Document ฉบับสมบูรณ์ — อ่านก่อนเขียน code ทุกระบบ** |
| prototype_v2.jsx | Logic reference: gacha, stat calc, skill tree, combat mock, world map |
| HANDOVER.md | ประวัติการออกแบบ, บริบท, สิ่งที่คุยมาแล้ว |
