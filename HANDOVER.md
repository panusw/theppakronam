# HANDOVER.md — เทพปกรณัม
> บันทึกประวัติการออกแบบ, บริบท, และสิ่งที่คุยมาแล้ว
> อัปเดตทุกครั้งที่มีการตัดสินใจสำคัญ

---

## สถานะล่าสุด

**วันที่อัปเดต:** มิถุนายน 2026
**Phase ปัจจุบัน:** Phase 1 เริ่มต้น — Godot 4.7 project พร้อมแล้ว
**สิ่งที่มีแล้ว:** Schema SQL + React prototype + **Godot project scaffold ครบ**
**Godot version:** 4.7 (project.godot อัปเดตโดย Godot editor เมื่อเปิดครั้งแรก)
**สิ่งที่ต้องทำต่อ:** วาง Sunnyside sprites + เชื่อม Supabase + implement core systems

---

## ประวัติการออกแบบ

### v1 → v2 (ก่อนหน้า)
- v1: มีตัวละครสุ่มจาก gacha (ยกเลิก)
- v2: เปลี่ยนเป็นสุ่ม item เท่านั้น — ผู้เล่นมีตัวเดียวตลอด คือ "ผู้ท้าชิงนิรนาม"
- เหตุผล: ลด complexity, focus ที่ progression ผ่าน skill tree แทน

### React → Godot 4 (มิถุนายน 2026)
- เหตุผล: React prototype พิสูจน์ game logic แล้ว แต่ไม่เหมาะ implement จริง
  - ATB combat ใน browser ต้องสร้าง game loop เอง
  - Sprite / animation / audio จัดการยาก
  - Godot มี scene system, input, renderer ในตัว
- ผู้พัฒนา: ยังไม่มีประสบการณ์ Godot — เริ่มจาก 0
- Target: PC (Windows/Mac) ก่อน — ไม่ export mobile ใน Phase 1

---

## สิ่งที่ตกลงในแต่ละ session

### Session: ออกแบบ core concept
- ชื่อเกม: **เทพปกรณัม** (Theppakronam / Tower of Convergence)
- แนวคิดหลัก: ผู้ท้าชิงนิรนาม + หอเทวภพอนันต์ + กลายเป็นเทพผ่าน skill tree
- Gacha: สุ่ม item (skill_node / weapon / armor / rune / ore) ไม่ใช่ตัวละคร
- ไม่มี element system — ใช้ stat type โดยตรง (fire_dmg ฯลฯ)
- Monster ใช้ capture เป็น bestiary collector ไม่ได้ใช้ต่อสู้

### Session: ออกแบบ Schema v2
- schema_core_v2.sql: players, items, gacha, skill tree, stat cache, energy
- schema_tower_v2.sql: tower structure, combat log, bestiary
- schema_skilltree_v2.sql: seed data ครบ tier 1-5 รวม ascension nodes
- Skill tree node UUIDs เป็น pattern ตายตัว (`00000000-0000-0000-000X-00000000000Y`)
- Center node UUID: `00000000-0000-0000-0000-000000000001`

### Session: วางแผน Phase 1-4
- Phase 1 (ทำอยู่): Foundation — core loop เล่นได้จริง, Band 1 floors 1-9
- Phase 2: Content + Economy — Band 2-3, weapon refine, event banner
- Phase 3: Social + Meta — Guild (feature flag), leaderboard, Band 4-5
- Phase 4: Endgame — ทวยเทพบุตร, floor 50+, prestige

### Session: ตรวจสอบระบบครบ + อัปเดต CLAUDE.md และ HANDOVER.md (มิถุนายน 2026)
- พบว่า §5 (Gacha) และ §8 (Upgrade & Refine) header หายไป — แก้ไขแล้ว ตอนนี้ครบ 66 sections
- Cross-reference check 20 ระบบสำคัญ — ผ่านทั้งหมด content ครบถูกต้อง
- CLAUDE.md อัปเดต: schema table ครบทุก table ใหม่ (§57-§66), สถานะ §1-§66 ครบ
- HANDOVER.md: Gap Analysis ทุก item เปลี่ยนเป็น ✅

### Session: In-Game News & Patch Note System §66 (มิถุนายน 2026)
- 4 entry points: Main Menu badge, Login popup, HUD bell icon, Settings About
- 5 news types: patch/event/maintenance/tip/announcement
- Patch note format: Markdown, แบ่ง sections (ปรับสมดุล/แก้บั๊ก/ปรับ UI)
- Game Tips pool 8 หมวด: Combat/Economy/Survival/Crafting/Progression/Social/Defense/Auto-Hunt
- Auto-popup patch note เมื่อ version เปลี่ยน (compare last_seen_version vs current)
- Schema: `game_news` (expires_at, target_version, is_pinned), `player_news_read`, `get_unread_news_count()` function
- NewsManager.gd autoload, fetch + mark_read + badge update
- อัปเดต Gap Analysis: In-game news เปลี่ยนจาก ❌ → ✅

**✅ Gap Analysis ครบ 100% — ทุกรายการออกแบบเสร็จแล้ว**

### Session: Daily/Weekly Leaderboard & Ladder Reset §65 (มิถุนายน 2026)
- 3 ระบบแยก: Hall of Fame (ถาวร) / Daily Leaderboard (รีเซ็ตทุกวัน) / Weekly Ladder (รีเซ็ตวันจันทร์)
- **Daily** 5 หมวด: Most Kills, Gold Earned, Master Chef, Best Fisher, Crafter — Top 3 ได้ Gold/Gem
- **Weekly Ladder**: score formula (kills×1 + boss×10 + craft×2 + explore×5 + divinity×3) — Top 20 ได้ Gem 20-200
  - #1 ได้ badge "แชมป์สัปดาห์" ชั่วคราว 7 วัน
- **Season (Monthly)**: ผลรวม Weekly Score — Top 3 ได้ Legendary Guarantee Stone + badge ถาวร
- Reset ด้วย pg_cron: Daily 00:00, Weekly 00:05 วันจันทร์
- `player_reward_queue` table — rewards จ่ายตอน login ครั้งถัดไป
- Schema: `player_daily_stats`, `player_weekly_stats`, `leaderboard_history`, `player_reward_queue`
- อัปเดต Gap Analysis: Daily/weekly leaderboard เปลี่ยนจาก ⚠️ → ✅

### Session: Guild System §64 Phase 3 (มิถุนายน 2026)
- **Feature flag ปิด** จนถึง Phase 3 แต่ schema foundation วางล่วงหน้าแล้ว
- Guild สูงสุด 30 คน, roles: Master/Officer/Member/Recruit
- Guild Stash: 4 tab × 20 slots, Gold Vault, log ทุก action
- Guild Quest รายสัปดาห์ 5 ประเภท → Guild EXP → Guild Level 1-20
- Level milestone: Level 5 ATK buff, Level 10 Stash+, Level 15 Drop rate+, Level 20 Guild Hall
- Guild Hall: NPC พิเศษ, Trophy Room, bonus crafting station
- Guild War: PvE race mode ก่อน (PvP ยังไม่ออกแบบ), war score, 10% gold deposit
- Schema: `guilds`, `guild_members`, `guild_stash_items`, `guild_stash_log`, `guild_quests` (ทั้งหมด feature-flagged)
- อัปเดต Gap Analysis: Guild system เปลี่ยนจาก ⚠️ บางส่วน → ✅ ออกแบบครบ (Phase 3)

### Session: Mystery Camp Event Table §63 (มิถุนายน 2026)
- 5 categories: Treasure(25%)/Encounter(30%)/Shrine(20%)/Curse(15%)/Merchant Special(10%)
- **Treasure** 7 events: กล่องสมบัติ, ถุงทอง, ซากนักเดินทาง, สายน้ำศักดิ์สิทธิ์, ต้นไม้มหัศจรรย์, แร่ซ่อน, ตราสัญลักษณ์โบราณ
- **Encounter** 7 events: กองโจรมิติ, สัตว์บาดเจ็บ(choice), นักเดินทางหลงทาง, กับดักลับ, การเผชิญหน้ากลางคืน, ราชาหมอก, นักล่าผี
- **Shrine/Blessing** 8 events: buff stat, Divinity EXP, HP เต็ม, recipe unlock, Gem drop
- **Curse** 7 events: Mimic, คำสาป, หลุมกับดัก, เขตสาป, วิญญาณขโมย, ก๊าซพิษ, แสงลวงตา
- **Merchant Special** 5 events: พ่อค้าพเนจร/ลึกลับ/แลกเปลี่ยน/ความลับ/Eternal Path
- **Band-specific events** ครบทุก Band (Thai/Greek/Norse/Egyptian/Japanese/Primordial) 3 events/Band
- Weather interaction: Fog → ราชาหมอก event weight ×2, กลางคืน → การเผชิญหน้าในความมืด
- MysteryEventManager.gd, data-driven จาก `mystery_events` table, log ใน `player_mystery_log`
- อัปเดต Gap Analysis: Mystery camp เปลี่ยนจาก ⚠️ → ✅

