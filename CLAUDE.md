# CLAUDE.md — เทพปกรณัม (Theppakronam)
> อ่านไฟล์นี้ก่อนทำงานทุกครั้ง

---

## สรุปโปรเจกต์ใน 3 ประโยค

เทพปกรณัม (Tower of Convergence) คือ PC RPG แนว survival-craft + gacha + ATB combat
ผู้เล่นรับบทเป็น "ผู้ท้าชิงนิรนาม" ไต่หอเทวภพ สุ่ม gacha รับ item/weapon/armor/skill node
ปลดล็อก passive skill tree จนกลายเป็นเทพ — มีระบบ gathering/farming/building/hunting/fishing เสริม

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

### 3. Stat Calculation (StatCalculator.gd)
Port จาก `calcStats()` ใน prototype:
```
effective_stat = base_stat
              + divinity_bonus (per divinity_level — ดู §2 Divinity Level Table)
              + equipment_bonus (รวม set bonus + affix)
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

### 6. Character Creator (character_creator.tscn)
- แสดงก่อนเข้าเกมครั้งแรก (หลัง register) และที่ Character Select
- Sunnyside assets: 7 hairstyles (animated), palette swap สำหรับ hair color / skin tone / outfit color
- Palette swap ทำด้วย `character_palette.gdshader` บน 3 sprite layers: Body, Outfit, Hair
- 1 account มีได้ 3 character slots — แต่ละ slot = save file แยกกัน
- ลบตัวละคร: soft delete (`deleted_at`) + confirm 2 ขั้น (modal + พิมพ์ชื่อ)
- Asset source: https://danieldiggle.itch.io/sunnyside

### 7. Supabase Connection (SupabaseClient.gd)
- ใช้ Godot `HTTPRequest` node — REST API
- ทุก stat-sensitive operation → server-side Supabase function
- Client ส่ง action → server validate → return result

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
| Ascension | สะสม Divinity EXP จากหลายแหล่ง → level 0-10 |
| Element system | **ไม่มี weakness system** — ใช้ stat type (fire_dmg ฯลฯ) + elemental resistance per enemy |
| Combat | **ATB** — Attack (miss if SPD<) / Skill (energy) / Item (HOT) / Flee / Capture |
| Gold | **ไม่ drop จาก monster** — จาก Treasure Chest / ถุงเงิน / ขาย NPC |
| Monster | สะสมเป็น bestiary (collector) — ไม่ได้ใช้ต่อสู้ |
| Guild | Feature flag ปิดอยู่ — เปิด Phase 3 |
| Progression gate | Band unlock = server-wide boss first kill / Skill node tier 3-5 ต้องการ divinity_level 2-8 |
| Boss Gate | ต้องครบ **2 ใน 3** เงื่อนไข |
| Boss Phases | Mini-boss ≥ 2 phases, Boss ≥ 3 phases — data-driven ผ่าน boss_templates |
| Enemy AI | 5 archetypes (Berserker/Tactician/Support/Trickster/Tank), elemental resistance, night modifier |
| Durability | Weapon เสื่อมเมื่อ hit โดน, Armor เมื่อรับ damage > 0, ×enemy_type_mult (Slime ×0 → Mythic ×3) |
| Difficulty | Normal / Hard / Ascendant / **Eternal Path** (hardcore one-life) |
| Offline/Online | แยก slot — Offline (local) / Guest (anonymous cloud) / Account (cloud ถาวร) |
| Auth | Username+Password / Google / Facebook / Steam / Apple / Discord (Supabase OAuth) |
| Multiplayer | **Friend Session** (ENet P2P + room code) + **Server List** (dedicated) |
| Hardcore marketplace | **Eternal-only** ซื้อขายได้ — normal อ่านราคาได้แต่ซื้อขายไม่ได้ |
| Save | Offline = local encrypt, Guest = anonymous cloud, Account = cloud |
| Upgrade/Refine fail | 3 penalty tiers (60%/30%/10%) — Guarantee Stone ข้ามทุก tier |
| Skill | **Combat Skill (§26)** แยกจาก **Life Skill (§27)** — EXP pool แยก |
| Tool × Skill | item/tool rarity สูง + skill ต่ำ = ผลไม่เต็ม (ทุก Life Skill) |
| Gold sink | Repair Loop (mandatory) + 13 รายการ optional — Town Treasury passive burn |
| Survival | Hunger/Thirst/Fatigue — soft buff/debuff ไม่ตาย, decay หยุดเมื่อ offline |
| Time | Day/Night ทุก 1 ชม. real time, ฤดูกาลตาม Pantheon แต่ละ Band |
| Building | Grid-based ใน camp field map, shared server, Raid Mode opt-in |
| NPC service | ทุก skill NPC ทำได้ ผู้เล่นทำได้เช่นกัน ถ้า Life Skill level เพียงพอ |

---

## Schema Files (อย่าแก้โดยไม่จำเป็น)

| File | Tables หลัก |
|---|---|
| schema_core_v2.sql | players (+hunger/thirst/fatigue/inventory_slots/energy/band_travel_cooldown_until/badge_slot_1/2/3), items (+food stats/base_value/is_food), player_items (+is_identified/durability/affixes/food_state/spoilage_timer/storage_type), player_equipment (+weapon_main_id/weapon_off_id) |
| schema_tower_v2.sql | tower_bands, tower_floors, tower_camps, camp_connections, player_camp_state, battle_logs, bestiary_monsters, player_monsters, server_boss_kills (+difficulty), boss_clear_records, band_ascension_log, divinity_exp_log, auto_hunt_sessions, weather_pool |
| schema_skilltree_v2.sql | seed data 181 nodes (UUID ตายตัว) ครบทุก Band tier 1-5 |
| schema_character_v1.sql | accounts, players (+difficulty/char_type/death_locked/is_guest/guest_device_id), active_characters view |
| schema_combat_v1.sql | combat_sessions (+party_id/is_party_combat/loot_mode/action_window_sec), combat_action_log, player_status_effects, party_combat_members (+join_order/is_downed/loot_received), party_loot_rolls, boss_templates, boss_phases, boss_drop_table, enemy_templates (+durability_damage_mult), enemy_patterns |
| schema_upgrade_v1.sql | upgrade_attempts |
| schema_marketplace_v1.sql | marketplace_listings (Eternal-only) |
| schema_crafting_v1.sql | crafting_recipes, crafting_recipe_inputs, player_proficiency (+skill_type), camp_buildings (+trap/tower columns), farm_plots, tamed_animals, treasure_spots, merchant_catalog (+npc_role/sell_category), npc_services, achievements, player_achievements, mystery_events, player_mystery_log |
| schema_social_v1.sql | friendships, friend_requests, player_notifications, player_blocks, active_friends view, room_codes, player_stash, quests, player_daily_stats, player_weekly_stats, leaderboard_history, player_reward_queue, guilds, guild_members, guild_stash_items, guild_stash_log, guild_quests |
| schema_world_v1.sql | world_time_config (+current_weather/weather_end_at/raid_mode), get_game_time(), weather_pool, game_news, player_news_read |
| schema_npc_v1.sql | npc_templates, camp_npcs, player_crimes, player_threat, player_reputation, jail_sentences, npc_damage_log, town_treasury, treasury_log |
| schema_ecosystem_v1.sql | floor_species, species_relations, ecosystem_log, run_ecosystem_tick() |

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