### Session: Weather System §62 (มิถุนายน 2026)
- Weather layer ซ้อนบน Season — สุ่มทุก 2-6 ชั่วโมงเกม, transition 30 วินาที real time
- 10 weather types: Clear/Cloudy/Light Rain/Heavy Rain/Fog/Thunderstorm/Sandstorm/Blizzard/Heat Wave/Aurora
- Effect ครบ: visibility, movement, combat DMG, gathering yield, farming grow time
- Weather pool per Band+Season ออกแบบครบทุก Band (Band 6 พิเศษ: Void Storm/Primordial Heat/Eternal Fog/Cosmic Aurora)
- Special mechanics: ⛈️ Lightning Strike (AOE unblockable ทุก 60-120 วิ), 🌫️ Fog Ambush, ❄️ Hypothermia stack, 🔥 Dehydration, 🌪️ Sandstorm eye irritation
- HUD: weather icon + countdown + expand panel แสดง effects + prediction ถัดไป
- WeatherManager.gd autoload, data-driven จาก `weather_pool` table
- Schema: weather columns ใน `world_time_config`, `weather_pool` seed data Band 1 ครบ
- อัปเดต Gap Analysis: Weather system เปลี่ยนจาก ❌ → ✅

### Session: Analytics & Telemetry §61 (มิถุนายน 2026)
- 5 event categories: Combat / Progression / Economy / Survival / Session
- ~25 event types ครอบคลุม: combat_ended, boss_killed, gacha_pull, band_ascension, food_spoiled, raid_ended ฯลฯ
- Implementation: AnalyticsManager.gd singleton, batch 20 events หรือ flush ทุก 60 วิ, fire-and-forget
- Schema: `analytics_events` (JSONB properties) แยก schema จาก game data, partition by month
- Key metrics 10 ตัวสำหรับ balance tuning (win rate, clear time, gold delta, drop rate ฯลฯ)
- Privacy: ไม่เก็บ PII, retention 90 วัน, purge on request
- อัปเดต Gap Analysis: Analytics/telemetry เปลี่ยนจาก ❌ → ✅

### Session: Achievement System §60 (มิถุนายน 2026)
- **63 achievements** แบ่ง 7 หมวด: Combat(12)/Progression(10)/Exploration(10)/Survival&Crafting(10)/Social(6)/Eternal Path(4)/Secret(5)
- Badge Display: 3 slot ข้าง portrait เลือกได้อิสระ, Eternal/Server First badge มี glow effect
- Reward: Gem 50-1,000 ตาม achievement tier
- Secret achievement: ไม่แสดงจนกว่าจะ unlock (เช่น ทอยเต๋า 1 Critical Fail 10 ครั้ง, กิน Rotten food ไม่ nausea)
- Schema: `achievements`, `player_achievements`, badge_slot_1/2/3 ใน players
- อัปเดต Gap Analysis: Achievement system เปลี่ยนจาก ⚠️ → ✅

### Session: Building Defense — Trap & Watchtower §59 (มิถุนายน 2026)
- **Trap Types** 5 ชนิด: Spike/Snare/Iron Spike/Flame/Lightning Rod — แบ่ง one-time และ reset-able
- **Trap Damage Formula**: base × skill_mult(construction 0.5-1.0) × tier_mult(1.0-2.0) - def×0.3 × type_resist
- monster type resistance: slime/small ×0.5, normal ×1.0, armored ×0.7, elite/boss ×0.5
- Trap durability: 3-10 activations ตาม tier, repair ด้วย material
- **Watchtower** 4 tier (Wood/Stone/Iron/Mythril) — ATK 25-160, Range 5-12 tiles, 1-3 targets
- **Watchtower Damage Formula**: base × skill_mult × range_factor(0.6-1.0) - def×0.5, elite ×0.7, boss ×0.4
- Target priority: monster ที่ใกล้ Hub/Campfire มากที่สุด (protect core ก่อน)
- Synergy: Snare (slow) + Watchtower = โดนยิงเพิ่ม, Flame + Spike = DOT stack
- **Construction Skill milestone**: unlock tier 1→25→50→75→100 + Mastery bonus (damage ×1.5, rate +1, repair -50%)
- Placement rules: วาง tile ว่าง, monster มองไม่เห็น trap, player เจ้าของไม่ trigger
- Schema: `camp_buildings` เพิ่ม trap/tower columns (base_damage/base_atk/range/effect/builder_player_id)
- อัปเดต Gap Analysis: Building trap/watchtower เปลี่ยนจาก ⚠️ → ✅

### Session: Food Quality & Spoilage System §58 (มิถุนายน 2026)
- **Food States**: Fresh → Stale → Spoiled → Rotten พร้อม icon/สีแยกชัด
- **Spoilage Timer**: real-time ทุกประเภท (Raw Meat 30 นาที → 1 ชม. → 2 ชม. / Bread 8 ชม. → 16 ชม. → 48 ชม.)
- Offline spoilage: ดำเนินต่อ คำนวณ elapsed เมื่อ login กลับ
- **Storage slows spoilage**: inventory ×1.0, Wood Chest ×0.5, Ice Box ×0.1, Magic Chest ×0
- Ice Box: craftable Carpentry 40, Ice Crystal ×4, 20 slots
- **Food Quality Tier**: cooking skill × ingredient rarity → hunger/buff magnitude คำนวณ real-time
- Quality label: Poor/Normal/Good/Excellent/Master (⭐)
- **Eating Raw**: ได้ Hunger น้อย, raw meat/fish มี nausea chance (DEF/SPD penalty)
- **Compost System**: Spoiled/Rotten → Compost Bin → Basic Fertilizer (10 points/fertilizer)
- HUD: icon แสดง state (🟡 stale 🔴 spoiled ⬛ rotten), notification เมื่อใกล้เน่า, tooltip แสดง timer
- Schema: `items` เพิ่ม food columns (is_food/hunger/buff/nausea), `player_items` เพิ่ม food_state/spoilage_timer/quality_tier/storage_type
- อัปเดต Gap Analysis: Food & cooking quality เปลี่ยนจาก ⚠️ → ✅

### Session: Auto-Hunt System §57 (มิถุนายน 2026)
- AFK progress มีขอบเขต — efficiency 65-70% ของ manual play
- เงื่อนไขเริ่ม: World Energy ≥ 20, HP ≥ 50%, Battle Energy เต็ม, Hunger/Thirst ≥ 30, inventory ว่าง ≥ 10 slots
- Session duration: 30 นาที / 1 ชั่วโมง / 2 ชั่วโมง + World Energy cost 15/25/40
- Session cap: 3 session/วัน + cooldown 15-60 นาทีหลัง session
- Safety Recall: HP < 20%, Energy = 0, Inventory < 3 slots, Hunger/Thirst < 10
- Auto-use item: HP Potion ถ้า HP < 40% (toggle ได้)
- Reward formula: drop rate ×0.65, combat EXP ×0.70, ไม่ได้ Gold/Divinity EXP/Bestiary
- ไม่โจมตี boss/mini-boss node, ไม่มี offline auto-hunt
- Field Log: บันทึกทุก event ระหว่าง session
- Session Summary UI: kills/items/เวลา/เหตุที่หยุด
- ไม่มีใน Eternal Path
- Schema: `auto_hunt_sessions`, `get_auto_hunt_count_today()` function
- GDScript: AutoHuntManager.gd, AutoHuntPanel.gd, FieldLog.gd
- อัปเดต Gap Analysis: Auto-hunt เปลี่ยนจาก ⚠️ → ✅

### Session: Recipe List §56 (มิถุนายน 2026)
- **125 recipes** รวม Tailoring (เพิ่มในรอบนี้)
- Cooking 20: tier 1-4 + master, Band-specific tier 4 (Thai/Greek/Norse/Egyptian/Japanese)
- Alchemy 20: tier 1-4 + master (อมฤตเทพ), รวม Scroll of Revelation, Guarantee Stone, Magic Fertilizer
- Smithing 27: stone→iron→silver/gold→mythril→legendary (divine blade/armor)
- Carpentry 21: tool, building (Forge/Alchemy Table/Barn/Stable), furniture, trap
- Masonry 11: stone brick, iron/mythril wall, glass, tower
- Farming 6: crop + seasonal filter (Lotus วัสสาน, Sacred Grain Akhet)
- **Tailoring 20** (ใหม่): leather/cloth armor, bag (+5/+10/+15/+25 slots), Taming Rope, legendary Celestial Robe
- unlock tier: auto/skill25/50/75/100, Band-specific ต้องเคยผ่าน Band นั้น
- SQL seed data format สำหรับ schema_crafting_v1.sql
- อัปเดต Gap Analysis: Recipe list เปลี่ยนจาก ⚠️ → ✅

### Session: NPC Shop & Vendor System §55 (มิถุนายน 2026)
- NPC แต่ละ role มี shop แยกกัน: Merchant / Blacksmith / Nurse-Alchemist / Farmer
- **Sell to NPC**: sell_price = base_value × trading_skill_mult × durability_mult (70-100%)
  - Unidentified item: ×0.7 เสมอ, Soulbound/Eternal: ปฏิเสธซื้อ
- **Band 1 catalog ครบ** (base + rotating): Merchant, Blacksmith, Nurse พร้อม rotating ตาม 3 ฤดูไทย
- **Band 2** catalog ตัวอย่าง + Greek seasonal rotating
- **Band 3-6**: scaling formula (price ×1.0→×4.0, tier ขึ้นตาม Band)
- Base value table ตาม rarity (20-100K gold)
- Shop UI: [ซื้อ][ขาย][Rotating], batch sell ทุก common item
- Restock mechanic: server-side ตรวจ game day + season filter
- Player purchase limit per restock cycle ป้องกัน stockpile
- Schema: merchant_catalog เพิ่ม npc_role/sell_category/visible, items เพิ่ม base_value, `npc_services` table ใหม่
- อัปเดต Gap Analysis: NPC shop เปลี่ยนจาก ⚠️ → ✅

### Session: Party ATB Sync §53 — ออกแบบสมบูรณ์ (มิถุนายน 2026)

§53 ครอบคลุมครบทุกประเด็น:
- Combat Session State Machine: WAITING → INITIALIZING → ACTIVE → RESOLVING → ENDED
- Shared Timeline 20 ticks/วิ, action queue เรียง SPD
- Action Window 8-15 วิ ตาม difficulty, auto-attack logic เมื่อหมดเวลา
- Simultaneous resolution: parallel window, SPD order, dead-target skip
- Loot 4 modes: Free-for-all / Round Robin / Need-Greed / Leader + roll implementation
- Death & Revive: downed 30 วิ, Revive skill (+revive_immunity 2 turns), Spectate mode
- Combat End Conditions ครบ: WIN / LOSE / ALL_FLED / KO-บางคน + reward table
- Disconnect: auto-attack 30 วิ → auto-fled, P2P vote migrate host ≥ 50%
- Late Join: ไม่อนุญาต
- Network RPC ครบ: submit_action (reliable), broadcast_result (reliable), sync_atb (unreliable/5ticks), loot_choice
- Friendly Fire: ไม่มี — targeting ตาม target_type enum
- Schema: party_combat_members (+join_order/is_downed/loot_received), party_loot_rolls

### Session: Skill Node Content Pool §54 + Party ATB Sync §53 (มิถุนายน 2026)

**§53 Party ATB Sync:**
- Shared Timeline + Individual Action Window (8-15 วินาที ตาม difficulty)
- Parallel action requests, resolve ตาม SPD order
- Flee อิสระต่อคน, disconnect handling (30 วิ → auto-fled)
- Network RPC: reliable action, unreliable ATB sync ทุก 5 ticks
- Schema: `party_combat_members`, action_window_sec

**§54 Skill Node Content Pool — 181 nodes ครบทุก Band:**
- **Node Structure**: stat_bonus + active_skill + passive_effect (3 ส่วนครบ)
- **Tier 1** (58 nodes): stat bonus ล้วน, Universal 10 + Band แต่ละ Band 6-10
- **Tier 2** (37 nodes): stat + passive effect เบาๆ (conditional, stacking)
- **Tier 3** (32 nodes): stat + passive ชัดเจน + บาง node มี active skill (uncommon/rare)
- **Tier 4** (30 nodes): passive ทรงพลัง + active skill epic ทุก node
- **Tier 5** (24 nodes): Ascension — Legendary 3+/Band + Mythic 1/Band
  - Band 1: อัคคีเทพบุตร / นาคเทพบุตร / วัชรเทพบุตร (legendary) + ทวยเทพบุตร (mythic)
  - Band 2-6: 3 legendary + 1 mythic ต่อ Band ออกแบบแล้ว
- SQL seed data format สำหรับ schema_skilltree_v2.sql
- อัปเดต Gap Analysis: Skill node pool เปลี่ยนจาก ⚠️ → ✅

### Session: Durability Decay Rules (มิถุนายน 2026)
- **Weapon**: เสื่อมเฉพาะ hit โดน — miss/พลาด → ±0
- **Armor/Accessory**: เสื่อมเฉพาะรับ damage จริง — damage = 0 (DEF block) / ไม่ถูกตี → ±0
- **Enemy type modifier** (`durability_damage_mult` ใน enemy_templates):
  - Slime/ooze ×0.0, Normal ×1.0, Armored/Stone/Boss ×1.5, Fire/Acid ×2.0, Mythic ×3.0
- มือรองเสื่อมช้ากว่ามือหลัก (×0.5)
- อัปเดต Repair Loop ใน §11 ให้สะท้อนกฎใหม่
- เพิ่ม column `durability_damage_mult` ใน `enemy_templates` schema (§52)

### Session: Enemy AI System §52 (มิถุนายน 2026)
- **Field AI**: AggroType 4 ประเภท (Passive/Aggressive/Territorial/Flee), PatrolMode 4 แบบ, detection radius modifier (กลางคืน/stealth/weather/band)
- **Combat AI Archetypes** 5 แบบ: Berserker / Tactician / Support / Trickster / Tank — แต่ละตัวมี priority logic และ target preference ต่างกัน
- **Pattern Selection**: weighted random ใน top 3 candidates — ป้องกัน predictable AI
- **Elemental Resistance**: elemental_profile per enemy, AI ปรับ behavior ตาม player element ที่ใช้บ่อย
- **Multi-enemy Coordination**: EnemyGroup.gd — tank taunt รอบแรก, healer ถอยหลัง, focus fire เมื่อ player HP < 20%
- **Night Behavior**: detect +25%, aggro ง่ายขึ้น, ATK +10%, spawn +50%
- **Camp Type → AI Composition**: normal/elite/mini_boss/boss/hunting_zone มี enemy composition ต่างกัน
- Schema: `enemy_templates`, `enemy_patterns` พร้อม seed data ตัวอย่าง Band 1
- อัปเดต Gap Analysis: Enemy AI เปลี่ยนจาก ⚠️ → ✅

### Session: Boss & Mini-Boss Mechanics §51 (มิถุนายน 2026)
- ออกแบบ **Phase System** สมบูรณ์: BossEntity.gd + BossPhase data structure, immunity window, transition effects
- Stat scaling ตาม difficulty ครบ (HP/ATK mult, Enrage timer)
- **Mini-boss ≥ 2 phases**: Band 1 — นาคราช (water mechanic), ครุฑพัน (wind/arena)
- **Boss ≥ 3 phases** ทุก Band:
  - Band 1: มหายักษ์ทรนง — 3 phases (Stone/Berserk/Spirit), tree mechanic, spirit wall
  - Band 2: Titan of Olympus — 3 phases (Stone/Lightning/Ragnarok), pillar mechanic
  - Band 3: Fenrir Unchained — 3 phases, chain mechanic, blizzard visibility
  - Band 4: Ra the Corrupted — 3 phases, sand sink mechanic, Eclipse darkness
  - Band 5: Yamata no Orochi — 4 phases (1/3/6/8 heads), hydra regen mechanic
  - Band 6: The First Ascendant — 4 phases (mirror/divine/void/primordial), copy cat mechanic
- Score par_time ต่อ boss type, phase clear bonus multiplier
- Schema: `boss_templates`, `boss_phases`, `boss_drop_table`
- อัปเดต Gap Analysis: Boss Mechanics เปลี่ยนจาก ❌ → ✅

### Session: Friend List System + Gold Economy Balance (มิถุนายน 2026)

**§34 Friend List System (ใหม่):**
- Friend request flow: ค้นหา / คลิก portrait / คลิกชื่อใน chat / party panel
- Privacy setting: anyone / friends_of_friends / nobody
- Online status 5 ระดับ: Online / In Combat / AFK / Offline / Do Not Disturb + privacy location
- Friend Profile Panel: Divinity, floor สูงสุด, playtime, actions
- Friend limit: Guest 10 / Account 200
- Friend Activity Feed: milestone สำคัญของเพื่อนช่วง 24 ชม. (login bonus, boss kill, legendary drop)
- Notification System: bell icon บน HUD — friend request, online, party invite, whisper, achievement
- Block & Report: บล็อกแล้ว unfriend อัตโนมัติ, ไม่รู้ว่าถูกบล็อก
- Schema: `friendships`, `friend_requests`, `player_notifications`, `player_blocks`, `active_friends` view
- Section renumber: §34 (เดิม Chat) → §35 Chat, §35-49 → §36-50, §50 = Ecosystem

**§11 Gold Economy Balance (ออกแบบใหม่ครบ):**
- Income ทุกช่องทาง: ขาย item (~900 gold/session จริง), กล่องสมบัติ, ถุงเงิน, quest, marketplace
- Gold Sink 14 รายการ: repair (mandatory), skill node, warp, identify, NPC service, Bounty fine
- Inflation Control 5 กลไก: Repair Loop, Sell Price Cap (trading skill 70-100%), Band Travel, Time-Gated Restock, Server Tax (Town Treasury)
- Balance Simulation: Early/Mid/Late-game ตัวเลข income vs expense
- NPC Merchant Catalog: base (ซื้อเสมอ) + rotating (3 วันเกม, ตามฤดู, จำนวนจำกัด)
- Schema: `merchant_catalog`, `player_merchant_purchases`
- F2P Gem: ~1,300/month → 13 pulls → pity epic+ ≈ 3.8 เดือน

### Session: Upgrade/Refine Failure Penalty (มิถุนายน 2026)
- เพิ่ม **3 ระดับผลล้มเหลว** สำหรับ Upgrade (§8A) และ Refine (§8B):
  - Tier 1 (60%): resource หาย, level/refine ไม่เปลี่ยน
  - Tier 2 (30%): resource หาย, **level/refine ลด 1**
  - Tier 3 (10%): resource หาย, level/refine ลด 1, **damage พิเศษ** (burn rune / durability -20%)
- Guarantee Stone ยังคงข้ามทุก penalty tier — success 100%
- อัปเดต CLAUDE.md: design decisions เพิ่ม Upgrade fail tiers, Boss Gate 2/3, Tool×Skill principle

### Session: Review Comments — Combat, Equipment, Life Skills (มิถุนายน 2026)

**§3 Tower — Boss Gate:**
- เปลี่ยนเงื่อนไข Boss Gate จาก "1 ใน 3" → **"2 ใน 3"** เงื่อนไข

**§4 ATB Combat — ปรับหลายจุด:**
- Energy System: เพิ่มบทลงโทษ **Exhausted** (energy = 0) → ATK miss +15%, DEF รับ damage +10%, Skill/Flee/Capture greyed out
- Flee fail: เพิ่ม **drop ถุงเงิน rand(1-10)% gold** (multiplayer เท่านั้น)
- Flee success (dice ลบ): drop ถุงเงิน rand(1-5)% gold
- ตายใน field map: drop ถุงเงิน 20% gold
- Item drop จาก combat win: **1-2 → 1-9 items**
- Capture: กดได้ทันทีที่ปุ่มแสดง (enemy HP < 10%) ไม่ต้องกดก่อน kill
- Gold ไม่ drop จาก monster: เพิ่ม Treasure Chest มีทั้งแบบ drop และล่าสมบัติ (§42)

**§7 Equipment:**
- เพิ่ม **crossbow** (one-handed, CRIT_RATE) ในตารางอาวุธมือเดียว
- staff/wand: ระบุชัดว่า elemental DMG ใช้กับ **monster และ player ทั้งคู่**
- Random Affix: ระบุชัดว่า item ใน set เดียวกันได้ affix ต่างกัน (affix อิสระจาก set bonus)
- Blacksmith NPC แบ่งเป็น **4 ระดับ** (ฝึกหัด/ฝีมือ/เชี่ยวชาญ/เทพ) ทั้งซ่อมและ identify ราคาต่างกัน
- Repair Kit: มี rarity, **ต้องมี repair skill** → `actual = kit_pct × (skill/100)`

**§26 Combat Skill System (เปลี่ยนชื่อจาก Active Skill):**
- เพิ่ม **Rarity Scaling** ของ combat skill: common → mythic damage ×1.0-6.0
- Combat Proficiency แยกย่อยตาม weapon class

**§27 Life Skill System (เปลี่ยนชื่อจาก Proficiency):**
- แยก 5 กลุ่ม: Production / Gathering / Agriculture / Construction / Trade & Social
- เพิ่ม skill ใหม่: `repair`, `upgrade`, `tailoring`, `construction`, `trading`, `naturalist`
- หลักการ **NPC ↔ Player**: ทุก skill NPC ทำได้ ผู้เล่นทำได้เช่นกัน ถ้า skill + station ครบ
- **Rarity Scaling ทุก Life Skill**: item/tool rarity สูง → EXP สูง + ผลดีกว่า แต่ต้องมี skill เพียงพอ

**Skill × Tool requirement เพิ่มครบทุก Life Skill:**
- Gathering tools (Axe/Pickaxe/Sickle): `yield = base × tool_bonus × (0.5 + skill/200)`
- Fishing Rod: `effective_power = rod_power × (0.3 + skill/143)`
- Scroll of Revelation: ต้องมี smithing ≥ 1, ceiling rarity ตาม level
- Guarantee Stone: การันตี success แต่ไม่ข้าม upgrade skill requirement
- Shovel/Dowsing Rod: `quality × (0.5 + scavenging/200)`, `clarity × (0.4 + scavenging/167)`
- Fertilizer: `effect × (0.4 + farming/167)`, Magic Fertilizer ต้องการ farming ≥ 25
- Taming Item: item_bonus (rarity ×1.0-5.0) × (animal_handling/100)

### Session: Band Ascension Sacrifice (ปรับปรุง) + Hall of Fame Redesign (มิถุนายน 2026)
- **Band Ascension Sacrifice — ปรับใหม่ให้ครอบคลุมขึ้นและลง:**
  - ข้ามได้ทั้งขึ้น (Band ต่ำ→สูง) และลง (Band สูง→ต่ำ) — ค่าเท่ากัน
  - **Cooldown** หลังข้ามทุกครั้ง: 1 ขั้น=30 นาที, 2 ขั้น=2 ชม., 3 ขั้น=8 ชม., 4 ขั้น=24 ชม., 5 ขั้น=72 ชม.
  - **Multi-step penalty**: Σ(base cost) × multiplier (×1.0 / ×1.5 / ×2.5 / ×4.0 / ×6.0)
  - ตัวอย่าง Band 1→6 (5 ขั้น): 1,800 × 6.0 = 10,800 EXP
  - EXP ไม่ติดลบ — ถ้าไม่พอ ระบบไม่อนุญาต
  - Supabase RPC `travel_band()` validate + execute + log + set cooldown
  - Schema: `band_travel_cooldown_until` ใน players, `band_ascension_log`
- **Hall of Fame — ออกแบบใหม่**:
  - แยกตาม difficulty (Normal/Hard/Ascendant/Eternal Path) อย่างสมบูรณ์
  - 3 category: First Kill / Best Clear Time / Highest Score
  - Score = base + time_bonus + hp_bonus + no_item_bonus + no_flee_bonus
  - Eternal Path เพิ่ม "floor สูงสุดก่อนตาย"
  - Schema: `server_boss_kills` (PK = boss+difficulty), `boss_clear_records`, `boss_leaderboard` view

### Session: Inspirations เพิ่ม Survival/Farming (มิถุนายน 2026)
- เพิ่ม Stardew Valley (farming cycle, fishing minigame, seasonal crop)
- เพิ่ม Terraria (resource gathering, building, material tiers, crafting station)
- เพิ่ม Valheim (survival needs, building placement, biome progression, boss unlock)
- เพิ่ม My Time at Portia/Sandrock (town hub NPC, crafting commission, town economy)
- เพิ่ม Romestead (camp building, animal husbandry, gathering)
- เพิ่ม Don't Starve (hunger/thirst, seasonal hazard, food quality)
- แก้ Path of Exile 2: เพิ่ม item identification เป็น inspiration

### Session: Dice Minigame, Base Stats, Combat, Equipment, Gacha, Divinity Fix (มิถุนายน 2026)

**Divinity — แก้ไขให้สอดคล้องทั้งเอกสาร:**
- Core Loop: เปลี่ยนจาก "ascension node → divinity +1" → "สะสม Divinity EXP, Ascension node ให้ +200 EXP"
- §6 Skill Tree: Tier 5 ← Divinity EXP +200 (ไม่ใช่ +1 โดยตรง), ระบุ unlock condition ชัด (tier 4 ≥ 3, tier 5 legend ≥ 4, mythic ≥ 8)
- §11 Progression Gating: Band unlock = server-wide boss first kill (ไม่ใช่ divinity gate)
- §13 GameState: เพิ่ม `divinity_exp`, `world_energy`, `battle_energy`
- CLAUDE.md: แก้ stat formula และ design decisions

**Base Stats — เพิ่ม Energy (Battle):**
- Energy (🔋) แยกจาก HP — base 10, regen per turn + idle
- §10 แยก World Energy (⚡ travel) และ Battle Energy (🔋 combat) ชัดเจน
- World Energy cost ลดลง: normal 4, elite 6, mini_boss 8, boss 10, resource/mystery 2

**§4 ATB Combat — ปรับใหม่ทั้งหมด:**
- Attack: miss chance เมื่อ SPD < enemy SPD (สูงสุด 40%)
- Skill: energy cost 3-10, มาจาก 3 แหล่ง (node/weapon innate/armor affix)
- Item (Potion): HOT (Heal Over Time) ค่อยๆ regen ต่อ turn ไม่ฟื้นทันที
- Flee: base 20% (จาก 50%), SPD bonus +1%/10 SPD, Escape Smoke +60%, ยังอยู่ field map, energy cost สำเร็จ 2 / ล้มเหลว 4
- Capture: แสดงเมื่อ HP < 10%, ต้องมี Capture Item (มี rarity), minigame บังคับ
- Gold: ไม่ drop จาก monster — กล่องสมบัติ/ถุงเงิน/ขาย NPC เท่านั้น
- combat_action_log เพิ่ม `energy_after`, `is_miss`, `dice_roll` columns

**§5 Gacha — Pity ที่ 50 การันตี epic+** (เปลี่ยนจาก legendary+)

**§7 Equipment — ออกแบบใหม่ทั้งหมด:**
- weapon_main + weapon_off แยก slot อิสระ, อาวุธสองมือครองทั้งคู่
- Cross-set dual-wield ได้ (drop เดี่ยวเสมอ ไม่มี drop เป็นคู่)
- Set bonus เมื่อ weapon/armor ครบ set (2/3/4 piece)
- Random Affix 1-3 ตัวต่อ item (buff และ/หรือ debuff) ตาม rarity
- Durability system: ลดจาก combat, stat penalty เมื่อเหลือ 50%/25%/0%
- ซ่อมที่ Blacksmith หรือ Repair Kit item, affix `Fragile` = ซ่อมไม่ได้

**§8 Upgrade & Refine — เพิ่ม Guarantee Stone:**
- 5 tier (Uncommon→Mythic): การันตีสำเร็จ 100%
- หินทวยเทพ (Mythic): bonus +1 level ฟรี, หาได้จาก Eternal Marketplace เท่านั้น

**Dice Minigame — เพิ่มผลลบ:**
- 6 ระดับ: Critical Fail(1) / Bad(2-5) / Below Avg(6-8) / Average(9-12) / Good-Great(13-18) / Excellent(19) / Critical(20)
- Flee modifier: -25% ถึง +40%, Critical Fail → enemy ตีก่อน roll
- Capture modifier: -30% ถึง +50% clamp(5%,95%), Critical Fail → trap ระเบิด enemy หนี, Critical → จับได้แถม item drop
- สุ่มแท้ 100% ไม่มี timing mechanic

### Session: Ecosystem System (มิถุนายน 2026)
- **§49 Ecosystem**: Population-based + Food Chain, per-floor scope
- 4 tier food chain: Flora → Prey → Predator → Apex
- Population tick ทุก 10 นาที real time (pg_cron → `run_ecosystem_tick()`)
- Player kill → `current_pop -= 1` ทันที, overhunt trigger "Ecosystem Disrupted" debuff
- Cascade effect: prey ลด → predator หิว → aggro +50%, prey เพิ่ม → flora ถูกกินมาก → respawn ช้า
- Migration: floor ที่ pop วิกฤต รับสัตว์จาก floor ข้างเคียง (ใช้เวลา 1 ชั่วโมง)
- Seasonal interaction: Spring birth_rate ×2, Winter prey ลด 20%, Akhet ปลา ×2
- "Thriving Ecosystem" buff (ทุก tier ≥ 80% base): gathering +15%, rare drop +10%
- Naturalist skill (proficiency ใหม่): ปลดล็อก UI ดู population ละเอียดขึ้น
- Conservation Quest: Messenger NPC สร้าง quest เมื่อ species วิกฤต
- Schema: schema_ecosystem_v1.sql (floor_species, species_relations, ecosystem_log, tick function)

### Session: NPC Stats, Guard & Bounty System (มิถุนายน 2026)
- **NPC Stats §48**: NPC ทุกตัวมี HP/ATK/DEF/SPD/Stamina ตาม role, scale ตาม Band
- **Safe Zone**: ทุก camp ที่มี NPC อาศัย (ไม่จำกัดเฉพาะ Hub)
- **Crime & Threat**: 5 ระดับ (Clean→Suspicious→Wanted→Criminal→Outlaw), decay -5/นาที
- **Guard AI**: เตือนก่อนที่ threat 50-99, โจมตีทันทีที่ 100+, หยุดเมื่อ player HP < 20% → จับแทน
- **Arrest**: 2 ประเภท — จำคุก (threat 50-149) หรือตีบาดเจ็บหนัก (ริบ gold 15%) Guard เลือกตาม context
- **Jail**: ติดคุก N นาที (threat/10, max 30), หนีได้ด้วย Lockpick mini-game
- **Bounty**: ประกาศเมื่อ threat ≥ 200 หรือหนีจากคุก — NPC ทุก camp hostile, player อื่นจับได้รับ Gold reward
- **ล้าง Bounty**: จ่ายค่าปรับ ×1.5 ที่ Guard Captain / ครบ 24h decay / ถูกจับ / ถูก player knock out
- **Hospital**: NPC ที่ HP หมดใน safe zone → พักฟื้น N นาที (ไม่ตายถาวร), service หยุดชั่วคราว
- **Reputation**: -100 ถึง +100 ต่อ Band กระทบราคาค้าขายและ NPC service
- Schema: schema_npc_v1.sql (6 tables)

### Session: Item Identification + Monster Raid + i18n (มิถุนายน 2026)
- **Item Identification §45**: Unidentified state สำหรับ monster drop + treasure chest
  - identify ด้วย Scroll of Revelation (craft: Herb ×3 + Magic Flower ×1 + 100g) หรือ Blacksmith NPC (50g/item)
  - Gacha / craft / NPC shop / quest reward → Identified ทันที
  - is_identified column ใน player_items, RLS ซ่อน item_id จาก client ถ้ายังไม่ identify
- **Monster Raid §46**: Opt-in, ปิด default
  - เปิดแล้ว: ทุก building ใน camp โดนโจมตีทุก N วันเกม กลางคืน
  - Hub หลัก + Camp spawn มี NPC Guardian → protected zone
  - 3 wave structure, trap/watchtower ป้องกัน auto, ของใน chest ที่ destroyed → drop บนพื้น
  - Host config: raid_mode, raid_interval_days, raid_difficulty (normal/hard/siege)
- **i18n §47**: ภาษาไทย primary, i18n key ทุก string ห้าม hard-code
  - Phase 1: en.po ใช้ placeholder ภาษาไทย → Phase 2 แปลครบ
  - ~680 strings Phase 1 (UI/item/skill/NPC/quest)
  - Font: Sarabun (Thai+Latin), Thai pixel font ต้องหาเพิ่ม
  - Format string สำหรับ dynamic text (damage/ชื่อ)

### Session: Time System & Seasons (มิถุนายน 2026)
- **Day/Night Cycle §44**: 1 วันเกม = 1 ชั่วโมงจริง (default), กลางวัน 40 นาที กลางคืน 20 นาที
  - Host ปรับได้: day length 20-240 นาที, day ratio 40-80%, season length 3-30 วัน
  - Offline: เวลาเดินต่อเนื่อง ตรวจ timestamp ตอน login
  - Godot: `TimeManager.gd` autoload, CanvasLayer overlay สีน้ำเงินเข้ม
  - ความมืด: ต้องมีแสง (Torch/Campfire) หรือ visibility radius ลด 60%
- **Season System**: ฤดูตาม Pantheon แต่ละ Band
  - Band 1 Thai: 3 ฤดู (คิมหันต์/วัสสาน/เหมันต์)
  - Band 2 Greek: 4 ฤดู (Earos/Theros/Phthinoporon/Cheimon)
  - Band 3 Norse: 4 ฤดู (Vor/Sumar/Haust/Vetr) — Sumar กลางคืนสั้น, Vetr หิมะหนัก
  - Band 4 Egyptian: 2 ฤดู (Akhet น้ำท่วม/Shemu แล้ง)
  - Band 5 Japanese: 4 ฤดู (Haru/Natsu/Aki/Fuyu)
  - Band 6 Primordial: ไม่มีฤดู — กลางคืนตลอด
- **Season Effects**: กระทบ farming crop type, hunting animal spawn, fishing bite rate, gathering herb
- **Seasonal Events**: เทศกาลประจำแต่ละ Band (สงกรานต์/Dionysus/Yule/Nile Flood/Hanami)
- **Season-Exclusive content**: crop พิเศษ, สัตว์พิเศษ เฉพาะฤดู
- Schema: `schema_world_v1.sql` — `world_time_config` + `get_game_time()` function

### Session: Hunting/Farming/Fishing/Animal/Treasure + Lore (มิถุนายน 2026)
- **Hunting §38**: สัตว์ 2 ประเภท (field map passive + hunting zone rare), stealth system, tracking footprint, taming mechanic
- **Farming §39**: Real-time grow cycle, 5 crop types (2h-48h), water/fertilizer, offline grow ต่อเนื่อง, decay window
- **Fishing §40**: Stat-based + mini-game bonus (Wait phase + Reel phase), 5 rod types, legendary fish
- **Animal Husbandry §41**: Passive baseline + active care bonus, 6 animal types (ไก่/วัว/แกะ/สุนัข/แมว/ม้า), taming, happiness system
- **Treasure Hunting §42**: Random spot (Dowsing Rod/Scavenging detect) + Treasure Map item (drop จาก monster), 5 tiers, Shovel mechanic
- **World Lore §43**: 6 Band story arc ครบ (Thai/Greek/Norse/Egyptian/Japanese/Primordial), 5 NPC หลัก, lore discovery ผ่าน tablet/NPC/treasure/ascension
- Proficiency ใหม่เพิ่ม: `hunting`, `fishing`, `farming`, `animal_handling`, `scavenging`
- Schema เพิ่ม: `farm_plots`, `tamed_animals`, `treasure_spots` (ใน schema_crafting_v1.sql)

### Session: Survival/Crafting/Building + Gap Analysis Systems (มิถุนายน 2026)
- เพิ่ม Survival layer: กิน/ดื่ม/นอน เป็น **soft buff/debuff** ไม่ใช่ death condition
- Gathering §22: ต้นไม้/หิน/แร่/พืช/ของบนพื้น — tools, proficiency, respawn timer
- Crafting §23: Hand Craft + Station Craft (Campfire/Workbench/Forge ฯลฯ), recipe schema
- Survival Needs §24: Hunger/Thirst/Fatigue — 4 level effect, decay rate, food schema
- Building §25: Grid-based placement ใน field map, 4 tiers (Wood/Stone/Iron/Mythril), shared server
- Active Skill System §26: 4 hotbar slots, skill sources (node/scroll/weapon), status effect trigger
- Proficiency §27: 18 skills ใน 4 กลุ่ม (Combat/Gathering/Crafting/Survival), level 1-100, milestone rewards
- Status Effects §28: 12 effects (Burn/Freeze/Shocked/Stun/Bleed/Poison ฯลฯ), stack rules, resist/cleanse
- Death & Respawn §29: penalty แต่ละ mode, drop on death (Ascendant), checkpoint flow
- NPC/Hub/Warp §30: 5 NPC types, warp system (50 gold/ครั้ง), dialogue structure
- Inventory/Stash §31: 40 slots inventory, 60 slots stash, camp chest (shared), auto-pickup rules
- Quest §32: main/daily/weekly/achievement, 8 condition types, reward structure, UI
- Party §33: 4 คน max, loot mode 4 แบบ, EXP sharing, Eternal Path party risk
- Chat §34: Global/Party/Whisper, rate limit, block/report
- Anti-Cheat §35: server-authoritative list, rate limiting, ban schema
- Mini-map/HUD §36: layout ครบ, mini-map 120px, needs bars
- Tutorial §37: 9-step learn-by-doing flow, tooltip system
- Schema ใหม่: schema_crafting_v1.sql, schema_social_v1.sql
- Gap analysis เทียบ RO + PoE2: 40 systems วิเคราะห์ พบขาด 15 รายการ → ออกแบบครบแล้ว

### Session: Room Code Server + Voice Acting (มิถุนายน 2026)
- **Room Code Server → Supabase Edge Function** (ไม่ใช้ VPS แยก)
  - TypeScript Edge Function: POST /create, GET /{code}, DELETE /{code}
  - เก็บใน table `room_codes` อายุ 30 นาที, cleanup ด้วย pg_cron
  - Code อยู่ใน GAME_DESIGN.md §19 พร้อม deploy
- **Voice Acting Phase 1 → ไม่มี dialog**
  - Voice bus ควบคุม combat grunts เท่านั้น
  - เสียงพากย์จริงเพิ่ม Phase 3+ เมื่อมีนักพากย์

### Session: Offline/Online, Difficulty, Multiplayer, Settings (มิถุนายน 2026)
- **Difficulty modes**: Normal / Hard / Ascendant / **Eternal Path** (hardcore one-life)
  - Eternal Path: no energy, drop ×2, ตายแล้วล็อก character (death_locked)
  - Difficulty ลดไม่ได้ — เพิ่มได้ทางเดียว, Eternal Path เปลี่ยนไม่ได้เลย
- **Offline/Online แยก slot**: Offline (local file, ไม่ต้อง login) vs Online (Supabase, ต้อง login)
  - Offline 3 slots ต่อเครื่อง + Online 3 slots ต่อ account = 6 slots รวม
  - ห้าม convert offline → online (ป้องกัน dupe)
- **Multiplayer**:
  - Friend Session: ENet P2P + Room Code 6 ตัว (ผ่าน lightweight room server)
  - Server List: Official + Community dedicated server (Godot headless build)
  - Host = authority, client ส่ง intent
- **Eternal Marketplace**:
  - ขายได้เฉพาะ legendary+ ที่ drop ใน Eternal Path session (is_eternal_drop flag)
  - ซื้อขายเฉพาะ Eternal player — normal อ่านราคาได้ (FOMO mechanic)
  - ค่า fee 5%, ใช้ Gold เป็น currency
- **Settings Menu** ออกแบบครบ:
  - Main Menu: เล่นคนเดียว (เริ่มใหม่/เล่นต่อ) + Friend Session + Server List + ตั้งค่า
  - Graphics: resolution, window mode, pixel zoom (1-4×), pixel snap, FPS cap, VSync
  - Language: text locale + voice locale แยกกัน (ไทย/EN Phase 1)
  - Controls: remap keyboard+mouse และ controller แยกกัน, InputMap
  - Audio: Master / BGM / SFX / Voice แยก bus (Godot AudioServer)
  - บันทึกใน `user://settings.cfg` ผ่าน ConfigFile
- Schema ใหม่: schema_marketplace_v1.sql (marketplace_listings)
- schema_character_v1.sql เพิ่ม columns: difficulty, char_type (offline/online), death_locked

### Session: Character Creator + Sunnyside Assets (มิถุนายน 2026)
- เลือกใช้ **Sunnyside World** by danieldiggle เป็น asset หลัก
  - License: commercial OK, ห้าม resell/AI training, credit ไม่บังคับ
- ออกแบบ Character Creator ครบ:
  - 7 hairstyles จาก Sunnyside + 8 hair colors + 5 skin tones + 6 outfit colors
  - Palette swap shader ใน Godot (character_palette.gdshader)
  - 3 sprite layers: Body / Outfit / Hair (AnimatedSprite2D แยก material)
- 1 account = 3 character slots, save file แยกกัน
- ลบตัวละคร: soft delete + double confirm (modal + พิมพ์ชื่อ)
- เพิ่ม schema_character_v1.sql: accounts table + players columns เพิ่ม
- เพิ่ม scene: character_select.tscn + character_creator.tscn

### Session: Game Design Document สมบูรณ์ (มิถุนายน 2026)
- ตัดสินใจ Combat action set: Attack / Skill / Item / Flee (FF7 style)
- ตัดสินใจ Upgrade mechanic: Random chance + resource เป็นพื้นฐาน, minigame (Timing Ring) เป็น optional chance booster
- ตัดสินใจ Auth: Username + Password, cloud save only (Supabase Auth)
- สร้าง GAME_DESIGN.md ครอบคลุมทุกระบบ (15 sections)
- ออกแบบ schema_combat_v1.sql และ schema_upgrade_v1.sql (SQL draft ใน GAME_DESIGN.md)

### Session: Asset Reorganization + Shader Fix (มิถุนายน 2026)

**A. ลบขยะออกจาก project:**
- `__MACOSX/` + `._*` macOS dotfiles + `.DS_Store` → ลบ
- ZIP files (9 ไฟล์) → ลบ
- Stale `.import` files ที่ root → ลบ
- `.godot/imported/` → clear force Godot reimport ใหม่

**B. ย้าย assets ไปไว้ใน path ที่ถูกต้อง:**
- `Sunnyside_World_ASSET_PACK_V2.1/Characters/Human/` → `assets/sprites/character/human/{ACTION}/`
  - 20 action folders: ATTACK/AXE/CARRY/CASTING/CAUGHT/DEATH/DIG/DOING/HAMMERING/HURT/IDLE/JUMP/MINING/REELING/ROLL/RUN/SWIMMING/WAITING/WALKING/WATERING
  - Naming convention: `{hairstyle}_{action}_strip{N}.png`
  - `base_*` = body without hair, `bowlhair_*` / `curlyhair_*` / `longhair_*` / `mophair_*` / `shorthair_*` / `spikeyhair_*` = hair layer
- Goblin → `assets/sprites/enemies/goblin/` (13 PNGs)
- Skeleton → `assets/sprites/enemies/skeleton/` (13 PNGs)
- Elements/Animals/Crops/Plants/VFX → `assets/sprites/environment/*/`
- Tileset → `assets/tilesets/` (106 PNGs)
- UI → `assets/ui/sunnyside/` + loose icon PNGs → `assets/ui/icons/` (173 total)
- Environment: Decorations/Leaves/Minerals/Props/Rocks/Trees → `assets/sprites/environment/*/` (440 PNGs)
- Characters parts pack (chara_0..15.png) → `assets/sprites/character/parts/`
- Aseprite source files → `_source/` (`.gdignore` ป้องกัน Godot import)

**C. แก้ character_palette.gdshader:**
- ปัญหาเดิม: shader ใช้ red-channel เป็น palette index แต่ Sunnyside sprites เป็น RGB สีปกติ
- วิธีใหม่: **color-match approach** — เทียบ pixel กับ source_palette, แทนที่ด้วย target_palette
- ใช้ `source_palette` (1×N ImageTexture) + `target_palette` (1×N ImageTexture) + `palette_size` uniform
- สร้าง `CharacterColors.gd` autoload ใหม่:
  - เก็บ preset arrays: SKIN_SRC / HAIR_SRC / OUTFIT_SRC (approximate — ต้อง calibrate จาก Aseprite)
  - เก็บ target presets: 5 skin tones / 8 hair colors / 6 outfit colors
  - `build_texture(colors)` → ImageTexture สำหรับ shader uniform
  - `apply_to_material(mat, skin_key, hair_key, outfit_key, layer)` → wire shader ใน 1 call
- `assets/palettes/skin|hair|outfit/` ยังว่าง — ไม่ต้องสร้าง PNG แล้ว ใช้ runtime build แทน
- **TODO**: เปิด `base_idle_strip9.png` ใน Aseprite, eyedrop สีจริง → อัปเดต SKIN_SRC/HAIR_SRC/OUTFIT_SRC ใน CharacterColors.gd

### Session: Godot 4.7 Project Scaffold + Asset ยืนยัน (มิถุนายน 2026)

- **Godot project scaffold สร้างครบแล้ว** — เปิดใน Godot 4.7 แล้ว import resources สำเร็จ
  - project.godot: 1280×720, stretch=canvas_items, GL Compatibility renderer
  - Godot version จาก 4.3 → **4.7** (editor อัปเดตอัตโนมัติเมื่อเปิดครั้งแรก)
  - Autoloads ลงทะเบียนครบ 4 ตัว: GameState / SupabaseClient / TimeManager / AudioManager
  - Scenes stub ครบ 10 ไฟล์: main_menu / character_select / character_creator / world_map / combat / gacha_ui / skill_web / inventory / bestiary / hud
  - Scripts stub: autoload 4 ไฟล์ + character_palette.gdshader
  - Folder structure ตรง CLAUDE.md ครบทุก directory
- **ยืนยัน Sunnyside World เป็น asset หลัก** (เดิมตัดสินใจแล้ว — ยืนยันอีกครั้งตอน scaffold):
  - Source: https://danieldiggle.itch.io/sunnyside
  - License: commercial OK, ห้าม resell/AI training
  - Characters: body_base / outfit_base / hair_01-07 (7 hairstyles, animated)
  - Palette swap: character_palette.gdshader (3 layers: Body/Outfit/Hair, red-channel index → palette texture)
  - ต้องดาวน์โหลดและวางที่: `assets/sprites/character/` + `assets/palettes/skin|hair|outfit/`

### Session: Migration plan (มิถุนายน 2026)
- ตัดสินใจย้ายไป Godot 4 เพื่อ PC release
- Migration แบ่งเป็น 3 layer:
  1. **Data** (Supabase) — คงเดิม 100%
  2. **Logic** — แปลง JS → GDScript (gacha, stat calc, skill tree, ATB)
  3. **Presentation** — สร้างใหม่ใน Godot (scene, sprite, UI)
- สร้าง CLAUDE.md + HANDOVER.md สำหรับ context ระหว่าง session

---

## Prototype Reference (prototype_v2.jsx)

ไฟล์นี้คือ React prototype ที่สมบูรณ์ มี:

| ส่วน | Function/Component | สถานะ |
|---|---|---|
| Stat calculation | `calcStats(player)` | ✅ port ได้เลย |
| Gacha engine | `doGacha(count)` | ✅ port ได้เลย |
| Skill tree data | `SKILL_NODES`, `NODE_EDGES` | ✅ match กับ SQL seed |
| World map | `makeMap()`, `bfsPath()` | ✅ แนวคิดใช้ได้, render ใหม่ใน Godot |
| ATB combat | mock ใน component | ⚠️ ยังเป็น mock — ต้องออกแบบใหม่ |
| Item catalog | `ITEMS`, `ITEM_MAP` | ✅ reference สำหรับ item master data |
| Color constants | `C` object | ✅ ใช้เป็น palette reference |

---

## ข้อตกลงสำคัญที่ห้ามเปลี่ยน

1. **ไม่มีตัวละครสุ่ม** — gacha ได้แค่ item
2. **ไม่มี element weakness system** — ใช้ stat bonus โดยตรง
3. **Single player combat** ใน Phase 1 — ไม่มี party
4. **Stat คำนวณฝั่ง server** — ป้องกัน cheat
5. **Skill tree graph-based** — ปลดล็อกต้องมี adjacent node ที่ unlock แล้ว
6. **Divinity max = 10** — ต้องปลดล็อก ascension node ทั้งหมด
7. **Guild feature flag ปิด** ใน Phase 1-2

---

## สิ่งที่ต้องออกแบบต่อ (Backlog)

### ด่วน (ก่อนเขียน code Phase 1)
- [x] ~~schema_combat_v1.sql~~ — draft อยู่ใน GAME_DESIGN.md §4 แล้ว → **ต้องสร้างใน Supabase จริง**
- [x] ~~schema_upgrade_v1.sql~~ — draft อยู่ใน GAME_DESIGN.md §14 → **ต้องสร้างใน Supabase จริง**
- [x] ~~Supabase auth~~ — ตัดสินใจแล้ว: Username + Password
- [x] ~~**Godot project structure**~~ — ✅ เสร็จแล้ว Godot 4.7
- [ ] **สร้าง schema ใน Supabase จริง** — run SQL files ทั้งหมด

### Phase 1 Backlog
- [ ] Minigame mechanic สำหรับ skill node upgrade
- [ ] Monster capture mechanic — timing-based หรือ rng?
- [ ] Energy regen — Godot timer หรือ server-side timestamp?
- [ ] SkillWebRenderer.gd — วาด graph ด้วย `draw_line()` + `draw_circle()`

### Phase 2+ Backlog
- [ ] Weapon refine system — minigame + ore consumption
- [ ] Event banner (limited time) — schedule system
- [ ] Daily quest schema
- [ ] Band 2 content: greek pantheon, floor 10-19

---

## Godot 4 Learning Path (สำหรับมือใหม่)

### สัปดาห์ 1 — Concepts
- Scene tree คืออะไร (Node, Scene, instancing)
- Signal system (เหมือน event listener)
- GDScript syntax พื้นฐาน (คล้าย Python)
- Autoload / Singleton pattern

### สัปดาห์ 2 — Port Logic
- สร้าง `GachaEngine.gd` — port จาก `doGacha()`
- สร้าง `StatCalculator.gd` — port จาก `calcStats()`
- สร้าง `SkillTreeGraph.gd` — graph traversal
- Test ผ่าน GDScript console ก่อนมี UI

### สัปดาห์ 3-4 — First Scene
- Main Menu scene
- HTTPRequest → Supabase (login / load player)
- Gacha UI scene พื้นฐาน

---

## Supabase Setup

| | |
|---|---|
| Provider | Supabase |
| Region | (ยังไม่เลือก) |
| Auth method | (ยังไม่ตัดสินใจ — anonymous vs account) |
| RLS | ต้องวาง policy ก่อน launch |
| Godot connection | `HTTPRequest` node → REST API |

**Supabase URL pattern:**
```
https://<project>.supabase.co/rest/v1/<table>
Authorization: Bearer <anon_key>
apikey: <anon_key>
```

---

## ประเด็นที่เปิดค้างไว้

| ประเด็น | ตัวเลือก | สถานะ |
|---|---|---|
| Combat schema | ออกแบบแล้ว (GAME_DESIGN §4) | ✅ draft พร้อม — ต้อง run ใน Supabase |
| Minigame mechanic | Timing Ring (GAME_DESIGN §8C) | ✅ ตัดสินใจแล้ว |
| Auth strategy | Username + Password, cloud only | ✅ ตัดสินใจแล้ว |
| Save strategy | Offline local / Online cloud แยก slot | ✅ ตัดสินใจแล้ว |
| Difficulty | Normal/Hard/Ascendant/Eternal Path | ✅ ตัดสินใจแล้ว |
| Multiplayer | Friend Session P2P + Server List | ✅ ตัดสินใจแล้ว |
| Hardcore marketplace | Eternal-only, normal อ่านได้ | ✅ ตัดสินใจแล้ว |
| Settings menu | ออกแบบครบ (GAME_DESIGN §21) | ✅ พร้อม implement |
| Pixel art tool | Aseprite (palette textures) | ✅ เลือกแล้ว |
| Asset source | Sunnyside World by danieldiggle | ✅ ตัดสินใจแล้ว |
| Room Code Server | Supabase Edge Function (GAME_DESIGN §19) | ✅ ตัดสินใจแล้ว + code พร้อม |
| Voice acting | Phase 1 ไม่มี dialog — combat grunts เท่านั้น | ✅ ตัดสินใจแล้ว |
| Godot project scaffold | สร้าง folder + scene stubs | ✅ เสร็จแล้ว — Godot 4.7, 10 scenes, 4 autoloads |

---

## สถานะสุดท้าย — Design เสร็จสมบูรณ์ 100%

**GAME_DESIGN.md §1-§66 ครบทุกระบบ — Gap Analysis 100% ✅ ไม่มี ⚠️ หรือ ❌ เหลืออีก**

สิ่งที่ออกแบบครบแล้วในรอบล่าสุด:
- Divinity EXP system (หลายแหล่ง) + Floor unlock (server-wide boss first kill)
- Base Stats: HP 10, ATK 1, DEF 1, SPD 1, Energy 10 (แยก World/Battle)
- ATB Combat ครบ: miss chance, HOT potion, Flee 20% base, Capture < 10% HP
- Dice Minigame: 6 ระดับ มีผลลบถึง -30% และ Critical Fail special effect
- Equipment: dual-wield, set bonus, random affix, durability, repair
- Guarantee Stone 5 tier สำหรับ Upgrade/Refine
- Gacha pity ที่ 50 การันตี epic+ (ไม่ใช่ legendary+)

พร้อม implement ตามลำดับนี้:
1. **Godot project scaffold** — folder, autoload, scene stubs, shaders, settings
2. **Run SQL ทั้งหมดใน Supabase** — schema ครบ 9 ไฟล์ (core/character/combat/upgrade/marketplace/crafting/social/world/npc/ecosystem)
3. **Deploy Edge Functions** — Room Code server, game action validators
4. **Settings scene** — ทดสอบได้ก่อนโดยไม่ต้องมี backend
5. **Character Creator** — palette swap + Sunnyside sprites
6. **Game Hub + HUD** — layout หลัก, World Energy bar, Battle Energy bar
7. **World Map** — tower graph
8. **Combat scene** — ATB loop + Dice minigame

---

## Gap Analysis vs เกมต้นแบบ (อัปเดตล่าสุด มิถุนายน 2026)

วิเคราะห์ 63 ระบบเทียบกับ 10 เกมต้นแบบ: RO, PoE2, FF7, Gacha, Stardew Valley, Terraria, Valheim, My Time at Portia, Romestead, Don't Starve

### สรุป
| สถานะ | จำนวน |
|---|---|
| ออกแบบครบ | 46 |
| มีบางส่วน | 11 |
| ขาด/ไม่สมบูรณ์ | 6 |

### ตารางเปรียบเทียบ

| ระบบ / Feature | หมวด | Ref | สถานะ | Priority | สิ่งที่ขาด / หมายเหตุ |
|---|---|---|---|---|---|
| ATB Combat loop | Combat | FF7 | ✅ ครบ | — | — |
| Miss chance (SPD) | Combat | FF7 | ✅ ครบ | — | — |
| Energy system (Battle) | Combat | FF7 | ✅ ครบ | — | — |
| Exhausted penalty | Combat | FF7 | ✅ ครบ | — | — |
| Status effects | Combat | FF7/PoE2 | ✅ ครบ | — | — |
| Enemy AI | Combat | FF7 | ✅ ครบ | — | ออกแบบแล้วใน §52 — 5 archetypes, elemental resistance, night modifier, multi-enemy coordination |
| **Boss mechanics** | Combat | FF7/PoE2 | ✅ ครบ | — | ออกแบบแล้วใน §51 — phase system, arena mechanic, enrage timer ครบทุก Band |
| Party combat sync | Combat | RO | ✅ ครบ | — | ออกแบบสมบูรณ์ใน §53 — State Machine, loot 4 modes, death/revive, disconnect, RPC ครบ |
| Passive skill tree | Progression | PoE2 | ✅ ครบ | — | — |
| Divinity EXP system | Progression | PoE2 | ✅ ครบ | — | — |
| Combat Skill (§26) | Progression | FF7/PoE2 | ✅ ครบ | — | — |
| Skill node content pool | Progression | PoE2 | ✅ ครบ | — | ออกแบบแล้วใน §54 — 181 nodes ครบทุก Band tier 1-5 |
| Equipment & weapons | Progression | PoE2/RO | ✅ ครบ | — | — |
| Set bonus system | Progression | RO | ✅ ครบ | — | — |
| Random affix | Progression | PoE2 | ✅ ครบ | — | — |
| Upgrade & refine | Progression | RO | ✅ ครบ | — | — |
| Item durability | Progression | Valheim | ✅ ครบ | — | — |
| Life Skill / Proficiency | Progression | Stardew/RO | ✅ ครบ | — | — |
| Gacha system | Economy | Gacha | ✅ ครบ | — | — |
| **Gold economy balance** | Economy | RO | ✅ ครบ | — | ออกแบบแล้วใน §11 (รอบล่าสุด) |
| NPC shop / vendor | Economy | RO/Stardew | ✅ ครบ | — | ออกแบบแล้วใน §55 — catalog ครบ Band 1-2, scaling formula Band 3-6, sell system |
| Eternal Marketplace | Economy | PoE2 | ✅ ครบ | — | — |
| Town Treasury | Economy | Portia | ✅ ครบ | — | — |
| Crafting system | Economy | Terraria/Valheim | ✅ ครบ | — | — |
| Recipe list | Economy | Stardew | ✅ ครบ | — | ออกแบบแล้วใน §56 — 125 recipes ครบ 7 skill (Cooking/Alchemy/Smithing/Carpentry/Masonry/Farming/Tailoring) |
| World map & tower | World | RO/PoE2 | ✅ ครบ | — | — |
| Field map & movement | World | RO | ✅ ครบ | — | — |
| Auto-hunt system | World | RO | ✅ ครบ | — | ออกแบบแล้วใน §57 — session limit, safety recall, reward formula, field log |
| Warp / fast travel | World | RO/PoE2 | ✅ ครบ | — | — |
| Day/Night cycle | World | Stardew/Valheim | ✅ ครบ | — | — |
| Season system | World | Stardew | ✅ ครบ | — | — |
| Ecosystem | World | — | ✅ ครบ | — | — |
| Weather system | World | Valheim | ✅ ครบ | — | ออกแบบแล้วใน §62 — 10 weather types, special mechanics, data-driven pool per Band+Season |
| Mystery camp events | World | PoE2 | ⚠️ บางส่วน | low | mystery camp มี แต่ยังไม่ออกแบบ random event table |
| Farming | Survival | Stardew | ✅ ครบ | — | — |
| Animal husbandry | Survival | Stardew | ✅ ครบ | — | — |
| Fishing | Survival | Stardew | ✅ ครบ | — | — |
| Hunting | Survival | Valheim | ✅ ครบ | — | — |
| Gathering & resources | Survival | Terraria | ✅ ครบ | — | — |
| Treasure hunting | Survival | — | ✅ ครบ | — | — |
| Survival needs | Survival | Don't Starve | ✅ ครบ | — | — |
| Food & cooking quality | Survival | Valheim/Stardew | ✅ ครบ | — | §56 recipe list 20 recipes + §58 spoilage system ครบ |
| Building system | Survival | Terraria/Valheim | ✅ ครบ | — | — |
| Building defense / trap | Survival | Terraria | ✅ ครบ | — | ออกแบบแล้วใน §59 — damage formula ครบ, 5 trap types, 4 watchtower tiers |
| NPC stats & Guard | Social | — | ✅ ครบ | — | — |
| Bounty & crime | Social | — | ✅ ครบ | — | — |
| **Friend list** | Social | RO | ✅ ครบ | — | ออกแบบแล้วใน §34 (รอบล่าสุด) |
| Guild system | Social | RO | ⚠️ บางส่วน | low | feature flag ปิด Phase 3 — ยังไม่มีรายละเอียดใดๆ |
| Party & co-op | Social | RO | ✅ ครบ | — | — |
| Chat system | Social | RO | ✅ ครบ | — | — |
| Leaderboard | Social | RO | ✅ ครบ | — | ออกแบบแล้วใน §65 — daily 5 หมวด, weekly ladder, season monthly, pg_cron reset |
| Multiplayer networking | Social | RO | ✅ ครบ | — | — |
| Monster Bestiary | Meta | RO | ✅ ครบ | — | — |
| Achievement system | Meta | Stardew | ✅ ครบ | — | ออกแบบแล้วใน §60 — 63 achievements, 7 หมวด, badge 3 slots |
| Title / badge display | Meta | RO | ⚠️ บางส่วน | low | Divinity title มี แต่ achievement title display ยังไม่ชัดเจน |
| Tutorial / onboarding | Meta | Stardew | ✅ ครบ | — | — |
| Settings menu | Meta | — | ✅ ครบ | — | — |
| Auth & Guest mode | Meta | — | ✅ ครบ | — | — |
| Localization (i18n) | Meta | — | ✅ ครบ | — | — |
| Analytics / telemetry | Meta | — | ✅ ครบ | — | ออกแบบแล้วใน §61 — 25 event types, batch system, key metrics, privacy policy |
| Patch note / in-game news | Meta | RO | ✅ ครบ | — | ออกแบบแล้วใน §66 — 5 news types, auto-popup patch note, tips pool |
| Character appearance | Meta | RO | ✅ ครบ | — | — |
| World lore & story | Meta | PoE2 | ✅ ครบ | — | — |
| Item Identification | Meta | RO/PoE2 | ✅ ครบ | — | — |
| Difficulty modes | Meta | Valheim | ✅ ครบ | — | — |

### รายการที่ยังต้องออกแบบ (เรียงตาม Priority)

**Priority สูง: ✅ ทุกรายการออกแบบครบแล้ว**

**Priority กลาง:**
- [x] ~~Party ATB Sync~~ — ออกแบบแล้วใน §53
- [x] ~~Skill node pool~~ — 181 nodes ออกแบบแล้วใน §54
- [x] ~~NPC shop~~ — ออกแบบแล้วใน §55
- [x] ~~Recipe list~~ — 125 recipes ออกแบบแล้วใน §56
- [x] ~~Auto-hunt~~ — ออกแบบแล้วใน §57
- [x] ~~Food & cooking recipes + spoilage~~ — §56 + §58
- [x] ~~Building trap/watchtower~~ — damage formula ออกแบบแล้วใน §59
- [x] ~~Achievement list~~ — 63 achievements ออกแบบแล้วใน §60
- [x] ~~Analytics/telemetry~~ — ออกแบบแล้วใน §61

**Priority ต่ำ:**
- [x] ~~Weather system~~ — ออกแบบแล้วใน §62
- [x] ~~Mystery camp random event table~~ — ออกแบบแล้วใน §63
- [x] ~~Guild system~~ — ออกแบบแล้วใน §64 (Phase 3, feature flag ปิด)
- [x] ~~Daily/weekly leaderboard~~ — ออกแบบแล้วใน §65
- [x] ~~In-game news~~ — ออกแบบแล้วใน §66
