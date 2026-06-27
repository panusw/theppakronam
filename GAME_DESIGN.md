# GAME_DESIGN.md — เทพปกรณัม (Theppakronam)
> Game Design Document ฉบับสมบูรณ์ — อ่านควบคู่กับ CLAUDE.md
> อัปเดตล่าสุด: มิถุนายน 2026

---

## สารบัญ

1. [ภาพรวมเกม](#1-ภาพรวมเกม)
2. [ผู้ท้าชิงนิรนาม (Protagonist)](#2-ผู้ท้าชิงนิรนาม)
3. [หอเทวภพ (Tower Structure)](#3-หอเทวภพ)
4. [ระบบ ATB Combat](#4-ระบบ-atb-combat)
5. [ระบบ Gacha](#5-ระบบ-gacha)
6. [Passive Skill Tree](#6-passive-skill-tree)
7. [ระบบ Equipment](#7-ระบบ-equipment)
8. [ระบบ Upgrade & Refine](#8-ระบบ-upgrade--refine)
9. [Monster Capture & Bestiary](#9-monster-capture--bestiary)
10. [ระบบ Energy](#10-ระบบ-energy)
11. [Economy & Progression](#11-economy--progression)
12. [Auth & Save](#12-auth--save)
13. [Character Creator](#13-character-creator)
14. [UI/UX Flow](#14-uiux-flow)
15. [Schema ที่ต้องสร้างเพิ่ม](#15-schema-ที่ต้องสร้างเพิ่ม)
16. [Godot Scene Map](#16-godot-scene-map)
17. [Difficulty Modes](#17-difficulty-modes)
18. [Offline / Online & Save Strategy](#18-offline--online--save-strategy)
19. [Multiplayer & Networking](#19-multiplayer--networking)
20. [Hardcore Mode & Marketplace](#20-hardcore-mode--marketplace)
21. [Settings Menu](#21-settings-menu)
22. [Gathering & Resource System](#22-gathering--resource-system)
23. [Crafting System](#23-crafting-system)
24. [Survival Needs (Soft System)](#24-survival-needs-soft-system)
25. [Building System](#25-building-system)
26. [Combat Skill System](#26-combat-skill-system)
27. [Life Skill System](#27-life-skill-system)
28. [Status Effects (Buff / Debuff)](#28-status-effects-buff--debuff)
29. [Death Penalty & Respawn](#29-death-penalty--respawn)
30. [NPC, Town Hub & Warp](#30-npc-town-hub--warp)
31. [Inventory, Stash & Storage](#31-inventory-stash--storage)
32. [Quest & Mission System](#32-quest--mission-system)
33. [Party & Co-op System](#33-party--co-op-system)
34. [Friend List System](#34-friend-list-system)
35. [Chat System](#35-chat-system)
36. [Anti-Cheat & Security](#35-anti-cheat--security)
37. [Mini-map & HUD](#36-mini-map--hud)
38. [Hunting System](#38-hunting-system)
39. [Farming System](#39-farming-system)
40. [Fishing System](#40-fishing-system)
41. [Animal Husbandry System](#41-animal-husbandry-system)
42. [Treasure Hunting System](#42-treasure-hunting-system)
43. [World Lore & Story Arc](#43-world-lore--story-arc)
44. [Time System & Seasons](#44-time-system--seasons)
45. [Item Identification](#45-item-identification)
46. [Monster Raid System](#46-monster-raid-system)
47. [Localization (i18n)](#47-localization-i18n)
48. [NPC Stats, Guard & Bounty System](#48-npc-stats-guard--bounty-system)
49. [Ecosystem System](#49-ecosystem-system)
51. [Boss & Mini-Boss Mechanics](#51-boss--mini-boss-mechanics)
52. [Enemy AI System](#52-enemy-ai-system)
53. [Party ATB Sync](#53-party-atb-sync)
54. [Skill Node Content Pool](#54-skill-node-content-pool)
55. [NPC Shop & Vendor System](#55-npc-shop--vendor-system)
56. [Recipe List](#56-recipe-list)
57. [Auto-Hunt System](#57-auto-hunt-system)
58. [Food Quality & Spoilage System](#58-food-quality--spoilage-system)
59. [Building Defense — Trap & Watchtower Mechanics](#59-building-defense--trap--watchtower-mechanics)
60. [Achievement System](#60-achievement-system)
61. [Analytics & Telemetry](#61-analytics--telemetry)
62. [Weather System](#62-weather-system)
63. [Mystery Camp Event Table](#63-mystery-camp-event-table)
64. [Guild System (Phase 3)](#64-guild-system-phase-3)
65. [Daily/Weekly Leaderboard & Ladder Reset](#65-dailyweekly-leaderboard--ladder-reset)
66. [In-Game News & Patch Note System](#66-in-game-news--patch-note-system)

---

## 1. ภาพรวมเกม

### Concept
เกม RPG gacha single-player บน PC สำหรับผู้เล่น 1 คน ไต่หอเทวภพอนันต์
ผู้เล่นไม่ได้เก็บตัวละคร แต่เก็บ **อาวุธ / เกราะ / skill node / วัสดุ**
เพื่อ **ปลดล็อก passive skill tree** จนตัวเองกลายเป็นเทพ

### Core Loop
```
ไต่หอ → ต่อสู้ศัตรู → drop item (Unidentified)
      → identify item → equip หรือ ขาย NPC ได้ gold
      → gacha ด้วย gem → ได้ item ใหม่
      → ปลดล็อก skill tree ด้วย item + gold → stat แข็งแกร่งขึ้น
      → สะสม Divinity EXP จากทุกกิจกรรม → Divinity level ขึ้น
      → ปลดล็อก Ascension Node (tier 5) → Divinity EXP +200
      → Divinity level 10 → กลายเป็นเทพปกรณัม
```

### Inspirations
| เกม | ยืมอะไรมา |
|---|---|
| Ragnarok Online | world map style, auto-hunt, field log |
| Path of Exile 2 | passive skill web, camp graph, item identification |
| Final Fantasy VII | ATB combat system |
| Gacha games (ทั่วไป) | pity system, banner, rarity |
| **Stardew Valley** | farming cycle, fishing minigame, seasonal crop, NPC relationship |
| **Terraria** | resource gathering, building system, material tiers, crafting station |
| **Valheim** | survival needs, building placement, biome-based progression, boss unlock |
| **My Time at Portia / Sandrock** | town hub NPC, crafting commission, building upgrade, town economy |
| **Romestead** | camp-based building, animal husbandry, gathering from environment |
| **Don't Starve** | survival needs (hunger/thirst), seasonal hazard, food quality |

### Platform & Tech
- Godot 4 (GDScript), PC Windows/Mac
- Backend: Supabase (PostgreSQL + REST)
- Art: 16-bit pixel art
- Release: itch.io beta → Steam Early Access

---

## 2. ผู้ท้าชิงนิรนาม

### Concept
ผู้เล่นรับบทเป็น "ผู้ท้าชิง" ไม่มีชื่อ ไม่มีหน้าตาตายตัว
เติบโตผ่าน skill tree — ไม่มี level แบบดั้งเดิม
ความแข็งแกร่งมาจาก: **equipment + unlocked skill nodes + divinity level**

### Divinity Progression

Divinity คือระดับ "ความเป็นเทพ" ส่วนตัวของผู้เล่น — ไม่ผูกกับ floor ที่ผ่าน
ได้มาจาก **หลายแหล่ง** สะสมเรื่อยๆ ตลอดการเล่น

#### แหล่ง Divinity EXP

| แหล่ง | Divinity EXP |
|---|---|
| ปลดล็อก Ascension Node (tier 5) | +200 ต่อ node |
| สังหาร Boss ครั้งแรก (first kill) | +50 ต่อ boss |
| Clear camp ครั้งแรก (first clear) | +2 ต่อ camp |
| ปลดล็อก skill node (tier 1-4) ครั้งแรก | +1 ต่อ node |
| ค้นพบ Ascension Node ครั้งแรก (เดินถึง) | +5 ต่อ node |
| Complete main quest (band) | +100 ต่อ band |
| Bestiary ครบ band | +30 ต่อ band |
| Ecosystem Thriving (ดูแล floor ≥ 7 วันเกม) | +10 ต่อ floor |
| กิจกรรมพิเศษ (Seasonal Event) | +20-50 ต่อ event |
| Eternal Path — ไต่ถึง floor ใหม่ก่อนใคร (server first) | +100 |

#### Divinity Level Table (EXP สะสม)

| Level | EXP ที่ต้องการ (สะสม) | ชื่อ | Base Stat เพิ่มรวม |
|---|---|---|---|
| 0 | 0 | ผู้ท้าชิง | HP+0, ATK+0, DEF+0 |
| 1 | 100 | ผู้แสวงหา | HP+150, ATK+20, DEF+10 |
| 2 | 250 | นักสำรวจ | HP+300, ATK+40, DEF+20 |
| 3 | 450 | ขุนศึก | HP+450, ATK+60, DEF+30 |
| 4 | 700 | วีรบุรุษ | HP+600, ATK+80, DEF+40 |
| 5 | 1,000 | เซียน | HP+750, ATK+100, DEF+50 |
| 6 | 1,400 | ผู้รู้แจ้ง | HP+900, ATK+120, DEF+60 |
| 7 | 1,900 | เทพบุตร/เทพธิดา | HP+1,050, ATK+140, DEF+70 |
| 8 | 2,500 | เทพเจ้า | HP+1,200, ATK+160, DEF+80 |
| 9 | 3,200 | เทพสูงสุด | HP+1,350, ATK+180, DEF+90 |
| 10 | 4,000 | เทพปกรณัม | HP+1,500, ATK+200, DEF+100 |

**Stat สุดท้าย Divinity 10:**
```
HP  = 10  + 1,500 = 1,510  (ก่อน equip/nodes)
ATK = 1   + 200   = 201
DEF = 1   + 100   = 101
```

**Formula:**
```gdscript
func get_divinity_stat_bonus(divinity: int) -> Dictionary:
    return {
        "hp":  divinity * 150,
        "atk": divinity * 20,
        "def": divinity * 10,
    }

func get_divinity_level(exp: int) -> int:
    var thresholds = [0, 100, 250, 450, 700, 1000, 1400, 1900, 2500, 3200, 4000]
    for i in range(thresholds.size() - 1, -1, -1):
        if exp >= thresholds[i]:
            return i
    return 0
```

#### Divinity Level Up Event
เมื่อ level ขึ้น → แสดง full-screen animation "divine ascension"
- ชื่อ title เปลี่ยนใน HUD
- Passive stat bonus เพิ่มทันที
- unlock content ที่ผูกกับ level นั้น (tier 4/5 node, special quest)

#### Unlock จาก Divinity Level

| Divinity | สิ่งที่ปลดล็อก |
|---|---|
| 1 | Skill node tier 2 (ปลดล็อกได้แล้ว) |
| 2 | Skill node tier 3, Hunting Zone access |
| 3 | Skill node tier 4 |
| 4 | Ascension Node (tier 5 legendary) |
| 5 | Alchemy Table tier 2 recipes |
| 6 | Forge tier 3 recipes |
| 7 | Eternal Marketplace (ถ้าเป็น Eternal Path) |
| 8 | Ascension Node (tier 5 mythic — ทวยเทพบุตร) |
| 9 | Server-wide title "เทพสูงสุด" แสดงข้าง portrait |
| 10 | Endgame content, band 6 unlock (ดูเงื่อนไข floor ด้านล่าง) |

---

### Floor & Band Unlock — Server-Wide System

**หลักการ:** Floor ใหม่ปลดล็อกให้ **ทุกคนในเซิร์ฟเวอร์** เมื่อ **ผู้เล่นคนใดคนหนึ่งสังหาร Boss** ของ floor นั้นสำเร็จเป็นครั้งแรก

```
Server: Floor 9 Boss "มหายักษ์ทรนง" ยังไม่มีใคร kill
  ↓
ผู้เล่น A สังหารสำเร็จ (First Kill)
  ↓
[Server Broadcast] "⚡ ผู้ท้าชิง [ชื่อ A] พิชิต มหายักษ์ทรนง!
                    Band 2 วิหารแสงสุริยา — เปิดให้ทุกคนแล้ว!"
  ↓
Floor 10-19 (Band 2) unlock สำหรับ server ทั้งหมด
ผู้เล่น A ได้ Divinity EXP +100 (server first bonus)
```

#### Boss Kill ที่ Trigger Band Unlock

| Boss | Floor | Band ที่ปลดล็อก |
|---|---|---|
| มหายักษ์ทรนง | Floor 9 | Band 2 (Greek, floor 10-19) |
| Titan of Olympus | Floor 19 | Band 3 (Norse, floor 20-29) |
| Fenrir Unchained | Floor 29 | Band 4 (Egyptian, floor 30-39) |
| Ra the Corrupted | Floor 39 | Band 5 (Japanese, floor 40-49) |
| Yamata no Orochi | Floor 49 | Band 6 (Primordial, floor 50+) |

#### Floor Unlock ภายใน Band (Individual)
ภายใน band เดียวกัน floor ปลดล็อกสำหรับ **ผู้เล่นแต่ละคน** เมื่อ clear boss floor ก่อนหน้า:

```
Floor 1 → ผ่าน boss floor 1 → ปลดล็อก floor 2 (เฉพาะตัวเอง)
...
Floor 8 → ผ่าน boss floor 8 → ปลดล็อก floor 9 (boss gate)
Floor 9 boss kill (any player) → Band 2 unlock (server-wide)
```

#### Offline Server (Solo)
ไม่มี "player อื่น" → ผู้เล่นต้อง kill boss เองทุกตัว เป็น solo progression ล้วน

---

### Band Ascension — การสละ Divinity เพื่อข้าม Band

**Concept:** การเดินทางระหว่าง Band ไม่ว่าจะขึ้นหรือลง ต้องแลกด้วย Divinity EXP เสมอ
ธีมสอดคล้องกับ lore: "การเคลื่อนผ่านมิติต้องจ่ายด้วยพลังแห่งเทพ"

#### กฎพื้นฐาน
- ข้ามได้ **ทั้งขึ้น (Band ต่ำ → สูง) และลง (Band สูง → ต่ำ)**
- ต้องไปที่ **Gate Keeper ใน Hub** ของ Band ที่ตัวเองอยู่
- Band ปลายทางต้อง server-wide unlock แล้ว (กรณีขึ้น)
- มี **Cooldown** หลังข้าม Band ทุกครั้ง
- ข้ามมากกว่า 1 ขั้น (เช่น Band 1 → Band 3) ต้องจ่าย **เพิ่มขึ้นแบบ exponential**

---

#### Divinity Sacrifice Cost

**Base cost ต่อ 1 ขั้น (ทั้งขึ้นและลง เท่ากัน):**

| การข้าม (ขึ้น หรือ ลง) | Base EXP (1 ขั้น) |
|---|---|
| Band 1 ↔ Band 2 | 50 EXP |
| Band 2 ↔ Band 3 | 150 EXP |
| Band 3 ↔ Band 4 | 300 EXP |
| Band 4 ↔ Band 5 | 500 EXP |
| Band 5 ↔ Band 6 | 800 EXP |

**Multi-step penalty (ข้ามมากกว่า 1 ขั้น):**

ค่าใช้จ่ายรวม = Σ(base cost ของแต่ละขั้น) × multiplier

| จำนวนขั้นที่ข้าม | Multiplier |
|---|---|
| 1 ขั้น | ×1.0 (ปกติ) |
| 2 ขั้น | ×1.5 |
| 3 ขั้น | ×2.5 |
| 4 ขั้น | ×4.0 |
| 5 ขั้น (Band 1 ↔ 6) | ×6.0 |

**ตัวอย่างการคำนวณ:**
```
ข้าม Band 1 → Band 3 (2 ขั้น ขึ้น):
  base = 50 (1→2) + 150 (2→3) = 200 EXP
  cost = 200 × 1.5 = 300 EXP

ข้าม Band 3 → Band 1 (2 ขั้น ลง):
  base = 150 (3→2) + 50 (2→1) = 200 EXP
  cost = 200 × 1.5 = 300 EXP  ← เท่ากัน

ข้าม Band 1 → Band 6 (5 ขั้น):
  base = 50+150+300+500+800 = 1,800 EXP
  cost = 1,800 × 6.0 = 10,800 EXP
```

```gdscript
func calc_band_travel_cost(from_band: int, to_band: int) -> int:
    var base_costs   = {1: 50, 2: 150, 3: 300, 4: 500, 5: 800}
    var multipliers  = {1: 1.0, 2: 1.5, 3: 2.5, 4: 4.0, 5: 6.0}
    var steps        = abs(to_band - from_band)
    var direction    = 1 if to_band > from_band else -1
    var total_base   = 0
    for i in range(steps):
        total_base += base_costs[from_band + (i * direction)]
    return int(total_base * multipliers[steps])
```

---

#### Cooldown System

หลังข้าม Band ทุกครั้ง → ไม่สามารถข้าม Band ได้อีกชั่วคราว (ทั้งขึ้นและลง)

| จำนวนขั้นที่ข้าม | Cooldown (real time) |
|---|---|
| 1 ขั้น | 30 นาที |
| 2 ขั้น | 2 ชั่วโมง |
| 3 ขั้น | 8 ชั่วโมง |
| 4 ขั้น | 24 ชั่วโมง |
| 5 ขั้น | 72 ชั่วโมง |

ระหว่าง Cooldown: ยังเล่นใน Band ปัจจุบันได้ปกติ, Gate Keeper แสดง timer countdown

---

#### ผลต่อ Divinity Level

```
ตัวอย่าง A — Level ไม่เปลี่ยน:
  EXP: 420 (level 3, threshold 250) → ข้าม 1 ขั้น (-50) → 370 → ยัง level 3 ✓

ตัวอย่าง B — Level ลง:
  EXP: 280 (level 2, threshold 250) → ข้าม 2 ขั้น (-300) → -20 → clamp 0 → level 0
  Title, stat bonus เปลี่ยน แต่ node ที่ unlock แล้วยังอยู่
```

**กฎ EXP:** ไม่ติดลบ — ถ้า EXP < cost → ระบบไม่อนุญาต ต้องสะสมเพิ่มก่อน

**สิ่งที่ไม่หายเมื่อ Level ลด:** Skill node ที่ unlock, equipment, inventory, bestiary, floor progress

**สิ่งที่เปลี่ยน:** Title ใน HUD, base stat bonus (HP/ATK/DEF), tier gate สำหรับ node ใหม่

---

#### UI Confirmation (2 ขั้น)

```
[Gate Keeper: "เจ้าต้องการเดินทางสู่ Band 3 ใช่หรือไม่?"]

  จาก: Band 1 แดนศรัทธาโบราณ
  ไปยัง: Band 3 ป่าหิมะยักษ์  (ข้าม 2 ขั้น ↑)

  Divinity EXP:   850 → 550     (-300 EXP)
  Divinity Level: 5  → 5        ✓ ไม่เปลี่ยน
  Cooldown: 2 ชั่วโมง หลังข้าม
  [ยืนยัน]  [ยกเลิก]

─── กรณี level ลด ───
  Divinity EXP:   280 → 0       (-280 EXP, clamp)
  Divinity Level: 2  → 0        ⚠ ลดลง!
  Base: HP -300, ATK -40, DEF -20
  หมายเหตุ: Skill node ที่ unlock แล้วยังคงอยู่
  [ยืนยัน — ฉันยอมรับ]  [ยกเลิก]
```

**Eternal Path:** สละ EXP เหมือนกัน + ได้ Eternal EXP bonus +50% ที่ band ปลายทาง

---

#### Schema (schema_tower_v2.sql)

```sql
ALTER TABLE players ADD COLUMN IF NOT EXISTS
    band_travel_cooldown_until TIMESTAMPTZ;

CREATE TABLE band_ascension_log (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  player_id       UUID NOT NULL REFERENCES players(id),
  from_band       INTEGER NOT NULL,
  to_band         INTEGER NOT NULL,
  steps           INTEGER NOT NULL,
  direction       TEXT NOT NULL,   -- 'up' / 'down'
  exp_sacrificed  INTEGER NOT NULL,
  divinity_before INTEGER NOT NULL,
  divinity_after  INTEGER NOT NULL,
  level_before    INTEGER NOT NULL,
  level_after     INTEGER NOT NULL,
  cooldown_until  TIMESTAMPTZ NOT NULL,
  ascended_at     TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Supabase RPC: validate + execute band travel
CREATE OR REPLACE FUNCTION travel_band(p_player_id UUID, p_to_band INTEGER)
RETURNS JSONB AS $$
DECLARE
  p           RECORD;
  steps       INTEGER;
  direction   INTEGER;
  total_base  INTEGER := 0;
  cost        INTEGER;
  cd_minutes  INTEGER[] := ARRAY[0, 30, 120, 480, 1440, 4320];
  multipliers NUMERIC[] := ARRAY[0, 1.0, 1.5, 2.5, 4.0, 6.0];
  base_costs  INTEGER[] := ARRAY[0, 50, 150, 300, 500, 800];
BEGIN
  SELECT * INTO p FROM players WHERE id = p_player_id FOR UPDATE;

  IF p.band_travel_cooldown_until IS NOT NULL
     AND now() < p.band_travel_cooldown_until THEN
    RETURN jsonb_build_object('ok', false, 'reason', 'cooldown',
      'ready_at', p.band_travel_cooldown_until);
  END IF;

  steps     := abs(p_to_band - p.current_band);
  direction := CASE WHEN p_to_band > p.current_band THEN 1 ELSE -1 END;

  FOR i IN 0..(steps-1) LOOP
    total_base := total_base + base_costs[p.current_band + (i * direction)];
  END LOOP;
  cost := (total_base * multipliers[steps])::INTEGER;

  IF p.divinity_exp < cost THEN
    RETURN jsonb_build_object('ok', false, 'reason', 'insufficient_exp',
      'required', cost, 'current', p.divinity_exp);
  END IF;

  UPDATE players SET
    divinity_exp               = divinity_exp - cost,
    current_band               = p_to_band,
    band_travel_cooldown_until = now() + (cd_minutes[steps] * INTERVAL '1 minute')
  WHERE id = p_player_id;

  INSERT INTO band_ascension_log
    (player_id, from_band, to_band, steps, direction, exp_sacrificed,
     divinity_before, divinity_after, level_before, level_after, cooldown_until)
  VALUES
    (p_player_id, p.current_band, p_to_band, steps,
     CASE WHEN direction=1 THEN 'up' ELSE 'down' END,
     cost, p.divinity_exp, GREATEST(0, p.divinity_exp - cost),
     get_divinity_level(p.divinity_exp),
     get_divinity_level(GREATEST(0, p.divinity_exp - cost)),
     now() + (cd_minutes[steps] * INTERVAL '1 minute'));

  RETURN jsonb_build_object('ok', true, 'exp_spent', cost,
    'new_exp', GREATEST(0, p.divinity_exp - cost),
    'cooldown_minutes', cd_minutes[steps]);
END;
$$ LANGUAGE plpgsql;
```

### Server First Hall of Fame

บันทึกถาวรใน **แผ่นจารึก** ที่ Hub แต่ละ Band
แยกตาม **ระดับความยาก** และมีทั้ง **First Kill** และ **Best Record**

#### Hall of Fame Categories

```
[แผ่นจารึก — ผู้พิชิตแห่งหอเทวภพ]
[ระดับความยาก: Normal ▼]  Normal / Hard / Ascendant / Eternal Path

──────────────── First Kill ────────────────
Boss                   ผู้พิชิต         วันที่
มหายักษ์ทรนง (Band 1)  สมชาย           วันที่ 3 คิมหันต์
Titan of Olympus        (ยังไม่มีผู้พิชิต)
...

──────────────── Best Clear Time ────────────────
Boss                   ผู้เล่น          เวลา
มหายักษ์ทรนง           มานี             2:34.5
มหายักษ์ทรนง           สมชาย           3:12.1
มหายักษ์ทรนง           วิชัย            3:45.8

──────────────── Highest Score ────────────────
Boss                   ผู้เล่น          คะแนน
มหายักษ์ทรนง           วิชัย            98,450
มหายักษ์ทรนง           มานี             87,200
มหายักษ์ทรนง           สมชาย           72,100
```

#### Best Clear Time
- นับตั้งแต่ **enter boss arena** จนถึง **boss HP = 0**
- บันทึกแยกต่อ boss ต่อ difficulty
- แสดง Top 10 ต่อ boss
- ผู้เล่นที่ hold record ได้ unique badge ข้าง portrait จนกว่าจะถูกทำลาย

#### Score System
คะแนนคำนวณจากหลายปัจจัย:

```
base_score     = boss_max_hp / damage_per_turn    # ยิ่งทำ damage เร็ว ยิ่งได้ score สูง
time_bonus     = max(0, (par_time - clear_time) × 100)
  # par_time = เวลา "ปกติ" ของ boss แต่ละตัว
  # เร็วกว่า par → bonus สูง
hp_bonus       = (player.hp / player.max_hp) × 20000
  # เหลือ HP มาก → bonus สูง
no_item_bonus  = 10000 ถ้าไม่ใช้ item ระหว่าง boss fight
no_flee_bonus  = 5000  ถ้าไม่ได้ใช้ Flee attempt

final_score = base_score + time_bonus + hp_bonus + no_item_bonus + no_flee_bonus
```

```gdscript
# ScoreManager.gd
func calculate_boss_score(session: CombatSession) -> int:
    var base   = int(session.enemy_hp_start / (session.turns_taken + 1)) * 10
    var par    = BossData.get_par_time(session.enemy_name)
    var t_bonus = max(0, (par - session.turns_taken) * 100)
    var hp_pct  = float(session.player_hp_end) / session.player_max_hp
    var hp_b   = int(hp_pct * 20000)
    var no_item = 10000 if not session.used_item else 0
    var no_flee = 5000  if not session.attempted_flee else 0
    return base + t_bonus + hp_b + no_item + no_flee
```

#### Difficulty Separation
- Hall of Fame **แยกสมบูรณ์** ตาม difficulty — ไม่ปนกัน
- Eternal Path มี Hall of Fame พิเศษ: แสดง **floor สูงสุดที่ถึงก่อนตาย** เพิ่มด้วย
- Official server: Hall of Fame รวมทุก player บน server
- Community/Friend Session: Hall of Fame เฉพาะ players ใน session นั้น

#### Schema (เพิ่มใน schema_tower_v2.sql)
```sql
ALTER TABLE players ADD COLUMN IF NOT EXISTS
    divinity_exp INTEGER NOT NULL DEFAULT 0;

CREATE TABLE divinity_exp_log (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  player_id   UUID NOT NULL REFERENCES players(id) ON DELETE CASCADE,
  exp_gained  INTEGER NOT NULL,  -- ลบ = สละ (band ascension)
  source      TEXT NOT NULL,
    -- 'ascension_node'/'boss_first_kill'/'camp_clear'/'band_sacrifice'/...
  ref_id      TEXT,
  logged_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE band_ascension_log (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  player_id     UUID NOT NULL REFERENCES players(id),
  from_band     INTEGER NOT NULL,
  to_band       INTEGER NOT NULL,
  exp_sacrificed INTEGER NOT NULL,
  divinity_before INTEGER NOT NULL,
  divinity_after  INTEGER NOT NULL,
  level_before  INTEGER NOT NULL,
  level_after   INTEGER NOT NULL,
  ascended_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE server_boss_kills (
  boss_camp_id  UUID NOT NULL REFERENCES tower_camps(id),
  difficulty    TEXT NOT NULL,  -- 'normal'/'hard'/'ascendant'/'eternal'
  first_killer  UUID NOT NULL REFERENCES players(id),
  killed_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
  band_unlocked INTEGER,
  PRIMARY KEY (boss_camp_id, difficulty)
);

CREATE TABLE boss_clear_records (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  boss_camp_id  UUID NOT NULL REFERENCES tower_camps(id),
  player_id     UUID NOT NULL REFERENCES players(id),
  difficulty    TEXT NOT NULL,
  server_id     TEXT NOT NULL,  -- 'official'/'community_{uuid}'/'solo'
  clear_time_turns INTEGER NOT NULL,   -- จำนวน turns
  clear_time_ms    INTEGER NOT NULL,   -- milliseconds จริง
  score            INTEGER NOT NULL,
  hp_remaining_pct NUMERIC NOT NULL,
  used_item        BOOLEAN NOT NULL DEFAULT FALSE,
  attempted_flee   BOOLEAN NOT NULL DEFAULT FALSE,
  recorded_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- View: Top 10 per boss per difficulty per server
CREATE VIEW boss_leaderboard AS
SELECT
  b.boss_camp_id,
  b.difficulty,
  b.server_id,
  b.player_id,
  p.char_name,
  b.score,
  b.clear_time_ms,
  RANK() OVER (
    PARTITION BY b.boss_camp_id, b.difficulty, b.server_id
    ORDER BY b.score DESC
  ) AS score_rank,
  RANK() OVER (
    PARTITION BY b.boss_camp_id, b.difficulty, b.server_id
    ORDER BY b.clear_time_ms ASC
  ) AS time_rank
FROM boss_clear_records b
JOIN players p ON p.id = b.player_id;

CREATE INDEX idx_boss_records_lookup
  ON boss_clear_records (boss_camp_id, difficulty, server_id, score DESC);

CREATE INDEX idx_divinity_log ON divinity_exp_log (player_id, logged_at DESC);
```





### Base Stats
| Stat | ค่าเริ่มต้น | แหล่งที่มา |
|---|---|---|
| HP | **10** | base + divinity + equip + nodes |
| **Energy** | **10** | base + equip + nodes (แยกจาก HP) |
| ATK | **1** | base + divinity + equip + nodes |
| DEF | **1** | base + divinity + equip + nodes |
| SPD | **1** | base + equip + nodes (ชาร์จ ATB) |
| CRIT_RATE | **0%** | nodes เท่านั้น (max 95%) |
| CRIT_DMG | **0%** | nodes เท่านั้น |
| FIRE_DMG | **0%** | equip + nodes |
| ICE_DMG | **0%** | equip + nodes |
| LIGHTNING_DMG | **0%** | equip + nodes |
| ALL_DMG | **0%** | equip + nodes |
| HP_REGEN | **0** | nodes / equip / item in inventory |
| ENERGY_REGEN | **0** | nodes / equip / item in inventory |

> **Energy** แยกออกจาก HP — ใช้สำหรับ Skill และบาง action
> Energy regen เร็วกว่า HP regen เสมอ

**Stat คำนวณฝั่ง server เท่านั้น** — cache ใน `player_stat_cache`

---

## 3. หอเทวภพ (Tower Structure)

### โครงสร้าง
```
หอเทวภพ
├── Band 1: แดนศรัทธาโบราณ (thai, floor 1-9)      ← Phase 1
├── Band 2: วิหารโอลิมปัส (greek, floor 10-19)     ← Phase 2
├── Band 3: ยักษ์ฟรอสต์ (norse, floor 20-29)       ← Phase 3
├── Band 4: แดนอนุบิส (egyptian, floor 30-39)      ← Phase 3
├── Band 5: ดินแดนเงาคามิ (japanese, floor 40-49)  ← Phase 4
└── Band 6: รากฐานปฐมกาล (primordial, floor 50+)  ← Phase 4
```

### Floor Structure
แต่ละ floor คือ **graph ของ camp** (แบบ PoE2 world map)
```
[spawn] ─── [normal] ─── [elite] ─── [mini_boss]
               └── [resource] ─── [mystery]
                                      └── [checkpoint]
                                              └── [boss_gate] ─── [boss]
```

### Camp Types
| Type | คำอธิบาย | Energy cost |
|---|---|---|
| spawn | จุดเริ่มต้นของ floor | 0 |
| normal | ศัตรูธรรมดา, drop ธรรมดา | 6 |
| elite | ศัตรูแข็งกว่า, drop ดีกว่า | 8 |
| mini_boss | ศัตรูพิเศษ, drop รับประกัน rare+ | 10 |
| checkpoint | บันทึก progress, ฟื้น HP 30% | 0 |
| boss_gate | ประตูที่ต้องปลดล็อก (เงื่อนไข) | 0 |
| boss | บอสประจำ floor, drop epic+ | 12 |
| resource | farm gold / ore โดยไม่ต่อสู้ | 4 |
| mystery | random event (buff / item / trap) | 3 |

### Boss Gate Unlock Conditions
Boss gate เปิดเมื่อครบ **2 ใน 3** เงื่อนไข:
- `camps_cleared_pct`: clear camp ≥ N% ของ floor
- `mini_bosses_killed`: kill mini_boss ≥ N ตัว
- `specific_camps`: clear camp เฉพาะที่กำหนด

### World Map ใน Godot
- render ด้วย **Node2D** วาด graph ด้วย `draw_line()` + `draw_circle()`
- ไม่ใช้ TileMap (tower map เป็น abstract graph ไม่ใช่ tile world)
- แต่ละ camp คือ `Area2D` node — คลิกได้, แสดง tooltip
- Player character เคลื่อนที่ตาม path animation (Tween)
- Field map (สำหรับ camp type normal/elite ที่ walk around) ใช้ TileMap ภายใน camp scene

### Field Map (ภายใน Camp)
- TileMap 28×22 tiles, tile size 16px
- Player เดินได้, มี enemy sprite ในแผนที่
- Click to move → BFS pathfinding
- Auto-hunt mode: AI เดินหา enemy อัตโนมัติ
- เข้าใกล้ enemy → trigger ATB combat

---

## 4. ระบบ ATB Combat

### Concept
FF7-style Active Time Battle — แต่ละ unit มี ATB gauge ชาร์จตาม SPD
เมื่อ gauge เต็ม → unit นั้นได้ทำ action, player pause time เลือก action ได้ (semi-active)

### ATB Formula
```
atb_charge_per_tick = unit.spd / 100
ticks_to_full       = 100 / atb_charge_per_tick

# ตัวอย่าง: SPD 100 (หลัง equip+nodes) → เต็มใน 100 ticks
# SPD เริ่มต้น = 1 → เต็มใน 10,000 ticks (ต้องพึ่ง equip/nodes)
```

### Energy System (ใน Combat)
```
Energy ใช้สำหรับ: Skill, Flee, Capture attempt, action พิเศษบางอย่าง
Energy regen: +energy_regen ทุก turn อัตโนมัติ (เร็วกว่า HP regen)

Energy cost ตัวอย่าง:
  Skill       : 3-10 energy (ขึ้นกับ skill tier)
  Flee attempt: 2 energy (สำเร็จ) / 4 energy (ล้มเหลว) + ถุงเงิน rand(1-10)% gold (multiplayer)
  # ตรวจ energy ก่อนแสดงปุ่ม Flee:
  #   energy ≥ 4 → แสดงปกติ (รองรับทั้งสำเร็จและล้มเหลว)
  #   energy 2-3 → แสดงปุ่ม + คำเตือน "⚠ energy อาจไม่พอถ้าหนีล้มเหลว"
  #               ถ้าหนีล้มเหลว → หัก energy ที่มีทั้งหมด (ไม่ติดลบ)
  #   energy < 2 → ปุ่ม Flee greyed out (ไม่มีแรงแม้แต่จะวิ่ง)
  Capture     : 5 energy
```

**บทลงโทษเมื่อ Energy หมด (Exhausted)**

เมื่อ `current_energy = 0` ผู้เล่นเข้าสู่สถานะ **"หมดแรง" (Exhausted)**:

| ผลกระทบ | รายละเอียด |
|---|---|
| Skill ใช้ไม่ได้ | ปุ่มทุก skill greyed out จนกว่า energy จะ regen |
| Flee ใช้ไม่ได้ | ปุ่ม Flee greyed out (energy < 2) |
| Capture ใช้ไม่ได้ | ปุ่ม Capture greyed out |
| ATK penalty | miss chance เพิ่ม +15% (ล้าจนตีพลาดง่ายขึ้น) |
| DEF penalty | รับ damage +10% (ป้องกันตัวได้แย่ลง) |
| HUD indicator | กรอบ portrait กระพริบสีเหลือง + ไอคอน ⚡💤 |

```gdscript
# CombatEntity.gd
func is_exhausted() -> bool:
    return current_energy <= 0

func get_miss_chance_modifier() -> float:
    return 0.15 if is_exhausted() else 0.0

func get_damage_received_modifier() -> float:
    return 1.10 if is_exhausted() else 1.0

# ใน _process_turn():
var final_miss = base_miss_chance + get_miss_chance_modifier()
var dmg_taken  = raw_dmg * get_damage_received_modifier()
```

> **Design note:** penalty ไม่ได้ทำให้ผู้เล่น "แพ้อัตโนมัติ" แต่กดดันให้ใช้ energy อย่างระวัง
> ทาง out ที่สะอาดคือ รอ regen (ใช้ Attack ไปก่อน) หรือใช้ Energy Potion item



### Turn Structure
```
loop:
  tick += 1
  for each unit (player + enemies):
    unit.atb    += unit.spd / 100
    unit.energy  = min(max_energy, unit.energy + unit.energy_regen)
    unit.hp      = min(max_hp, unit.hp + unit.hp_regen)
    if unit.atb >= 100:
      unit.atb = 0
      if unit == player:
        pause game → show action menu
      else:
        execute enemy AI action
```

### Player Action Menu (เมื่อ ATB เต็ม)
```
┌──────────────────────────────────────┐
│  ⚔️  โจมตี                           │
│  ✨  ทักษะ  [Q][E][R][T]  ⚡3/10     │
│  🧪  ไอเทม  [เลือก item]             │
│  🏃  หนี    (20% + SPD bonus)  ⚡2   │
│  🪤  จับ    [แสดงเมื่อ HP < 10%]  ⚡5│
└──────────────────────────────────────┘
```

---

#### โจมตี (Attack)
**Miss chance** — ถ้า player SPD < enemy SPD มีโอกาสโจมตีพลาด:
```
miss_chance = max(0, (enemy.spd - player.spd) / enemy.spd × 0.4)
# ตัวอย่าง: player SPD 50, enemy SPD 100
# miss_chance = (100-50)/100 × 0.4 = 0.20 (20%)

if rand() < miss_chance:
    show "พลาด!" → ไม่ทำ damage
else:
    raw_dmg   = atk - enemy.def + rand(-5, +5)
    is_crit   = rand() < crit_rate
    final_dmg = is_crit ? max(1, raw_dmg × (1 + crit_dmg)) : max(1, raw_dmg)
    final_dmg = final_dmg × (1 + all_dmg)
    # elemental bonus: บวกจาก fire_dmg/ice_dmg/lightning_dmg ตาม weapon element
```
Attack ไม่ใช้ Energy

---

#### ทักษะ (Skill)
Skill มาจาก 3 แหล่ง:
1. **Skill node** ที่ปลดล็อกบน passive tree
2. **Weapon innate skill** — skill ติดมากับ weapon (ตาม weapon class + random affix)
3. **Armor/accessory skill** — skill พิเศษจาก set bonus หรือ random affix

```
Skill ใช้ Energy: 3-10 ต่อ skill (ระบุใน skill definition)
ถ้า Energy ไม่พอ → ปุ่ม skill greyed out
```

---

#### ไอเทม (Item)
Potion **ไม่ฟื้นทันที** — ค่อยๆ regen ทีละนิดต่อ turn:
```gdscript
# เมื่อใช้ HP Potion:
var hot = {                    # Heal Over Time
    "hp_per_turn": potion.heal_power,
    "turns_left":  potion.duration,  # เช่น 5 turns
}
active_hots.append(hot)

# ทุก turn:
for hot in active_hots:
    player.hp = min(max_hp, player.hp + hot.hp_per_turn)
    hot.turns_left -= 1
    if hot.turns_left <= 0:
        active_hots.erase(hot)
```
HUD แสดง HOT icon + turns ที่เหลือ

---

#### หนี (Flee)
```
Energy cost: สำเร็จ 2 / ล้มเหลว 4 + ถุงเงิน rand(1-10)% gold (multiplayer)
Pre-check ก่อนแสดงปุ่ม:
  energy ≥ 4  → แสดงปกติ
  energy 2-3  → แสดงปุ่ม + ⚠ "energy อาจไม่พอถ้าหนีล้มเหลว"
                ถ้าล้มเหลว → หัก energy ที่มีทั้งหมด (ไม่ติดลบ)
  energy < 2  → ปุ่ม Flee greyed out

base_flee_chance = 20%
ถ้า player SPD > enemy SPD:
    spd_bonus = (player.spd - enemy.spd) / 10 × 1%
    (ไม่มี cap — SPD สูงมากหนีได้แน่นอน)
ถ้าใช้ Escape Smoke:
    flee_chance += 60%  (รวมสูงสุดได้เกิน 100% = หนีแน่นอน)

Minigame เต๋า 20 หน้า (optional):
    ทอยก่อนคำนวณ flee → ผลตาม Dice Table (บวกหรือลบ)
    เช่น ทอยได้ 15 → +15% flee chance
    เช่น ทอยได้ 3  → -10% flee chance (สะดุดตีนตัวเอง)
    (ดูรายละเอียด Dice Minigame ด้านล่าง)

ผล:
  สำเร็จ  → ออกจาก battle, ยังอยู่ใน field map เดิม, เสีย Energy 2
  ล้มเหลว → enemy โจมตี 1 ครั้ง, เสีย Energy min(4, current_energy),
             drop ถุงเงิน rand(1-10)% ของ gold ที่ถือ ณ ขณะนั้น (multiplayer เท่านั้น)
```

---

#### จับ (Capture)
ปุ่มแสดงเมื่อ **enemy HP < 10%** และ player มี Capture Item ใน inventory

```
Energy cost: 5

Capture Item rarity กระทบ base capture rate:
  Common Trap    : base 20%
  Uncommon Trap  : base 35%
  Rare Trap      : base 50%
  Epic Trap      : base 65%
  Legendary Trap : base 80%

Minigame เต๋า 20 หน้า (บังคับ):
  ทอยก่อนเสมอ → ผลตาม Dice Table (บวกหรือลบ)
  เช่น ทอยได้ 18 → +36% capture chance
  เช่น ทอยได้ 2  → -16% capture chance (trap หลุดมือ)

final_capture_chance = clamp(base_rate + dice_modifier, 5%, 95%)
  # ไม่ต่ำกว่า 5% (ยังมีโอกาสเล็กน้อย) ไม่เกิน 95% (ไม่การันตี)
  เช่น Common Trap (20%) + ทอยได้ 18 (+36%) = 56%
  เช่น Common Trap (20%) + ทอยได้ 2  (-16%) = 4% → clamp = 5%

ผล:
  สำเร็จ → capture enemy → เพิ่ม Bestiary, ได้ capture exp
  ล้มเหลว → enemy หนี (ออกจาก field), ไม่ได้ drop ใดๆ
  ตายระหว่าง capture (DoT kill) → ถือว่า kill, capture ล้มเหลว
```

---

### Dice Minigame (ทอยเต๋า 20 หน้า)

ใช้ใน: **Flee** (optional) และ **Capture** (บังคับ)

#### Dice Result Table

| ผลเต๋า | ระดับ | Effect (Flee) | Effect (Capture) | Flavour text |
|---|---|---|---|---|
| 1 | Critical Fail | -25% | -30% | "หกล้มกลิ้งไปชนศัตรู!" |
| 2-3 | Bad | -15% | -16% | "มือสั่น trap หลุดมือ" |
| 4-5 | Poor | -8% | -8% | "ลังเลนิดหน่อย" |
| 6-8 | Below Avg | -3% | -4% | "พอใช้ได้..." |
| 9-12 | Average | +0% | +0% | "ไม่ดีไม่เลว" |
| 13-15 | Good | +10% | +12% | "ตัดสินใจฉับพลัน" |
| 16-18 | Great | +20% | +28% | "จังหวะดีมาก!" |
| 19 | Excellent | +30% | +38% | "สัมผัสของนักล่า!" |
| 20 | Critical! | +40% + ฟรี Energy | +50% | "⭐ เทพช่วย!" |

**Critical Fail (1):**
- Flee: flee chance ลดหนัก + enemy ได้โจมตี 1 ครั้งทันที *ก่อน* ระบบ roll flee
- Capture: trap ระเบิด → enemy ตกใจวิ่งหนีออก field ทันที (ไม่ได้จับ ไม่ได้ kill)

**Critical (20):**
- Flee: +40% และ **ไม่เสีย Energy** ไม่ว่าจะสำเร็จหรือไม่
- Capture: +50% และถ้า capture สำเร็จ → **ได้ item drop ด้วย** (ไม่ตัดทิ้ง)

#### Formula
```gdscript
func roll_dice() -> int:
    return randi_range(1, 20)

func get_dice_modifier(roll: int, context: String) -> float:
    var flee_table    = {1:-0.25, 2:-0.15, 3:-0.15, 4:-0.08, 5:-0.08,
                         6:-0.03, 7:-0.03, 8:-0.03,
                         9:0.0,  10:0.0,  11:0.0,  12:0.0,
                        13:0.10, 14:0.10, 15:0.10,
                        16:0.20, 17:0.20, 18:0.20,
                        19:0.30, 20:0.40}
    var capture_table = {1:-0.30, 2:-0.16, 3:-0.16, 4:-0.08, 5:-0.08,
                         6:-0.04, 7:-0.04, 8:-0.04,
                         9:0.0,  10:0.0,  11:0.0,  12:0.0,
                        13:0.12, 14:0.12, 15:0.12,
                        16:0.28, 17:0.28, 18:0.28,
                        19:0.38, 20:0.50}
    return flee_table[roll] if context == "flee" else capture_table[roll]

func apply_dice(base_chance: float, roll: int, context: String) -> float:
    var mod = get_dice_modifier(roll, context)
    if context == "flee":
        return base_chance + mod   # ไม่ clamp (หนีได้เกิน 100% = แน่นอน)
    else:
        return clamp(base_chance + mod, 0.05, 0.95)
```

#### UI
```
[ลูกเต๋า 20 หน้า หมุนอยู่]
   กด [Space] / [A] เพื่อทอย

→ หยุด: แสดงเลข "17"
→ ✨ Great! +28% capture chance
→ Base: 35%  +  28%  =  63%  ← แสดง final %
   [ยืนยัน]
```

ไม่มี "กด timing ให้ถูก" — ผลเต๋าสุ่มแท้จริง 100%
ความตื่นเต้นมาจากการลุ้น ไม่ใช่ skill

---

### HP Regen & Energy Regen

ทั้ง HP และ Energy regen เกิดขึ้นใน **3 สถานการณ์**:

1. **Combat (per turn):** regen ตาม `hp_regen` และ `energy_regen` stat ทุก turn อัตโนมัติ
2. **หยุดทำกิจกรรม (field map):** เมื่อ player ไม่ได้เดิน/กด input นาน 3 วินาที
   ```
   idle_regen_hp     = max_hp × 0.02 / วินาที
   idle_regen_energy = max_energy × 0.05 / วินาที  (เร็วกว่า HP 2.5×)
   ```
3. **จาก item/equip:**
   - Potion: HOT (Heal Over Time) ตาม turns
   - Equipment affix: `+N hp_regen` หรือ `+N energy_regen` ต่อ turn
   - Item ใน inventory บางชนิด: passive regen ตราบที่อยู่ใน inventory

```gdscript
# RegenManager.gd
func apply_passive_regen(delta: float) -> void:
    # inventory passive
    for item in player.inventory:
        if item.has_meta("passive_hp_regen"):
            player.hp = min(max_hp, player.hp + item.passive_hp_regen × delta)
        if item.has_meta("passive_energy_regen"):
            player.energy = min(max_energy, player.energy + item.passive_energy_regen × delta)
```

---

### Win Rewards
- **ไม่มี Gold drop จาก monster** — Gold ได้จาก:
  - กล่องสมบัติ (Treasure Chest) — drop บนพื้นจากศัตรู หรือขุดพบจากระบบล่าสมบัติ (§42)
  - ถุงเงิน (Money Bag) ที่ศัตรู "ทำหล่น" ไว้ในแผนที่ (world object)
  - ถุงเงิน drop จาก **ผู้เล่นคนอื่น** ในกรณีต่อไปนี้ (multiplayer เท่านั้น):
    - หนีการต่อสู้ **สำเร็จ** แต่ผลเต๋าติดลบ (dice result 1-8) → drop gold บางส่วนจากที่ถือ
    - หนีการต่อสู้ **ล้มเหลว** → drop gold บางส่วนจากที่ถือ
    - ตายใน field map → drop gold บางส่วนจากที่ถือ
    ```
    # จำนวน gold ที่ drop (ไม่ drop ของใน inventory)
    flee_success_loot (dice ลบ) : gold × rand(1-5)%
    flee_fail_loot               : gold × rand(1-10)%
    death_loot                   : gold × 20%

    # ถุงเงินอยู่บนพื้น 5 นาที แล้วหาย
    # ใครก็เก็บได้ — ไม่ผูกกับ player คนใด
    # Offline character / Solo server: ไม่มี rule นี้
    ```
  - ขาย item กับ NPC
- Item drop: สุ่มจาก `camp.item_drop_pool` (1-9 items, Unidentified)
- Capture: กดได้ทันทีเมื่อปุ่มแสดงขึ้นมา (enemy HP < 10%) (ดู §9)

---

### Combat Schema (schema_combat_v1.sql)
```sql
CREATE TABLE combat_sessions (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  player_id         UUID NOT NULL REFERENCES players(id),
  camp_id           UUID NOT NULL REFERENCES tower_camps(id),
  enemy_name        TEXT NOT NULL,
  status            TEXT NOT NULL DEFAULT 'active',
  player_hp_start   INTEGER NOT NULL,
  player_hp_end     INTEGER,
  player_en_start   INTEGER NOT NULL,
  player_en_end     INTEGER,
  enemy_hp_start    INTEGER NOT NULL,
  enemy_hp_end      INTEGER,
  turns_taken       INTEGER NOT NULL DEFAULT 0,
  items_dropped     UUID[],
  started_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  ended_at          TIMESTAMPTZ
);

CREATE TABLE combat_action_log (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  session_id      UUID NOT NULL REFERENCES combat_sessions(id) ON DELETE CASCADE,
  turn_number     INTEGER NOT NULL,
  actor           TEXT NOT NULL,
  action_type     TEXT NOT NULL,
    -- 'attack'/'attack_miss'/'skill'/'item'/'flee_attempt'/'flee_success'/'capture_attempt'
  skill_node_id   UUID REFERENCES skill_nodes(id),
  item_id         UUID REFERENCES items(id),
  damage_dealt    INTEGER,
  damage_received INTEGER,
  is_crit         BOOLEAN NOT NULL DEFAULT FALSE,
  is_miss         BOOLEAN NOT NULL DEFAULT FALSE,
  hp_after        INTEGER NOT NULL,
  energy_after    INTEGER NOT NULL,
  dice_roll       INTEGER,    -- ผลเต๋า (ถ้า flee/capture)
  logged_at       TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_combat_log_session ON combat_action_log (session_id, turn_number);
```

---

## 5. ระบบ Gacha

### Concept
สุ่ม **item** เท่านั้น — ไม่มีตัวละคร
Item categories ที่สุ่มได้: `skill_node / weapon / armor / rune / ore`

### Banner
Phase 1 มี 1 banner: **ประตูแห่งศรัทธา** (ธีม band 1 ไทย)
Phase 2+ เพิ่ม event banner (limited time) และ standard banner

### Rarity Weights
| Rarity | Weight | % |
|---|---|---|
| common | 45 | 45.00% |
| uncommon | 25 | 25.00% |
| rare | 18 | 18.00% |
| epic | 9 | 9.00% |
| legendary | 2.7 | 2.70% |
| mythic | 0.3 | 0.30% |

### Pity System
- Pull counter เพิ่มทุก pull
- ที่ pull ที่ **50**: การันตี `epic+` (reset counter)
- ได้ epic/legendary/mythic ก่อน 50: reset counter
- Pity เก็บแยกตาม banner และ player

### Cost
| Action | ราคา |
|---|---|
| Pull ×1 | 💎 100 gems |
| Pull ×10 | 💎 900 gems (ลด 10%) |

### Pull Algorithm
```gdscript
func do_pull(player_id, banner_id, count) -> Array:
    var results = []
    var pity = get_pity(player_id, banner_id)
    var pool = get_banner_pool(banner_id)

    for i in count:
        pity += 1
        var rarity

        if pity >= 50:
            rarity = weighted_random({"epic":70,"legendary":25,"mythic":5})
            pity = 0
        else:
            rarity = weighted_random(RARITY_WEIGHTS)
            if rarity in ["epic", "legendary", "mythic"]:
                pity = 0

        var rarity_pool = pool.filter(func(item): return item.rarity == rarity)
        var item = rarity_pool.pick_random()
        results.append(item)

    save_pity(player_id, banner_id, pity)
    add_to_inventory(player_id, results)
    log_pulls(player_id, banner_id, results)
    return results
```

### Duplicate Handling
- Weapon / Armor: duplicate → เก็บเป็น `refine material` (ใช้ refine ตัวที่มีอยู่)
- Skill node: duplicate → เก็บเป็น quantity (ใช้ปลดล็อก node บน tree)
- Rune / Ore: stackable, quantity เพิ่ม

---

## 6. Passive Skill Tree

### Concept
Graph-based web, ปลดล็อกออกจาก center node
ไม่มีการ reset (permanent) — เลือกสายได้หลายสาย

### โครงสร้าง Tier
```
           [Ascension - Tier 5]  ← Divinity EXP +200 (ไม่ได้ +1 divinity โดยตรง)
          /
    [Tier 4] ← ต้องการ divinity_level ≥ 3, item พิเศษ
     /
[Tier 3] ← rare item
 /
[Tier 2] ← uncommon skill_node item
 /
[Tier 1] ← ง่าย, gold เท่านั้น
 /
[Center] ← ปลดล็อกอัตโนมัติ
```

### Unlock Conditions
1. **ต้องมี adjacent node ที่ unlock แล้ว** (graph traversal)
2. **มี gold เพียงพอ**
3. (tier 2+) **มี skill_node item ที่ตรง rarity**
4. (tier 4) **divinity_level ≥ 3**
5. (tier 5 legendary) **divinity_level ≥ 4**
6. (tier 5 mythic) **divinity_level ≥ 8**

### Unlock Cost Table
| Tier | Rarity | Gold cost | Item ที่ต้องใช้ |
|---|---|---|---|
| 1 | common | 200 | ไม่ต้องการ |
| 2 | uncommon | 600 | skill_node (uncommon) ×1 |
| 3 | rare | 1,500 | skill_node (rare) ×1 |
| 4 | epic | 4,000 | skill_node (epic) ×1 |
| 5 (legendary) | legendary | 10,000 | skill_node (legendary) ×1 |
| 5 (mythic) | mythic | 25,000 | skill_node (mythic) ×1 |

### Ascension Node Effects
Ascension node (tier 5) ให้ทั้ง stat bonus **และ** special passive:
- อัคคีเทพบุตร: Fire +100%, All DMG +30% | เมื่อ HP < 30% → Fire DMG +50%
- นาคเทพบุตร: Ice +100%, HP +50% | ทุกโจมตี 20% ชะลอศัตรู
- วัชรเทพบุตร: Lightning +100%, SPD +50% | ทุก Crit ชาร์จ lightning gauge
- ทวยเทพบุตร (mythic): All DMG +50%, Crit +15%, Crit DMG +50% | กลายเป็นเทพปกรณัม

### Skill Web Renderer (Godot)
```gdscript
# SkillWebRenderer.gd — วาดใน _draw()
func _draw():
    # edges ก่อน
    for edge in edges:
        var node_a = nodes[edge.a]
        var node_b = nodes[edge.b]
        var color = GOLD if (node_a.unlocked and node_b.unlocked) else DIM
        var width = 2.0 if color == GOLD else 0.8
        draw_line(node_a.pos, node_b.pos, color, width)

    # nodes ทับ
    for node in nodes.values():
        var pos = node.pos  # normalized (-1..1) → canvas coords
        var radius = [14, 10, 10, 11, 13][node.tier - 1]
        var col = RARITY_COLOR[node.rarity]
        var fill = col if node.unlocked else (Color(col, 0.25) if node.available else PANEL)
        draw_circle(pos, radius, fill)
        draw_arc(pos, radius, 0, TAU, 32, col if node.unlocked else DIM, 1.5)
```

---

## 7. ระบบ Equipment

### Equipment Slots
```
weapon_main   (มือหลัก)  — อาวุธมือเดียว หรือ อาวุธสองมือ
weapon_off    (มือรอง)   — อาวุธมือเดียว หรือ โล่ (ว่างถ้าใช้อาวุธสองมือ)
armor_head    (1 slot)
armor_chest   (1 slot)
armor_legs    (1 slot)
armor_feet    (1 slot)
accessory     (2 slots)
```

### Weapon Types

**อาวุธมือเดียว (One-Handed)** — ถือได้ทั้งมือหลักและมือรอง
| Class | Stat หลัก | Bonus พิเศษ |
|---|---|---|
| sword | ATK | SPD |
| dagger | ATK | CRIT_DMG |
| wand | ATK | elemental DMG (FIRE/ICE/LIGHTNING — ใช้กับ monster และ player ทั้งคู่) |
| mace | ATK | DEF pierce |
| crossbow | ATK | CRIT_RATE |
| shield | DEF | HP (มือรองเท่านั้น) |

**อาวุธสองมือ (Two-Handed)** — ครอง weapon_main + weapon_off พร้อมกัน
| Class | Stat หลัก | Bonus พิเศษ |
|---|---|---|
| polearm | ATK ×1.5 | FIRE_DMG |
| greatsword | ATK ×1.6 | ALL_DMG |
| bow | ATK ×1.3 | CRIT_RATE |
| staff | ATK ×1.2 | elemental DMG ×2 (FIRE/ICE/LIGHTNING — ใช้กับ monster และ player ทั้งคู่) |
| catalyst | ATK ×1.1 | ALL_DMG + SPD |

### Dual-Wield & Cross-Set Pairing

อาวุธมือเดียว **drop เดี่ยวเสมอ** ไม่มี drop เป็นคู่
ผู้เล่นจับคู่ได้อิสระ — ข้าม set ได้:

```
ตัวอย่างที่ valid:
  มือหลัก: sword "ดาบเทพ"  + มือรอง: shield "โล่อสูร"    ← ข้าม set
  มือหลัก: dagger "มีดพราน" + มือรอง: wand "คฑาไฟ"      ← ข้าม set
  มือหลัก: mace "กระบองนาค" + มือรอง: mace "กระบองวายุ" ← dual mace
```

**Set Bonus** — ถ้า weapon_main + weapon_off เป็น set เดียวกัน:
```
set_bonus ปลดล็อกทันทีเมื่อครบคู่:
  เช่น ดาบ + โล่ ชุด "อัคนีวรรณ":
    HP +200, Fire DMG +15%, Skill พิเศษ "เปลวโล่" (active skill ใหม่)
```

### Armor Set Bonus
armor 2 ชิ้น / 3 ชิ้น / 4 ชิ้น (head+chest+legs+feet) จาก set เดียวกัน:
```
2-piece: stat bonus เล็กน้อย (เช่น DEF +10%)
3-piece: stat bonus ปานกลาง (เช่น HP +15%, HP regen +2)
4-piece: stat bonus ใหญ่ + skill พิเศษ (passive หรือ active)
```
Accessory set: 2 ชิ้น → set bonus เช่นกัน

### Random Affix System

**ทุก item ที่ equip ได้** มี affix สุ่ม 1-3 ตัว เมื่อ identify แล้ว

> **หมายเหตุสำคัญ:** Affix สุ่มแยกอิสระจาก Set Bonus — item ชิ้นเดียวกันใน set เดียวกัน
> เมื่อ drop คนละครั้งจะได้ affix ที่แตกต่างกันเสมอ
> เช่น ดาบ "อัคนีวรรณ" ชิ้นที่ 1 อาจได้ Vampiric ส่วนชิ้นที่ 2 อาจได้ Brittle
> Set Bonus (stat/skill พิเศษ) ยังคงเหมือนกันทุกชิ้น — เฉพาะ affix เท่านั้นที่ต่างกัน

```
Affix tier ตาม rarity ของ item:
  common:    1 affix (minor buff เท่านั้น)
  uncommon:  1-2 affix (buff หรือ minor debuff)
  rare:      2 affix (buff + อาจมี debuff)
  epic:      2-3 affix (buff ใหญ่ + อาจมี significant debuff)
  legendary: 3 affix (powerful buff + อาจมี major debuff)
  mythic:    3 affix + 1 unique affix (game-changing effect)
```

**ตัวอย่าง Affix Pool:**

| Affix | ประเภท | Effect |
|---|---|---|
| Vampiric | Buff | lifesteal 5-15% |
| Swift | Buff | SPD +5-20 |
| Fortified | Buff | DEF +5-25 |
| Blazing | Buff | FIRE_DMG +10-40% |
| Brittle | Debuff | DEF -5-15 |
| Cursed Weight | Debuff | SPD -5-10 |
| Fragile | Debuff | Durability -30% (ดู Durability) |
| Soul Link | Unique | HP เพิ่มตาม Energy ที่เหลือ |
| Unbreakable | Unique | ซ่อมไม่ได้ แต่ Durability ไม่ลด |
| Soulbound | Unique | ขายไม่ได้ trade ไม่ได้ แต่ stat ×1.5 |

**Affix "ซ่อมไม่ได้"** — affix `Unbreakable` = ไม่เสื่อม แต่ `Fragile` = ซ่อมไม่ได้ (หักแล้วทิ้ง)

### Durability System

**ทุก weapon, armor, accessory มี Durability:**

```
max_durability ตาม rarity:
  common:    30
  uncommon:  50
  rare:      80
  epic:      120
  legendary: 180
  mythic:    250

Durability ลดเมื่อ:
  **Weapon** — ลดเฉพาะเมื่อ hit โดน (ถ้า miss → ไม่เสื่อม):
    โจมตีโดน (hit)         : -1
    ใช้ skill และ hit โดน  : -1
    โจมตีพลาด / miss        : ±0 (ฟันอากาศ ไม่เสียดสีอะไร)

  **Armor / Accessory** — ลดเฉพาะเมื่อโดน damage จริง:
    รับ damage จาก enemy   : -1 ต่อ hit ที่รับ
    รับ damage = 0 (blocked): ±0
    ไม่ได้ถูกโจมตี         : ±0

  **Enemy-type modifier** — ค่าเสื่อมขึ้นกับประเภทศัตรู:
    Slime / ooze type       : ×0 (ไม่มีค่าเสื่อม — ลำตัวนิ่มไม่ทำลายอาวุธ)
    Normal enemy            : ×1.0
    Armored / stone / boss  : ×1.5 (แข็ง ทำให้อาวุธสึกเร็ว)
    Fire / acid type        : ×2.0 (กัดกร่อน เสื่อมเร็วทั้ง weapon และ armor)
    Mythic / primordial     : ×3.0 (ต้าน durability พิเศษ)

  **ตายใน combat** : -5 ทุก item ที่สวมใส่ (กระแทกพื้น)
```gdscript
func on_weapon_hit(enemy: CombatEntity) -> void:
    var mult = enemy.durability_damage_mult  # ค่าจาก enemy_template
    if mult <= 0: return
    weapon_main.durability -= 1 * mult
    if weapon_off: weapon_off.durability -= 0.5 * mult  # มือรองเสื่อมช้ากว่า

func on_armor_hit(damage_received: int) -> void:
    if damage_received <= 0: return  # blocked ทั้งหมด → ไม่เสื่อม
    for slot in equipped_armor:
        slot.durability -= 1 * attacker.durability_damage_mult
```

ผลเมื่อ Durability ต่ำ:
  50% → stat ลด 10%
  25% → stat ลด 25%
  0%  → item หยุดทำงาน (unequip บังคับ) — ซ่อมก่อนใช้ได้
```

**ซ่อม Durability:**
- ที่ **Blacksmith NPC** ใน Hub: จ่าย gold ตามสัดส่วนที่หาย
  Blacksmith มีหลายระดับ ความสามารถและค่าใช้จ่ายต่างกัน:

  | ระดับ | ซ่อมได้ (rarity สูงสุด) | ค่าซ่อม (per durability) | พบที่ |
  |---|---|---|---|
  | ช่างฝึกหัด | common / uncommon | 8 gold | Band 1 Hub |
  | ช่างฝีมือ | rare | 15 gold | Band 2-3 Hub |
  | ช่างเชี่ยวชาญ | epic | 30 gold | Band 4-5 Hub |
  | ช่างเทพ | legendary / mythic | 60 gold | Band 6 Hub |

  ```
  repair_cost = (max_durability - current_durability) × cost_per_point × rarity_multiplier
  rarity_multiplier: common=1.0 / uncommon=1.2 / rare=1.5 / epic=2.0 / legendary=3.0
  ```

  ช่างระดับต่ำ **ปฏิเสธซ่อม** item ที่ rarity เกินความสามารถ → ต้องหา Hub Band สูงกว่า

- **ผู้เล่นซ่อมเองได้** ด้วย `repair` proficiency + Workbench/Forge (ดู §27 — ซ่อมได้บางส่วนขึ้นกับ level)
- ด้วย **Repair Kit** item (craftable, มี rarity): ซ่อมได้ทุกที่
  ```
  Repair Kit rarity → ซ่อม durability ได้ต่างกัน (ที่ repair skill = 100):
    common    : ซ่อมได้ 25% ของ max_durability
    uncommon  : ซ่อมได้ 50%
    rare      : ซ่อมได้ 75%
    epic      : ซ่อมได้ 100% (เต็ม)
    legendary : ซ่อมได้ 100% + ทนทานขึ้น max_durability +10% ถาวร

  ผลจริง = kit_repair_pct × (repair_skill_level / 100)
  ตัวอย่าง: Rare Kit (75%) + repair skill 50 → ซ่อมได้จริง 37.5%
  ตัวอย่าง: Epic Kit (100%) + repair skill 100 → ซ่อมได้จริง 100% (เต็ม)

  repair skill level 0 → Repair Kit ใช้ไม่ได้เลย (ไม่รู้จะซ่อมอย่างไร)
  ต้องมี repair skill ≥ 1 ถึงจะใช้ Kit ได้
  ```
- item ที่มี affix `Fragile` หรือ `Unbreakable` ตามที่ affix กำหนด

```
repair_cost = (max_durability - current_durability) × item_rarity_multiplier × 10 gold
```

### Equip Formula (รวมใน calcStats)
```
effective_atk = base_atk
              + weapon_main.base_atk + weapon_off.base_atk (ถ้ามี)
              + Σ(equip affix atk bonuses)
              + Σ(node atk bonuses)
              + set_bonus.atk (ถ้าครบ set)

effective_def = base_def
              + Σ(armor.base_def)
              + Σ(equip affix def bonuses)
              + Σ(node def bonuses)
              + set_bonus.def

# durability penalty คูณหลังสุด:
if durability_pct < 0.5:
    effective_atk × (1 - durability_penalty)
    effective_def × (1 - durability_penalty)
```

### Schema เพิ่มเติม (schema_core_v2.sql)
```sql
ALTER TABLE player_items ADD COLUMN IF NOT EXISTS
    durability        INTEGER,          -- null = item ไม่มี durability (consumable)
    max_durability    INTEGER,
    is_repairable     BOOLEAN NOT NULL DEFAULT TRUE,
    affixes           JSONB DEFAULT '[]';
    -- [{id, type, value, is_buff}]

ALTER TABLE player_equipment ADD COLUMN IF NOT EXISTS
    weapon_main_id  UUID REFERENCES player_items(id),
    weapon_off_id   UUID REFERENCES player_items(id);
    -- แยก main/off hand ชัดเจน
```

---


## 8. ระบบ Upgrade & Refine

### Design Principle
Upgrade/Refine ใช้ **random chance เป็นพื้นฐาน** ปรับด้วย resource
Minigame เป็น **optional** เพิ่ม chance ได้แต่ไม่บังคับ
มี **Guarantee Item** สำหรับการันตีความสำเร็จ

**โอกาสล้มเหลวมี 3 ระดับ** แต่ละ attempt จะ roll ผลก่อน จากนั้น roll penalty tier:

| Roll ผล | Penalty Tier | โอกาสเกิด |
|---|---|---|
| สำเร็จ | — | ตาม success rate |
| ล้มเหลวธรรมดา | Tier 1 — resource หาย | 60% ของโอกาสล้มเหลว |
| ล้มเหลวหนัก | Tier 2 — resource หาย + level ลด 1 | 30% ของโอกาสล้มเหลว |
| ล้มเหลวร้ายแรง | Tier 3 — resource หาย + item เสียหายหนัก | 10% ของโอกาสล้มเหลว |

```
ตัวอย่าง: refine 3→4 (base 55%), roll ได้ fail:
  Tier 1 (60%): ore หาย, level ไม่เปลี่ยน
  Tier 2 (30%): ore หาย, refine ลงเป็น 2
  Tier 3 (10%): ore หาย, refine ลงเป็น 2, durability -30%
```

> Guarantee Stone ข้ามทุก penalty tier — success เสมอ (ดู §8D)

### 8D — Guarantee Item (ใหม่)

**Guarantee Stone** — item พิเศษที่การันตีความสำเร็จ 100% ไม่ว่า base rate จะเป็นเท่าไหร่

| Item | Rarity | ใช้กับ | drop จาก |
|---|---|---|---|
| หินแห่งศรัทธา | Uncommon | Skill Node upgrade lv 1-2 | Boss Band 1, gacha |
| หินแห่งพลัง | Rare | Skill Node upgrade lv 3-4, Refine 1-2 | Boss Band 2-3, gacha |
| หินแห่งเทพ | Epic | Skill Node upgrade lv 5, Refine 3-4 | Boss Band 4-5, gacha |
| หินแห่งปฐมกาล | Legendary | ทุก upgrade/refine ทุก level | Boss Band 6, Eternal drop |
| หินทวยเทพ | Mythic | ทุก upgrade/refine + bonus +1 level free | Eternal Marketplace เท่านั้น |

```
ใช้ Guarantee Stone:
  success_rate = 100% (ข้ามการคำนวณ chance ทั้งหมด)
  ไม่จำเป็นต้องเล่น minigame
  resource อื่น (rune/ore) ยังต้องใช้ตามปกติ
  ต้องมี `upgrade` skill level เพียงพอสำหรับ rarity ของ item นั้น
    (Guarantee Stone การันตี "สำเร็จ" แต่ไม่ข้าม skill requirement)
    เช่น ใช้ หินแห่งเทพ (epic) upgrade legendary item → ต้องมี upgrade ≥ 65

หินทวยเทพ (Mythic):
  success + bonus: upgrade 1 level เพิ่มฟรีโดยไม่ใช้ resource เพิ่ม
  เช่น refine 3→4 สำเร็จ + refine 4→5 ฟรีโดยอัตโนมัติ

Guarantee Stone มี rarity → ปลดล็อก recipe ใน Alchemy ได้บางส่วน:
  หินแห่งศรัทธา: craft ได้ที่ Alchemy lv 25 (Herb ×10 + Rune ×5 + Gold 500)
  หินแห่งพลัง+: craft ไม่ได้ — ต้อง drop หรือซื้อ Marketplace
```

### 8A — Skill Node Upgrade
Skill node ที่ปลดล็อกแล้วสามารถ **upgrade level** ได้ (เพิ่ม stat bonus)

#### Upgrade Level
- Node มี upgrade level 0-5
- แต่ละ level เพิ่ม stat bonus 20%
- Level 5 = bonus ×2 ของ base

#### Upgrade Mechanic
```
ต้องการ:
  - rune ตรง element ×N   (หลัก)
  - gold ×M               (ค่าดำเนินการ)

base_success_rate = 100% สำหรับ level 0→1
                  = 80%  สำหรับ level 1→2
                  = 60%  สำหรับ level 2→3
                  = 40%  สำหรับ level 3→4
                  = 20%  สำหรับ level 4→5

rate_boost ทำได้โดย:
  +10% ต่อ rune พิเศษ (uncommon rune ×1)
  +20% ต่อ rune ระดับ (rare rune ×1)
  +30% ต่อ minigame สำเร็จ

ถ้าล้มเหลว (roll penalty tier):
  Tier 1 (60%): rune หายหมด, node ไม่เปลี่ยน, gold หายครึ่ง
  Tier 2 (30%): rune หายหมด, node ลด 1 level, gold หายทั้งหมด
  Tier 3 (10%): rune หายหมด, node ลด 1 level, gold หายทั้งหมด + burn rune พิเศษที่ใช้ด้วย (ถ้ามี)
```

### 8B — Weapon / Armor Refine
Equipment refine เพิ่ม stat ตาม `item_stats.per_refine`

#### Refine Mechanic
```
ต้องการ:
  - ore (เหล็กดำ / มหาสิทธิ์) ×N ตาม rarity
  - duplicate item เดิม ×1 (เป็น catalyst) OR
    ore พิเศษ ×2 แทน

base_success_rate = 100% สำหรับ refine 0→1
                  = 90%  สำหรับ 1→2
                  = 75%  สำหรับ 2→3
                  = 55%  สำหรับ 3→4
                  = 35%  สำหรับ 4→5 (max)

rate_boost:
  +15% ถ้าใช้ duplicate เป็น catalyst (แทน ore พิเศษ)
  +25% ต่อ minigame สำเร็จ

ถ้าล้มเหลว (roll penalty tier):
  Tier 1 (60%): ore หายหมด, refine level ไม่เปลี่ยน
  Tier 2 (30%): ore หายหมด, refine level ลด 1, duplicate หาย (ถ้าใช้)
  Tier 3 (10%): ore หายหมด, refine level ลด 1, durability item -20%, duplicate หาย (ถ้าใช้)
```

### 8C — Minigame (Optional Chance Booster)

**Mechanic: Timing Ring**
- วงกลมหดเข้าหา target zone
- กด confirm ตอนอยู่ใน zone → success
- Zone size ขึ้นกับ rarity ของ item ที่ upgrade
  - common/uncommon: zone กว้าง 40°
  - rare: zone 30°
  - epic: zone 20°
  - legendary: zone 12°
  - mythic: zone 8°

```
# ผล minigame
if in_zone:
    bonus_rate += 30%
    if in_inner_zone (zone ใน 50%):
        bonus_rate += 10%  # perfect
else:
    bonus_rate += 0%  # ไม่ได้ bonus แต่ก็ไม่ลด

# minigame เล่นได้ 1 ครั้งต่อ upgrade attempt เท่านั้น
```

**ใน Godot**: `MinigameUpgrade.gd` — วาด ring ด้วย `draw_arc()`, ใช้ `Tween` หมุน indicator

---

## 9. Monster Capture & Bestiary

### Concept
Bestiary คือ **collector feature** แยกจาก combat progression
จับมอนสเตอร์ไว้ดู lore — ไม่ได้นำมาต่อสู้

### Capture Mechanic
ระหว่าง combat: player เลือก action "จับ" (**แทน** action อื่น)

```
capture_chance = base_capture_rate × (1 - enemy_hp_pct) × 2
# ยิ่ง HP ต่ำ ยิ่งจับได้ง่าย
# base_capture_rate มาจาก bestiary_monsters.base_capture_rate (เช่น 0.30)

# ตัวอย่าง:
# enemy HP 80% → chance = 0.30 × (1-0.80) × 2 = 0.12 (12%)
# enemy HP 20% → chance = 0.30 × (1-0.20) × 2 = 0.48 (48%)
# enemy HP 5%  → chance = 0.30 × (1-0.05) × 2 = 0.57 (57%)
```

**ผล capture attempt:**
- สำเร็จ: enemy หายออกจาก field, เพิ่ม bestiary entry, ไม่ได้ gold/drop
- ล้มเหลว (fled): enemy หนีออกจาก field, ไม่ได้ gold/drop
- ล้มเหลว (destroyed): damage ทำให้ HP = 0 ขณะ capture → ตาย, ไม่ได้จับ (กรณีนี้เกิดได้ถ้ามี DoT)

**Action cost**: ใช้ turn (ATB reset)

### Bestiary
- เก็บได้ 1 entry ต่อ 1 monster species
- แต่ละ entry แสดง: ชื่อ, รูป, lore, band, rarity, capture rate, วันที่จับ
- จับครบ monster ใน band → รับ bonus gem

---

## 10. ระบบ Energy

ระบบนี้มี **2 ประเภท Energy ที่แยกกัน:**

| ประเภท | ชื่อ | ใช้ทำอะไร | Base | Regen |
|---|---|---|---|---|
| **World Energy** | ⚡ พลังงานเดินทาง | เข้า camp (travel cost) | 100 | server-side timer |
| **Battle Energy** | 🔋 พลังงานต่อสู้ | Skill / Flee / Capture ใน combat | 10 | per turn + idle |

---

### World Energy (⚡ Travel Energy)

ใช้เมื่อ **เดินเข้า camp** — เป็น resource จำกัดที่ regen ตามเวลาจริง

#### Config (จาก energy_config table)
| Key | Value |
|---|---|
| regen_amount | 1 |
| regen_interval_minutes | 5 |
| base_max_world_energy | 100 |

#### Regen Logic
```
# คำนวณ server-side ทุกครั้งที่ login
elapsed_minutes   = now - player.last_energy_regen (นาที)
regen_ticks       = floor(elapsed_minutes / 5)
energy_gained     = min(regen_ticks × 1, max_world_energy - current_world_energy)
player.world_energy    += energy_gained
player.last_energy_regen = now - (elapsed_minutes % 5 minutes)
```

#### World Energy Cost ตาม Camp Type
| Camp Type | World Energy Cost |
|---|---|
| spawn | 0 |
| normal | 4 |
| elite | 6 |
| mini_boss | 8 |
| checkpoint | 0 |
| boss_gate | 0 |
| boss | 10 |
| resource | 2 |
| mystery | 2 |
| hunting_zone | 5 |
| hub / town | 0 |

> ลดจากเดิม (6/8/10/12 → 4/6/8/10) เพื่อให้ session gameplay ราบรื่นขึ้น
> Eternal Path: ไม่มี World Energy เดินได้อิสระ

---

### Battle Energy (🔋 Combat Energy)

ใช้ใน **ATB combat** — regen ต่อ turn อัตโนมัติ ไม่มี real-time timer

| | |
|---|---|
| Base | 10 (เพิ่มได้จาก equip + nodes) |
| Regen per turn | energy_regen stat (base 0 + equip/nodes) |
| Idle regen (field) | max_energy × 5% / วินาที ที่ไม่ทำกิจกรรม |

ดูรายละเอียดใน §4 (ATB Combat) — Energy cost ต่อ action ครบ

---

### Energy Display (Godot HUD)
```
⚡ [World Energy bar]  84/100  (+1 ใน 3:20)
🔋 [Battle Energy bar] แสดงเฉพาะระหว่าง combat
```

---


## 11. Economy & Progression

### Currency
| Currency | ได้มาจาก | ใช้ทำอะไร |
|---|---|---|
| 💎 Gem | login bonus, achievement, purchase | gacha |
| 🪙 Gold | กล่องสมบัติ, ถุงเงิน, ขาย item กับ NPC, warp fee, marketplace fee | unlock skill node, repair, upgrade/refine, warp, NPC services |

---

### Gold Income Sources (ทุกช่องทาง)

| แหล่งรายได้ | Gold ต่อครั้ง | ความถี่ | หมายเหตุ |
|---|---|---|---|
| ขาย item (common) กับ NPC | 20-80 | drop 1-9 ต่อ combat | ราคาขึ้นกับ `trading` skill |
| ขาย item (uncommon) | 100-300 | ต่อ drop | — |
| ขาย item (rare+) | 500+ | หายาก | — |
| กล่องสมบัติ (random spot) | 50-1,000 | floor ละ 2-5 จุด/24h | tier ตาม floor depth |
| ถุงเงินใน field map | 30-200 | spawn random | world object |
| ถุงเงิน drop จาก player | rand(1-20)% of target gold | multiplayer เท่านั้น | flee fail / ตาย |
| ขาย item ใน Eternal Marketplace | ตามราคาตลาด - 5% fee | Eternal Path เท่านั้น | gold จำนวนมาก |
| warp fee (ของ player อื่นผ่าน Gate) | 50% ของ warp cost | passive | เข้า Town Treasury |
| quest reward | 100-5,000 | ต่อ quest | ตาม tier |
| Town Treasury donation | — | — | ไม่ได้รับ gold กลับ |

**ประมาณการ income ต่อ session (~30 นาที):**
```
ขาย item จาก combat 5 ครั้ง (avg 3 items/combat, avg 60g/item):
  = 5 × 3 × 60 = 900 gold

กล่องสมบัติ / ถุงเงิน (avg):
  = 150 gold

Quest reward (ถ้ามี):
  = 0-500 gold

รวม: ~1,000-1,550 gold/session
```

---

### Gold Sink (รายจ่าย)

**หลักการ:** gold ต้องมี "รูรั่ว" หลายจุด ป้องกัน inflation
ผู้เล่นที่ progress เร็วจะใช้ gold เร็วกว่าหาได้ — ทำให้ gold มีคุณค่าตลอด

| รายจ่าย | ราคา | บังคับหรือเลือกได้ |
|---|---|---|
| Unlock skill node tier 1 | 200 gold | เลือกได้ |
| Unlock skill node tier 2 | 600 gold | เลือกได้ |
| Unlock skill node tier 3 | 1,500 gold | เลือกได้ |
| Unlock skill node tier 4 | 4,000 gold | เลือกได้ |
| Unlock skill node tier 5 | 10,000-25,000 gold | เลือกได้ |
| Repair equipment (ที่ Blacksmith) | 80-3,000+ gold ต่อ item | บังคับ (ถ้าไม่ใช้ Kit) |
| Upgrade/Refine resource cost | gold ×M ต่อ attempt | เลือกได้ |
| Warp ผ่าน Gate Keeper | 50 gold/ครั้ง | เลือกได้ |
| Identify item ที่ Blacksmith | 30-250 gold/item | เลือกได้ |
| NPC service (Nurse รักษา) | 200 gold/ครั้ง | เลือกได้ |
| ซื้อ item จาก NPC Merchant | ตามราคา | เลือกได้ |
| จ่ายค่าปรับ (ล้าง Bounty) | bounty × 1.5 | บังคับ (ถ้าต้องการล้าง) |
| Band Travel (Gate Keeper) | 50-10,800 gold EXP (Divinity) | บังคับ (ถ้าต้องการข้าม) |
| Building materials | ตาม recipe | เลือกได้ |
| Stash expansion | 500 gold / +10 slots | เลือกได้ |

**Gold Sink ที่ถาวร (burn ไม่กลับ):**
- Skill node unlock → gold หายถาวร
- Warp fee → 50% เข้า Town Treasury, 50% burn
- NPC service → burn ทั้งหมด
- ค่าปรับ Bounty → burn ทั้งหมด
- Marketplace listing fee (5%) → burn

---

### Inflation Control Mechanisms

**1. Repair Loop (mandatory sink)**
Equipment เสื่อมจาก combat ตามเงื่อนไข:
- Weapon เสื่อมเฉพาะเมื่อ **hit โดน** (miss ไม่เสื่อม)
- Armor เสื่อมเฉพาะเมื่อ **รับ damage จริง** (ถ้า DEF สูงจน damage = 0 ไม่เสื่อม)
- Enemy type กระทบ: Slime ×0, Normal ×1.0, Stone/Boss ×1.5, Acid/Fire ×2.0
- ยิ่งเล่นมาก ยิ่ง repair บ่อย → gold ออกสม่ำเสมอ

**2. Item Sell Price Scaling**
NPC ซื้อ item ราคา **ต่ำกว่าจริง** เสมอ (ขึ้นกับ trading skill 70-100%)
ทำให้ inflation จาก sell ถูก cap

**3. Band Travel Cost (Divinity sacrifice)**
ข้าม Band ใช้ Divinity EXP ไม่ใช่ gold โดยตรง → gold sink อีกทางผ่าน resource ที่ใช้ในขั้นตอน

**4. Time-Gated Restock**
NPC Merchant restock บาง item ทุก N วันเกม
สร้าง demand-side pressure โดยไม่ต้องเพิ่ม supply

**5. Server-Level Tax (Town Treasury)**
50% ของ warp fee และ 50% ของ marketplace fee เข้า Treasury โดยอัตโนมัติ
Treasury ใช้จ่ายเพื่อ upgrade Guard, Hospital ฯลฯ — เป็น passive gold burn

---

### Gold Balance Simulation (Phase 1, Band 1)

```
ผู้เล่นใหม่ (0-50 ชั่วโมง playtime):
  Income:  ~1,200 gold/session × 2 session/วัน = 2,400 gold/วัน
  Expense: unlock tier 1-2 nodes (~5,000 gold รวม)
           repair equipment (~300 gold/วัน)
           warp (50 gold × 5 ครั้ง = 250 gold/วัน)
  Net:     ~1,850 gold/วัน (สะสมได้ goal ใน 3 วัน)

ผู้เล่น mid-game (Band 2-3):
  Income:  ~2,500 gold/session (item ราคาสูงขึ้น)
  Expense: unlock tier 3-4 nodes (~20,000 gold รวม)
           repair epic equipment (~1,000 gold/วัน)
           upgrade attempts (~500 gold/attempt)
  Net:     ~3,500 gold/วัน (goal ใน 5-6 วัน)

ผู้เล่น late-game (Band 4-6):
  Income:  ~5,000+ gold/session + Eternal Marketplace
  Expense: tier 5 ascension (~20,000-50,000 gold)
           legendary repair (2,000+ gold/item)
           Band travel costs
  Net:     ตึงตัว — gold มีคุณค่า ไม่ overflow
```

---

### NPC Merchant — Item Catalog & Restock

ออกแบบ NPC Merchant ให้มี **base catalog** ที่ซื้อได้เสมอ และ **rotating stock** ที่เปลี่ยนตามฤดู/วัน:

**Base Catalog (ซื้อได้เสมอ):**
| Item | ราคา | หมายเหตุ |
|---|---|---|
| HP Potion (common) | 80 gold | ฟื้น HP แบบ HOT |
| Energy Potion (common) | 60 gold | ฟื้น battle energy |
| Escape Smoke | 150 gold | +60% flee chance |
| Repair Kit (common) | 200 gold | ซ่อม 25% × skill |
| Scroll of Revelation | 300 gold | identify 1 item |
| Basic Fertilizer | 100 gold | grow time -15% |
| Animal Feed (generic) | 50 gold | happiness +10 |

**Rotating Stock (restock ทุก 3 วันเกม — ตามฤดูกาล):**
- ฤดูต่างกัน → stock ต่างกัน (seed ฤดูร้อน, เหยื่อปลาฤดูฝน ฯลฯ)
- ราคา rotating stock สูงกว่า base 20-50%
- จำนวนจำกัดต่อ restock (ป้องกันซื้อกักตุน)

**Schema (schema_npc_v1.sql เพิ่ม):**
```sql
CREATE TABLE merchant_catalog (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  band_number     INTEGER NOT NULL,
  item_id         UUID NOT NULL REFERENCES items(id),
  buy_price       INTEGER NOT NULL,
  stock_type      TEXT NOT NULL DEFAULT 'base',  -- 'base' / 'rotating'
  season_filter   TEXT,          -- null = ทุกฤดู / 'hot','rain','cold' ฯลฯ
  stock_qty       INTEGER,       -- null = ไม่จำกัด
  restock_days    INTEGER,       -- จำนวนวันเกมก่อน restock
  last_restock_at TIMESTAMPTZ
);

CREATE TABLE player_merchant_purchases (
  player_id    UUID NOT NULL REFERENCES players(id),
  catalog_id   UUID NOT NULL REFERENCES merchant_catalog(id),
  qty_bought   INTEGER NOT NULL DEFAULT 0,
  restock_date DATE NOT NULL,
  PRIMARY KEY (player_id, catalog_id, restock_date)
);
```

---

### Gem Income & Gacha Rate

**Gem income:**
| แหล่ง | Gem | ความถี่ |
|---|---|---|
| Login bonus | 10 | ทุกวัน |
| Quest (daily) | 5-20 | ทุกวัน |
| Quest (weekly) | 30-80 | ทุกสัปดาห์ |
| Achievement | 50-200 | ครั้งเดียว |
| Band clear (first) | 200 | ครั้งเดียว ×6 band |
| Seasonal Event | 50-100 | ต่อ event |
| Purchase | ซื้อได้ | — |

**ประมาณ F2P gem per month:**
```
Login: 10 × 30 = 300
Daily quest: avg 10 × 30 = 300
Weekly quest: avg 50 × 4 = 200
Achievement (แรก 30 วัน): ~500
รวม: ~1,300 gem/month ≈ 13 pulls/month
pity 50 pulls → การันตี epic+ ≈ 3.8 เดือน F2P
```

**Gacha rate:**
```
pity 50 → การันตี epic+
  roll: epic 70%, legendary 25%, mythic 5%
base rate epic: 9%, legendary: 2.7%, mythic: 0.3%
```

---

### Progression Gating

**Floor unlock ภายใน Band (individual):** clear boss floor ก่อนหน้า
**Band unlock (server-wide):** ผู้เล่นคนใดคนหนึ่งใน server kill boss band ครั้งแรก

| Milestone | เงื่อนไข |
|---|---|
| Floor 2-9 ภายใน Band 1 | individual: clear boss floor ก่อนหน้า |
| Band 2 (floor 10-19) | server-wide: มีผู้เล่น kill Boss Floor 9 ครั้งแรก |
| Band 3 (floor 20-29) | server-wide: มีผู้เล่น kill Boss Floor 19 ครั้งแรก |
| Band 4-6 | server-wide: ตามลำดับ boss floor 29/39/49 |
| Skill node tier 3 | divinity_level ≥ 2 |
| Skill node tier 4 | divinity_level ≥ 3 |
| Ascension Node (legendary) | divinity_level ≥ 4 |
| Ascension Node (mythic) | divinity_level ≥ 8 |
| Hunting Zone access | divinity_level ≥ 2 |
| Eternal Marketplace | divinity_level ≥ 7 + Eternal Path character |
| Band 6 (endgame) | server-wide unlock + divinity_level ≥ 10 (ผู้เล่นแต่ละคน) |

---

## 12. Auth & Save

### Auth Strategy

รองรับ **3 โหมด** ตามบริบทการเล่น:

| โหมด | Login ต้องการ | ใช้กับ | Character slot |
|---|---|---|---|
| **Offline** | ❌ ไม่ต้อง | Solo / Friend Session (host) | Local file เท่านั้น |
| **Guest** | ❌ ไม่ต้อง | Official Server (ทดลองเล่น) | Cloud ชั่วคราว (anonymous) |
| **Account** | ✅ Username + Password | Official Server (เต็ม) | Cloud ถาวร |

---

#### A — Offline Mode
ไม่ต้องสมัครหรือ login — เล่นได้ทันที
บันทึกใน local file, ไม่สามารถเข้า Official Server ได้

#### B — Guest Mode (ใหม่)
เล่น Official Server ได้โดยไม่ต้องสมัคร — ระบบสร้าง **anonymous session** ให้อัตโนมัติ

```
ผู้เล่นกด "เข้าเล่นทันที" ที่ Main Menu
  ↓
ระบบสร้าง anonymous_id (UUID) + guest token เก็บใน user://session.cfg
  ↓
สร้าง guest character ได้ 1 slot (ชื่อ "ผู้ท้าชิง" ชั่วคราว)
  ↓
เล่น Official Server ได้ทันที (จำกัดบางฟีเจอร์)
```

**ข้อจำกัด Guest:**
| ฟีเจอร์ | Guest | Account |
|---|---|---|
| เล่น Official Server | ✅ | ✅ |
| Friend Session | ❌ | ✅ |
| Eternal Marketplace | ❌ | ✅ |
| Hall of Fame | ❌ บันทึกไม่ได้ | ✅ |
| Character slots | 1 slot เท่านั้น | 3 slots |
| Progress ถาวร | ⚠ ผูกกับ device | ✅ cloud |

**ผูกบัญชีในภายหลัง (Account Linking):**
```
Guest → เล่นไปสักพัก → เลือก "ผูกบัญชี" ใน Settings
  ↓
เลือกวิธีผูกบัญชี:
  ├── Username + Password (สมัครใหม่)
  ├── Google
  ├── Facebook
  ├── Steam
  └── บัญชีทางการอื่นๆ (Apple, Discord ฯลฯ)
  ↓
ระบบ migrate: guest_id → account_id
  anonymous session → JWT token
  guest character → account character slot
  progress, inventory, skill tree ย้ายทั้งหมด
  ↓
Guest session บน device เดิมหายไป — ใช้ account แทน
```

**ถ้าไม่ผูกบัญชี:**
- Progress เก็บไว้กับ device — ลบแอป / format = หาย
- ย้าย device ไม่ได้
- แจ้งเตือนในเกม: "บันทึกข้อมูลอาจสูญหาย กรุณาผูกบัญชี"

#### C — Account Mode

รองรับหลาย provider ผ่าน **Supabase Auth**:

| Provider | วิธี | หมายเหตุ |
|---|---|---|
| Username + Password | Supabase email/password | ใช้ username แทน email |
| Google | OAuth 2.0 | Supabase built-in |
| Facebook | OAuth 2.0 | Supabase built-in |
| Steam | OpenID / Steam Web API | Supabase custom OAuth |
| Apple | Sign in with Apple | Supabase built-in |
| Discord | OAuth 2.0 | Supabase built-in |

```
# Godot: เปิด browser / native SDK สำหรับ OAuth
OS.shell_open(supabase_oauth_url)
# รับ callback → extract token → เก็บใน user://session.cfg

# 1 account ผูกได้หลาย provider พร้อมกัน
# เช่น login ด้วย Google หรือ Steam ก็เข้า account เดียวกันได้
```

> **Phase 1:** รองรับ Username+Password + Google ก่อน
> **Phase 2+:** เพิ่ม Steam (จำเป็นถ้า release บน Steam), Facebook, Discord

---

### Auth Flow (Godot)
```
[Main Menu]
    │
    ├── มี saved_session?
    │     ├── Guest token → auto-resume guest session
    │     └── JWT token  → auto-login (refresh token)
    │
    └── ไม่มี session → แสดงตัวเลือก:
          ├── [เล่นออฟไลน์]     → Offline Mode (ไม่ login)
          ├── [เข้าเล่นทันที]   → Guest Mode (สร้าง anonymous session)
          └── [Login / สมัคร]  → Account Mode:
                ├── Username + Password
                ├── [G] Google
                ├── [f] Facebook
                ├── [🎮] Steam
                └── [อื่นๆ] Apple / Discord
```

### Session Management
- JWT / Guest token เก็บใน `user://session.cfg`
- JWT: auto-refresh ทุก 30 นาที
- Guest token: ไม่หมดอายุ แต่ผูกกับ device
- Token หมดอายุ / invalid → redirect to Main Menu

### Schema (schema_character_v1.sql เพิ่ม)
```sql
ALTER TABLE players ADD COLUMN IF NOT EXISTS
    is_guest      BOOLEAN NOT NULL DEFAULT FALSE,
    guest_device_id TEXT,    -- anonymous_id สำหรับ guest
    linked_at     TIMESTAMPTZ;  -- เวลาที่ผูกบัญชี (null = ยังเป็น guest)

-- index สำหรับ guest lookup
CREATE INDEX idx_players_guest ON players (guest_device_id) WHERE is_guest = TRUE;
```

### Save Strategy
- **Online character**: Cloud only — ไม่มี local game save
- **Offline character**: Local file เท่านั้น
- **Guest character**: Cloud anonymous — migrate ไป account ได้

Optimistic UI: update local state ก่อน, rollback ถ้า server error

### Offline Handling
- Offline character → เล่นได้เสมอ ไม่ต้องการ internet
- Online/Guest character → ไม่มี internet → แสดง "ไม่สามารถเชื่อมต่อได้"

---


## 13. Character Creator

### Asset Source
**Sunnyside World** by danieldiggle (https://danieldiggle.itch.io/sunnyside)
- License: ใช้ได้ใน commercial project, ห้าม repackage/resell, ห้ามใช้ train AI
- Credit: ไม่บังคับแต่ควรใส่ใน credits screen

### Concept
ก่อนเข้าเกมครั้งแรก (หลัง register) ผู้เล่นออกแบบหน้าตา "ผู้ท้าชิง" ของตัวเอง
ตัวละครที่สร้างจะใช้ sprite นี้ตลอดเกม — ใน field map, combat, และ UI portrait

**สร้างได้หลายตัวละคร** ต่อ 1 account — เลือก/ลบได้จาก Character Select screen
(เหมือน slot ตัวละครใน MMORPG)

### Character Slots
- 1 account มีได้สูงสุด **3 character slots**
- แต่ละ slot = save file แยกกัน (progression, inventory, skill tree แยกกันหมด)
- ลบตัวละครได้ (ต้อง confirm 2 ครั้ง) — ลบแล้วหายถาวร

---

### Customization Options (จาก Sunnyside assets)

#### A. Hair Style (7 แบบ)
Sunnyside มี 7 hairstyle animated sprites:
| ID | ชื่อ (ใช้ภายใน) | ลักษณะ |
|---|---|---|
| hair_01 | short_straight | สั้นตรง |
| hair_02 | medium_wavy | กลางหยัก |
| hair_03 | long_straight | ยาวตรง |
| hair_04 | ponytail | มัดหาง |
| hair_05 | bun | มวย |
| hair_06 | curly_short | หยิกสั้น |
| hair_07 | shaved | โกน/สั้นมาก |

#### B. Hair Color (palette swap)
8 สีให้เลือก — ใช้ Godot shader palette swap บน hair sprite layer:
| ID | ชื่อ | Hex (source → target) |
|---|---|---|
| hc_black | ดำ | #2c1b0e → #1a1a1a |
| hc_brown | น้ำตาล | #2c1b0e → #5c3317 |
| hc_auburn | น้ำตาลแดง | #2c1b0e → #8b2500 |
| hc_blonde | บลอนด์ | #2c1b0e → #d4a017 |
| hc_grey | เทา | #2c1b0e → #808080 |
| hc_white | ขาว | #2c1b0e → #e8e8e8 |
| hc_blue | น้ำเงิน (สีเทพ) | #2c1b0e → #2255cc |
| hc_gold | ทอง (สีเทพ) | #2c1b0e → #e0a030 |

#### C. Skin Tone (palette swap บน body sprite)
5 skin tones:
| ID | Hex |
|---|---|
| skin_light | #f5d5a0 |
| skin_medium | #c89060 |
| skin_tan | #a06030 |
| skin_dark | #603820 |
| skin_deep | #3a1e10 |

#### D. Outfit Color (palette swap บน clothes layer)
6 สี — เปลี่ยนสีชุดเริ่มต้น (ชุดผู้ท้าชิง):
| ID | ชื่อ |
|---|---|
| outfit_white | ขาว |
| outfit_navy | กรมท่า |
| outfit_red | แดง |
| outfit_green | เขียว |
| outfit_purple | ม่วง (default) |
| outfit_black | ดำ |

> หมายเหตุ: outfit เป็นแค่สีของชุดเริ่มต้น — เมื่อ equip armor จาก inventory จะแทนที่ด้วย sprite armor จริง

#### E. Character Name
- ผู้เล่นตั้งชื่อ "ผู้ท้าชิง" ของตัวเอง (แสดงใน UI แทน "ผู้ท้าชิงนิรนาม")
- max 20 ตัวอักษร, รองรับภาษาไทย
- ชื่อนี้เป็น display name ภายในเกม — ไม่เกี่ยวกับ account username

---

### Palette Swap Shader (Godot)

```gdscript
# character_palette.gdshader
shader_type canvas_item;

uniform sampler2D palette_from : hint_default_white;
uniform sampler2D palette_to   : hint_default_white;
uniform float tolerance : hint_range(0.0, 0.1) = 0.01;

void fragment() {
    vec4 original = texture(TEXTURE, UV);
    vec4 result    = original;

    int palette_size = textureSize(palette_from, 0).x;
    for (int i = 0; i < palette_size; i++) {
        vec4 from_color = texelFetch(palette_from, ivec2(i, 0), 0);
        if (distance(original.rgb, from_color.rgb) < tolerance) {
            result = texelFetch(palette_to, ivec2(i, 0), 0);
            result.a = original.a;
            break;
        }
    }
    COLOR = result;
}
```

**การใช้งาน**: Character sprite แบ่งเป็น 3 layers (Node2D children):
```
CharacterSprite (Node2D)
├── BodySprite    (AnimatedSprite2D) ← palette swap: skin tone
├── OutfitSprite  (AnimatedSprite2D) ← palette swap: outfit color
└── HairSprite    (AnimatedSprite2D) ← palette swap: hair color, เปลี่ยน texture: hair style
```

---

### Character Creator UI Flow

```
[Register สำเร็จ]
        ↓
[Character Select Screen]
  ┌─────────────────────────────────────────┐
  │  [Slot 1: ว่าง]  [Slot 2: ว่าง]  [Slot 3: ว่าง]  │
  │                                           │
  │  [+ สร้างตัวละครใหม่]                       │
  └─────────────────────────────────────────┘
        ↓ (กด สร้างตัวละครใหม่)
[Character Creator Screen]
  ┌─────────────────────────────────┐
  │  [Preview ตัวละคร — idle anim]  │
  │                                 │
  │  ชื่อ: [________________]       │
  │                                 │
  │  ทรงผม:  [◀] [แถวไอคอน 7 แบบ] [▶]│
  │  สีผม:   [● ● ● ● ● ● ● ●]      │
  │  ผิว:    [● ● ● ● ●]             │
  │  ชุด:    [● ● ● ● ● ●]           │
  │                                 │
  │  [← กลับ]        [✓ สร้าง]      │
  └─────────────────────────────────┘
        ↓ (กด สร้าง)
[Character Select Screen] ← slot ใหม่ปรากฏ
        ↓ (กด เลือก)
[Game Hub]
```

### Character Select Screen
```
┌─────────────────────────────────────────────────────┐
│  เทพปกรณัม — เลือกผู้ท้าชิง                          │
├──────────────┬──────────────┬───────────────────────┤
│  [portrait]  │  [portrait]  │  [+ ว่าง]             │
│  ชื่อ: ...   │  ชื่อ: ...   │                       │
│  Divinity: 3 │  Divinity: 0 │                       │
│  Floor: 12   │  Floor: 1    │                       │
│  [เล่น] [ลบ] │  [เล่น] [ลบ] │  [สร้างใหม่]           │
└──────────────┴──────────────┴───────────────────────┘
```

**[ลบ] flow:**
1. กด ลบ → modal "ต้องการลบ [ชื่อ] ใช่หรือไม่? การกระทำนี้ไม่สามารถเลิกทำได้"
2. กด ยืนยัน → modal ที่สอง "พิมพ์ชื่อตัวละครเพื่อยืนยัน: [___]"
3. ชื่อตรง → ลบ (soft delete ใน DB → `deleted_at = now()`)

---

### Character Data ใน Godot Runtime

```gdscript
# GameState.gd — ข้อมูลตัวละครที่ active
var character = {
    "id": "uuid",
    "name": "ชื่อตัวละคร",
    "hair_style": "hair_03",
    "hair_color": "hc_gold",
    "skin_tone": "skin_medium",
    "outfit_color": "outfit_purple",
    # progression
    "divinity_exp":   0,      # EXP สะสม (ดู §2 Divinity Progression)
    "divinity_level": 0,      # คำนวณจาก divinity_exp
    "current_floor": 1,
    "gems": 0,
    "gold": 0,
    "world_energy": 100,      # ⚡ Travel energy
    "battle_energy": 10,      # 🔋 Combat energy
}

# โหลด palette texture ตาม config
func apply_character_appearance(sprite_node: Node2D):
    var body   = sprite_node.get_node("BodySprite")
    var outfit = sprite_node.get_node("OutfitSprite")
    var hair   = sprite_node.get_node("HairSprite")

    body.material.set_shader_parameter("palette_to",
        load("res://assets/palettes/skin/%s.png" % character.skin_tone))
    outfit.material.set_shader_parameter("palette_to",
        load("res://assets/palettes/outfit/%s.png" % character.outfit_color))
    hair.texture = load("res://assets/sprites/hair/%s.png" % character.hair_style)
    hair.material.set_shader_parameter("palette_to",
        load("res://assets/palettes/hair/%s.png" % character.hair_color))
```

---

### Schema เพิ่มเติม (schema_character_v1.sql)

```sql
-- เพิ่ม column ใน players table
ALTER TABLE players ADD COLUMN IF NOT EXISTS
    char_name        TEXT,           -- ชื่อตัวละครในเกม (ต่างจาก username)
    hair_style       TEXT NOT NULL DEFAULT 'hair_01',
    hair_color       TEXT NOT NULL DEFAULT 'hc_black',
    skin_tone        TEXT NOT NULL DEFAULT 'skin_medium',
    outfit_color     TEXT NOT NULL DEFAULT 'outfit_purple',
    deleted_at       TIMESTAMPTZ;   -- soft delete

-- ถ้าต้องการ multi-character per account
-- ต้องแยก players ออกเป็น 2 table: accounts + characters
-- (แนะนำถ้าต้องการขยาย)

CREATE TABLE accounts (
    id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    username     TEXT NOT NULL UNIQUE,
    created_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- players table เปลี่ยนให้ผูกกับ account
ALTER TABLE players ADD COLUMN IF NOT EXISTS
    account_id   UUID REFERENCES accounts(id) ON DELETE CASCADE;

CREATE INDEX idx_players_account ON players (account_id) WHERE deleted_at IS NULL;

-- View สำหรับ query ตัวละครที่ยังไม่ถูกลบ
CREATE VIEW active_characters AS
    SELECT * FROM players WHERE deleted_at IS NULL;
```

---

### Asset File Structure (ใน Godot project)

```
assets/
├── sprites/
│   └── character/
│       ├── body_base.png          ← Sunnyside human base (spritesheet)
│       ├── outfit_base.png        ← Sunnyside outfit layer
│       └── hair/
│           ├── hair_01.png
│           ├── hair_02.png
│           ├── hair_03.png
│           ├── hair_04.png
│           ├── hair_05.png
│           ├── hair_06.png
│           └── hair_07.png
└── palettes/
    ├── skin/
    │   ├── skin_light.png         ← 1×1 px palette texture
    │   ├── skin_medium.png
    │   ├── skin_tan.png
    │   ├── skin_dark.png
    │   └── skin_deep.png
    ├── hair/
    │   ├── hc_black.png
    │   ├── hc_brown.png
    │   └── ... (8 files)
    └── outfit/
        ├── outfit_white.png
        └── ... (6 files)
```

> Palette texture = PNG 8×1 px (หรือ N×1 ตามจำนวนสีที่ต้องการ swap)
> สร้างด้วย Aseprite หรือ script

---

## 14. UI/UX Flow


### Scene Flow
```
[Boot]
  └── [Main Menu] ── [Login/Register]
        │                    │
        │             [Character Creator]  ← register ครั้งแรก
        │
        └── [Character Select] ── [Character Creator] ← สร้างตัวใหม่
                  │
                  └── [Game Hub] ──────────────────────────────────────┐
              │                                                      │
              ├── [World Map]          ← tower camp graph            │
              │     └── [Field Map]   ← tilemap ใน camp             │
              │           └── [Combat Scene] ← ATB battle           │
              │                 └── [Loot Screen] ← หลัง win         │
              │                                                      │
              ├── [Gacha Screen]       ← pull + reveal animation     │
              │                                                      │
              ├── [Skill Web]          ← passive tree (Node2D)       │
              │     └── [Node Detail Panel]                          │
              │           └── [Upgrade Panel] ← minigame             │
              │                                                      │
              ├── [Inventory]                                        │
              │     ├── [Item Detail]                                │
              │     └── [Refine Panel] ← minigame                    │
              │                                                      │
              └── [Bestiary]           ← collection viewer           │
                                                                     │
              [HUD] CanvasLayer ── HP bar, Energy, Gold, Gem ────────┘
```

### HUD (CanvasLayer — always visible)
```
┌─────────────────────────────────────────┐
│ [ชื่อ / Divinity title]    💎 xxx  🪙 xxx │
│ HP ████████░░  ⚡ energy bar            │
└─────────────────────────────────────────┘
```

### Bottom Navigation (Game Hub)
```
[ 🗺️ หอเทวภพ ] [ ✨ Gacha ] [ 🌐 Skill ] [ 🎒 ไอเทม ] [ 📖 Bestiary ]
```

### Combat Scene Layout
```
┌──────────────────────────────────┐
│         enemy sprite + name       │
│         [ HP bar ]               │
│─────────────────────────────────│
│    [   combat log (4 lines)   ]  │
│─────────────────────────────────│
│  ATB ████████░░  SPD [ตาม equip+nodes]        │
│─────────────────────────────────│
│  [ ⚔️ โจมตี ] [ ✨ ทักษะ ]        │
│  [ 🧪 ไอเทม ] [ 🏃 หนี  ]         │
└──────────────────────────────────┘
```

### Gacha Scene Flow
```
[Banner art] → [กด Pull 1 / Pull 10] → [Loading animation]
→ [Reveal: ไพ่พลิก ทีละใบ (×1) หรือ grid animate (×10)]
→ [กด OK] → [กลับ Gacha screen]
```

---

## 15. Schema ที่ต้องสร้างเพิ่ม

### schema_character_v1.sql
ดูตัวอย่างใน [Section 13 ด้านบน](#13-character-creator)
- เพิ่ม columns ใน `players`: `char_name`, `hair_style`, `hair_color`, `skin_tone`, `outfit_color`, `deleted_at`
- แยก `accounts` table สำหรับ multi-character per account
- `active_characters` view กรอง soft-deleted records

### schema_combat_v1.sql
ดูตัวอย่างใน [Section 4 ด้านบน](#4-ระบบ-atb-combat)
Tables: `combat_sessions`, `combat_action_log`

### schema_upgrade_v1.sql
```sql
CREATE TABLE upgrade_attempts (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  player_id       UUID NOT NULL REFERENCES players(id),
  target_type     TEXT NOT NULL,       -- 'skill_node' / 'weapon' / 'armor'
  target_id       UUID NOT NULL,       -- player_items.id หรือ player_skill_nodes ที่เกี่ยวข้อง
  from_level      INTEGER NOT NULL,
  to_level        INTEGER NOT NULL,
  base_rate       NUMERIC NOT NULL,    -- % ก่อน boost
  boost_rate      NUMERIC NOT NULL DEFAULT 0, -- % จาก item + minigame
  final_rate      NUMERIC NOT NULL,
  success         BOOLEAN NOT NULL,
  minigame_played BOOLEAN NOT NULL DEFAULT FALSE,
  minigame_result TEXT,               -- 'perfect' / 'success' / 'miss' / null
  resources_used  JSONB NOT NULL,     -- [{item_id, qty}]
  attempted_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- node upgrade level (เก็บแยกจาก player_skill_nodes)
ALTER TABLE player_skill_nodes
  ADD COLUMN upgrade_level INTEGER NOT NULL DEFAULT 0;
```

### schema_quest_v1.sql (Phase 2)
```sql
CREATE TABLE quests (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name        TEXT NOT NULL,
  description TEXT,
  quest_type  TEXT NOT NULL, -- 'daily' / 'weekly' / 'achievement'
  condition   JSONB NOT NULL, -- {type, target, count}
  reward_gold INTEGER DEFAULT 0,
  reward_gems INTEGER DEFAULT 0,
  reward_items JSONB DEFAULT '[]',
  resets_at   TEXT, -- 'daily' / 'weekly' / null (achievement ไม่ reset)
  is_active   BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE player_quest_progress (
  player_id   UUID NOT NULL REFERENCES players(id) ON DELETE CASCADE,
  quest_id    UUID NOT NULL REFERENCES quests(id),
  progress    INTEGER NOT NULL DEFAULT 0,
  is_complete BOOLEAN NOT NULL DEFAULT FALSE,
  claimed_at  TIMESTAMPTZ,
  reset_date  DATE,  -- สำหรับ daily/weekly
  PRIMARY KEY (player_id, quest_id, COALESCE(reset_date, '1970-01-01'))
);
```

---

## 16. Godot Scene Map

### Autoload Singletons
| Singleton | หน้าที่ |
|---|---|
| `GameState.gd` | player data, current session, stat cache |
| `SupabaseClient.gd` | HTTP calls, auth token, queue |
| `AudioManager.gd` | BGM, SFX |
| `ToastManager.gd` | แสดง notification popup |

### Scene List
| Scene | Node root | หน้าที่ |
|---|---|---|
| `boot.tscn` | Node | โหลด config, check session |
| `main_menu.tscn` | Control | login / register / play |
| `character_select.tscn` | Control | เลือก / ลบ / สร้าง character slot |
| `character_creator.tscn` | Control | ออกแบบตัวละคร + ตั้งชื่อ |
| `game_hub.tscn` | Control | bottom nav, load sub-scenes |
| `hud.tscn` | CanvasLayer | HP, energy, gold, gem — always on |
| `world_map.tscn` | Node2D | tower camp graph |
| `field_map.tscn` | Node2D | TileMap combat field |
| `combat.tscn` | Control | ATB battle UI |
| `loot.tscn` | Control | หลัง combat win |
| `gacha_ui.tscn` | Control | banner, pull, reveal |
| `skill_web.tscn` | Node2D | passive skill tree renderer |
| `node_detail.tscn` | Control | popup แสดง node info + upgrade |
| `minigame_upgrade.tscn` | Control | timing ring minigame |
| `inventory.tscn` | Control | item list + equip + refine |
| `bestiary.tscn` | Control | collection viewer |

### Signal Architecture
```
# ตัวอย่าง signal flow
CombatScene → emit("combat_ended", result)
  → GameState.update_player(result)
  → GameState → emit("player_updated")
    → HUD.refresh()
    → LootScreen.show(result.loot)
```

### Resource Management
- Item catalog, skill nodes, tower data → โหลดตอน login ครั้งเดียว → cache ใน GameState
- Player data → sync กับ Supabase หลัง action สำคัญทุกครั้ง
- Assets (sprites, audio) → preload ตาม scene ที่ใช้

---

## 17. Difficulty Modes

### โหมดความยากทั้งหมด

| ID | ชื่อไทย | ชื่อ EN | ลักษณะหลัก |
|---|---|---|---|
| `normal` | ปกติ | Normal | ค่า default — balanced |
| `hard` | ยาก | Hard | ศัตรูแข็งขึ้น, drop rate ดีขึ้น |
| `ascendant` | เส้นทางเทพ | Ascendant | ยากมาก, drop rate สูงกว่า |
| `hardcore` | วิถีนิรันดร์ | Eternal Path | **One life** — ตายจบเลย |

> ชื่อ "วิถีนิรันดร์ / Eternal Path" สื่อถึงการเดินทางที่ไม่มีโอกาสแก้ตัว เหมาะกับธีมปกรณัม

### Difficulty ปรับ stat ศัตรูและ drop rate

| Stat | Normal | Hard | Ascendant | Eternal Path |
|---|---|---|---|---|
| Enemy HP | ×1.0 | ×1.4 | ×2.0 | ×2.0 |
| Enemy ATK | ×1.0 | ×1.3 | ×1.8 | ×1.8 |
| Enemy DEF | ×1.0 | ×1.2 | ×1.5 | ×1.5 |
| Drop rate | ×1.0 | ×1.3 | ×1.6 | ×2.0 |
| Gold drop | ×1.0 | ×1.2 | ×1.5 | ×1.8 |
| XP/progress | ×1.0 | ×1.1 | ×1.3 | ×1.5 |

### Difficulty เลือกตอนสร้างตัวละคร
- ผูกกับ **character slot** ไม่ใช่ account
- เปลี่ยน difficulty ได้เฉพาะ **Normal → Hard → Ascendant** (เพิ่มเท่านั้น, ลดไม่ได้)
- **Eternal Path เปลี่ยนไม่ได้** — เลือกแล้วล็อกตลอดชีวิตตัวละคร

### Eternal Path (Hardcore) — กฎพิเศษ
1. **One life** — HP = 0 → ตัวละครถูกล็อก (`death_locked = TRUE`)
   - ตัวละครยังดูได้ใน memorial หน้า Character Select แต่ไม่สามารถเล่นได้
   - สร้างตัวใหม่ได้ใน slot เดิม (ถ้าต้องการ)
2. **Energy ไม่มี** — เข้า camp ได้อิสระ, ไม่มีระบบ regen
3. **Drop legendary+ ซื้อขายได้** ผ่าน Eternal Marketplace (ดู Section 20)
4. **Separate leaderboard** — rank แยกจาก mode อื่น (floor สูงสุดที่ถึงก่อนตาย)
5. **Character badge** — portrait มี frame พิเศษ สีทอง + เปลวไฟ

### Difficulty ใน Multiplayer
- Session ใช้ difficulty ของ **Host**
- Guest ที่ difficulty ต่ำกว่า Host: ได้ drop rate ของ Host แต่ stat ศัตรูก็สูงตามด้วย
- Eternal Path: เล่น multiplayer ได้ แต่ถ้าตายใน session ก็ยังนับเป็นตาย

---

## 18. Offline / Online & Save Strategy

### Character Slot Types

แต่ละ slot มี type ที่เลือกตอนสร้าง **เปลี่ยนไม่ได้:**

| Type | Save ที่ไหน | Login ต้องการ? | Multiplayer |
|---|---|---|---|
| **Offline** | Local file (`user://saves/`) | ❌ ไม่ต้อง | ❌ ไม่ได้ |
| **Online** | Supabase (cloud) | ✅ ต้องการ | ✅ ได้ |

> Offline character ไม่สามารถ convert เป็น Online ได้ (ป้องกัน item dupe)

### Offline Save Format
```
user://saves/
├── characters.json          ← index: list ของ offline characters
├── char_{uuid}/
│   ├── player.json          ← stats, resources, divinity
│   ├── inventory.json       ← items, equipment
│   ├── skill_tree.json      ← unlocked nodes
│   ├── camp_progress.json   ← floor/camp state
│   └── settings.json        ← per-character settings
```

ใช้ Godot `FileAccess` + `JSON.stringify()` encrypt ด้วย key ที่ generate จาก machine ID (ป้องกัน hex edit ง่ายๆ แต่ไม่ได้ hardcore anti-cheat)

### Online Save Flow
```
Action → validate locally → POST Supabase → ack → update local cache
ถ้าไม่มี internet → แสดง "ต้องการ internet สำหรับ Online character"
                  → ไม่ให้เล่นต่อ (ไม่มี offline fallback)
```

### Save Diagram
```
[Main Menu] → เลือก character type
                   │
        ┌──────────┴──────────┐
        ▼                     ▼
  [Offline Slot]         [Online Slot]
  local file only        Supabase only
  ไม่ต้อง login          ต้อง login
  ไม่ได้ multiplayer     ได้ multiplayer
  ไม่ได้ marketplace     ได้ marketplace (ถ้า Eternal)
```

### Slot Configuration (ต่อ account / ต่อเครื่อง)
- **Offline slots**: 3 slots ต่อเครื่อง (local)
- **Online slots**: 3 slots ต่อ account (cloud)
- รวม 6 slots สูงสุดต่อคน (3 offline + 3 online)

---

## 19. Multiplayer & Networking

### Overview: 2 Modes

```
[Multiplayer Menu]
├── Friend Session  ← P2P ผ่าน room code (ENet)
└── Server List     ← Official / Community servers
```

### Mode A — Friend Session (P2P via ENet)

**Flow:**
```
Host:  กด "สร้าง Friend Session"
       → Godot สร้าง ENet server บน port สุ่ม
       → ได้ Room Code 6 ตัวอักษร (A3X7K2)
       → แชร์ code ให้เพื่อน

Guest: ใส่ Room Code
       → ระบบ lookup IP+port ของ Host (ผ่าน matchmaking server เล็กๆ)
       → เชื่อมต่อ ENet โดยตรง (ต้องการ NAT traversal / UPNP)
       → ถ้า NAT ล้มเหลว → fallback ผ่าน relay (Nakama หรือ self-hosted)
```

**Limitations:**
- รองรับ 1 Host + สูงสุด **4 Guests** (รวม 5 คน)
- Host disconnect = session สิ้นสุด
- ไม่บันทึก progress ถ้า disconnect กลางคัน (Online character บันทึกล่าสุดก่อน session)
- Offline character **ไม่สามารถเข้า Friend Session** ได้

**Room Code Server — ใช้ Supabase Edge Function:**
```typescript
// supabase/functions/room-code/index.ts
// POST /room-code/create  → { code, ip, port } → บันทึก 30 นาที
// GET  /room-code/{code}  → { ip, port }
// DELETE /room-code/{code} → ลบ

import { createClient } from "@supabase/supabase-js";

Deno.serve(async (req) => {
  const url = new URL(req.url);
  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
  );

  if (req.method === "POST" && url.pathname.endsWith("/create")) {
    const { ip, port } = await req.json();
    const code = Math.random().toString(36).slice(2, 8).toUpperCase();
    const expires_at = new Date(Date.now() + 30 * 60 * 1000).toISOString();
    await supabase.from("room_codes").insert({ code, ip, port, expires_at });
    return Response.json({ code });
  }

  if (req.method === "GET") {
    const code = url.pathname.split("/").pop();
    const { data } = await supabase
      .from("room_codes")
      .select("ip, port")
      .eq("code", code)
      .gt("expires_at", new Date().toISOString())
      .single();
    if (!data) return new Response("Not found", { status: 404 });
    return Response.json(data);
  }

  if (req.method === "DELETE") {
    const code = url.pathname.split("/").pop();
    await supabase.from("room_codes").delete().eq("code", code);
    return new Response(null, { status: 204 });
  }
});
```

```sql
-- เพิ่มใน schema_marketplace_v1.sql หรือ schema_multiplayer_v1.sql
CREATE TABLE room_codes (
  code        TEXT PRIMARY KEY,           -- 6 ตัวอักษร เช่น "A3X7K2"
  ip          TEXT NOT NULL,
  port        INTEGER NOT NULL,
  expires_at  TIMESTAMPTZ NOT NULL,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);
-- cleanup expired codes ด้วย pg_cron หรือ trigger
```

**Godot implementation:**
```gdscript
# NetworkManager.gd (autoload)
var peer: ENetMultiplayerPeer

func create_session() -> String:
    peer = ENetMultiplayerPeer.new()
    peer.create_server(0)  # port 0 = OS เลือกให้
    multiplayer.multiplayer_peer = peer
    var port = peer.get_local_port()
    var code = await RoomCodeAPI.register(get_my_ip(), port)
    return code

func join_session(code: String) -> Error:
    var info = await RoomCodeAPI.lookup(code)
    peer = ENetMultiplayerPeer.new()
    return peer.create_client(info.ip, info.port)
```

### Mode B — Server List (Dedicated / Official)

**Server types:**
| ประเภท | ใครดูแล | เข้าได้ | Eternal Path |
|---|---|---|---|
| Official | ทีมพัฒนา | ทุกคน | ✅ |
| Community | ผู้เล่นสร้าง | ตามการตั้งค่า | config ได้ |

**Server List UI:**
```
┌──────────────────────────────────────────────────────────┐
│ ชื่อ Server          │ Online │ Ping │ Mode     │ Join   │
├──────────────────────┼────────┼──────┼──────────┼────────┤
│ [Official] แดนเทพ #1 │ 42/100 │ 22ms │ All      │ [เข้า] │
│ [Official] แดนเทพ #2 │ 18/100 │ 35ms │ All      │ [เข้า] │
│ [Community] BKK Club │  5/20  │ 8ms  │ Normal   │ [เข้า] │
│ [Community] Hardcore │  3/20  │ 55ms │ Eternal  │ [เข้า] │
└──────────────────────┴────────┴──────┴──────────┴────────┘
         [🔄 รีเฟรช]   [+ สร้าง Community Server]
```

**Dedicated Server Build:**
- Godot export เป็น headless server (Linux)
- Config ผ่าน `server.cfg`: port, max_players, allowed_difficulty, server_name
- Announce ตัวเองไปยัง Master Server List (endpoint ที่เกมเรียก)

**Multiplayer Sync (RPC):**
```gdscript
# สิ่งที่ sync ผ่าน RPC:
# - ตำแหน่ง player ใน field map (position_sync — unreliable)
# - combat actions (action_broadcast — reliable)
# - item drop ที่เกิดจาก kill (loot_sync — reliable)
# - chat message (chat_broadcast — reliable)

@rpc("any_peer", "unreliable")
func sync_position(pos: Vector2):
    $Players[multiplayer.get_remote_sender_id()].position = pos

@rpc("authority", "reliable")
func broadcast_combat_result(result: Dictionary):
    CombatManager.apply_result(result)
```

**Authority model:**
- **Host / Dedicated Server = authority** — ตัดสิน combat, loot, progression
- Client ส่ง intent → server validate → broadcast result
- ป้องกัน client-side cheat พื้นฐาน

---

## 20. Hardcore Mode & Marketplace

### Eternal Path (Hardcore) — ทบทวนกฎ
*(ดูเพิ่มเติมใน Section 17)*
- One life, no energy, drop rate ×2.0
- Legendary+ drops → ขายได้ใน Eternal Marketplace
- Leaderboard แยก

### Eternal Marketplace

**ใครเข้าได้:**
| Action | Eternal Path player | Normal/Hard/Ascendant player |
|---|---|---|
| วางขาย (list item) | ✅ | ❌ |
| ซื้อ (buy) | ✅ | ❌ |
| ดูรายการ + ราคา (read-only) | ✅ | ✅ (สร้าง FOMO) |

**Item ที่ขายได้:**
- Rarity ≥ `legendary` เท่านั้น
- ต้อง drop ใน **Eternal Path session** (flag `is_eternal_drop = TRUE` บน item)
- ห้ามขาย item ที่ได้จาก gacha (ต้องเป็น field drop เท่านั้น)

**Currency ของตลาด:**
- ใช้ **Gold** (ไม่มี real money transaction ใน design นี้)
- ราคาตั้งโดยผู้ขาย, ไม่มี floor/ceiling price ใน Phase 1

**Listing Flow:**
```
[Inventory ของ Eternal character]
    │ เลือก item legendary+
    ▼
[ตั้งราคา Gold]
    │ ยืนยัน
    ▼
[Item หายจาก inventory → ไปอยู่ใน listing]
    │
    ▼ ถ้ามีคนซื้อ:
[Gold เข้า seller] ← Supabase function หักค่า fee 5%
[Item เข้า buyer inventory]
```

**Marketplace Schema (schema_marketplace_v1.sql):**
```sql
CREATE TABLE marketplace_listings (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  seller_id       UUID NOT NULL REFERENCES players(id),
  player_item_id  UUID NOT NULL REFERENCES player_items(id),
  item_id         UUID NOT NULL REFERENCES items(id),
  rarity          rarity_tier NOT NULL,
  price_gold      INTEGER NOT NULL CHECK (price_gold > 0),
  status          TEXT NOT NULL DEFAULT 'active',
    -- 'active' / 'sold' / 'cancelled'
  listed_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
  sold_at         TIMESTAMPTZ,
  buyer_id        UUID REFERENCES players(id),
  fee_pct         NUMERIC NOT NULL DEFAULT 0.05
);

CREATE INDEX idx_marketplace_active
  ON marketplace_listings (rarity, price_gold)
  WHERE status = 'active';

-- ตรวจสอบว่า item เป็น eternal drop และ rarity ≥ legendary
-- ทำผ่าน Supabase RPC function:
-- fn_list_item(player_id, player_item_id, price) → validates + inserts
```

**Marketplace UI:**
```
┌──────────────────────────────────────────────────────┐
│  Eternal Marketplace  [ดูได้ทุกคน / ซื้อขายเฉพาะ Eternal]  │
├──────────────────────────────────────────────────────┤
│ Filter: [Legendary ▼] [อาวุธ ▼] [ราคา ▲▼]            │
├──────────────────────────────────────────────────────┤
│ 🌟 ตรีศูลเทวภพ     legendary   52,000 🪙  [ซื้อ]     │
│ ⭐ อัคคีเทพบุตร    legendary   38,000 🪙  [ซื้อ]     │
│ 👑 ทวยเทพบุตร      mythic     180,000 🪙  [ซื้อ]     │
├──────────────────────────────────────────────────────┤
│ [📋 ของฉันที่วางขาย]  [+ วางขายใหม่]                  │
└──────────────────────────────────────────────────────┘
  * normal/hard/ascendant player เห็นหน้านี้แต่ปุ่มซื้อ/ขายถูก lock
```

---

## 21. Settings Menu

### Settings เข้าถึงได้จาก
- Main Menu → ⚙️ Settings
- In-game → Pause Menu → ⚙️ Settings
- ตั้งค่าบันทึกใน `user://settings.cfg` (Godot `ConfigFile`)

---

### 21A — หน้าหลัก Main Menu

```
┌────────────────────────────────────────┐
│          เทพปกรณัม                      │
│                                        │
│   [ ▶  เล่นออฟไลน์          ]          │
│   [ ⚡  เข้าเล่นทันที (Guest)]          │
│   [ 👤  Login / สมัครสมาชิก  ]          │
│   [ 👥  Friend Session       ]          │
│   [ 🌐  Server List          ]          │
│   [ ⚙️  ตั้งค่า              ]          │
│   [ ✕  ออกจากเกม            ]          │
└────────────────────────────────────────┘
```

> ถ้ามี saved_session → ปุ่ม "เข้าเล่นทันที" เปลี่ยนเป็น "เล่นต่อ ([ชื่อ])"
> ถ้า login แล้ว → ซ่อนปุ่ม Guest/Login แสดงชื่อ account แทน

#### ปุ่ม "เล่นออฟไลน์" → Sub-menu:
```
┌────────────────────────────────────────┐
│  เล่นคนเดียว                           │
│                                        │
│  [ ▶  เริ่มใหม่ / จัดการตัวละคร ]       │
│       → ไป Character Select            │
│                                        │
│  [ ⚡  เล่นต่อ (ตัวล่าสุด: [ชื่อ]) ]    │
│       → โหลด last-played character     │
│       → ข้ามไป Game Hub ทันที           │
│                                        │
│  [ ←  กลับ ]                           │
└────────────────────────────────────────┘
```

**"เล่นต่อ" logic:**
```gdscript
# บันทึก last_played_char_id ใน settings.cfg
# ถ้าไม่มี → ปุ่ม greyed out
# ถ้า character นั้นเป็น Online → ต้อง login ก่อน
# ถ้า character นั้นเป็น Offline → โหลดได้เลย
```

#### ปุ่ม "Friend Session" → Sub-menu:
```
┌────────────────────────────────────────┐
│  Friend Session                        │
│                                        │
│  [ 🏠  สร้าง Session ]                 │
│       → แสดง Room Code + รอเพื่อน      │
│                                        │
│  [ 🔑  Join ด้วย Room Code ]           │
│       [   A3X7K2   ] [เชื่อมต่อ]        │
│                                        │
│  [ ←  กลับ ]                           │
└────────────────────────────────────────┘
```

---

### 21B — ตั้งค่ากราฟิก (Graphics)

```
┌──────────────────────────────────────────────┐
│  กราฟิก                                      │
├──────────────────────────────────────────────┤
│  ความละเอียดหน้าจอ                            │
│  [1280×720 ▼]  (720p / 1080p / 1440p / 4K)  │
│                                              │
│  โหมดหน้าจอ                                  │
│  [◉ Windowed]  [○ Fullscreen]  [○ Borderless]│
│                                              │
│  Pixel Zoom (ขนาด sprite บนหน้าจอ)           │
│  1×  [──●────────]  4×                      │
│  ค่าปัจจุบัน: 2×  (แนะนำ 2× สำหรับ 1080p)    │
│                                              │
│  Pixel Snap                                  │
│  [✓] เปิด (แนะนำ — ป้องกัน sprite เบลอ)      │
│                                              │
│  FPS Cap                                     │
│  [30]  [◉ 60]  [120]  [ไม่จำกัด]             │
│                                              │
│  VSync                                       │
│  [◉ เปิด]  [○ ปิด]                           │
└──────────────────────────────────────────────┘
```

**Pixel Zoom implementation (Godot):**
```gdscript
# project.godot: viewport stretch = canvas_items (integer scale)
# ปรับ zoom ผ่าน:
func set_pixel_zoom(zoom: int):  # 1-4
    get_viewport().set_scaling_3d_scale(1.0)
    var base = Vector2i(320, 180)  # base resolution (16-bit feel)
    DisplayServer.window_set_size(base * zoom)
    # หรือใช้ SubViewport + scale ถ้าต้องการ fixed internal resolution
```

---

### 21C — ตั้งค่าภาษา (Language)

```
┌──────────────────────────────────────────────┐
│  ภาษา                                        │
├──────────────────────────────────────────────┤
│  ภาษาข้อความ (UI & Dialogue)                  │
│  [🇹🇭 ภาษาไทย ▼]                             │
│   ▸ 🇹🇭 ภาษาไทย                              │
│   ▸ 🇬🇧 English                              │
│   ▸ 🇯🇵 日本語  (Phase 3+)                    │
│                                              │
│  ภาษาเสียงพากย์ (Voice Language)              │
│  [🇹🇭 ไทย ▼]                                 │
│   ▸ 🇹🇭 ไทย                                  │
│   ▸ 🇬🇧 English                              │
│   ▸ ไม่มีเสียงพากย์                           │
│                                              │
│  * ภาษาข้อความและเสียงตั้งค่าแยกกันได้         │
└──────────────────────────────────────────────┘
```

**Godot i18n implementation:**
```gdscript
# ใช้ Godot built-in TranslationServer
TranslationServer.set_locale("th")   # ภาษาไทย
TranslationServer.set_locale("en")   # English

# ใน .tscn ใช้ tr() wrapper:
$Label.text = tr("MAIN_MENU_PLAY")  # → "เล่นเกม" / "Play"

# ไฟล์แปล: res://i18n/th.po, res://i18n/en.po
# Voice: AudioStreamPlayer โหลด file ตาม locale:
# res://audio/voice/{locale}/{clip_name}.ogg
```

---

### 21D — การควบคุม (Controls)

```
┌──────────────────────────────────────────────┐
│  การควบคุม                                   │
├──────────────────────────────────────────────┤
│  อุปกรณ์ที่ตรวจพบ: [⌨️ Keyboard+Mouse]        │
│                    [🎮 Controller: DS5]       │
│                                              │
│  ──────── Keyboard / Mouse ────────          │
│  เดิน ↑       [W]          [เปลี่ยน]         │
│  เดิน ↓       [S]          [เปลี่ยน]         │
│  เดิน ←       [A]          [เปลี่ยน]         │
│  เดิน →       [D]          [เปลี่ยน]         │
│  โจมตี        [คลิกซ้าย]   [เปลี่ยน]         │
│  ทักษะ 1      [Q]          [เปลี่ยน]         │
│  ทักษะ 2      [E]          [เปลี่ยน]         │
│  ไอเทม        [F]          [เปลี่ยน]         │
│  แผนที่       [M]          [เปลี่ยน]         │
│  Pause        [Esc]        [เปลี่ยน]         │
│                                              │
│  ──────── Controller ────────                │
│  เดิน         [Left Stick]  [เปลี่ยน]        │
│  โจมตี        [Square / X]  [เปลี่ยน]        │
│  ทักษะ 1      [Triangle / Y][เปลี่ยน]        │
│  ทักษะ 2      [Circle / B]  [เปลี่ยน]        │
│  ไอเทม        [R1 / RB]     [เปลี่ยน]        │
│  แผนที่       [Touchpad/V.] [เปลี่ยน]        │
│                                              │
│  [↺ Reset เป็นค่าเริ่มต้น]                   │
└──────────────────────────────────────────────┘
```

**Godot InputMap implementation:**
```gdscript
# Controls.gd — บันทึก/โหลด key bindings
func remap_action(action: String, event: InputEvent):
    InputMap.action_erase_events(action)
    InputMap.action_add_event(action, event)
    save_bindings()

func save_bindings():
    var cfg = ConfigFile.new()
    for action in InputMap.get_actions():
        if action.begins_with("game_"):  # เฉพาะ action ของเกม
            var events = InputMap.action_get_events(action)
            cfg.set_value("bindings", action, events[0].as_text() if events else "")
    cfg.save("user://settings.cfg")

# Controller detection:
func _input(event):
    if event is InputEventJoypadButton or event is InputEventJoypadMotion:
        HUD.show_controller_hints()
    elif event is InputEventKey or event is InputEventMouse:
        HUD.show_keyboard_hints()
```

---

### 21E — ตั้งค่าเสียง (Audio)

```
┌──────────────────────────────────────────────┐
│  เสียง                                        │
├──────────────────────────────────────────────┤
│  เสียงรวม (Master)                            │
│  🔊 [████████░░] 80%                         │
│                                              │
│  เสียงพื้นหลัง (BGM)                          │
│  🎵 [██████░░░░] 60%                         │
│                                              │
│  เสียงเอฟเฟกต์ (SFX)                          │
│  💥 [████████░░] 80%                         │
│                                              │
│  เสียงตัวละคร (Voice)                         │
│  🗣️ [█████████░] 90%                         │
│                                              │
│  [🔇 Mute ทั้งหมด]                            │
└──────────────────────────────────────────────┘
```

**Godot AudioBus implementation:**
```gdscript
# project.godot → Audio Bus Layout:
# Bus 0: Master
# Bus 1: BGM    (parent: Master)
# Bus 2: SFX    (parent: Master)
# Bus 3: Voice  (parent: Master)  ← Phase 1: combat grunts เท่านั้น (ไม่มี dialog)

func set_volume(bus_name: String, pct: float):  # pct 0.0-1.0
    var idx = AudioServer.get_bus_index(bus_name)
    var db = linear_to_db(pct) if pct > 0 else -80.0
    AudioServer.set_bus_volume_db(idx, db)
```

> **Phase 1 — ไม่มีเสียงพากย์ dialog**: Voice bus ควบคุม combat grunts (เสียงโจมตี/โดนตี)
> เสียงพากย์ NPC และ story จะเพิ่มใน Phase 3+ เมื่อมีนักพากย์

---

### 21F — Settings Storage

```gdscript
# SettingsManager.gd (autoload)
const SETTINGS_PATH = "user://settings.cfg"

var defaults = {
    "graphics/resolution": "1280x720",
    "graphics/window_mode": "windowed",
    "graphics/pixel_zoom": 2,
    "graphics/pixel_snap": true,
    "graphics/fps_cap": 60,
    "graphics/vsync": true,
    "language/text": "th",
    "language/voice": "th",
    "audio/master": 0.8,
    "audio/bgm": 0.6,
    "audio/sfx": 0.8,
    "audio/voice": 0.9,
    "controls/bindings": {},  # action → event string
    "game/last_played_char_id": "",
}

func load_settings():
    var cfg = ConfigFile.new()
    if cfg.load(SETTINGS_PATH) == OK:
        for key in defaults:
            var section = key.split("/")[0]
            var prop    = key.split("/")[1]
            defaults[key] = cfg.get_value(section, prop, defaults[key])
    apply_all()

func save_settings():
    var cfg = ConfigFile.new()
    for key in defaults:
        var section = key.split("/")[0]
        var prop    = key.split("/")[1]
        cfg.set_value(section, prop, defaults[key])
    cfg.save(SETTINGS_PATH)
```

---

## 22. Gathering & Resource System

### Concept
วัสดุธรรมชาติในโลกได้มาจากการ interact กับสภาพแวดล้อมใน field map
ไม่ใช่แค่ drop จาก monster — เพิ่ม pacing และ loop ของเกมให้หลากหลาย

### Resource Node Types
| Node | รูปแบบ | Drop | Respawn |
|---|---|---|---|
| ต้นไม้ | ตัดด้วย axe / มือเปล่า (ช้า) | Wood (ไม้ธรรมดา), Branch (กิ่ง), Rare Bark | 5 นาที |
| ก้อนหิน | ทุบด้วย pickaxe / มือเปล่า | Stone, Gravel, Flint | 8 นาที |
| แร่ภูเขา | ต้องมี pickaxe | Ore (iron/silver/gold/mythril), Gem shard | 15 นาที |
| พืช/ดอกไม้ | เก็บด้วยมือ | Herb, Flower, Seed | 10 นาที |
| ของบนพื้น | เดินผ่าน auto-pickup หรือ กด F | item ต่างๆ ที่ drop จากศัตรูหรือ world | ไม่ respawn |
| น้ำ | ใช้ Flask ตักจากแหล่งน้ำ | Fresh Water | ไม่หมด |

### Gathering Skills & Proficiency (ดู §27 ด้วย)
กิจกรรม gathering แต่ละประเภทมี Proficiency level (1-100) แยกกัน:
- `Woodcutting` — ตัดต้นไม้
- `Mining` — ทำเหมือง
- `Foraging` — เก็บพืช/สมุนไพร
- `Scavenging` — เก็บของบนพื้น (เพิ่ม drop chance)

**Proficiency effect:**
```
gather_amount  = base_amount × (1 + proficiency/200)   # max ×1.5
gather_speed   = base_time  × (1 - proficiency/250)    # max ×0.6 speed
rare_drop_rate = base_rate  × (1 + proficiency/100)    # max ×2.0
```

### Tools & Gathering
| Tool | ใช้กับ | ไม่มี tool | Skill ที่ใช้ |
|---|---|---|---|
| Axe | ต้นไม้ (เร็ว ×3, drop ดีกว่า) | ตัดมือเปล่าได้ช้า | `woodcutting` |
| Pickaxe | หิน, แร่ (จำเป็นสำหรับแร่) | หินทุบมือได้, แร่ทำไม่ได้ | `mining` |
| Sickle | พืช/ดอกไม้ (เร็ว ×2, yield +50%) | เก็บมือได้ปกติ | `foraging` |
| Flask | ตักน้ำ | ตักไม่ได้ | — |

**Tool rarity × Skill level = ผลจริง:**
```
tool_bonus   = tool.tier_bonus          # Axe tier 1=×1.0, tier 2=×1.3, tier 3=×1.6
skill_factor = woodcutting_level / 100  # 0.01-1.00
actual_yield = base_yield × tool_bonus × (0.5 + skill_factor × 0.5)
  # skill level 1  → ×0.51 ของ potential เต็ม
  # skill level 50 → ×0.75
  # skill level 100 → ×1.00 (ผลเต็มตาม tool)

# tool rarity สูง แต่ skill ต่ำ → ได้ผลไม่เต็ม
# ตัวอย่าง: Mythril Axe (tier 4, ×2.0) + woodcutting 25 → actual ×0.875
```

Tool มี durability — ใช้ไปเรื่อยๆ จนหัก ซ่อมได้ด้วยวัสดุ

### Gather Animation (Godot)
```gdscript
# GatherNode.gd — attached to resource nodes in field map
@export var resource_type: String
@export var base_yield: int = 3
@export var gather_time: float = 2.0
@export var requires_tool: String = ""  # "" = ไม่ต้องมี tool

func interact(player: Player) -> void:
    if requires_tool and not player.has_tool(requires_tool):
        ToastManager.show("ต้องการ " + requires_tool)
        return
    var progress_bar = $ProgressBar
    progress_bar.visible = true
    var tween = create_tween()
    tween.tween_property(progress_bar, "value", 100, gather_time)
    await tween.finished
    var amount = calc_yield(player.get_proficiency(get_skill()))
    player.add_resource(resource_type, amount)
    ProficiencyManager.add_exp(player, get_skill(), amount)
    start_respawn_timer()
```

---

## 23. Crafting System

### Concept
แบ่งเป็น 2 ประเภท:

**A) Hand Crafting** — ทำได้ทันทีโดยไม่ต้องมีสิ่งก่อสร้าง (recipe เรียบง่าย)
**B) Station Crafting** — ต้องใช้สิ่งก่อสร้าง (แคมป์ไฟ, workbench, forge) ให้ recipe ซับซ้อนได้

### Crafting Categories & Stations
| หมวด | Station ที่ต้องใช้ | ตัวอย่าง output |
|---|---|---|
| Tool | Workbench | Axe, Pickaxe, Sickle |
| Food | Campfire | Cooked Meat, Herb Stew, Bread |
| Potion | Alchemy Table | HP Potion, Stamina Potion |
| Building Material | Sawmill / Stonecutter | Plank, Stone Brick, Rope |
| Weapon (crafted) | Forge | Iron Sword, Stone Polearm |
| Trap | Workbench | Spike Trap, Snare |
| Furniture | Workbench | Bed, Chest, Torch |

### Recipe Structure
```gdscript
# CraftingRecipe resource
var recipe = {
    "id": "recipe_iron_axe",
    "name": "ขวานเหล็ก",
    "station": "forge",
    "inputs": [
        {"item": "iron_ore", "qty": 3},
        {"item": "wood",     "qty": 2},
    ],
    "output": {"item": "iron_axe", "qty": 1},
    "craft_time": 5.0,         # วินาที
    "proficiency_skill": "smithing",
    "proficiency_exp": 20,
    "proficiency_required": 10,  # ต้องมี skill level นี้ก่อน
}
```

### Crafting Proficiency Skills
- `Cooking` — ทำอาหาร (Campfire, Cooking Pot)
- `Alchemy` — ปรุงยา (Alchemy Table)
- `Smithing` — ตีเหล็ก (Forge)
- `Carpentry` — งานไม้ (Workbench, Sawmill)
- `Masonry` — งานหิน (Stonecutter)

### Crafting Schema (เพิ่มใน schema_crafting_v1.sql)
```sql
CREATE TABLE crafting_recipes (
  id                  TEXT PRIMARY KEY,
  name                TEXT NOT NULL,
  station_type        TEXT,              -- null = hand craft
  output_item_id      UUID REFERENCES items(id),
  output_qty          INTEGER NOT NULL DEFAULT 1,
  craft_time_seconds  NUMERIC NOT NULL DEFAULT 0,
  proficiency_skill   TEXT,
  proficiency_exp     INTEGER NOT NULL DEFAULT 0,
  proficiency_required INTEGER NOT NULL DEFAULT 0,
  is_active           BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE crafting_recipe_inputs (
  recipe_id   TEXT NOT NULL REFERENCES crafting_recipes(id),
  item_id     UUID NOT NULL REFERENCES items(id),
  qty         INTEGER NOT NULL,
  PRIMARY KEY (recipe_id, item_id)
);

CREATE TABLE player_proficiency (
  player_id   UUID NOT NULL REFERENCES players(id) ON DELETE CASCADE,
  skill       TEXT NOT NULL,   -- 'woodcutting','mining','cooking','smithing' ฯลฯ
  level       INTEGER NOT NULL DEFAULT 1,
  exp         INTEGER NOT NULL DEFAULT 0,
  PRIMARY KEY (player_id, skill)
);
```

---

## 24. Survival Needs (Soft System)

### Design Philosophy
ไม่ใช่ hardcore survival — **needs เป็น buff/debuff system ไม่ใช่ death condition**
ไม่กิน/ดื่ม/นอน → ไม่ตาย → แต่ stat แย่ลง เล่นยากขึ้น
กิน/ดื่ม/นอน → ได้ buff ช่วย regen และ stat bonus

### Needs Stats
| Need | เต็ม | หมด | Decay rate |
|---|---|---|---|
| Hunger (ความหิว) | 100 | 0 | -1/5 นาที real time |
| Thirst (ความกระหาย) | 100 | 0 | -1/3 นาที real time |
| Fatigue (ความเหนื่อย) | 100 | 0 | -1 ต่อ combat 1 ครั้ง |

**Decay หยุดเมื่อ offline** — ไม่มี real-time decay ขณะ offline

### Effect ตาม Need Level
| Need Level | Effect |
|---|---|
| 76-100 (Well-fed/Hydrated/Rested) | HP Regen +50%, ATK +5%, SPD +5% |
| 51-75 (Satisfied) | HP Regen ปกติ, ไม่มี penalty |
| 26-50 (Hungry/Thirsty/Tired) | HP Regen -50%, Max HP -10% |
| 1-25 (Starving/Dehydrated/Exhausted) | HP Regen หยุด, ATK -15%, SPD -15% |

### การฟื้นฟู
| กิจกรรม | ฟื้นฟู Need | รายละเอียด |
|---|---|---|
| กินอาหาร (cooked) | Hunger +30-60 | ตาม recipe tier |
| กินผลไม้/ดิบ | Hunger +10-20, อาจ Debuff | raw food มีโอกาส Food Poisoning |
| ดื่มน้ำสะอาด | Thirst +40 | ต้องมี Flask + Fresh Water |
| ดื่มน้ำดิบ | Thirst +20, Debuff | อาจเป็น Nausea |
| นอนที่ Bed | Fatigue +80, bonus HP regen | ต้องมี Bed ใน camp |
| นั่งพัก (Campfire) | Fatigue +20/นาที | ไม่ต้องมี Bed |

### Food Item Schema (เพิ่ม columns ใน items)
```sql
ALTER TABLE items ADD COLUMN IF NOT EXISTS
    hunger_restore  INTEGER DEFAULT 0,
    thirst_restore  INTEGER DEFAULT 0,
    fatigue_restore INTEGER DEFAULT 0,
    buff_effect     JSONB DEFAULT NULL,    -- {stat, value, duration_sec}
    debuff_chance   NUMERIC DEFAULT 0,     -- 0.0-1.0
    debuff_effect   TEXT DEFAULT NULL;     -- 'food_poison'/'nausea' etc.

ALTER TABLE players ADD COLUMN IF NOT EXISTS
    hunger   INTEGER NOT NULL DEFAULT 100,
    thirst   INTEGER NOT NULL DEFAULT 100,
    fatigue  INTEGER NOT NULL DEFAULT 100;
```

---

## 25. Building System

### Scope & Location
- สร้างได้เฉพาะ **field map ภายใน camp** ที่ผู้เล่นมีอยู่
- แต่ละ camp มี build zone จำกัด (grid หรือ free-placement ใน area)
- **Shared** — ทุกคนในเซิร์ฟเวอร์เดียวกันเห็นและใช้ได้ แต่เจ้าของ camp (ผู้ที่ unlock camp นั้น) เป็น admin สามารถ lock/unlock permissions ได้

### Building Categories
| หมวด | ตัวอย่าง | Effect |
|---|---|---|
| **Fire** | Campfire, Cooking Pot | ทำอาหารได้, ให้ Warmth buff, จุด respawn |
| **Rest** | Bedroll, Bed, Hammock | ฟื้น Fatigue, bonus HP regen overnight |
| **Storage** | Chest, Barrel, Crate | เพิ่ม inventory storage (shared ใน party) |
| **Crafting** | Workbench, Forge, Alchemy Table, Sawmill, Stonecutter | unlock crafting recipes |
| **Defense** | Wall (Wood/Stone), Gate, Spike Trap, Snare Trap, Watchtower | ป้องกัน monster raid |
| **Utility** | Torch, Signpost, Flag, Notice Board | แสงสว่าง, ทิศทาง, โน้ตสำหรับ player อื่น |
| **Farming** | Garden Bed, Water Trough | ปลูกพืชได้ รดน้ำ harvest |

### Placement System
```
Grid-based placement (16px grid ตาม tile ของ field map)
- แต่ละ building มี footprint (กว้าง × สูง เป็น tiles)
- ต้องวางบน walkable tile เท่านั้น
- ห้ามวางทับกัน
- มี ghost preview ขณะ drag ก่อนวาง (สีเขียว = OK / สีแดง = ไม่ได้)
```

### Building Tier & Materials
| Tier | วัสดุ | HP | ต้านทาน |
|---|---|---|---|
| 1 — ไม้ (Wood) | Wood ×N | 100 | ต่ำ — ไฟทำลายได้ |
| 2 — หิน (Stone) | Stone Brick ×N | 300 | ปานกลาง |
| 3 — เหล็ก (Iron) | Iron Ingot ×N + Stone ×N | 600 | สูง |
| 4 — เทพ (Mythril) | Mythril Ingot ×N | 1200 | สูงมาก + ต้านมนตร์ |

Upgrade tier ได้ in-place โดยเพิ่มวัสดุ tier สูงขึ้น

### Building Damage & Repair
- Monster raid (เฉพาะ server บางประเภท) ทำลาย building ได้
- ซ่อมแซมได้ด้วยวัสดุเดิม (สัดส่วน HP ที่หาย)
- Single player offline: building ไม่โดน damage

### Building Schema (schema_building_v1.sql)
```sql
CREATE TABLE building_blueprints (
  id              TEXT PRIMARY KEY,
  name            TEXT NOT NULL,
  category        TEXT NOT NULL,
  tier            INTEGER NOT NULL DEFAULT 1,
  footprint_w     INTEGER NOT NULL DEFAULT 1,
  footprint_h     INTEGER NOT NULL DEFAULT 1,
  max_hp          INTEGER NOT NULL DEFAULT 100,
  crafting_station TEXT,   -- ถ้าเป็น crafting station ระบุ type
  is_active       BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE blueprint_materials (
  blueprint_id  TEXT NOT NULL REFERENCES building_blueprints(id),
  item_id       UUID NOT NULL REFERENCES items(id),
  qty           INTEGER NOT NULL,
  PRIMARY KEY (blueprint_id, item_id)
);

CREATE TABLE camp_buildings (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  camp_id         UUID NOT NULL REFERENCES tower_camps(id) ON DELETE CASCADE,
  blueprint_id    TEXT NOT NULL REFERENCES building_blueprints(id),
  owner_player_id UUID NOT NULL REFERENCES players(id),
  tile_x          INTEGER NOT NULL,
  tile_y          INTEGER NOT NULL,
  tier            INTEGER NOT NULL DEFAULT 1,
  current_hp      INTEGER NOT NULL,
  max_hp          INTEGER NOT NULL,
  placed_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
  last_repaired_at TIMESTAMPTZ
);

CREATE INDEX idx_camp_buildings ON camp_buildings (camp_id) WHERE current_hp > 0;
```

---

## 26. Combat Skill System

### Concept
Combat Skill คือ **active action** ที่ใช้ระหว่าง ATB combat โดยเฉพาะ
แยกสมบูรณ์จาก Life Skill (§27) — คนละ category คนละ pool EXP

### Skill Sources
Combat Skill ได้มาจาก 3 แหล่ง:
1. **Skill Node (Passive Tree)** — บาง node ให้ active skill เป็น bonus
2. **Skill Scroll** (item จาก drop/gacha) — เรียนรู้ skill ใหม่
3. **Weapon / Armor Innate** — skill ติดมากับ weapon class หรือ armor set bonus

### Skill Hotbar
- 4 slots (Q / E / R / T บน keyboard, face buttons บน controller)
- ลาก skill จาก skill list เข้า slot ได้
- แต่ละ slot แสดง icon + cooldown overlay + energy cost

### Rarity Scaling ของ Combat Skill
Skill Scroll และ Weapon Innate skill มี rarity — **ยิ่ง rarity สูง ผลยิ่งดี:**

| Rarity | Damage mult | Energy cost | Special |
|---|---|---|---|
| common | ×1.0-1.2 | 3 | ไม่มี |
| uncommon | ×1.3-1.6 | 4 | status chance 15% |
| rare | ×1.7-2.2 | 5 | status chance 25%, AOE |
| epic | ×2.3-3.0 | 6 | status chance 40%, AOE+, dual effect |
| legendary | ×3.1-4.5 | 8 | guaranteed status, AOE+, passive trigger |
| mythic | ×4.6-6.0 | 10 | guaranteed + amplified status, terrain effect |

### Skill Attributes
```gdscript
var skill = {
    "id":             "skill_fire_strike",
    "name":           "เพลิงพุ่ง",
    "rarity":         "rare",
    "type":           "active",
    "target":         "single",     # single / aoe / self / all_enemies
    "damage_mult":    1.8,          # × ATK
    "element":        "fire",
    "cooldown":       3,            # turns
    "energy_cost":    5,
    "status_effect":  "burn",
    "status_chance":  0.25,
    "status_duration": 2,
    "anim_id":        "fire_strike",
}
```

### Combat Proficiency (แยกจาก Life Skill)
การใช้ combat skill และอาวุธสะสม **Combat EXP** แยกต่างหาก:

| Proficiency | เพิ่ม EXP จาก | Effect ที่ได้ |
|---|---|---|
| `swordsmanship` | ใช้ sword ใน combat | sword DMG +0.4%/level, CRIT +0.02%/level |
| `polearm_mastery` | ใช้ polearm | polearm DMG +0.5%/level, FIRE_DMG +0.1%/level |
| `archery` | ใช้ bow | bow DMG +0.4%/level, CRIT_RATE +0.03%/level |
| `crossbow` | ใช้ crossbow | crossbow DMG +0.35%/level, CRIT_DMG +0.04%/level |
| `staffcraft` | ใช้ staff | elemental DMG +0.5%/level, skill cooldown -0.01%/level |
| `unarmed` | โจมตีโดยไม่มีอาวุธ | ATK +1/level, CRIT_RATE +0.05%/level |

### Phase 1 Starter Skills (ทุก character เริ่มมี)
| Skill | Rarity | Type | Effect | Energy |
|---|---|---|---|---|
| ฟันตรง (Slash) | common | Melee single | ATK ×1.2 | 3 |
| ฟาดหนัก (Heavy Strike) | common | Melee single | ATK ×2.0, Stun 30% | 5 |
| ร่างเร็ว (Swift) | common | Self buff | SPD +50% next turn | 4 |
| จับ (Capture) | — | Special | ลองจับมอนสเตอร์ | 5 |

---

## 27. Life Skill System

### Concept
Life Skill คือความชำนาญในกิจกรรม **นอก combat** ทั้งหมด
แยกสมบูรณ์จาก Combat Skill — EXP pool แยกกัน, ไม่มีผลต่อ combat โดยตรง

**หลักการสำคัญ:** ทุก skill ที่ NPC ทำได้ ผู้เล่นทำได้เช่นกัน ถ้ามี Life Skill level เพียงพอ + อุปกรณ์ครบ

**Rarity Scaling:** ยิ่ง rarity ของ material หรือ item ที่ใช้/ทำสูง ยิ่งได้ผลดีและ EXP สูงกว่า

---

### Life Skill Categories & Skills

#### กลุ่ม A — การผลิต (Production)
| Skill | ทำอะไร | EXP จาก | Rarity Scaling |
|---|---|---|---|
| `smithing` | craft อาวุธ/เกราะ, identify item, ซ่อม equipment | craft/identify/repair สำเร็จ | item rarity สูง → EXP ×2-5, ผลดีกว่า |
| `carpentry` | craft furniture, building material, tool | craft สำเร็จ | material tier สูง → durability ผลผลิตสูงขึ้น |
| `masonry` | craft stone building, stonecutter recipes | craft สำเร็จ | stone tier สูง → DEF ของ building สูงขึ้น |
| `alchemy` | craft potion, identify อย่างละเอียด, รักษา HP | brew สำเร็จ | rare+ herb → potion effect แรงขึ้น 50-200% |
| `cooking` | ทำอาหาร, food quality | cook สำเร็จ | ingredient rarity สูง → Hunger restore+, buff นานขึ้น |
| `tailoring` | craft cloth armor, accessory, bag | craft สำเร็จ | cloth rarity สูง → DEF/affix slot เพิ่ม |
| `repair` | ซ่อม durability equipment | ซ่อมสำเร็จ | item rarity สูง → EXP สูง, ต้องการ level สูงกว่า |
| `upgrade` | upgrade/refine equipment | upgrade สำเร็จ | item rarity สูง → EXP สูง, bonus จาก level |

#### กลุ่ม B — การเก็บเกี่ยว (Gathering)
| Skill | ทำอะไร | EXP จาก | Rarity Scaling |
|---|---|---|---|
| `woodcutting` | ตัดต้นไม้ | ตัดสำเร็จ | ต้นไม้ rare → yield+, rare wood drop |
| `mining` | ขุดหิน/แร่ | ขุดสำเร็จ | แร่ tier สูง → EXP ×2-4 |
| `foraging` | เก็บพืช/ดอกไม้/สมุนไพร | เก็บสำเร็จ | rare herb → EXP ×2 |
| `fishing` | ตกปลา | จับปลาสำเร็จ | ปลา rarity สูง → EXP ×1.5-5 |
| `scavenging` | เก็บของบนพื้น, ล่าสมบัติ | เก็บ/ขุดสำเร็จ | treasure tier สูง → EXP สูง |

#### กลุ่ม C — การเกษตร (Agriculture)
| Skill | ทำอะไร | EXP จาก | Rarity Scaling |
|---|---|---|---|
| `farming` | ปลูกพืช, รดน้ำ, เก็บเกี่ยว | harvest สำเร็จ | crop rarity สูง → yield+, special drop |
| `animal_handling` | เลี้ยงสัตว์, tame, care | ดูแลสัตว์/tame สำเร็จ | สัตว์ rarity สูง → output+ rare |
| `hunting` | ล่าสัตว์, tracking | kill/capture สำเร็จ | สัตว์ rarity สูง → EXP ×2-6 |

#### กลุ่ม D — การก่อสร้าง (Construction)
| Skill | ทำอะไร | EXP จาก | Rarity Scaling |
|---|---|---|---|
| `construction` | build/upgrade สิ่งก่อสร้าง | place/upgrade สำเร็จ | material tier สูง → HP building เพิ่ม, EXP สูง |

#### กลุ่ม E — การค้า & สังคม (Trade & Social)
| Skill | ทำอะไร | EXP จาก | Rarity Scaling |
|---|---|---|---|
| `trading` | ขาย/ซื้อกับ NPC ราคาดีขึ้น | transaction | item rarity สูง → margin กว้างขึ้น |
| `naturalist` | ดู ecosystem UI, track สัตว์ | observe/track | rare species → EXP สูง |

---

### Rarity Scaling — หลักการรวม

```
# ทุก Life Skill ใช้หลักการนี้:
base_exp    = action_base_exp
rarity_mult = {common:1.0, uncommon:1.5, rare:2.0, epic:3.0, legendary:5.0, mythic:8.0}
exp_gained  = base_exp × rarity_mult[item_rarity]

# ผลที่ได้ก็ scale ตาม rarity เช่นกัน:
output_quality = base_output × (1 + (rarity_tier - 1) × 0.3)
# common=×1.0, uncommon=×1.3, rare=×1.6, epic=×1.9, legendary=×2.2, mythic=×2.5
```

**ตัวอย่าง cooking:**
```
ทำ "ข้าวต้มธรรมดา" (common ingredient):
  Hunger restore: 30, buff: ไม่มี, EXP: 10

ทำ "สตูว์มังกร" (epic ingredient):
  Hunger restore: 60, buff: ATK+10% 30 นาที, EXP: 30

ทำ "อมฤตเทพ" (mythic ingredient):
  Hunger restore: 100, buff: all stat +15% 60 นาที, EXP: 80
```

---

### NPC ↔ Player Life Skill Mapping

| NPC บริการ | Life Skill | Station | Min Level | Rarity ที่ทำได้ |
|---|---|---|---|---|
| Blacksmith — identify | `smithing` | Workbench | 20 | common/uncommon |
| Blacksmith — identify rare+ | `smithing` | Workbench | 40/65/90 | rare/epic/legendary |
| Blacksmith — repair common | `repair` | Workbench | 10 | common |
| Blacksmith — repair rare | `repair` | Forge | 30 | rare |
| Blacksmith — repair epic | `repair` | Forge tier 2 | 55 | epic |
| Blacksmith — repair legendary | `repair` | Forge tier 3 | 80 | legendary |
| Blacksmith — upgrade/refine | `upgrade` | Forge | 25 | ตาม item rarity |
| Merchant — ซื้อขาย | `trading` | — | 1 | ทุก rarity |
| Nurse — รักษา HP | `alchemy` | Alchemy Table | 40 | — |
| Gate Keeper — warp | — | ไม่มีทางแทน | — | — |

---

### Repair Skill Detail
```
repair skill level → ซ่อม durability ได้:
  level 1-24  : 20% ของที่หาย
  level 25-49 : 40%
  level 50-74 : 65%
  level 75-99 : 85%
  level 100   : 100% (Mastery = เทียบเท่า NPC)

วัสดุซ่อมตาม rarity:
  common/uncommon : Wood ×2 หรือ Stone ×2
  rare            : Iron Ore ×2
  epic            : Gold Ore ×2
  legendary       : Mythril Ore ×2
  mythic          : Primordial Shard ×1

EXP = (durability ซ่อม) × rarity_mult[item_rarity] × 0.5
```

### Trading Skill Detail
```
trading level → ราคาขาย/ซื้อ:
  level 1   : ขาย 70% / ซื้อราคาเต็ม
  level 25  : ขาย 80%
  level 50  : ขาย 90% / ซื้อ -5%
  level 75  : ขาย 95%
  level 100 : ขาย 100% / ซื้อ -10% (Mastery)

EXP = gold value × 0.01 × rarity_mult[item_rarity]
```

---

### Level & EXP
- Level 1-100 ต่อ skill
- `exp_for_level(n) = FLOOR(100 × n^1.5)`
- เพิ่ม EXP จากการใช้งานจริงเท่านั้น — ไม่มี idle training
- ฝึกเร็ว → ทำ action ซ้ำๆ กับวัสดุ rarity สูงขึ้น

### Milestone Rewards (ทุก 10 level)
- Level 10: ปลดล็อก recipe / ability ใหม่
- Level 25: quality/effect bonus เพิ่มขึ้น
- Level 50: ปลดล็อก advanced recipe, สามารถทำ rarity ระดับถัดไปได้
- Level 75: title พิเศษ (เช่น "นักตีเหล็กฝีมือเยี่ยม")
- Level 100: Mastery — ปลดล็อก hidden recipe / passive พิเศษ + ทำได้เทียบเท่า NPC ระดับสูงสุด

### Schema (schema_crafting_v1.sql)
```sql
-- player_proficiency แยก skill_type เพื่อ filter
ALTER TABLE player_proficiency ADD COLUMN IF NOT EXISTS
    skill_type TEXT NOT NULL DEFAULT 'life';
    -- 'combat' หรือ 'life'

-- skills ทั้งหมด:
-- Combat: swordsmanship, polearm_mastery, archery, crossbow, staffcraft, unarmed
-- Life A: smithing, carpentry, masonry, alchemy, cooking, tailoring, repair, upgrade
-- Life B: woodcutting, mining, foraging, fishing, scavenging
-- Life C: farming, animal_handling, hunting
-- Life D: construction
-- Life E: trading, naturalist

CREATE INDEX idx_proficiency_type ON player_proficiency (player_id, skill_type);
```

---

## 28. Status Effects (Buff / Debuff)

### Effect Categories
| หมวด | ตัวอย่าง | Duration type |
|---|---|---|
| Elemental DoT | Burn, Freeze, Shocked | turns |
| Physical | Stun, Slow, Bleed | turns |
| Survival | Food Poison, Nausea, Hypothermia | real minutes |
| Buff | Well-fed, Hasted, Fortified | turns / real minutes |

### Effect Definitions
| ID | ชื่อ | Effect | Stack |
|---|---|---|---|
| `burn` | ติดไฟ | HP -5% ต่อ turn | ×3 max |
| `freeze` | แช่แข็ง | SPD -60%, ข้าม turn 30% | ไม่ stack |
| `shocked` | ถูกฟ้าผ่า | รับ damage +25%, SPD -20% | ไม่ stack |
| `stun` | มึนงง | ข้าม 1 turn | ไม่ stack |
| `slow` | ช้า | SPD -30% | ไม่ stack |
| `bleed` | เลือดออก | HP -3% ต่อ turn | ×5 max |
| `poison` | พิษ | HP -2% ต่อ turn (นาน) | ×2 max |
| `well_fed` | อิ่ม | HP Regen +50%, ATK +5% | ไม่ stack |
| `hasted` | เร็ว | SPD +50% | ไม่ stack |
| `fortified` | เสริมป้อม | DEF +30% | ไม่ stack |
| `food_poison` | อาหารเป็นพิษ | HP -1%/นาที, SPD -20% | ไม่ stack |
| `hypothermia` | ตัวเย็น | ATK -25%, HP Regen -80% | ไม่ stack |

### Resist & Cleanse
- **Elemental resist**: มาจาก armor และ skill node
- **Cleanse**: item "ยาล้างพิษ" ลบ debuff ทั้งหมด, skill บาง node cleanse ได้
- **Immunity**: ascension node บางอัน immune to specific effect

### Schema (เพิ่มใน schema_combat_v1.sql)
```sql
CREATE TABLE player_status_effects (
  player_id     UUID NOT NULL REFERENCES players(id) ON DELETE CASCADE,
  effect_id     TEXT NOT NULL,
  stacks        INTEGER NOT NULL DEFAULT 1,
  turns_left    INTEGER,          -- null = duration ใน seconds
  seconds_left  NUMERIC,
  applied_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (player_id, effect_id)
);
```

---

## 29. Death Penalty & Respawn

### Normal / Hard / Ascendant Mode
| Mode | Death Effect | Respawn Location | EXP Penalty |
|---|---|---|---|
| Normal | ไม่มี penalty | Checkpoint ล่าสุด, HP 50% | ไม่มี |
| Hard | เสียเงิน 10% gold ที่ถือ | Checkpoint ล่าสุด, HP 30% | ไม่มี |
| Ascendant | เสียเงิน 20% gold, drop วัสดุ crafting ที่ถือ | Camp spawn ของ floor, HP 20% | ไม่มี |
| Eternal Path | ตัวละครล็อกถาวร (`death_locked`) | ไม่มี | ทั้งชีวิต |

### Drop on Death (Ascendant)
- Drop เฉพาะ **crafting materials** (wood, stone, ore, herb) สูงสุด 5 slot
- ไม่ drop equipment หรือ gacha item
- ของที่ drop อยู่บนพื้น 10 นาที ก็หาย — คนอื่นเก็บได้

### Respawn Flow
```
Player HP → 0
    │
    ├── Eternal Path → modal "ผู้ท้าชิงสิ้นชีพ..." → lock character → Character Select
    │
    └── Normal/Hard/Ascendant:
            apply penalty
            → fade to black (2 วินาที)
            → spawn at: ถ้ามี checkpoint ที่ผ่านมา → ไป checkpoint
                        ถ้าไม่มี → ไป camp spawn ของ floor
            → HP regen 5%/วินาที จน full หรือ player เดิน
```

### Checkpoint Mechanic
- เดินเข้า checkpoint camp → auto-save progress + ฟื้น 30% HP
- แสดง banner "🚩 Checkpoint — บันทึกแล้ว"
- Respawn ที่ checkpoint ล่าสุดที่ผ่าน **ใน session นั้น** (reset ถ้า logout)

---

## 30. NPC, Town Hub & Warp

### Town Hub (แต่ละ band มี 1 hub)
Hub คือ safe zone ภายใน camp พิเศษ (camp_type = `checkpoint` ที่ band เปิดตัว)
ไม่มีศัตรู, มี NPC บริการต่างๆ

**NPC ที่มีใน Hub:**
| NPC | บริการ |
|---|---|
| พ่อค้า (Merchant) | ขาย consumable, tool, basic material |
| ช่างซ่อม (Blacksmith) | ซ่อม equipment durability |
| คนรับฝาก (Storage Keeper) | เข้าถึง Stash (ดู §31) |
| ผู้ส่งสาร (Messenger) | รับ/ส่ง quest (ดู §32) |
| ผู้พิทักษ์ประตู (Gate Keeper) | warp ไป hub อื่น (ถ้าปลดล็อกแล้ว) |

### Warp System
```
ปลดล็อก warp ได้เมื่อ: ผ่าน checkpoint ของ floor นั้น ≥ 1 ครั้ง

Warp destinations:
- Hub ของ band ที่ผ่านมาแล้ว
- Camp spawn ของ floor ที่ผ่านมาแล้ว (ต้องซื้อ "ใบอนุญาตเดินทาง" จาก Gate Keeper)

Cost: 50 gold ต่อครั้ง (ลดได้ด้วย skill node)
```

### NPC Dialogue
Phase 1: text-only dialogue (ไม่มีเสียง), กล่อง dialogue แบบ RPG คลาสสิก
โครงสร้าง:
```gdscript
var dialogue = {
    "npc_id": "merchant_band1",
    "greeting": ["ยินดีต้อนรับ ผู้ท้าชิง!", "มีอะไรให้ช่วยไหม?"],
    "options": [
        {"text": "ซื้อของ", "action": "open_shop"},
        {"text": "ถามเรื่องหอ", "action": "show_lore"},
        {"text": "ลาก่อน",  "action": "close"},
    ]
}
```

---

## 31. Inventory, Stash & Storage

### Inventory (พกพา)
- **40 slots** ต่อ character
- Stackable item (material, consumable): stack สูงสุด 99 ต่อ slot
- Equipment: 1 ชิ้นต่อ slot
- Weight system: ไม่มี (เพื่อความง่าย phase 1)

### Stash (คลังถาวร)
- เข้าถึงได้ที่ Storage Keeper ใน Hub เท่านั้น
- **60 slots** เริ่มต้น ขยายได้ด้วย gold
- แชร์ระหว่าง Online character ของ account เดียวกัน
- Offline character มี local stash แยก (ไม่ cross)

### Camp Chest (สาธารณะ)
- Chest ที่ build ใน camp — ใครก็เข้าถึงได้ใน server นั้น
- ขโมยของกันได้ — ไม่มีการล็อก (design choice: trust-based community)
- Owner สามารถ lock chest ได้ (ต้องใช้ Key item)

### Auto-pickup Rules
```
ของบนพื้น → เดินผ่าน:
  - material (wood/stone/ore/herb): auto-pickup ถ้า inventory ไม่เต็ม
  - equipment/gacha item: ต้องกด F confirm ก่อน
  - gold: auto-pickup เสมอ
```

### Inventory Schema (เพิ่มใน schema_core_v2.sql)
```sql
ALTER TABLE players ADD COLUMN IF NOT EXISTS
    inventory_slots INTEGER NOT NULL DEFAULT 40;

CREATE TABLE player_stash (
  player_id    UUID NOT NULL REFERENCES players(id) ON DELETE CASCADE,
  item_id      UUID NOT NULL REFERENCES items(id),
  quantity     INTEGER NOT NULL DEFAULT 1 CHECK (quantity > 0),
  slot         INTEGER NOT NULL,
  stash_tab    INTEGER NOT NULL DEFAULT 0,   -- 0 = default tab
  added_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (player_id, slot, stash_tab)
);
```

---

## 32. Quest & Mission System

### Quest Types
| Type | Reset | ตัวอย่าง |
|---|---|---|
| `main` | ไม่ reset | kill boss band 1, reach floor 5, ปลดล็อก ascension |
| `daily` | ทุกวัน 00:00 | kill 20 monster, gather 50 wood, craft 5 item |
| `weekly` | ทุกจันทร์ | clear floor X, kill mini-boss 5 ตัว |
| `achievement` | ไม่ reset, ทำครั้งเดียว | first kill, first craft, reach divinity 5 |

### Quest Condition Types
```gdscript
# เงื่อนไข quest ที่รองรับ Phase 1:
"kill":       {"monster_type": "all" / "boss" / specific_name, "count": N}
"gather":     {"resource": "wood"/"stone"/"herb", "count": N}
"craft":      {"item_id": uuid / "any", "count": N}
"reach":      {"floor": N}
"unlock":     {"node_id": uuid}
"build":      {"blueprint_id": "campfire" / "any", "count": N}
"eat":        {"food_type": "cooked" / "any", "count": N}
```

### Quest Reward
```gdscript
var reward = {
    "gold": 500,
    "gems": 50,
    "items": [{"item_id": uuid, "qty": 3}],
    "proficiency_exp": {"skill": "cooking", "exp": 100},
    "title": "ผู้พิชิตแดนศรัทธา",  # null ถ้าไม่มี
}
```

### Quest UI
```
[Quest Log — แสดงจาก Messenger NPC หรือ pause menu]
┌───────────────────────────────────────────┐
│  Main Quest                               │
│  ▸ พิชิตบอสแดนศรัทธา          0/1   [!]  │
│                                           │
│  Daily (reset ใน 4:32:10)                 │
│  ▸ กำจัดมอนสเตอร์ 20 ตัว     15/20       │
│  ▸ เก็บไม้ 30 ท่อน            30/30  [รับ]│
│                                           │
│  Achievement                              │
│  ▸ ปลดล็อก Skill Node ครั้งแรก ✓ [รับ]  │
└───────────────────────────────────────────┘
```

---

## 33. Party & Co-op System

### Party Formation
- สูงสุด **4 คน** ต่อปาร์ตี้ (Host + 3 members)
- Online character เท่านั้น — Offline character เล่น multiplayer ไม่ได้
- สร้างปาร์ตี้ได้จาก: Friends List, Server List, หรือ ชวนตรงๆ ใน field map

### Loot Rules (เลือกได้โดย Party Leader)
| Mode | กฎ |
|---|---|
| Free-for-all | ใครเก็บก่อนได้ก่อน |
| Round Robin | หมุนเวียนสิทธิ์รับของ |
| Need / Greed | roll dice — Need ชนะ Greed เสมอ |
| Leader | Leader แจกของเอง |

### EXP / Progress Sharing
- Combat EXP (Proficiency): แต่ละคนได้เท่ากัน (ไม่แบ่ง)
- Gold drop: แบ่งเท่าๆ กัน auto
- Quest progress: นับสำหรับทุกคนในปาร์ตี้
- Floor progress: ใช้ floor ของ Host เป็น reference

### Difficulty ใน Party
- ใช้ difficulty ของ **Host**
- Eternal Path: member ที่ตายใน session ถือว่าตายจริง (death_locked)
- ดังนั้น Eternal party ต้องยอมรับ risk ร่วมกัน

### Party UI
```
[Party Panel — มุมซ้ายบน ขณะอยู่ใน Party]
┌──────────────────────┐
│ 🗡️ ปาร์ตี้ (3/4)     │
│ [Portrait] สมชาย  HP████░ │
│ [Portrait] สมหญิง HP███░░ │
│ [Portrait] คุณ    HP█████ │
└──────────────────────┘
```

---

## 34. Friend List System

### Concept
Friend List เป็นศูนย์กลาง social ของเกม — ดู online status, invite party, whisper, track activity ของเพื่อน
ใช้ได้กับ **Online character เท่านั้น** (Guest มีได้แต่จำกัด, Offline ไม่มี)

---

### Friend Request Flow
```
ผู้เล่น A ต้องการเพิ่มเพื่อน B:
  วิธี 1: ค้นหาชื่อ → [ส่งคำขอ]
  วิธี 2: คลิก portrait B ใน field map → [เพิ่มเพื่อน]
  วิธี 3: คลิกชื่อใน chat → [เพิ่มเพื่อน]
  วิธี 4: ใน Party panel → คลิกชื่อ → [เพิ่มเพื่อน]
  ↓
B ได้รับ notification "A ส่งคำขอเป็นเพื่อน"
  ├── [ยอมรับ] → เป็นเพื่อนกัน bilateral
  └── [ปฏิเสธ] → A ไม่รู้ว่าถูกปฏิเสธ (แค่ "ยังรอ")
```

**Privacy setting:**
- `anyone` — ใครก็ส่ง request ได้ (default)
- `friends_of_friends` — ส่งได้เฉพาะคนที่มีเพื่อนร่วมกัน
- `nobody` — ปิดรับ request ทั้งหมด

---

### Friend Status & Online Indicator

| Status | ไอคอน | แสดงให้เพื่อนเห็น |
|---|---|---|
| Online (in game) | 🟢 | ชื่อ + Band + Floor ที่อยู่ |
| In Combat | ⚔️ | ชื่อ + "กำลังต่อสู้" |
| AFK (ไม่ active > 5 นาที) | 🟡 | ชื่อ + "ไม่อยู่หน้าจอ" |
| Offline | ⚫ | ชื่อ + "ออฟไลน์ N ชม.ที่แล้ว" |
| Do Not Disturb | 🔴 | ชื่อ + "ไม่ต้องการถูกรบกวน" (ซ่อน location) |

**ผู้เล่นเลือก privacy ได้:**
- แสดง location แบบ exact (Band 2, Floor 14, Camp: Elite Camp)
- แสดงแบบ rough (Band 2 เท่านั้น)
- ซ่อน location (แสดงแค่ online/offline)

---

### Friend List UI

```
[Friend List]  ─────────────────────────────────
[🔍 ค้นหาเพื่อน...]           [+ เพิ่มเพื่อน]

Online (4)
  🟢 สมชาย       Band 2 · Floor 14    [Party] [💬]
  ⚔️ มานี         กำลังต่อสู้           [Party] [💬]
  🟡 วิชัย        ไม่อยู่หน้าจอ          [💬]
  🟢 นภา          Band 1 · Floor 7     [Party] [💬]

Offline (12)
  ⚫ สมศรี        3 ชั่วโมงที่แล้ว      [💬]
  ⚫ ประสิทธิ์     1 วันที่แล้ว          [💬]
  ... (แสดง 5 ล่าสุด, กด "ดูทั้งหมด")

[คำขอที่รอ (2)] ────────────────────────────────
  สมหญิง  [ยอมรับ] [ปฏิเสธ]
  ไชยา     [ยอมรับ] [ปฏิเสธ]
```

---

### Friend Actions

**[Party]** — invite เพื่อนเข้าปาร์ตี้ทันที
- ถ้า party เต็ม (4/4) → ปุ่มเป็น greyed out
- เพื่อนรับ notification "[ชื่อ] ชวนคุณเข้าปาร์ตี้" → [เข้าร่วม] [ปฏิเสธ]

**[💬]** — เปิด Whisper chat กับเพื่อนคนนั้น (offline ก็ส่งได้ → เพื่อนเห็นตอน login)

**คลิกชื่อ** → เปิด Friend Profile Panel:
```
┌─────────────────────────────────┐
│ [Portrait] สมชาย                │
│ Divinity: เซียน (Lv.5)          │
│ Floor สูงสุด: Band 2, Floor 16  │
│ เล่นมาแล้ว: 124 ชั่วโมง         │
│                                 │
│ [Party] [Whisper] [ลบเพื่อน]    │
│ [บล็อก] [รายงาน]                │
└─────────────────────────────────┘
```

---

### Friend Limit

| Account Type | Friend สูงสุด | คำขอรอสูงสุด |
|---|---|---|
| Guest | 10 | 5 |
| Account (ปกติ) | 200 | 50 |

---

### Block & Report

**Block:**
- บล็อกแล้ว → ไม่เห็น message จากคนนั้น, ส่ง request ไม่ได้, ไม่เห็นใน nearby player list
- บล็อกแล้วเป็นเพื่อนกันอยู่ → ยกเลิก friendship อัตโนมัติ
- คนที่ถูกบล็อกไม่รู้ว่าถูกบล็อก

**Report:**
- เลือก reason: spam / harassment / cheating / inappropriate name / other
- ส่ง flag ไปยัง admin queue

---

### Friend Activity Feed (ใหม่)

เมื่อ login → แสดง activity ของเพื่อนช่วง 24 ชั่วโมงที่ผ่านมา:
```
[Activity — เพื่อนของคุณ]
  🏆 สมชาย  ปลดล็อก Ascension Node "อัคคีเทพบุตร"
  ⚔️ มานี    พิชิต Boss Band 2 เป็นครั้งแรก!
  🎣 นภา     จับปลาอมตะได้ (Legendary)
  🏗️ วิชัย   สร้าง Forge tier 3 ที่ Floor 8
```

Activity feed กรองเฉพาะ milestone สำคัญ — ไม่แสดงทุก action

---

### Notification System

| Event | Notification |
|---|---|
| เพื่อนส่ง friend request | 🔔 "[ชื่อ] ส่งคำขอเป็นเพื่อน" |
| เพื่อน online | 🟢 "[ชื่อ] เข้าเล่นแล้ว" (toggle ได้ใน settings) |
| เพื่อน invite party | 🎮 "[ชื่อ] ชวนคุณเข้าปาร์ตี้" |
| เพื่อน whisper (offline) | 📬 "[ชื่อ] ส่งข้อความถึงคุณ" |
| เพื่อน achieve milestone | 🏆 "[ชื่อ] [achievement]" (toggle ได้) |

Notification แสดงที่ **bell icon** บน HUD — กด bell เพื่อเปิด notification center

---

### Schema (schema_social_v1.sql เพิ่ม)

```sql
CREATE TABLE friendships (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  requester_id  UUID NOT NULL REFERENCES players(id) ON DELETE CASCADE,
  addressee_id  UUID NOT NULL REFERENCES players(id) ON DELETE CASCADE,
  status        TEXT NOT NULL DEFAULT 'pending',
    -- 'pending' / 'accepted' / 'blocked'
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (requester_id, addressee_id),
  CHECK (requester_id <> addressee_id)
);

CREATE TABLE friend_requests (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  from_id      UUID NOT NULL REFERENCES players(id) ON DELETE CASCADE,
  to_id        UUID NOT NULL REFERENCES players(id) ON DELETE CASCADE,
  sent_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  expires_at   TIMESTAMPTZ NOT NULL DEFAULT (now() + INTERVAL '7 days'),
  UNIQUE (from_id, to_id)
);

CREATE TABLE player_notifications (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  player_id   UUID NOT NULL REFERENCES players(id) ON DELETE CASCADE,
  type        TEXT NOT NULL,
    -- 'friend_request'/'friend_online'/'party_invite'/'whisper'/'achievement'
  from_id     UUID REFERENCES players(id),
  payload     JSONB NOT NULL DEFAULT '{}',
  is_read     BOOLEAN NOT NULL DEFAULT FALSE,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE player_blocks (
  blocker_id  UUID NOT NULL REFERENCES players(id) ON DELETE CASCADE,
  blocked_id  UUID NOT NULL REFERENCES players(id) ON DELETE CASCADE,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (blocker_id, blocked_id)
);

-- View: active friendships (bilateral)
CREATE VIEW active_friends AS
SELECT
  f.requester_id AS player_id,
  f.addressee_id AS friend_id
FROM friendships f WHERE f.status = 'accepted'
UNION ALL
SELECT
  f.addressee_id,
  f.requester_id
FROM friendships f WHERE f.status = 'accepted';

CREATE INDEX idx_friendships_addressee ON friendships (addressee_id, status);
CREATE INDEX idx_notifications_unread  ON player_notifications (player_id, is_read) WHERE is_read = FALSE;
```

---

## 35. Chat System


### Channel Types
| Channel | Prefix | ใครเห็น |
|---|---|---|
| Global | ไม่มี | ทุกคนใน server |
| Party | /p | เฉพาะปาร์ตี้ |
| Whisper | /w [ชื่อ] | เฉพาะคนที่ส่งและรับ |
| System | — | auto จากระบบ (drop ดี, level up) |

### Chat Features
- ข้อความ max 200 ตัวอักษร
- Rate limit: 3 ข้อความ/วินาที
- Filter คำไม่เหมาะสม (blacklist)
- Block player: ซ่อน message จาก player นั้น
- Report: ส่ง flag ไปให้ admin

### Chat UI
```
[Chat Box — มุมล่างซ้าย]
[Global] สมชาย: พบ legendary drop!
[System] สมหญิง ปลดล็อก Ascension Node
[Party]  คุณ: มา boss กัน
[_____________________] [ส่ง]
  /p  /w  [ช่อง: Global ▼]
```

---

## 36. Anti-Cheat & Security

### Server-Authoritative Actions
สิ่งเหล่านี้ **ต้อง validate ฝั่ง server เสมอ:**
- Combat damage calculation
- Item drop & loot assignment
- Currency transaction (gold/gem)
- Skill unlock (ตรวจสอบ prerequisite)
- Building placement (ตรวจ resource)
- Quest completion

### Rate Limiting (Supabase RLS + Edge Function)
```
- Combat action: max 10 actions/วินาที
- Gather: max 1 action/0.5 วินาที
- Chat: max 3 messages/วินาที
- Trade: max 5 listings/นาที
```

### Anomaly Detection (Phase 2+)
- Gold gain > threshold/ชั่วโมง → flag
- Item มาจาก source ไม่รู้จัก → flag
- Position teleport (movement too fast) → kick

### Ban System
```sql
CREATE TABLE player_bans (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  player_id   UUID NOT NULL REFERENCES players(id),
  reason      TEXT NOT NULL,
  banned_by   UUID REFERENCES admin_users(id),
  expires_at  TIMESTAMPTZ,   -- null = permanent
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

---

## 37. Mini-map & HUD

### HUD Layout
```
┌────────────────────────────────────────────────────┐
│ [Portrait] ชื่อ / Divinity   💎 xxx  🪙 xxx  ⚡ xx │
│ HP ████████░░  Stamina ██████░░                    │
│ [Buff icons]                                        │
│                                          [Mini-map] │
│                                                     │
│                    [Field Map]                      │
│                                                     │
│ [Q][E][R][T]  ← Skill hotbar (ATB cooldown overlay)│
│ Hunger ████░  Thirst ████░  Fatigue ███░            │
└────────────────────────────────────────────────────┘
```

### Mini-map
- ขนาด 120×120px มุมขวาบน
- แสดง: ผู้เล่น (จุดเหลือง), ศัตรู (จุดแดง), resource node (จุดเขียว), building (จุดเทา)
- M → toggle full map
- Full map แสดง camp connections ทั้ง floor

### Needs Bars (HUD ล่าง)
- แสดง Hunger / Thirst / Fatigue เป็น bar เล็กๆ
- กะพริบเมื่อ level < 25 (เตือน)
- ซ่อนได้ใน Settings

---

## 38. Tutorial & Onboarding

### Design Principle
**"Learn by doing"** — ไม่มี wall of text ตั้งแต่ต้น
ทุก tutorial trigger เมื่อผู้เล่นทำสิ่งนั้นครั้งแรก

### Onboarding Flow
```
[สร้างตัวละคร]
    ↓
[เข้าหอเทวภพ — Floor 1 Camp 1: Tutorial Zone]
    ↓ (ป้ายอธิบาย + highlight)
[Tutorial 1: การเดินและ interact]
    ↓ พบมอนสเตอร์ตัวแรก
[Tutorial 2: ATB Combat — โจมตี, ทักษะ, หนี]
    ↓ ศัตรูตาย → drop item
[Tutorial 3: เก็บของ — auto-pickup vs manual]
    ↓ เดินไปต้นไม้
[Tutorial 4: Gathering — ตัดไม้]
    ↓ มี wood ในมือ
[Tutorial 5: Crafting — สร้าง Campfire]
    ↓ วาง Campfire
[Tutorial 6: Building — placement]
    ↓ นั่งข้าง Campfire
[Tutorial 7: Survival needs — กิน/พัก]
    ↓ เดินถึง Skill Tree NPC
[Tutorial 8: Passive Skill Tree — ปลดล็อก node แรก]
    ↓ เดินไป Gacha Stone
[Tutorial 9: Gacha — pull ครั้งแรก (free)]
    ↓ Tutorial จบ → open world
```

### Tutorial Tips (In-game tooltip)
- ทุกระบบใหม่ที่เจอครั้งแรก → popup tooltip มุมขวา "ระบบใหม่: ..." (กด X ปิด)
- ดู tutorial ซ้ำได้จาก Settings → Help

---

## 39. Hunting System

### Concept
สัตว์ป่าแยกออกจาก monster ชัดเจน — monster คือ "ศัตรู" ล่าเพื่อ combat loot
สัตว์ป่าคือ "เหยื่อ" ล่าเพื่อ crafting material (เนื้อ, หนัง, กระดูก, ขน)

### สัตว์ประเภท A — สัตว์ธรรมดา (Field Map ทั่วไป)
Spawn ใน field map เหมือน monster แต่ **ไม่โจมตีก่อน** (passive) — วิ่งหนีเมื่อ player เข้าใกล้

| สัตว์ | Band | วิธีล่า | Drop |
|---|---|---|---|
| กระต่าย | 1 (Thai) | วิ่งตาม + โจมตี 1 ครั้ง | Rabbit Meat, Fur |
| กวาง | 1-2 | Bow/Spear เท่านั้น (วิ่งเร็ว) | Venison, Hide, Antler |
| หมูป่า | 1-2 | โจมตีเมื่อถูกทำให้บาดเจ็บ | Boar Meat, Tusk, Hide |
| นก | 2-3 | Bow เท่านั้น | Feather, Bird Meat |
| ปลาแม่น้ำ | ทุก band | ตกปลา (§40) | Fish |

### สัตว์ประเภท B — สัตว์หายาก (Hunting Zone)
camp_type ใหม่: `hunting_zone` — area พิเศษบน floor ที่มีสัตว์ rarity สูง
เข้าได้ฟรีแต่ต้องมี Hunting License (ซื้อจาก NPC หรือ craft)

| สัตว์ | Band | Rarity | Drop พิเศษ |
|---|---|---|---|
| เสือโคร่ง | 1-2 | Uncommon | Tiger Pelt, Claw (crafting tier 2) |
| ช้างเผือก | 2 | Rare | Ivory, Blessed Hide |
| มังกรน้ำ | 3 | Epic | Dragon Scale, Dragon Blood |
| ฟีนิกซ์ | 4-5 | Legendary | Phoenix Feather, Ember Core |
| เทพสัตว์ | Band ตาม pantheon | Mythic | Mythic Material เฉพาะ band |

### Hunting Mechanics

**สัตว์ธรรมดา:**
```
1. เดินเข้าใกล้ → สัตว์ตรวจจับ (detection radius ตาม SPD)
2. สัตว์วิ่งหนีตาม BFS path หนีจาก player
3. player ไล่ตาม → โจมตี (สัตว์ passive ไม่สู้กลับ ยกเว้น Boar ถ้า HP < 50%)
4. ตาย → drop material, proficiency EXP (hunting)
```

**สัตว์หายาก (Hunting Zone):**
```
1. ต้องมี Hunting License + weapon ที่เหมาะสม
2. Tracking phase: หา footprint node บนแผนที่ → ติดตาม → พบสัตว์
3. Stealth approach: ถ้าเดินช้า (Hold Shift) → detection radius ลด 50%
4. Combat: สัตว์หายากสู้กลับ มี HP สูง + special attack
5. ถ้าหนีไม่ทัน → สัตว์ escape (disappear) และ respawn ช้า (6 ชั่วโมง)
```

### Stealth System (สำหรับ Hunting)
```gdscript
# player เข้า stealth mode (Hold Shift ขณะ hunting)
var stealth_active: bool = false
var detection_multiplier: float = 1.0

func _input(event):
    if event is InputEventKey and event.keycode == KEY_SHIFT:
        stealth_active = event.pressed
        detection_multiplier = 0.5 if stealth_active else 1.0
        # SPD ลด 40% ขณะ stealth
        movement_speed = base_speed * (0.6 if stealth_active else 1.0)
```

### Tracking System
Footprint node: จุด interact บนแผนที่ที่มองเห็นได้ด้วย Hunting skill ≥ 20
- Footprint มีอายุ 10 นาที แล้วหายไป
- ติดตาม footprint ครบ 3 จุด → reveal สัตว์ที่ซ่อนอยู่

### Hunting Proficiency Effect
| Level | Effect |
|---|---|
| 1-24 | ล่าสัตว์ธรรมดาได้ |
| 25 | ปลดล็อก tracking footprint |
| 50 | detection radius ลด 25% เพิ่ม |
| 75 | drop rate สัตว์หายาก +50% |
| 100 (Mastery) | ปลดล็อก recipe จาก mythic material |

---

## 40. Farming System

### Concept
Real-time grow cycle — ปลูกแล้วรอจริงๆ (ชั่วโมง/วัน real time)
ผลผลิตได้เมื่อ online กลับมา — decay ถ้าทิ้งไว้นานเกินไป

### Farm Structures (ใน Building System §25)
| Structure | ต้องการ | หน้าที่ |
|---|---|---|
| Garden Bed | Wood ×4, Soil ×2 | ปลูกพืช (2×2 tiles) |
| Water Trough | Wood ×2, Stone ×1 | เก็บน้ำสำหรับรดต้น |
| Greenhouse | Wood ×8, Glass ×4 | ปลูกพืชนอกฤดู, ลด grow time 25% |
| Compost Bin | Wood ×3 | แปลง waste → Fertilizer |
| Grain Mill | Wood ×6, Stone ×4 | แปลง Grain → Flour |

### Crop Types & Grow Time
| พืช | Grow time | Water/day | ผลผลิต | Drop |
|---|---|---|---|---|
| ผัก (Herb) | 2 ชั่วโมง | 1 ครั้ง | 3-6 Herb | ยา/อาหาร |
| ข้าว (Grain) | 8 ชั่วโมง | 2 ครั้ง | 5-10 Grain | แป้ง, อาหาร |
| ผลไม้ | 12 ชั่วโมง | 2 ครั้ง | 3-8 Fruit | อาหาร, potion |
| ดอกไม้มนตร์ | 24 ชั่วโมง | 3 ครั้ง | 1-3 Magic Flower | alchemy |
| ต้นไม้ผล | 48 ชั่วโมง | 1 ครั้ง/วัน | 10-20 Fruit | harvest ซ้ำได้ |

### Grow Cycle States
```
[Seed planted]
      │ ผ่านไป 25% grow time
      ▼
[Sprouting] — รดน้ำ 1 ครั้ง
      │ ผ่านไป 50% grow time
      ▼
[Growing] — รดน้ำ N ครั้งตาม crop
      │ ผ่านไป 100% grow time
      ▼
[Ready to Harvest] ← กด F เก็บ
      │ ถ้าไม่เก็บภายใน grow_time อีกรอบ
      ▼
[Overripe / Withered] — yield ลด 50% / ไม่ได้เลย
```

**Offline farming:** grow ต่อเนื่องขณะ offline — ตรวจสอบ timestamp เมื่อ login กลับมา
**Water ขาด:** ถ้าไม่รดน้ำตามกำหนด → grow pause จนกว่าจะรด (ไม่ตาย)

### Fertilizer System
```
ใส่ Fertilizer ก่อน/ระหว่าง grow:
  - Basic Fertilizer (จาก Compost Bin): grow time -15%, yield +20%
  - Magic Fertilizer (จาก Alchemy): grow time -30%, yield +50%, rare drop chance +10%
```

**Fertilizer rarity × farming skill = ผลจริง:**
```
fertilizer_effect = base_effect × (0.4 + farming_level / 167)
  # farming skill 1   → 40% ของ effect ที่ระบุ
  # farming skill 50  → 70%
  # farming skill 100 → 100%

ตัวอย่าง: Magic Fertilizer (yield +50%) + farming skill 50
  → yield จริง +50% × 0.70 = +35%

farming skill ≥ 25 จึงจะใช้ Magic Fertilizer ได้
  (ทักษะไม่พอ → item หลุดมือ ใส่ไม่ติด)
```

### Farming Proficiency Effect
| Level | Effect |
|---|---|
| 1 | ปลูกพืชพื้นฐานได้ |
| 25 | ปลดล็อก crop tier 2 (ดอกไม้มนตร์) |
| 50 | Yield +25% ทุก crop |
| 75 | Overripe window ×2 (เก็บช้าได้กว่าเดิม) |
| 100 | ปลดล็อก crop พิเศษ (เฉพาะ band ที่ผ่านมา) |

### Farm Schema (schema_crafting_v1.sql เพิ่ม)
```sql
CREATE TABLE farm_plots (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  camp_building_id UUID NOT NULL REFERENCES camp_buildings(id) ON DELETE CASCADE,
  slot            INTEGER NOT NULL,          -- slot ใน garden bed (0-3)
  crop_id         TEXT,                      -- null = ว่าง
  planted_at      TIMESTAMPTZ,
  grow_time_sec   INTEGER,
  water_needed    INTEGER NOT NULL DEFAULT 0,
  water_given     INTEGER NOT NULL DEFAULT 0,
  fertilizer      TEXT,                      -- null / 'basic' / 'magic'
  state           TEXT NOT NULL DEFAULT 'empty',
    -- 'empty'/'sprouting'/'growing'/'ready'/'overripe'/'withered'
  PRIMARY KEY constraint: (camp_building_id, slot) → ผ่าน camp_building_id
);
```

---

## 41. Fishing System

### Concept
Stat-based + Mini-game bonus — ไม่มี mini-game ก็ตกได้ แต่ทำ mini-game ได้ดี → ได้ปลาดีกว่า

### Fishing Locations
- แหล่งน้ำใน field map (tile type `water`) → ตกได้ทุกที่ที่มีน้ำ
- Fishing Spot (จุดพิเศษ กระพริบ) → drop rate ปลาหายาก ×2
- ต้องมี Fishing Rod (tool) — durability หมด → rod หัก

### Fishing Rod Types
| Rod | วัสดุ | Fishing Power | Rare Fish Chance |
|---|---|---|---|
| Bamboo Rod | Bamboo ×3 | 1 | ฐาน |
| Wooden Rod | Wood ×4, String ×2 | 2 | +10% |
| Iron Rod | Iron ×2, Wood ×2 | 4 | +25% |
| Mythril Rod | Mythril ×2, Magic Thread ×2 | 8 | +60% |

### Loot Table
```
base_roll = fishing_skill_level / 10 + rod.fishing_power

# fishing_skill × rod rarity = ผลจริง
# rod.fishing_power เต็มเมื่อ fishing_skill = 100
# rod rarity สูง + skill ต่ำ → fishing_power ใช้ได้บางส่วน:
effective_power = rod.fishing_power × (0.3 + fishing_skill_level / 143)
  # skill 1   → 30% ของ power
  # skill 50  → 65%
  # skill 100 → 100%

roll → loot tier:
  < 3   → Common fish (80%), Trash (20%)
  3-6   → Uncommon fish (60%), Common fish (35%), Trash (5%)
  7-10  → Rare fish (30%), Uncommon (60%), Common (10%)
  11-15 → Epic fish (15%), Rare (50%), Uncommon (35%)
  16+   → Legendary fish (5%), Epic (30%), Rare (65%)
```

### Fish Types & Uses
| Tier | ตัวอย่าง | ใช้ทำ |
|---|---|---|
| Common | ปลาดุก, ปลาช่อน | อาหารพื้นฐาน, เหยื่อสัตว์ |
| Uncommon | ปลาทอง, ปลาหมึก | อาหาร tier 2, alchemy |
| Rare | ปลามังกร | อาหาร tier 3, crafting |
| Epic | ปลาเทพ | Potion tier 3, special recipe |
| Legendary | ปลาอมตะ | Mythic recipe, alchemy tier 4 |

### Mini-game (Optional Bonus)
เหมือน Timing Ring ใน Upgrade (§8C) แต่ปรับสำหรับการตกปลา:

```
Phase 1 — รอกัด (Wait phase):
  - Progress bar เคลื่อนที่ random
  - เมื่อปลากัด → bar กระโดด + เสียง SFX
  - กด [Space] ทัน → เข้า Phase 2
  - กดช้า > 1 วินาที → ปลาหนี (ลอง cast ใหม่)

Phase 2 — ดึงสาย (Reel phase):
  - Gauge ซ้าย-ขวา ผู้เล่นต้องกด ←/→ ให้ indicator อยู่กลาง
  - ถ้าอยู่กลางตลอด → ได้ปลาระดับ +1 tier
  - ถ้าหลุดออกนอก 3 ครั้ง → ปลาหนี
```

**Stat-only mode:** กด [Auto] แทน → ระบบ roll loot โดยไม่ต้องเล่น mini-game (ได้ loot tier ปกติ ไม่ได้ +1 tier bonus)

### Fishing Proficiency Effect
| Level | Effect |
|---|---|
| 1 | ตกปลาได้ |
| 25 | มองเห็น Fishing Spot ที่ซ่อน |
| 50 | Wait phase ง่ายขึ้น (window กว้างขึ้น 50%) |
| 75 | Rare fish chance +25% ทุก loot table |
| 100 | ปลดล็อก Fishing Spot พิเศษ (legendary fish) |

---

## 42. Animal Husbandry System

### Concept
Passive baseline + Active care ให้ bonus
ไม่ดูแลเลย → สัตว์ยังผลิต item ได้แต่น้อย
ดูแลสม่ำเสมอ → output เพิ่มขึ้นและได้ item พิเศษ

### สัตว์เลี้ยง
| สัตว์ | ได้มาจาก | Passive output / วัน | Active care bonus |
|---|---|---|---|
| ไก่ | ซื้อ NPC / หาจาก field | Egg ×1 | ให้ Grain → Egg ×3, Golden Egg 5% |
| วัว | ซื้อ NPC (แพง) | Milk ×1 | ให้ Hay → Milk ×3, Cream 10% |
| แกะ | Hunting (จับไม่ฆ่า) | Wool ×1 / สองวัน | ให้ Grass → Wool ×2, Fine Wool 15% |
| สุนัข | Hunting (tame) | — | ช่วย detect Footprint radius +30% |
| แมว | field map / tame | — | ลด Scavenging time 20% |
| ม้า | ซื้อ NPC (แพงมาก) | — | ขี่ได้ — เดินเร็ว ×2 |

### Animal Structures
| Structure | ต้องการ | ใช้กับ |
|---|---|---|
| Chicken Coop | Wood ×8, Thatch ×4 | ไก่ สูงสุด 4 ตัว |
| Barn | Wood ×20, Stone ×10 | วัว/แกะ สูงสุด 4 ตัว |
| Stable | Wood ×15, Stone ×5 | ม้า สูงสุด 2 ตัว |
| Animal Pen (รั้ว) | Wood ×2/tile | กันสัตว์ไม่ให้หนี |

### Taming Mechanic (สำหรับสัตว์ป่า → เลี้ยง)
สัตว์บางชนิดจับจากธรรมชาติได้แทนการฆ่า:

```
1. ลด HP สัตว์ลงถึง < 20% (ไม่ฆ่า)
2. ใช้ Taming Item ที่ตรง (Bait, Rope, Whistle) — มี rarity
3. tame_chance = animal_handling_skill / 100 × item_bonus
   item_bonus ตาม rarity: common=1.0, uncommon=1.4, rare=2.0, epic=3.0, legendary=5.0
   # item rarity สูง + skill ต่ำ → ยังได้ผลน้อย
   # ตัวอย่าง: Legendary Whistle + skill 20 → 20/100 × 5.0 = 1.0 → 100% (cap)
   # ตัวอย่าง: Common Bait + skill 20 → 20/100 × 1.0 = 0.20 → 20%
4. สำเร็จ → สัตว์กลายเป็น "Tamed" → วางใน structure
5. ล้มเหลว → สัตว์หนี (ไม่ตาย) รอ respawn
```

### Care Actions & Effects
| Action | ผล |
|---|---|
| ให้อาหาร (Feed) | happiness +20, output ×2 วันนั้น |
| ให้น้ำ (Water) | happiness +10 |
| ทำความสะอาด (Clean) | happiness +15, ป้องกัน disease |
| Brush / Pet | happiness +5, สุนัข/แมว loyalty +1 |

**Happiness ส่งผลต่อ output:**
```
happiness 80-100: output ×2, bonus item chance 15%
happiness 50-79:  output ×1 (baseline)
happiness 20-49:  output ×0.5
happiness 0-19:   output หยุด, สัตว์อาจหนีถ้าไม่มี fence
```

**Happiness decay:** -5/วัน ถ้าไม่ได้รับ care อะไรเลย — ลดช้า offline

### Animal Husbandry Schema (schema_crafting_v1.sql เพิ่ม)
```sql
CREATE TABLE tamed_animals (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  camp_building_id UUID NOT NULL REFERENCES camp_buildings(id),
  animal_type     TEXT NOT NULL,       -- 'chicken'/'cow'/'sheep'/'dog' ฯลฯ
  name            TEXT,                -- player ตั้งชื่อได้
  happiness       INTEGER NOT NULL DEFAULT 80 CHECK (happiness BETWEEN 0 AND 100),
  last_fed_at     TIMESTAMPTZ,
  last_output_at  TIMESTAMPTZ,
  is_active       BOOLEAN NOT NULL DEFAULT TRUE
);
```

---

## 43. Treasure Hunting System

### Concept
สองโหมดรวมกัน:
- **Random Spot** — จุดฝังสมบัติ spawn สุ่มบน field map (ต้องมี Shovel ขุด)
- **Treasure Map** — item ที่ drop จาก monster ระบุตำแหน่งสมบัติในแผนที่

### Random Treasure Spots
- Spawn ใน field map ตอน generate — สุ่ม 2-5 จุดต่อ floor
- มองไม่เห็นด้วยตาเปล่า — ต้องใช้ **Dowsing Rod** (tool พิเศษ) หรือ Scavenging skill ≥ 40
- เมื่อ detect → จุดแสดงเป็น `?` บนแผนที่ → เดินไปขุดด้วย Shovel
- Respawn จุดใหม่ทุก 24 ชั่วโมง (ไม่ซ้ำตำแหน่งเดิม)

**Shovel rarity × scavenging skill = ผลจริง:**
```
shovel_bonus = {common:1.0, uncommon:1.2, rare:1.5, epic:2.0, legendary:3.0}
loot_quality = base_tier_loot × shovel_bonus × (0.5 + scavenging_level / 200)
  # scavenging 1   → 50.5% ของ potential
  # scavenging 50  → 75%
  # scavenging 100 → 100%

# Shovel rarity สูง + skill ต่ำ → ไม่ได้ผลเต็ม
# ตัวอย่าง: Legendary Shovel + scavenging 20 → ×3.0 × 0.60 = ×1.80
```

**Dowsing Rod rarity × scavenging skill:**
```
# rod rarity สูง → detect radius กว้างขึ้น
# แต่ถ้า skill ต่ำ → compass signal อ่อน (สั่นน้อย ระบุทิศไม่ชัด)
detection_clarity = rod.base_radius × (0.4 + scavenging_level / 167)
  # skill 1   → 40% ของ radius ที่ rod นั้นมี
  # skill 100 → 100%
```

```
Treasure Spot Tiers (สุ่มตาม floor depth):
  Floor 1-3:  Common cache  — Gold 50-200, Common material
  Floor 4-6:  Uncommon cache — Gold 200-500, Uncommon item
  Floor 7-9:  Rare cache    — Gold 500-1000, Rare item
  Floor 10+:  Epic cache    — Gold 1000+, Epic item, rare recipe scroll
```

### Treasure Map Item
- Drop จาก monster (ทุก type โอกาส 2%), Elite/Boss โอกาส 10%
- Item: "แผนที่สมบัติ [Floor N]" — ใช้แล้วเปิด overlay บน world map
- Overlay แสดง X mark บน camp ที่ซ่อนสมบัติไว้ (ต้องเดินไปขุด)
- สมบัติจาก Map มี tier สูงกว่า random spot เสมอ (+1 tier)

**Treasure Map Loot Table:**
```
Common Map   → Uncommon cache loot
Uncommon Map → Rare cache loot
Rare Map     → Epic cache loot + chance at gacha item
Epic Map     → Legendary cache — gacha item การันตี + Gold 2000+
Legendary Map → Mythic cache — Eternal-flagged legendary item + special blueprint
```

### Digging Mechanic
```gdscript
# TreasureSpot.gd
func dig(player: Player) -> void:
    if not player.has_tool("shovel"):
        ToastManager.show("ต้องการ Shovel")
        return
    var dig_time = 3.0 - (player.get_proficiency("scavenging") / 50.0)  # max 1 วินาที
    await AnimationPlayer.play("dig")
    await get_tree().create_timer(dig_time).timeout
    var loot = TreasureLootTable.roll(tier, player.get_proficiency("scavenging"))
    player.add_loot(loot)
    ProficiencyManager.add_exp(player, "scavenging", 30)
    queue_free()  # จุดหายไปหลังขุด
```

### Dowsing Rod Mechanic
- Equip Dowsing Rod → HUD แสดง compass ที่ชี้ทิศสมบัติใกล้ที่สุด
- ยิ่งใกล้ → compass สั่นเร็วขึ้น + pulse แดง
- Durability หมด → rod หัก (ต้อง craft ใหม่)

### Scavenging Proficiency Effect
| Level | Effect |
|---|---|
| 1 | เก็บของบนพื้นได้ |
| 25 | auto-detect random treasure spot โดยไม่ต้อง Dowsing Rod |
| 40 | เห็น `?` บน mini-map แม้ไม่มี rod |
| 50 | dig time ลด 50% |
| 75 | Treasure Map loot +1 tier |
| 100 | โอกาส 5% พบ "Hidden Vault" — super rare cache ที่ไม่มีบน map |

### Treasure Schema (schema_crafting_v1.sql เพิ่ม)
```sql
CREATE TABLE treasure_spots (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  camp_id         UUID NOT NULL REFERENCES tower_camps(id),
  tile_x          INTEGER NOT NULL,
  tile_y          INTEGER NOT NULL,
  tier            TEXT NOT NULL,  -- 'common'/'uncommon'/'rare'/'epic'/'legendary'
  source          TEXT NOT NULL,  -- 'random'/'map_item'
  map_item_id     UUID REFERENCES player_items(id),  -- ถ้ามาจาก map item
  is_dug          BOOLEAN NOT NULL DEFAULT FALSE,
  spawned_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  dug_by          UUID REFERENCES players(id),
  dug_at          TIMESTAMPTZ
);
```

---

## 44. World Lore & Story Arc

### Setting
หอเทวภพ (Tower of Convergence) ไม่ใช่หอที่มนุษย์สร้าง — มันคือโครงสร้างระหว่างมิติ
ที่รวมพลังงานของ pantheon ทั้งหมดไว้ที่แกนกลาง
"ผู้ท้าชิง" คือมนุษย์ที่ถูกเรียกโดยหอ — ไม่รู้เหตุผล แต่รู้สึกว่าต้องไต่ขึ้นไป

### Story Arc (ตาม Band)

**Band 1 — แดนศรัทธาโบราณ (Thai Pantheon)**
> "ก้าวแรกของมนุษย์ที่จะกลายเป็นเทพ"

ผู้ท้าชิงมาถึงหอจากดินแดนที่เต็มไปด้วยความศรัทธาโบราณ
เจอ NPC: พระฤๅษีแก่ (mentor), ยักษ์ผู้พิทักษ์ (boss gate NPC)
Boss แรก: มหายักษ์ทรนง — ผู้พิทักษ์ประตูสู่ภพที่สอง

**Band 2 — วิหารแสงสุริยา (Greek Pantheon)**
> "ความเย่อหยิ่งของเทพสู่ความอ่อนน้อมของมนุษย์"

เทพกรีกไม่ยอมรับมนุษย์ธรรมดา — ต้องพิสูจน์ตัว
Boss: อิคารัสที่ตกนรก — ผู้ที่ล้มเหลวในการเป็นเทพ

**Band 3 — ป่าหิมะยักษ์ (Norse Pantheon)**
> "ความแข็งแกร่งจากความสูญเสีย"

โลกที่ Ragnarok เกือบสิ้นสุดแล้ว — ผู้รอดชีวิตกำลังสร้างใหม่
Boss: Fenrir ที่ถูกจองจำ — กำลังหลุดพ้น

**Band 4 — ทะเลทรายนิรันดร์ (Egyptian Pantheon)**
> "ความตายและการเกิดใหม่"

ดินแดนที่วิญญาณยังไม่ยอมไป — Anubis ตัดสินผู้ท้าชิง
Boss: Ra ปลอม — เทพแห่งแสงที่ถูกทุจริต

**Band 5 — สวนซากุระมืด (Japanese Pantheon)**
> "เส้นบางระหว่างมนุษย์กับเทพ"

โลกที่ Kami และมนุษย์ยังอยู่ร่วมกัน — แต่สมดุลกำลังพัง
Boss: Yamata no Orochi — งู 8 หัวที่ตื่นขึ้น

**Band 6 — รากฐานปฐมกาล (Primordial)**
> "จุดกำเนิดและจุดสิ้นสุด"

แกนกลางของหอ — พลังงานที่สร้างทุกสิ่ง
Final Boss: เทพปกรณัมองค์แรก — ผู้ที่ไต่มาก่อนและกลายเป็นส่วนหนึ่งของหอ
เมื่อชนะ → ผู้ท้าชิงกลายเป็น "เทพปกรณัม" — ชื่อของตัวเองถูกจารึกในหอ

### NPC หลัก (Story Characters)

| NPC | Role | พบที่ |
|---|---|---|
| พระฤๅษีอมตะ | Mentor — ให้คำแนะนำและ tutorial quest | Band 1 Hub |
| นางฟ้าแห่งหอ | Quest giver หลัก — รู้ความจริงบางส่วน | ทุก Hub |
| เทพที่ตกจากสวรรค์ | Rival — ไต่หอพร้อมกันแต่เส้นทางต่างกัน | Band 2-4 |
| อนุบิสแห่งความยุติธรรม | Judge — ประเมินผู้ท้าชิงใน Band 4 | Band 4 |
| ผู้ท้าชิงองค์ก่อน | Ghost — ให้ hints และ warning | Band 5-6 |

### Lore Discovery System
Lore text ไม่ได้บอกตรงๆ — ค้นพบผ่าน:
- อ่าน Signpost / Stone Tablet ในแผนที่
- คุย NPC ซ้ำๆ (dialogue tier 2-3 ปลดล็อกหลัง event)
- เปิด Treasure (บาง cache มี Lore Fragment item)
- Kill Boss ครั้งแรก → cutscene text
- ปลดล็อก Ascension Node → vison/dream sequence (text + visual effect)

---

## 45. Time System & Seasons

### Concept
เวลาในเกมวิ่งเร็วกว่าจริง — กลางวัน/กลางคืนสลับ, ฤดูกาลหมุนเวียน
ฤดูกาลไม่ได้ global — แต่ละ **Band มีระบบฤดูของตัวเอง** ตาม Pantheon

---

### Day/Night Cycle

#### Structure
```
1 วันเกม = กลางวัน (67%) + กลางคืน (33%)
default: กลางวัน 40 นาทีจริง, กลางคืน 20 นาทีจริง
→ 1 วันเกม = 1 ชั่วโมงจริง
```

#### Host Settings (ปรับตอนสร้าง session)
| Parameter | Min | Default | Max |
|---|---|---|---|
| Day length (นาที/วัน) | 20 | 60 | 240 |
| Day ratio (% กลางวัน) | 40% | 67% | 80% |
| Season length (วันเกม/ฤดู) | 3 | 7 | 30 |
| Start season | ใดก็ได้ | ฤดูแรกของ band | — |

**Offline:** เวลาเดิน offline ด้วย — ตรวจ `elapsed = now - last_online` เมื่อ login กลับมา
คำนวณว่าผ่านไปกี่วัน/ฤดูเกม แล้วอัปเดต farm/animal state ตาม

#### Visual Transition (Godot)
```gdscript
# TimeManager.gd (autoload)
var game_time: float = 0.0       # วินาทีเกมที่ผ่านไป
var day_length_sec: float = 3600 # default 1 ชั่วโมงจริง
var day_ratio: float = 0.667

func _process(delta: float) -> void:
    game_time += delta
    var time_of_day = fmod(game_time, day_length_sec) / day_length_sec
    _update_lighting(time_of_day)
    _check_day_change()

func _update_lighting(t: float) -> void:
    # t = 0.0 (เที่ยงคืน) → 0.25 (รุ่งอรุณ) → 0.5 (เที่ยงวัน) → 0.75 (พลบค่ำ)
    var sky_color = _lerp_sky(t)
    Environment.ambient_light_color = sky_color
    # Sprite overlay: เพิ่ม CanvasLayer สีน้ำเงินเข้ม opacity 0-0.6 ตาม t

func get_hour() -> int:
    var t = fmod(game_time, day_length_sec) / day_length_sec
    return int(t * 24)  # 0-23

func get_day() -> int:
    return int(game_time / day_length_sec)

func get_season() -> String:
    var season_len = season_length_days * day_length_sec
    var season_idx = int(game_time / season_len) % season_count
    return current_band_seasons[season_idx]
```

#### กลางวัน/กลางคืน Effect
| ช่วงเวลา | Visual | Gameplay effect |
|---|---|---|
| รุ่งอรุณ (05:00-07:00) | แสงส้มอ่อน | สัตว์ป่า spawn peak, ปลาตีเช้า bite ×1.5 |
| กลางวัน (07:00-17:00) | แสงปกติ | farming รด้วยน้ำ, gathering ปกติ |
| พลบค่ำ (17:00-20:00) | แสงส้มแดง | สัตว์คืนเริ่ม spawn, ปลาพลบค่ำ bite ×1.3 |
| กลางคืน (20:00-05:00) | มืด (ต้องมีแสง) | monster aggro range +25%, สัตว์คืน spawn, ปลากลางคืน |

**ความมืด:** พื้นที่ห่างจากแสง (Torch, Campfire, จันทร์) → มองเห็น radius ลด 60%
Player ต้องพก Torch หรือ build แสงสว่างในแคมป์

---

### Season System (ตาม Band Pantheon)

#### Band 1 — แดนศรัทธาโบราณ (Thai) — 3 ฤดู
| ฤดู | ชื่อเกม | วันเกม/ฤดู | Visual |
|---|---|---|---|
| ร้อน | คิมหันต์ | 7 วัน | แดดจ้า, ท้องฟ้าสีฟ้าเข้ม, สีอุ่น |
| ฝน | วัสสาน | 7 วัน | ฝนตก, หมอก, สีเขียวเข้ม |
| หนาว | เหมันต์ | 7 วัน | หมอกเช้า, ท้องฟ้าเทา, สีเย็น |

**ฤดูร้อน (คิมหันต์):** crop ที่ต้องการน้ำมาก yield −20% ถ้าไม่รดสม่ำเสมอ, ปลาน้อยลง
**ฤดูฝน (วัสสาน):** crop grow time −15%, แม่น้ำมีปลาชุกขึ้น ×1.5, gathering herb +30%
**ฤดูหนาว (เหมันต์):** crop บางชนิด grow ไม่ได้ (ต้องมี Greenhouse), สัตว์ป่า spawn ลด 30%

#### Band 2 — วิหารแสงสุริยา (Greek) — 4 ฤดู
| ฤดู | ชื่อเกม | วันเกม/ฤดู | Visual |
|---|---|---|---|
| ใบไม้ผลิ | Earos (เอรอส) | 7 วัน | ดอกไม้บาน, แสงนุ่ม, สีชมพู-เขียว |
| ร้อน | Theros (เธรอส) | 7 วัน | แสงจ้า, สีทอง, เงาคมชัด |
| ใบไม้ร่วง | Phthinoporon | 7 วัน | ใบไม้แดง-ส้ม, แสงส้ม |
| หนาว | Cheimon (ไคมอน) | 7 วัน | หิมะบาง, แสงเงิน, ต้นไม้ไม่มีใบ |

**Earos:** crop พิเศษ Olive, Grape, Laurel ปลูกได้, สัตว์ hatch เพิ่ม
**Theros:** combat stat +5% (แสงสวรรค์ buff), crop ร้อนชอบ
**Phthinoporon:** harvest bonus ×1.3, gathering mushroom พิเศษ
**Cheimon:** หิมะ → movement ลด 20%, ปลูกไม่ได้นอก Greenhouse, สัตว์หายาก Nordic spawn

#### Band 3 — ป่าหิมะยักษ์ (Norse) — 4 ฤดู
| ฤดู | ชื่อเกม | วันเกม/ฤดู | Visual |
|---|---|---|---|
| ใบไม้ผลิ | Vor | 5 วัน | หิมะละลาย, สีเขียวสด,霧 |
| ร้อน | Sumar | 10 วัน | กลางวันยาวมาก (80%), ท้องฟ้าสว่างตลอด |
| ใบไม้ร่วง | Haust | 5 วัน |嵐 (พายุ), สีแดงเข้ม |
| หนาว | Vetr | 10 วัน | หิมะหนัก, กลางคืนยาว (60%), พายุหิมะ |

**Sumar:** กลางคืนสั้นมาก (20%) — monster กลางคืน spawn น้อยลงมาก
**Vetr:** หิมะหนัก → movement ลด 35%, ต้องมีแสงไฟหรือ Hypothermia debuff (ดู §28), ปลาใต้น้ำแข็ง (fishing mechanic พิเศษ)

#### Band 4 — ทะเลทรายนิรันดร์ (Egyptian) — 2 ฤดู
| ฤดู | ชื่อเกม | วันเกม/ฤดู | Visual |
|---|---|---|---|
| อาเขต | Akhet (น้ำท่วม) | 10 วัน | น้ำสูง, สีเขียว-น้ำตาล, หมอกชื้น |
| แล้ง | Shemu (เก็บเกี่ยว) | 10 วัน | ทรายลม, ท้องฟ้าส้ม, ความร้อน |

**Akhet:** น้ำท่วม → บาง tile เดินไม่ได้ (dynamic), crop flooding ชอบน้ำ, ปลาชุก ×2
**Shemu:** ทรายลม → visibility ลด 40% (sandstorm), crop แล้งต้องรดน้ำ ×3/วัน

#### Band 5 — สวนซากุระมืด (Japanese) — 4 ฤดู
| ฤดู | ชื่อเกม | วันเกม/ฤดู | Visual |
|---|---|---|---|
| ใบไม้ผลิ | Haru (春) | 7 วัน | ซากุระบาน, สีชมพู, ลมอ่อน |
| ร้อน | Natsu (夏) | 7 วัน | เขียวชอุ่ม, แสงร้อน, เสียงจักจั่น |
| ใบไม้ร่วง | Aki (秋) | 7 วัน | ใบเมเปิ้ลแดง, พระจันทร์เต็มดวง |
| หนาว | Fuyu (冬) | 7 วัน | หิมะ, เงียบสงัด, ต้นไม้ไม่มีใบ |

**Haru:** Hanami event — ต้นซากุระพิเศษ drop Sakura Petal (alchemy material หายาก)
**Aki:** Tsukimi event — กลางคืน ปลาหายากขึ้น, harvest item พิเศษ

#### Band 6 — รากฐานปฐมกาล (Primordial) — ไม่มีฤดู
ดินแดนปฐมกาลอยู่นอกเวลา — **ไม่มีกลางวัน/กลางคืน** เสมอกลางคืน
แสงมาจาก energy cracks ในพื้นดิน (visual พิเศษ)
Crop ปลูกไม่ได้ (ยกเว้น Primordial Seed — item พิเศษจาก boss)

---

### Season Effect Matrix (สรุป)

| ระบบ | ผลตาม Season |
|---|---|
| **Farming** | crop บางชนิดมีเฉพาะฤดู, grow time ±15-30%, water needs เปลี่ยน |
| **Hunting** | สัตว์บางชนิด spawn เฉพาะฤดู, migration pattern เปลี่ยน |
| **Fishing** | bite rate เปลี่ยนตามฤดู, ปลาบางชนิดมีเฉพาะฤดู |
| **Gathering** | herb/flower บางชนิดมีเฉพาะฤดู |
| **Building** | ฤดูหนาว/พายุ → building damage rate เพิ่มถ้าเปิด raid |
| **Combat** | เฉพาะ Band ที่ระบุ (Theros: +5% stats, Vetr: Hypothermia risk) |
| **NPC** | seasonal dialogue เปลี่ยน, seasonal quest ปลดล็อก |

---

### Season-Exclusive Crops (ตัวอย่าง Band 1)

| Crop | ฤดูที่ปลูกได้ | ใช้ทำ |
|---|---|---|
| พริกไทยร้อน | คิมหันต์ | อาหารเพิ่ม ATK, alchemy |
| บัวหลวง | วัสสาน | alchemy tier 2, offering |
| เห็ดหิมะ | เหมันต์ | potion พิเศษ, อาหาร |
| ดอกบัวทอง | วัสสาน+คิมหันต์ | rare — alchemy tier 3 |

---

### Season-Exclusive Animals (ตัวอย่าง)

| สัตว์ | Band | ฤดู | Drop พิเศษ |
|---|---|---|---|
| นกยูง | Band 1 | วัสสาน | Peacock Feather |
| กวางขาว | Band 2 | Earos | White Hide (rare) |
| หมีขาว | Band 3 | Vetr | Arctic Fur |
| ตั๊กแตนทะเลทราย | Band 4 | Shemu | Chitin (armor material) |
| หิ่งห้อย | Band 5 | Natsu | Glowdust (alchemy) |

---

### Seasonal Events (ปีละ 1 ครั้งต่อ Band)

| Event | Band | ฤดู | Special Mechanic |
|---|---|---|---|
| เทศกาลสงกรานต์ | Band 1 | คิมหันต์ | น้ำรด debuff ล้าง, bonus drop 3 วัน |
| Festival of Dionysus | Band 2 | Theros | Grape harvest ×3, special recipe |
| Yule Night | Band 3 | Vetr | ค่ำคืนยาวพิเศษ, bonus monster drop |
| Flooding of Nile | Band 4 | Akhet | Fertile Silt drop (super fertilizer) |
| Hanami | Band 5 | Haru | Sakura Petal drop 3 วัน |

---

### Time UI (HUD)

```
[มุมบนขวา หรือข้าง mini-map]
  🌙 20:35   วันที่ 4   เหมันต์
  [================          ] ← progress bar ของวัน
```

Full calendar เปิดได้จาก pause menu — แสดงฤดูปัจจุบัน, วันในฤดู, event ที่กำลังจะมา

---

### Schema (schema_world_v1.sql)

```sql
CREATE TABLE world_time_config (
  server_id         TEXT PRIMARY KEY,   -- 'offline' / server UUID
  day_length_sec    INTEGER NOT NULL DEFAULT 3600,
  day_ratio         NUMERIC NOT NULL DEFAULT 0.667,
  season_length_days INTEGER NOT NULL DEFAULT 7,
  current_day       INTEGER NOT NULL DEFAULT 1,
  current_season_idx INTEGER NOT NULL DEFAULT 0,
  game_time_offset  TIMESTAMPTZ NOT NULL DEFAULT now(),
    -- เวลาที่ game_day=0 เริ่ม ใช้คำนวณ current time
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Helper function: คำนวณ game time ณ ขณะนั้น
CREATE OR REPLACE FUNCTION get_game_time(server_id TEXT)
RETURNS TABLE(game_day INT, hour INT, season_idx INT) AS $$
  SELECT
    FLOOR(EXTRACT(EPOCH FROM (now() - w.game_time_offset)) / w.day_length_sec)::INT,
    FLOOR(
      (EXTRACT(EPOCH FROM (now() - w.game_time_offset)) % w.day_length_sec)
      / w.day_length_sec * 24
    )::INT,
    FLOOR(
      EXTRACT(EPOCH FROM (now() - w.game_time_offset))
      / (w.day_length_sec * w.season_length_days)
    )::INT % 4   -- จำนวนฤดูต่าง band ปรับใน code layer
  FROM world_time_config w
  WHERE w.server_id = $1;
$$ LANGUAGE SQL;
```

---

## 46. Item Identification

### Concept
Item ที่ drop จาก monster จะอยู่ในสถานะ **"ไอเทมปริศนา"** — รู้แค่ category และ rarity
ต้อง identify ก่อนถึงรู้ชื่อจริง, stat จริง, และ lore text

ไม่มี hidden affix system (ไม่ซับซ้อนแบบ PoE) — stat เป็นค่าตายตัวตาม item definition
แต่ **ไม่รู้ว่าเป็น item ไหน** จนกว่าจะ identify

### Unidentified State
```
[?? อาวุธ — หายาก]          [?? เกราะ — มหากาพย์]
 ไอเทมปริศนา                  ไอเทมปริศนา
 "ต้อง identify เพื่อดูรายละเอียด"
```

item ที่ยังไม่ identify:
- แสดงเป็น silhouette เบลอใน inventory
- equip ไม่ได้
- ขายให้ NPC ได้ในราคาต่ำกว่า (70% ของราคาจริง)
- วางใน Eternal Marketplace ไม่ได้

### วิธี Identify

**A — Scroll of Revelation** (item)
- craftable จาก: Herb ×3 + Magic Flower ×1 + Gold 100
- ใช้ได้ทุกที่ทุกเวลา — drag scroll ใส่ item ใน inventory
- identify ได้ 1 item ต่อ scroll
- **ต้องมี `smithing` skill ≥ 1** จึงจะใช้ scroll ได้
- rarity ของ item ที่ identify ได้ขึ้นกับ smithing level (เหมือนช่าง NPC):
  ```
  smithing < 20  : identify ได้ถึง common เท่านั้น
  smithing 20-39 : identify ได้ถึง uncommon
  smithing 40-64 : identify ได้ถึง rare
  smithing 65-89 : identify ได้ถึง epic
  smithing ≥ 90  : identify ได้ถึง legendary/mythic
  ```

**B — Blacksmith NPC** (ใน Hub)
- identify ทีละหลายชิ้นได้ (batch)
- ค่าบริการและ rarity ที่รับ identify ขึ้นกับระดับช่าง:

  | ระดับช่าง | identify ได้ถึง | ค่าบริการ/item |
  |---|---|---|
  | ช่างฝึกหัด | uncommon | 30 gold |
  | ช่างฝีมือ | rare | 60 gold |
  | ช่างเชี่ยวชาญ | epic | 120 gold |
  | ช่างเทพ | legendary / mythic | 250 gold |

  ช่างระดับต่ำปฏิเสธ identify item rarity เกินความสามารถ

### Drop Source → Identified State
| แหล่งที่มา | สถานะเมื่อได้รับ |
|---|---|
| Gacha pull | Identified ทันที |
| Craft (player สร้างเอง) | Identified ทันที |
| NPC Shop ซื้อ | Identified ทันที |
| Monster drop | **Unidentified** |
| Treasure chest | **Unidentified** |
| Quest reward | Identified ทันที |

### Schema (เพิ่มใน schema_core_v2.sql)
```sql
ALTER TABLE player_items ADD COLUMN IF NOT EXISTS
    is_identified BOOLEAN NOT NULL DEFAULT TRUE;
    -- FALSE = unidentified (monster drop / treasure)

-- RLS: ถ้า is_identified = FALSE → ซ่อน item_id จาก client
-- client เห็นแค่ category + rarity ไม่รู้ item_id จริง
```

### Scroll of Revelation Recipe (เพิ่มใน crafting_recipes)
```sql
INSERT INTO crafting_recipes VALUES
  ('recipe_scroll_revelation', 'Scroll of Revelation',
   NULL,   -- hand craft ไม่ต้อง station
   [output_item_id], 1, 0, 'alchemy', 10, 0);
-- inputs: Herb ×3, Magic Flower ×1
-- Gold cost หักตอน craft (ผ่าน Supabase function)
```

---

## 47. Monster Raid System

### Concept
Opt-in feature — ปิดโดย default ทุก server
เมื่อเปิด **Raid Mode**: กลางคืนทุก N วันเกม monster wave จะโจมตี **ทุก building ใน camp**

**กฎพิเศษ:**
- Hub หลักของแต่ละ Band (town hub) และ Camp spawn ที่มี NPC ประจำ → **NPC ป้องกันแทน** ไม่มีการโจมตี building ใน zone เหล่านี้
- Camp ทั่วไปที่ player build เอง → โดนโจมตีเต็มๆ

### Raid Trigger Conditions
```
เงื่อนไขทุกข้อต้องครบ:
1. Raid Mode = ON (server config)
2. เป็นกลางคืน (20:00-05:00 game time)
3. ผ่านมาแล้ว N วันเกมนับจาก raid ล่าสุด
   (N = raid_interval_days ใน server config, default 7)
4. มี player online อยู่ใน camp นั้น ≥ 1 คน
   (ถ้าไม่มีใคร online → skip raid camp นั้น)
```

### Raid Wave Structure
```
Raid Day N:
  Wave 1 (เริ่มกลางคืน):  monster tier ตาม floor × 0.8 จำนวน 5-10 ตัว
  Wave 2 (+5 นาที):        monster tier × 1.0 จำนวน 8-15 ตัว
  Wave 3 (+10 นาที):       monster tier × 1.2 จำนวน 10-20 ตัว (boss raid ถ้า day ≥ 14)

Raid จบเมื่อ: wave ทั้งหมดตาย หรือ player ออก camp
```

### NPC Protection Zone
Camp ที่ถือว่าเป็น "เมืองหลัก / Hub" จะมี NPC Guardian ประจำ:
- **Band Hub** (camp_type = checkpoint ที่เปิด band) → Protected
- **Camp spawn ของแต่ละ floor** → Protected (มี Gate Keeper NPC)
- Camp ที่ player build เอง (ไม่มี NPC ประจำ) → **ไม่ protected**

```gdscript
# RaidManager.gd
func is_camp_protected(camp_id: String) -> bool:
    var camp = DB.get_camp(camp_id)
    return camp.has_npc_guardian or camp.camp_type == "hub"

func start_raid(camp_id: String) -> void:
    if is_camp_protected(camp_id):
        return  # NPC จัดการเอง ไม่มี raid
    _spawn_wave(camp_id, 1)
    await get_tree().create_timer(300).timeout
    _spawn_wave(camp_id, 2)
    await get_tree().create_timer(300).timeout
    _spawn_wave(camp_id, 3)
```

### Building Behavior During Raid
- Monster เลือก target: **กำแพง/รั้วก่อน** → ถ้าทะลุ → building ใน
- Trap (Spike Trap, Snare) → activate อัตโนมัติเมื่อ monster เดินผ่าน
- Watchtower → ยิง monster อัตโนมัติ (damage ตาม tier)
- Campfire / Chest / Crafting station → โดนตีได้ แต่ monster ไม่ target ก่อน

### Repair After Raid
- Building HP เหลือ → ซ่อมด้วยวัสดุ (สัดส่วน % HP ที่หาย)
- Building HP = 0 → destroyed ต้อง build ใหม่
- ของใน Chest ที่ถูก destroy → drop บนพื้น (ไม่หาย)

### Server Config (เพิ่มใน Settings §21 และ schema_world_v1.sql)
```sql
ALTER TABLE world_time_config ADD COLUMN IF NOT EXISTS
    raid_mode           BOOLEAN NOT NULL DEFAULT FALSE,
    raid_interval_days  INTEGER NOT NULL DEFAULT 7,
    raid_difficulty     TEXT NOT NULL DEFAULT 'normal';
    -- 'normal' / 'hard' / 'siege' (wave เยอะขึ้น boss แข็งขึ้น)
```

**Host Settings UI เพิ่ม:**
```
── Raid Mode ──────────────────────────────
[○ ปิด]  [◉ เปิด]

ถ้าเปิด:
  Raid ทุก:    [7] วันเกม
  ความยาก:    [Normal ▼]  Normal / Hard / Siege
  หมายเหตุ: Hub หลักและ Camp spawn มี NPC คุ้มครอง
```

---

## 48. Localization (i18n)

### Design Principle
**ภาษาไทยเป็น primary** — ทุก string เขียนภาษาไทยก่อน
**ใช้ i18n key ตั้งแต่ต้น** — ห้าม hard-code text ใน code เด็ดขาด
English string ใน Phase 1 ใช้ภาษาไทย placeholder ไปก่อน แปลทีหลังทีละ key

### Phase Rollout
| Phase | ภาษา | สถานะ |
|---|---|---|
| Phase 1 | ภาษาไทย (primary) | ✅ ครบ |
| Phase 1 | English | placeholder (แสดงไทย) |
| Phase 2 | English | แปลครบ, release |
| Phase 3+ | ภาษาอื่น (JP/ZH) | ตามความต้องการ community |

### Key Structure
```
# รูปแบบ key: CATEGORY_SUBCATEGORY_ID
# ใช้ snake_case, uppercase

# UI
UI_MAINMENU_PLAY           = "เล่นเกม"
UI_MAINMENU_SETTINGS       = "ตั้งค่า"
UI_HUD_HUNGER              = "ความหิว"

# Items
ITEM_NAME_IRON_AXE         = "ขวานเหล็ก"
ITEM_DESC_IRON_AXE         = "ขวานตีเหล็กธรรมดา ใช้ตัดต้นไม้ได้เร็วขึ้น"

# Skills
SKILL_NAME_FIRE_STRIKE     = "เพลิงพุ่ง"
SKILL_DESC_FIRE_STRIKE     = "โจมตีด้วยพลังไฟ สร้างความเสียหาย..."

# NPC Dialogue
NPC_MERCHANT_BAND1_GREET_0 = "ยินดีต้อนรับ ผู้ท้าชิง!"
NPC_MERCHANT_BAND1_GREET_1 = "มีอะไรให้ช่วยไหม?"

# Seasons
SEASON_THAI_HOT            = "คิมหันต์"
SEASON_THAI_RAIN           = "วัสสาน"
SEASON_THAI_COLD           = "เหมันต์"

# Story/Lore
LORE_BAND1_INTRO           = "ในยุคที่เทพยังสถิตในดินแดน..."
QUEST_MAIN_BAND1_TITLE     = "พิชิตแดนศรัทธาโบราณ"
```

### Godot Implementation
```gdscript
# ใช้ tr() ทุกที่ที่มี text แสดงผล
$Label.text = tr("UI_MAINMENU_PLAY")
$ItemName.text = tr("ITEM_NAME_" + item_id.to_upper())

# ไฟล์แปล: res://i18n/th.po (primary)
#            res://i18n/en.po (Phase 2)

# th.po (Gettext format)
msgid "UI_MAINMENU_PLAY"
msgstr "เล่นเกม"

msgid "ITEM_NAME_IRON_AXE"
msgstr "ขวานเหล็ก"

# en.po Phase 1 — placeholder
msgid "UI_MAINMENU_PLAY"
msgstr "เล่นเกม"       ← ยังใช้ภาษาไทยไปก่อน

# en.po Phase 2 — แปลแล้ว
msgid "UI_MAINMENU_PLAY"
msgstr "Play"
```

### Dynamic Text (ชื่อตัวละคร, ตัวเลข)
```gdscript
# ใช้ tr() กับ format string
var msg = tr("COMBAT_DAMAGE_DEALT").format({"dmg": 150, "enemy": "วิญญาณพเนจร"})
# th: "สร้างความเสียหาย {dmg} ให้กับ {enemy}"
# → "สร้างความเสียหาย 150 ให้กับ วิญญาณพเนจร"
```

### Font Requirements
- ภาษาไทย: **Sarabun** หรือ **Noto Sans Thai** (รองรับ Unicode ไทยครบ)
- English: font เดียวกัน (Sarabun รองรับ Latin ด้วย)
- ขนาด: ไม่ต่ำกว่า 14px สำหรับ body text (ภาษาไทยอ่านยากถ้าเล็กเกิน)
- Bitmap pixel font: ใช้สำหรับ UI ที่ต้องการ retro feel — ต้องหา/สร้าง Thai pixel font เพิ่ม

### Content Scope (Phase 1 — ต้องแปล)
| หมวด | จำนวน string ประมาณ |
|---|---|
| UI ทั้งหมด | ~200 strings |
| Item name + desc | ~150 strings |
| Skill name + desc | ~80 strings |
| NPC dialogue (Band 1) | ~100 strings |
| Quest title + desc | ~50 strings |
| System message | ~100 strings |
| **รวม Phase 1** | **~680 strings** |

---

## 49. NPC Stats, Guard & Bounty System

### Concept
NPC ทุกตัวมี stat คล้ายผู้เล่น — ไม่ใช่แค่ object ที่คุยได้
ผู้เล่นโจมตี NPC ได้ แต่มีผลตามมาทันที
ระบบนี้ทำให้โลกรู้สึก "มีชีวิต" — NPC ไม่ได้อมตะ แต่ก็ไม่ตายถาวรในพื้นที่ปลอดภัย

---

### NPC Stats

NPC ทุกตัวมี stat พื้นฐานตาม role:

| Role | HP | ATK | DEF | SPD | Stamina |
|---|---|---|---|---|---|
| Merchant | 200 | 10 | 5 | 60 | 100 |
| Blacksmith | 350 | 40 | 20 | 50 | 150 |
| Messenger | 180 | 8 | 3 | 90 | 80 |
| Storage Keeper | 250 | 15 | 10 | 55 | 120 |
| Gate Keeper | 400 | 50 | 30 | 70 | 200 |
| Guard | 600 | 80 | 45 | 85 | 300 |
| Guard Captain | 1200 | 150 | 80 | 80 | 500 |
| Hospital Nurse | 150 | 5 | 2 | 65 | 80 |

**Stamina** — NPC ใช้ stamina ขณะสู้หรือวิ่ง หมด → ช้าลง, ATK ลด 30%

NPC stat scale ตาม Band (×1.0 Band 1 → ×3.0 Band 6)

---

### Safe Zone Definition

ระบบนี้ใช้กับ **ทุก camp ที่มี NPC อาศัยอยู่** ไม่ว่าจะเป็น Hub หรือ camp ทั่วไป
- Hub หลัก (Band Hub) → Guard หนาแน่นกว่า (มี Guard Captain)
- Camp ทั่วไปที่มี NPC → มี Guard 1-3 นาย ตาม camp tier

**พื้นที่ที่ไม่มี Guard:** field map ที่ไม่มี NPC — โจมตีสัตว์/monster ได้อิสระ

---

### Crime & Threat Level (ระดับความผิด)

เมื่อผู้เล่นทำ hostile action ต่อ NPC ใน safe zone → `threat_level` เพิ่ม

| Action | Threat เพิ่ม |
|---|---|
| โจมตี NPC 1 ครั้ง | +10 |
| ทำ NPC HP < 50% | +25 |
| ทำ NPC HP < 20% (critical) | +50 |
| ทำ NPC หมดสติ (HP = 1) | +100 |
| ขโมยของจาก NPC / Chest ล็อก | +30 |
| โจมตี Guard | +80 |
| โจมตี Guard Captain | +200 |
| หลบหนีจากการจับกุม | +150 |

**Threat decay:** -5 ต่อนาที real time เมื่อไม่ได้อยู่ใน safe zone นั้น

| Threat Level | สถานะ | ผล |
|---|---|---|
| 0 | Clean | ปกติ |
| 1-49 | Suspicious | NPC ใน zone พูดเตือน, Guard เฝ้ามองตาม |
| 50-99 | Wanted | Guard เข้ามาเตือน 1 ครั้ง "วางมืออาวุธ" |
| 100-199 | Criminal | Guard โจมตีทันที, NPC วิ่งหนี |
| 200+ | Outlaw | Guard ทุกนาย + Guard Captain รุม, Bounty ประกาศ |

---

### Guard AI & Response

**ขั้นตอน Guard Response:**

```
Threat ≥ 50:
  Guard เดินเข้าหา → dialogue "หยุด! วางอาวุธแล้วยอมจำนน"
  ผู้เล่นมี 5 วินาทีเลือก:
    [ยอมจำนน] → Guard จับตัว → เข้า Arrest flow
    [สู้ต่อ]  → Guard โจมตี → เข้า Combat flow
    [วิ่งหนี] → Guard ไล่ตาม → ถ้าออกจาก safe zone = หนีสำเร็จ
                                  ถ้าจับได้ระหว่างหนี = Arrest + Bounty

Threat ≥ 100:
  Guard โจมตีทันทีโดยไม่เตือน
  NPC ทั่วไปวิ่งหนีออกจากพื้นที่
  Guard ≥ 2 นาย spawn เพิ่มถ้ามีอยู่ใน zone

Threat ≥ 200:
  Guard Captain ออกมาด้วย
  Bounty ประกาศ (ดูหัวข้อ Bounty)
```

**Guard Combat Stats:** สู้เต็มที่ไม่ยั้ง — แต่เป้าหมายคือจับ ไม่ใช่ฆ่า
- ถ้า player HP < 20% → Guard หยุดโจมตี เปลี่ยนเป็น "จับ" แทน
- Guard ไม่ไล่ออกนอก safe zone boundary (หนีออกไปได้ถ้าทัน)

---

### Arrest Flow (เมื่อถูกจับ)

Guard เลือกโทษตาม threat level และ context:

```
Threat 50-149 → จำคุกชั่วคราว
Threat 150+   → จำคุก + ริบ Gold บางส่วน

Context modifier:
  ถ้าโจมตี Guard โดยตรง → โทษหนักขึ้น 1 tier
  ถ้า Bounty ติดอยู่แล้ว  → โทษหนักสุด
```

**โทษประเภท A — จำคุก (Jail):**
- Fade to black → spawn ใน Jail cell ของ camp นั้น
- ติดคุก N นาที real time (N = threat_level / 10, max 30 นาที)
- ระหว่างติดคุก: เล่นไม่ได้ (แต่ออกจากเกมได้ เวลานับต่อ offline)
- **หนีได้:** ถ้ามี Lockpick item → mini-game เปิดกุญแจ → หนีออกมา
  - สำเร็จ → Bounty เพิ่ม +150, ออกจาก safe zone ทันที
  - ล้มเหลว → เวลาติดคุกเพิ่ม +5 นาที

**โทษประเภท B — ตีบาดเจ็บหนัก (เมื่อสู้ Guard และแพ้):**
- HP เหลือ 1, debuff `beaten` 10 นาที (ATK -30%, SPD -40%)
- ริบ Gold 15% จากที่ถือ (ไม่ริบ inventory item)
- Spawn ที่นอกประตู safe zone

**ผู้เล่นเลือกยอมแพ้หรือสู้ได้เสมอ** — ถ้า HP = 0 ขณะสู้ Guard → โทษ B อัตโนมัติ

---

### Bounty System

Bounty ประกาศเมื่อ threat ≥ 200 หรือหลบหนีจากคุก

**ผลของ Bounty:**
1. **NPC ทุกตัวในทุก camp ที่มี NPC** → hostile ต่อผู้เล่นนั้น (เดินเข้า zone → Guard โจมตีทันที)
2. **Player อื่น** เห็น "🔴 ค่าหัว" ข้าง portrait ของผู้เล่นคนนั้น
3. **รางวัล:** player ที่จับ/knock out ผู้เล่นที่มี Bounty → ได้ Gold reward

**Bounty Amount:**
```
bounty_gold = threat_level × 10 + (ทุก crime ที่ทำใน session × 50)
ขั้นต่ำ 500 gold, ขั้นสูงไม่จำกัด
```

**การล้าง Bounty:**
| วิธี | เงื่อนไข |
|---|---|
| จ่ายค่าปรับ | ไปหา Guard Captain ที่ Bounty Notice Board → จ่าย bounty_gold × 1.5 |
| ครบเวลา | 24 ชั่วโมง real time ที่ไม่ทำ crime เพิ่ม (Bounty ลดลง 10%/ชั่วโมง) |
| ถูกจับโดย Guard | Bounty ล้าง แต่ติดคุกนานขึ้น |
| ถูก knock out โดย player อื่น | Bounty ล้าง, ผู้จับได้รับ reward |

**Bounty Notice Board:** อยู่ใน Hub แต่ละ Band — แสดงรายชื่อ player ที่มี Bounty + จำนวน gold

---

### NPC Injury & Hospital System

NPC ใน safe zone **ไม่ตายถาวร** — แต่ถ้า HP หมด → หมดสติ → ถูกนำตัวไป Hospital

**Hospital:**
- มีใน Hub หลักของทุก Band
- NPC ที่บาดเจ็บ → ออกจาก post หายไป N นาที (รักษาตัว)
- ระหว่างนั้น service ของ NPC นั้น **ไม่พร้อมใช้งาน**

**Recovery Time:**
```
recovery_minutes = (max_hp - hp_at_injury) / max_hp × 30
# ยิ่งบาดเจ็บหนัก ยิ่งนานกว่าจะกลับมา
# สูงสุด 30 นาที real time
# Guard Captain: สูงสุด 60 นาที
```

**ผลกระทบต่อ gameplay:**
- Blacksmith บาดเจ็บ → ซ่อม equipment ไม่ได้ชั่วคราว
- Merchant บาดเจ็บ → ซื้อขายไม่ได้ชั่วคราว
- Gate Keeper บาดเจ็บ → warp ไม่ได้ชั่วคราว
- Guard Captain บาดเจ็บ → ล้าง Bounty ไม่ได้ (ต้องรอ)

**Hospital UI:**
```
[ป้ายหน้า Hospital]
  ตอนนี้กำลังรักษา:
  🧔 ช่างสมชาย (Blacksmith)  — กลับมาใน 18 นาที
  👮 นาย Guard               — กลับมาใน 7 นาที
```

---

### NPC ใน Field Map (นอก Safe Zone)

NPC ที่ออก patrol หรืออยู่ใน field map **นอก safe zone boundary:**
- ไม่มี Guard คุ้มครอง — โจมตีได้โดยไม่มี threat เพิ่ม
- ถ้า NPC นั้นตาย → ไม่ไปโรงพยาบาล — **respawn ที่ post เดิมใน N ชั่วโมง** (เหมือน monster)
- Bounty ไม่ประกาศจากการโจมตี NPC นอก safe zone

---

### Crime Log & Reputation

นอกจาก Bounty — ผู้เล่นมี **Reputation** ต่อแต่ละ Band:

| Reputation | ระดับ | ผล |
|---|---|---|
| 100 | Honored | ราคาสินค้าลด 10%, Guard เป็นมิตร |
| 50-99 | Friendly | ปกติ |
| 0-49 | Neutral | ปกติ |
| -1 ถึง -49 | Suspicious | NPC ขายของราคาแพงขึ้น 10% |
| -50 ถึง -99 | Disliked | NPC ไม่คุยด้วย บาง service ปฏิเสธ |
| -100 ล่างสุด | Hated | ไม่มี NPC service ใด band นั้น |

**Reputation เพิ่มจาก:** ทำ quest, ช่วย NPC, kill bounty target
**Reputation ลดจาก:** crime ใน zone, มี Bounty, ทำ NPC บาดเจ็บ

---

### Anti-Exploit: Shared Damage Detection

**ปัญหาที่ต้องป้องกัน:** ผู้เล่นหลายคนตีคนละที เพื่อให้ NPC บาดเจ็บโดยแต่ละคน threat น้อยเกินกว่า Guard จะ response

#### กลไกหลัก — NPC Damage Log Window

NPC ทุกตัวมี **damage log** เก็บ timestamp + player_id ของทุก hit ที่เข้ามาภายใน **10 วินาที** (rolling window)

```
damage_log = [
  {player_id: A, damage: 30, time: T+0.0},
  {player_id: B, damage: 25, time: T+3.2},
  {player_id: A, damage: 28, time: T+6.1},
  {player_id: C, damage: 20, time: T+8.9},
]
```

**Rule: ถ้า damage log มีผู้เล่น ≥ 2 คน ภายใน 10 วินาที → ทุกคนใน log ได้รับ threat ทันที**

```gdscript
# NPCCombat.gd
const DAMAGE_WINDOW_SEC = 10.0
const MULTI_ATTACKER_THRESHOLD = 2  # จำนวน player ที่ถือว่า "รุมตี"

func receive_damage(attacker_id: String, damage: int) -> void:
    var now = Time.get_unix_time_from_system()

    # เพิ่ม hit ใหม่ลง log
    damage_log.append({"player_id": attacker_id, "damage": damage, "time": now})

    # ลบ hit ที่เก่าเกิน window
    damage_log = damage_log.filter(
        func(h): return (now - h.time) <= DAMAGE_WINDOW_SEC
    )

    # ตรวจจำนวน unique attacker
    var unique_attackers = {}
    for hit in damage_log:
        unique_attackers[hit.player_id] = true

    if unique_attackers.size() >= MULTI_ATTACKER_THRESHOLD:
        _trigger_shared_threat(unique_attackers.keys())
    else:
        # คนเดียว — threat ปกติ
        ThreatManager.add_threat(attacker_id, camp_id, _calc_threat(damage))

    # apply damage ตามปกติ
    current_hp = max(1, current_hp - damage)
    _check_injury_threshold()

func _trigger_shared_threat(attacker_ids: Array) -> void:
    # Guard aggro ทุกคนใน list ทันที
    for player_id in attacker_ids:
        # threat เพิ่มสำหรับทุกคน เท่ากับ "โจมตี NPC โดยตรง" (threat +50 ขึ้นไป)
        ThreatManager.add_threat(player_id, camp_id, 100)
        ThreatManager.set_guard_aggro(player_id, camp_id, true)

    GuardManager.call_guards(camp_id, attacker_ids)
    _broadcast_alert(attacker_ids)  # NPC อื่นในพื้นที่รู้ด้วย
```

#### ผลที่เกิดขึ้นเมื่อ Trigger

1. **Threat +100 ทุกคน** ที่อยู่ใน damage log — ไม่สำคัญว่าตีมากหรือน้อยแค่ไหน
2. **Guard aggro ทุกคน** ในทันที — ไม่มีการเตือนก่อน (ข้ามขั้นตอน dialogue)
3. **Alert broadcast:** NPC อื่นใน camp วิ่งหนี, Guard ที่อยู่ไกลกว่าวิ่งเข้ามาเสริม
4. **Damage log ล้าง** หลัง trigger (ป้องกัน double penalty)

#### Edge Cases

| กรณี | การจัดการ |
|---|---|
| ผู้เล่น A ตี แล้ว B ตีหลัง 11 วินาที | ไม่ trigger — อยู่คนละ window, A ได้ threat ปกติ, B ได้ threat ปกติ |
| ผู้เล่น A ตีเองคนเดียวหลายครั้ง | ไม่ trigger — unique attacker = 1 |
| ผู้เล่นใน party เดียวกันรุมตี | **Trigger** — ระบบไม่แยก party หรือไม่ party ถ้าหลายคนตีใน window |
| ผู้เล่นโดน mind control จาก monster แล้วไปตี NPC | ไม่นับ — damage source ต้องเป็น `player_input` เท่านั้น |

#### Reputation Penalty เพิ่มเติม

นอกจาก threat — "รุมตี NPC" ยังลด Reputation มากกว่าปกติ:

```
ปกติ: โจมตี NPC → reputation -5 ต่อ band
รุมตี (shared damage): reputation -20 ต่อ band สำหรับทุกคนใน log
```

#### Server-Side Validation (Supabase)

Damage log เก็บ server-side — client ส่งแค่ intent โจมตี:

```sql
CREATE TABLE npc_damage_log (
  npc_instance_id  UUID NOT NULL REFERENCES camp_npcs(id) ON DELETE CASCADE,
  player_id        UUID NOT NULL REFERENCES players(id),
  damage           INTEGER NOT NULL,
  hit_at           TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_npc_damage_recent
  ON npc_damage_log (npc_instance_id, hit_at DESC);

-- Function: ตรวจ multi-attacker ใน 10 วินาทีล่าสุด
CREATE OR REPLACE FUNCTION check_multi_attacker(p_npc_id UUID)
RETURNS TABLE(player_id UUID) AS $$
  SELECT DISTINCT player_id
  FROM npc_damage_log
  WHERE npc_instance_id = p_npc_id
    AND hit_at > now() - INTERVAL '10 seconds';
$$ LANGUAGE SQL;

-- Trigger: เรียก check หลังทุก INSERT
CREATE OR REPLACE FUNCTION on_npc_hit() RETURNS TRIGGER AS $$
DECLARE
  attackers UUID[];
BEGIN
  SELECT ARRAY_AGG(player_id) INTO attackers
  FROM check_multi_attacker(NEW.npc_instance_id);

  IF ARRAY_LENGTH(attackers, 1) >= 2 THEN
    -- เพิ่ม threat ทุกคน + set guard aggro
    INSERT INTO player_threat (player_id, camp_id, threat, has_bounty)
    SELECT unnest(attackers), get_camp_for_npc(NEW.npc_instance_id), 100, FALSE
    ON CONFLICT (player_id, camp_id)
    DO UPDATE SET threat = player_threat.threat + 100,
                  last_crime_at = now();

    -- Log crime
    INSERT INTO player_crimes (player_id, camp_id, crime_type, threat_added)
    SELECT unnest(attackers),
           get_camp_for_npc(NEW.npc_instance_id),
           'multi_attacker_assault',
           100;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_npc_hit
AFTER INSERT ON npc_damage_log
FOR EACH ROW EXECUTE FUNCTION on_npc_hit();
```

---

### Guard Bounty Hunting

Guard ไม่ได้แค่ปกป้อง safe zone — ถ้ามีผู้เล่นที่มี Bounty อยู่ใน camp
Guard จะ **ออกล่าค่าหัวด้วยตัวเอง** แม้ผู้เล่นนั้นจะไม่ได้ทำอะไรใหม่

#### Bounty Hunt Trigger
```
เงื่อนไข Guard ออกล่า:
1. ผู้เล่นเดิน enter camp ที่มี Guard
2. Guard detect ผู้เล่นที่มี has_bounty = TRUE
3. Guard เปลี่ยน state → "Bounty Hunt"
   (ข้ามขั้นตอนเตือน — เข้า combat ทันที)
```

**Detection radius:** Guard มองเห็น Bounty target ไกลกว่า player ปกติ ×1.5
**Priority:** Guard ใน Bounty Hunt mode ละทิ้งตำแหน่ง patrol ชั่วคราว — Bounty คือ priority สูงสุด

#### Guard Bounty Hunt AI
```gdscript
# GuardAI.gd
enum State { PATROL, ALERT, COMBAT, BOUNTY_HUNT }

func _check_for_bounty_targets() -> void:
    for player in get_players_in_range(detection_radius * 1.5):
        var threat = ThreatManager.get_threat(player.id, camp_id)
        if threat.has_bounty:
            current_target = player
            state = State.BOUNTY_HUNT
            _call_backup()  # ขอ Guard เสริม 1 นาย
            break

func _process_bounty_hunt() -> void:
    if current_target == null or not current_target.is_alive():
        state = State.PATROL
        return
    # ไล่ตาม — ออกนอก safe zone boundary ได้ (ต่างจาก Guard ปกติ)
    navigate_to(current_target.position)
    if distance_to(current_target) < attack_range:
        attack(current_target)
```

**Guard ใน Bounty Hunt สามารถออกนอก safe zone boundary ได้** เพื่อไล่ล่า
แต่ถ้าออกไปเกิน 2× ขนาด camp → หยุดไล่ กลับ patrol

#### เมื่อ Guard จับ Bounty Target ได้
```
1. Guard knock out ผู้เล่น (HP → 1)
2. Bounty ล้าง (has_bounty = FALSE, threat ลดเหลือ 0)
3. Bounty reward → Town Treasury (ดูหัวข้อถัดไป)
4. ผู้เล่น spawn ที่ Jail โดยอัตโนมัติ + ติดคุก (30 นาที fixed)
5. ระบบ log: "Guard [ชื่อ] จับ [ชื่อผู้เล่น] ได้ รับรางวัล X gold"
```

---

### Town Treasury (คลังเมือง)

**แนวคิด:** เงินทุกสตางค์ที่ flow เข้าเมืองถูกบันทึก — เมืองมีงบประมาณของตัวเอง
งบฯ นี้ใช้ **ขยาย Guard**, **อัปเกรด Hospital** และ **ซ่อมแซม NPC zone** โดยอัตโนมัติ

#### แหล่งรายได้ของ Treasury
| แหล่งรายได้ | จำนวน |
|---|---|
| Guard จับ Bounty ได้ | Bounty gold ทั้งหมด |
| ผู้เล่นจ่ายค่าปรับ (ล้าง Bounty) | จำนวนที่จ่าย |
| ผู้เล่นจ่ายค่าซ่อม building NPC zone | จำนวนที่จ่าย |
| ภาษี Marketplace (5% fee) | 50% ของ fee รวม (อีก 50% เป็น burn) |
| ค่า warp ผ่าน Gate Keeper | 50% ของค่า warp |
| ผู้เล่น donate ตรง (สมัครใจ) | จำนวนที่ donate |

#### รายจ่ายของ Treasury (อัตโนมัติ)
| รายการ | เงื่อนไข | ค่าใช้จ่าย |
|---|---|---|
| เพิ่ม Guard patrols | treasury ≥ 5,000 gold | 1,000/Guard/วันเกม |
| อัปเกรด Guard tier | treasury ≥ 20,000 gold | 10,000 (ถาวร) |
| ลด Hospital recovery time −20% | treasury ≥ 10,000 gold | 5,000 (ถาวร) |
| ซ่อม NPC building หลัง raid | Raid Mode เปิด | ตามความเสียหาย |
| Bounty reward จ่าย player ที่จับได้ | เมื่อ player จับ Bounty target | bounty_gold |

#### Treasury Balance
```sql
ALTER TABLE world_time_config ADD COLUMN IF NOT EXISTS
    treasury_gold    INTEGER NOT NULL DEFAULT 0,
    treasury_band    INTEGER NOT NULL DEFAULT 1;
    -- treasury แยกต่อ Band (แต่ละ Band มีคลังของตัวเอง)
```

```gdscript
# TreasuryManager.gd (autoload)
func deposit(band: int, amount: int, source: String) -> void:
    var current = SupabaseClient.get_treasury(band)
    SupabaseClient.update_treasury(band, current + amount)
    _log_transaction(band, amount, source, "income")
    _check_auto_upgrades(band)

func pay_bounty_reward(band: int, player_id: String, amount: int) -> void:
    if get_balance(band) >= amount:
        withdraw(band, amount, "bounty_reward")
        InventoryManager.add_gold(player_id, amount)
        _log_transaction(band, -amount, "bounty_reward", "expense")
    else:
        # Treasury ไม่พอ → จ่าย 50% ที่มี, ส่วนที่เหลือค้างจ่าย
        var partial = get_balance(band)
        withdraw(band, partial, "bounty_reward_partial")
        InventoryManager.add_gold(player_id, partial)
```

#### Treasury Log & Transparency
ผู้เล่นดู Treasury log ของแต่ละ Band ได้จาก **Bounty Notice Board** → tab "คลังเมือง"

```
[คลังเมือง — แดนศรัทธาโบราณ]  💰 ยอดคงเหลือ: 12,450 gold

รายการล่าสุด:
  +2,000  Guard จับ สมชาย (Bounty reward)        วันที่ 12 คิมหันต์
  -500    จ่าย Bounty reward → มานี              วันที่ 12 คิมหันต์
  +1,500  สมหญิง จ่ายค่าปรับ (ล้าง Bounty)       วันที่ 11 คิมหันต์
  +250    Marketplace fee (วันที่ 11)             วันที่ 11 คิมหันต์
  -1,000  เพิ่ม Guard patrol (1 นาย)             วันที่ 10 คิมหันต์
```

#### Guard Tier Upgrade (จาก Treasury)
เมื่อ Treasury สะสมเพียงพอ → Guard ของ camp นั้นอัปเกรด tier อัตโนมัติ:

| Tier | HP | ATK | เงื่อนไข Treasury |
|---|---|---|---|
| 1 — Guard ธรรมดา | 600 | 80 | เริ่มต้น |
| 2 — Guard ชำนาญ | 900 | 120 | 20,000 gold |
| 3 — Guard อีลิท | 1,400 | 180 | 50,000 gold |
| 4 — Guard เทพ | 2,000 | 260 | 100,000 gold |

Guard Captain อัปเกรดพร้อมกัน +50% stat ทุก tier

---

### Schema (schema_npc_v1.sql)

```sql
CREATE TABLE npc_templates (
  id              TEXT PRIMARY KEY,
  name            TEXT NOT NULL,
  role            TEXT NOT NULL,
  band_number     INTEGER NOT NULL,
  base_hp         INTEGER NOT NULL,
  base_atk        INTEGER NOT NULL,
  base_def        INTEGER NOT NULL,
  base_spd        INTEGER NOT NULL,
  base_stamina    INTEGER NOT NULL,
  is_guard        BOOLEAN NOT NULL DEFAULT FALSE,
  is_captain      BOOLEAN NOT NULL DEFAULT FALSE,
  respawn_minutes INTEGER NOT NULL DEFAULT 30
);

CREATE TABLE camp_npcs (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  camp_id         UUID NOT NULL REFERENCES tower_camps(id),
  template_id     TEXT NOT NULL REFERENCES npc_templates(id),
  current_hp      INTEGER NOT NULL,
  current_stamina INTEGER NOT NULL,
  status          TEXT NOT NULL DEFAULT 'active',
    -- 'active' / 'injured' / 'jailed' / 'patrolling'
  injured_at      TIMESTAMPTZ,
  returns_at      TIMESTAMPTZ,  -- เวลาที่จะกลับมา active
  pos_x           NUMERIC,
  pos_y           NUMERIC
);

CREATE TABLE player_crimes (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  player_id       UUID NOT NULL REFERENCES players(id) ON DELETE CASCADE,
  camp_id         UUID NOT NULL REFERENCES tower_camps(id),
  crime_type      TEXT NOT NULL,
  threat_added    INTEGER NOT NULL,
  committed_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE player_threat (
  player_id   UUID NOT NULL REFERENCES players(id) ON DELETE CASCADE,
  camp_id     UUID NOT NULL REFERENCES tower_camps(id),
  threat      INTEGER NOT NULL DEFAULT 0,
  bounty_gold INTEGER NOT NULL DEFAULT 0,
  has_bounty  BOOLEAN NOT NULL DEFAULT FALSE,
  last_crime_at TIMESTAMPTZ,
  PRIMARY KEY (player_id, camp_id)
);

CREATE TABLE player_reputation (
  player_id    UUID NOT NULL REFERENCES players(id) ON DELETE CASCADE,
  band_number  INTEGER NOT NULL,
  reputation   INTEGER NOT NULL DEFAULT 50,
  PRIMARY KEY (player_id, band_number)
);

CREATE TABLE jail_sentences (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  player_id       UUID NOT NULL REFERENCES players(id) ON DELETE CASCADE,
  camp_id         UUID NOT NULL REFERENCES tower_camps(id),
  sentence_minutes INTEGER NOT NULL,
  jailed_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
  release_at      TIMESTAMPTZ NOT NULL,
  escaped         BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE INDEX idx_player_threat_bounty ON player_threat (has_bounty) WHERE has_bounty = TRUE;
CREATE INDEX idx_jail_active ON jail_sentences (player_id, release_at) WHERE escaped = FALSE;

-- Anti-exploit: damage log
-- npc_damage_log + check_multi_attacker() + trg_npc_hit trigger

CREATE TABLE town_treasury (
  band_number     INTEGER PRIMARY KEY,
  gold_balance    INTEGER NOT NULL DEFAULT 0,
  total_income    INTEGER NOT NULL DEFAULT 0,
  total_expense   INTEGER NOT NULL DEFAULT 0,
  guard_tier      INTEGER NOT NULL DEFAULT 1,
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE treasury_log (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  band_number INTEGER NOT NULL,
  amount      INTEGER NOT NULL,  -- บวก = income, ลบ = expense
  source      TEXT NOT NULL,     -- 'bounty_capture'/'fine'/'marketplace'/'warp'/'repair'/'bounty_reward'
  player_id   UUID REFERENCES players(id),
  logged_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

---

## 50. Ecosystem System

### Design Philosophy
ไม่ใช่ full simulation — เป็น **abstracted population model** ที่วิ่งบน server
ผู้เล่นสัมผัสได้ผ่าน spawn rate ที่เปลี่ยนแปลง ไม่ใช่ผ่านตัวเลข simulation ตรงๆ
Scope: **per-floor** — แต่ละ floor มีระบบนิเวศของตัวเอง ไม่ผูกกัน

---

### ห่วงโซ่อาหาร (Food Chain)

แต่ละ floor มี 3 ระดับ:

```
[Tier 3 — Apex Predator]     เช่น มังกรน้ำ, เสือโคร่ง
        ↑ กิน
[Tier 2 — Predator]          เช่น หมูป่า, งูใหญ่, นักล่าเงา
        ↑ กิน
[Tier 1 — Prey / Herbivore]  เช่น กระต่าย, กวาง, นกเล็ก
        ↑ กิน
[Tier 0 — Flora]             หญ้า, ใบไม้, ผลไม้ป่า (resource node)
```

**กฎพื้นฐาน:**
- Apex กิน Predator และ Prey
- Predator กิน Prey และ Flora
- Prey กิน Flora เท่านั้น
- Flora ฟื้นตัวเองตามเวลา (respawn timer §22)

---

### Population Model

แต่ละ species บน floor มี:

```gdscript
var species = {
    "id": "deer_band1",
    "tier": 1,
    "current_pop": 40,       # จำนวนปัจจุบัน
    "min_pop": 5,            # ไม่ลดต่ำกว่านี้ (สัตว์ไม่สูญพันธุ์จริงใน game)
    "max_pop": 80,           # cap สูงสุดของ floor นี้
    "base_pop": 40,          # จำนวนอ้างอิง (สมดุล)
    "birth_rate": 0.05,      # +5% ต่อ tick ถ้า pop < base
    "death_rate": 0.02,      # -2% ต่อ tick จากสาเหตุธรรมชาติ
    "predator_ids": ["boar_band1", "shadow_killer"],  # สัตว์ที่กินมัน
    "prey_ids": ["herb_node", "fruit_node"],          # สิ่งที่มันกิน
}
```

**Population Tick** — คำนวณทุก **10 นาที real time** (server-side)

```
tick():
  for each species on floor:
    # ลดจากนักล่า
    predator_pressure = Σ(predator.current_pop × hunt_rate)
    pop -= predator_pressure

    # เพิ่มจากการสืบพันธุ์
    if pop < base_pop:
        pop += pop × birth_rate

    # ลดจากธรรมชาติ
    pop -= pop × death_rate

    # clamp
    pop = clamp(pop, min_pop, max_pop)
```

---

### Player Impact on Population

**การล่าสัตว์:** ทุกครั้งที่ player kill หรือ capture สัตว์
```
species.current_pop -= 1
```

**การ overhunt:** ถ้า `current_pop < base_pop × 0.3` (เหลือไม่ถึง 30% ของปกติ)
- spawn rate ลด proportional
- สัตว์ tier นั้นเริ่มหายากขึ้นมาก → ราคา drop จากสัตว์นั้นแพงขึ้นตลาด

**Flora depletion:** สัตว์กิน Flora node ด้วย (นอกจาก player)
```
# ทุก tick: Prey pop สูง → Flora resource node respawn ช้าลง
if prey_species.current_pop > base_pop × 1.5:
    flora_respawn_multiplier = 1.5   # ช้ากว่าปกติ 50%
else:
    flora_respawn_multiplier = 1.0
```

---

### Cascade Effect (ผลต่อเนื่องตามห่วงโซ่)

เมื่อ population ของ species หนึ่งเปลี่ยน → กระทบ tier ที่เชื่อมกัน

**ตัวอย่าง Floor 1:**
```
ผู้เล่นล่ากวางมากเกิน (Tier 1 Prey ลด)
  → เสือโคร่ง (Tier 2 Predator) หาอาหารได้น้อย → pop ลด
  → มังกรน้ำ (Tier 3 Apex) หาอาหารได้น้อย → pop ลด
  → หญ้า/ผลไม้ (Flora) ถูกกินน้อยลง → respawn เร็วขึ้น
  → กระต่าย (Tier 1 Prey อื่น) มีอาหารเยอะขึ้น → pop เพิ่ม
```

**ตัวอย่างแบบกลับกัน (ไม่ล่าเลย):**
```
ผู้เล่นไม่ล่ากวางเลย (Tier 1 Prey มากเกิน)
  → เสือโคร่ง (Predator) มีอาหารเยอะ → pop เพิ่ม
  → กวาง pop ลดเพราะถูกกินมากขึ้น → สมดุลใหม่
  → Flora ถูกกินเยอะ → respawn ช้าลง → gathering ยากขึ้น
```

---

### Migration (การอพยพ)

ถ้า population ของ floor ใดต่ำมาก (`< min_pop × 2`) → trigger migration จาก floor ข้างเคียงใน band เดียวกัน

```
migration_amount = min(
    adjacent_floor.current_pop - adjacent_floor.base_pop,  # เอาแค่ส่วนเกิน
    target_floor.max_pop - target_floor.current_pop        # เอาแค่ที่รับได้
) × 0.3   # อพยพ 30% ของ surplus

# ใช้เวลา 1 ชั่วโมง real time จึงจะมาถึง
```

---

### Seasonal Effect on Ecosystem

ผสมกับระบบฤดูกาล (§44):

| ฤดู | ผลต่อ Ecosystem |
|---|---|
| ฤดูผสมพันธุ์ (Spring/วัสสาน) | birth_rate ×2 — population ฟื้นเร็ว |
| ฤดูร้อน | death_rate +50% สำหรับสัตว์ที่ไม่ใช่ native ของ band |
| ฤดูหนาว/Vetr | Prey pop ลด 20% (หาอาหารยาก), Predator หิว → aggro range +30% |
| ฤดูน้ำท่วม/Akhet | ปลา pop ×2, สัตว์บก migrate ขึ้นที่สูง |

---

### Ecosystem UI (Optional — ซ่อนได้)

เปิดจาก pause menu → "นิเวศวิทยา" (ต้องมี Naturalist skill ≥ 25 ถึงจะเห็น)

```
[นิเวศวิทยา — Floor 3: แดนศรัทธาโบราณ]

Tier 3 — Apex
  🐉 มังกรน้ำ      ████████░░  78/80   ◀ สมบูรณ์

Tier 2 — Predator
  🐯 เสือโคร่ง     ████░░░░░░  28/60   ◀ ลดลง (ขาดอาหาร)
  🐍 งูใหญ่        ██████░░░░  45/60   ◀ ปกติ

Tier 1 — Prey
  🦌 กวาง          ██░░░░░░░░  12/80   ◀ ⚠ วิกฤต! (ล่ามากเกิน)
  🐰 กระต่าย       ████████░░  71/80   ◀ สมบูรณ์ (benefiting)
  🐦 นก            ██████░░░░  48/60   ◀ ปกติ

Tier 0 — Flora
  🌿 หญ้า/ผลไม้    ████████░░  Respawn: ปกติ

[คำเตือน] กวางอยู่ในสถานะวิกฤต — หากไม่หยุดล่า อาจกระทบ predator chain
```

**Naturalist Skill** — proficiency ใหม่ที่เพิ่มเข้า proficiency list (§27)
- Level 1: เห็น population bar คร่าวๆ (สมบูรณ์/ปานกลาง/วิกฤต)
- Level 50: เห็นตัวเลขจริง
- Level 75: เห็น cascade warning ล่วงหน้า
- Level 100: เห็น migration timer และ seasonal prediction

---

### Ecosystem Rewards & Consequences

**ผลดีจากการรักษาสมดุล:**
- Population ทุก tier ≥ base_pop × 0.8 → "Thriving Ecosystem" buff ทั้ง floor
  - Gathering yield +15%
  - Rare drop chance +10%
  - Flora respawn ×0.8 (เร็วขึ้น)

**ผลเสียจาก overhunt:**
- Species วิกฤต (`< base_pop × 0.3`) → "Ecosystem Disrupted" debuff
  - Drop จาก species นั้นหายาก ราคา NPC shop ขึ้น 30%
  - Predator ของ species นั้นหิวโหย → aggro range +50%, โจมตี player บ่อยขึ้น
  - Achievement หลุด: ถ้ามี Thriving Ecosystem achievement อยู่ → ถูกยกเลิก

**Conservation Quest** — Quest พิเศษจาก Messenger NPC:
- "ช่วยปกป้องกวาง — ห้ามล่าใน Floor นี้ 3 วันเกม" → รางวัล gold + reputation
- แสดงเมื่อ species ใดวิกฤต

---

### Schema (schema_ecosystem_v1.sql)

```sql
CREATE TABLE floor_species (
  id              TEXT NOT NULL,         -- 'deer_band1'
  floor_id        UUID NOT NULL REFERENCES tower_floors(id),
  tier            INTEGER NOT NULL,      -- 0-3
  current_pop     INTEGER NOT NULL,
  min_pop         INTEGER NOT NULL DEFAULT 5,
  max_pop         INTEGER NOT NULL,
  base_pop        INTEGER NOT NULL,
  birth_rate      NUMERIC NOT NULL DEFAULT 0.05,
  death_rate      NUMERIC NOT NULL DEFAULT 0.02,
  last_tick_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (id, floor_id)
);

CREATE TABLE species_relations (
  predator_id  TEXT NOT NULL,
  prey_id      TEXT NOT NULL,
  hunt_rate    NUMERIC NOT NULL DEFAULT 0.03,
    -- จำนวน prey ที่ predator 1 ตัวกินต่อ tick
  PRIMARY KEY (predator_id, prey_id)
);

CREATE TABLE ecosystem_log (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  floor_id    UUID NOT NULL REFERENCES tower_floors(id),
  species_id  TEXT NOT NULL,
  event_type  TEXT NOT NULL,
    -- 'player_kill'/'natural_death'/'birth'/'migration_in'/'migration_out'/'tick'
  pop_before  INTEGER NOT NULL,
  pop_after   INTEGER NOT NULL,
  cause       TEXT,             -- player_id ถ้า player_kill
  logged_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_ecosystem_floor ON floor_species (floor_id);
CREATE INDEX idx_ecosystem_log_floor ON ecosystem_log (floor_id, logged_at DESC);

-- Tick function (เรียกโดย pg_cron ทุก 10 นาที)
CREATE OR REPLACE FUNCTION run_ecosystem_tick(p_floor_id UUID) RETURNS VOID AS $$
DECLARE
  species RECORD;
  predator_pressure NUMERIC;
  new_pop INTEGER;
BEGIN
  FOR species IN
    SELECT * FROM floor_species WHERE floor_id = p_floor_id
  LOOP
    -- คำนวณ predator pressure
    SELECT COALESCE(SUM(fs.current_pop * sr.hunt_rate), 0)
    INTO predator_pressure
    FROM species_relations sr
    JOIN floor_species fs ON fs.id = sr.predator_id AND fs.floor_id = p_floor_id
    WHERE sr.prey_id = species.id;

    new_pop := species.current_pop;

    -- ลดจากนักล่า
    new_pop := new_pop - FLOOR(predator_pressure)::INT;

    -- เพิ่มจากการสืบพันธุ์
    IF new_pop < species.base_pop THEN
      new_pop := new_pop + CEIL(new_pop * species.birth_rate)::INT;
    END IF;

    -- ลดจากธรรมชาติ
    new_pop := new_pop - CEIL(new_pop * species.death_rate)::INT;

    -- clamp
    new_pop := GREATEST(species.min_pop, LEAST(species.max_pop, new_pop));

    -- update
    UPDATE floor_species
    SET current_pop = new_pop, last_tick_at = now()
    WHERE id = species.id AND floor_id = p_floor_id;

    -- log
    INSERT INTO ecosystem_log (floor_id, species_id, event_type, pop_before, pop_after)
    VALUES (p_floor_id, species.id, 'tick', species.current_pop, new_pop);
  END LOOP;
END;
$$ LANGUAGE plpgsql;
```

---

## 51. Boss & Mini-Boss Mechanics

### Design Philosophy
- **Mini-boss:** ≥ 2 phases — สัตว์/ศัตรูพิเศษที่แข็งกว่า elite มีพฤติกรรมเปลี่ยนเมื่อ HP ลด
- **Boss:** ≥ 3 phases — ผู้พิทักษ์ประตู Band มี story context, arena mechanic, server-wide unlock
- Assets (sprite/animation) ออกแบบทีหลัง — mechanics เป็น data-driven สมบูรณ์

---

### โครงสร้าง Phase System

```gdscript
# BossEntity.gd
var phases: Array[BossPhase] = []
var current_phase: int = 0

func check_phase_transition() -> void:
    var hp_pct = float(current_hp) / max_hp
    var next = current_phase + 1
    if next < phases.size() and hp_pct <= phases[next].trigger_hp_pct:
        _enter_phase(next)

func _enter_phase(idx: int) -> void:
    current_phase = idx
    var phase = phases[idx]
    # apply stat multipliers
    atk  = base_atk  * phase.atk_mult
    spd  = base_spd  * phase.spd_mult
    # trigger transition effect
    phase.on_enter.call(self)
    # unlock new attack patterns
    current_patterns = phase.attack_patterns
```

**Phase Transition Effects:**
- Flash + screen shake (0.5 วินาที)
- HP bar เปลี่ยนสี (เขียว → เหลือง → แดง)
- Boss พูด voice line / แสดง phase name
- Temporary **immunity window** 1.5 วินาที (ป้องกัน skip phase)

---

### Stat Scaling ตาม Difficulty

```
base_hp  × difficulty_mult:
  Normal: ×1.0 | Hard: ×1.4 | Ascendant: ×2.0 | Eternal: ×2.0

base_atk × difficulty_mult:
  Normal: ×1.0 | Hard: ×1.3 | Ascendant: ×1.8 | Eternal: ×1.8

Enrage timer (นาที):
  Normal: ไม่มี | Hard: 10 | Ascendant: 7 | Eternal: 5
```

---

### Mini-Boss Design (≥ 2 Phases)

#### Mini-Boss Template

| Element | รายละเอียด |
|---|---|
| HP | base_hp × floor_depth_mult (×1.0-2.0 ตาม floor) |
| Phase trigger | HP ลงถึง 50% → Phase 2 |
| World Energy cost | 10 ต่อ attempt |
| Drop | การันตี rare+, Guarantee Stone chance |
| Respawn | 2 ชั่วโมง real time |

#### Band 1 Mini-Bosses (Thai Pantheon)

**1. นาคราช (Naga Lord)** — Floor 3, Hunting Zone
```
Lore: งูขนาดยักษ์ผู้พิทักษ์แหล่งน้ำศักดิ์สิทธิ์

Phase 1 (HP 100-51%) — "ผู้พิทักษ์แหล่งน้ำ"
  Patterns:
    - Bite Attack: ATK ×1.5, poison 30%
    - Tail Sweep: AOE, slow 20% 2 turns
    - Water Surge: เติม HP 5% ทุก 3 turns (ถ้าอยู่ใกล้ tile น้ำ)
  Phase Trait: ชอบอยู่ใน tile น้ำ → DEF +20% ขณะอยู่ใน water

Phase 2 (HP 50-0%) — "นาคพิโรธ" [TRANSITION: ลุกขึ้นสูง เปล่งแสง]
  Stat changes: ATK ×1.3, SPD ×1.2, หยุด HP regen
  New Patterns:
    - Venom Spit: ranged, poison ×2 stacks
    - Constrict: Stun 1 turn, ATK ×2.0 (CD 5 turns)
    - Water Call: flood arena — น้ำขึ้น ทุก tile → Naga DEF +30% แต่ player SPD -20%
  Phase Trait: Enrage ถ้า HP < 20% → ATK ×1.5, miss chance ลด 50%
```

**2. ครุฑพัน (Garuda Warden)** — Floor 6, Elite Camp พิเศษ
```
Lore: นกครุฑที่รับใช้เทวดาในอดีต ถูกทอดทิ้งจนกลายเป็นนักล่า

Phase 1 (HP 100-60%) — "ผู้ล่าบนฟ้า"
  Patterns:
    - Talon Strike: ATK ×1.4, CRIT_RATE +20% this hit
    - Dive Bomb: AOE 2×2 tiles, knock back 1 tile
    - Wind Gust: push player ออก 2 tiles, ถ้าชนกำแพง → stun 1 turn

Phase 2 (HP 59-0%) — "ครุฑไฟ" [TRANSITION: ปีกลุกเป็นไฟ]
  Stat changes: ATK ×1.4, SPD ×1.3
  New Patterns:
    - Fire Feather Rain: AOE ทั้ง arena, burn 40% chance
    - Sacred Wind: ลบ buff ทั้งหมดของ player
    - Eye of Storm: Garuda อยู่กลาง, สร้าง wind wall รอบ — player ออกนอก wall → blow away
```

---

### Boss Design (≥ 3 Phases)

#### Boss Template

| Element | รายละเอียด |
|---|---|
| HP | 3-5× ของ mini-boss floor เดียวกัน |
| Phase trigger | ทุก ~33% HP (3 phases) หรือ ~25% (4 phases) |
| World Energy cost | 12 ต่อ attempt |
| Arena | special arena map — ไม่ใช่ field map ปกติ |
| Enrage Timer | Hard/Ascendant/Eternal มีนับถอยหลัง |
| Drop | การันตี epic+, โอกาส legendary, Guarantee Stone tier สูง |
| Server-wide | kill ครั้งแรก → unlock Band ถัดไป, Hall of Fame |

#### Band 1 Boss — มหายักษ์ทรนง (Mahayak Sathong)

```
Lore: ยักษ์ผู้ดูแลประตูสู่โลกที่สูงกว่า เคยเป็นผู้รับใช้เทพ
      แต่ถูกสาปให้ลืมตัวเองและกลายเป็นผู้พิทักษ์นิรันดร์

Floor: 9  |  HP: 8,000 (Normal)  |  Arena: ลานหินโบราณ กลางป่าไม้

Phase 1 (HP 100-67%) — "ผู้พิทักษ์ผู้หลับใหล"
  [เปิดฉาก: ยักษ์นอนหลับ ผู้เล่นเดินเข้าไป → ตื่น]
  ATK mult: ×1.0 | SPD: ช้า (ให้เวลาเรียนรู้ patterns)
  Patterns:
    - Ground Smash: โจมตี tile ที่ player อยู่ + adjacent 4 tiles, damage ×1.8
    - Rock Throw: ranged 3 tiles, chance stun 20%, 3 turns CD
    - Stomp: AOE รอบตัว radius 2, slow player 30% 2 turns
  Arena Mechanic: ต้นไม้ที่ขอบ arena — ทำลายได้ด้วย Ground Smash
    → ต้นไม้ล้ม = obstacle บน arena (blocking movement)
  Phase Trait: ทุก 4 turns → Roar: player miss chance +10% 2 turns

Phase 2 (HP 66-34%) — "ความโกรธที่ตื่นขึ้น"
  [TRANSITION: ยักษ์ตีอกตัวเอง เลือดพุ่ง พื้นสั่น 2 วินาที]
  ATK mult: ×1.4 | SPD: ×1.2 | DEF: +20%
  New Patterns:
    - Berserk Slash: 3 hit combo ต่อเนื่อง, hit 1-2 ×0.8, hit 3 ×2.0
    - Boulder Barrage: โยนก้อนหินใหญ่ 3 ก้อน ต่อเนื่อง, random target
    - War Cry: clear ทุก debuff บน boss + ATK +30% 3 turns (CD 8 turns)
  Arena Mechanic: ต้นไม้ที่ยังเหลือ → ยักษ์ใช้ถือขว้างเป็นอาวุธ (damage ×2.5)
    → ถ้า player ทำลายต้นไม้ทั้งหมดก่อน Phase 2 → ยักษ์ไม่มี Tree Throw
  Phase Trait: HP < 50% → Enrage check ทุก turn: ATK เพิ่ม 5% สะสม (cap ×2.0)

Phase 3 (HP 33-0%) — "ความทรงจำที่แตกสลาย"
  [TRANSITION: ยักษ์คุกเข่า แสงทองพุ่งออกจากอก วิญญาณลอยรอบตัว]
  ATK mult: ×1.8 | SPD: ×1.4 | HP regen: 1% ต่อ turn
  New Patterns:
    - Spirit Crush: AOE ทั้ง arena 50% damage, bypass DEF ครึ่งหนึ่ง
    - Curse of Forgetting: ลบ skill hotbar slot 1 แบบสุ่ม 3 turns
    - Ancient Rage: charge 1 turn → explosive strike ×3.5 damage
    - Memory Fragment: สร้าง spirit clone ของตัวเอง HP 20% เดินเข้าหา player
  Enrage (ถ้ามี timer):
    เมื่อครบ timer → Eternal Roar: ทุก 2 turns ลด max HP player 5% ถาวร (ใน combat นั้น)
  Arena Mechanic: Spirit Wall — วิญญาณล้อมรอบ arena
    → player หนีออกนอก wall ไม่ได้ (Flee ล้มเหลวอัตโนมัติถ้า HP boss < 33%)
  Death: [ยักษ์ล้มลง แสงทองระเบิดออก ประตูหินเปิด]
    → Server Broadcast + Hall of Fame + Band 2 unlock
```

#### Band 2 Boss — Titan of Olympus

```
Lore: Titan ที่รอดจาก Titanomachy ซ่อนตัวอยู่ในหอ
      ร่างกายแกร่งดั่งหิน แต่จิตใจแตกสลายจากการพ่ายแพ้

Floor: 19  |  HP: 20,000 (Normal)  |  Arena: ยอดเขาโอลิมปัส กลางพายุ

Phase 1 (HP 100-70%) — "Stone Titan"
  Patterns:
    - Fist of Stone: ×2.0, 3×1 line, break floor tile (impassable 3 turns)
    - Mountain Throw: ranged ×1.6, AOE 2×2, slow
    - Stone Armor: DEF ×2.0 ชั่วคราว 3 turns (CD 6)
  Arena: พายุฟ้าผ่าทุก 5 turns ตี random tile ×0.8 dmg (unblockable)

Phase 2 (HP 69-35%) — "Fallen God"
  [TRANSITION: เสียงฟ้าร้อง Titan ดูดซับฟ้าผ่า]
  ATK ×1.5, elemental: LIGHTNING_DMG +50%
  New Patterns:
    - Thunder Clap: AOE รอบตัว, shocked status 60%
    - Divine Spear: charge 2 turns → ×4.0 single, unblockable
    - Storm Call: เพิ่ม frequency ฟ้าผ่า → ทุก 2 turns
  Arena: ฟ้าผ่าถูกบน tile น้ำ (wet) → chain lightning ถึง player ทุกคน

Phase 3 (HP 34-0%) — "Ragnarok Echo"
  [TRANSITION: Titan กรีดร้อง ร่างแตกออกเป็นหิน แล้วรวมกลับ]
  ATK ×2.0, SPD ×1.5, immune to slow/freeze
  New Patterns:
    - Olympus Fall: ×3.5 AOE ทั้ง arena (1 turn warning — player เห็น shadow)
    - Stone Cyclone: Titan หมุน sweep รอบ arena, player ต้องกระโดดข้าม (timing mechanic)
    - Last Stand: HP < 10% → Berserk ทุก action ×1.5, ไม่มี CD ทุก skill
  Arena: Pillar Mechanic — เสาหินใน arena ป้องกัน Olympus Fall ได้
    → player ต้องซ่อนหลังเสาตอน cast (เสาพังได้ — มีจำนวนจำกัด)
```

#### Band 3 Boss — Fenrir Unchained

```
Lore: หมาป่าแห่ง Ragnarok ถูกปลดโซ่ครึ่งหนึ่ง ยังคงโกรธแค้น

Floor: 29  |  HP: 40,000 (Normal)  |  Arena: ป่าหิมะ โซ่ขาดอยู่กลาง

Phase 1 (HP 100-65%) — "Bound Fury" [โซ่ยังคงผูกอยู่ครึ่งตัว]
  Patterns: Pack Howl (summon wolf x2), Ice Bite (freeze 25%), Chain Lunge

Phase 2 (HP 64-30%) — "Half-Unchained" [ทำลายโซ่ข้างหนึ่ง]
  [TRANSITION: Fenrir ดึงโซ่ขาด ใช้โซ่เป็นอาวุธ]
  New: Chain Whip (AOE line), Frostbite (freeze guaranteed), Wolf Pack (4 wolves)

Phase 3 (HP 29-0%) — "Ragnarok" [โซ่ทั้งหมดขาด]
  [TRANSITION: Fenrir หอน ท้องฟ้าเปลี่ยนสี หิมะตกหนัก visibility ลด 60%]
  New: World Devour (×5.0 charge 2 turns), Blizzard (DOT ทั้ง arena), Mjolnir Echo
  Arena: หิมะปกคลุม — player movement ลด 30%, แต่ Fenrir SPD ไม่ลด
```

#### Band 4 Boss — Ra the Corrupted

```
Lore: เทพแห่งดวงอาทิตย์ที่ถูก Set วางยา กลายเป็นทรราช

Floor: 39  |  HP: 80,000 (Normal)  |  Arena: วิหารทราย กลางทะเลทราย

Phase 1 (HP 100-70%) — "False Sun" [แสงทองสุกใส แต่ fake]
  Patterns: Solar Beam (line), Sand Storm (AOE slow), Hieroglyph Curse (debuff random)

Phase 2 (HP 69-40%) — "Corrupted Light"
  [TRANSITION: แสงดำทะลักออกจากดวงตา]
  New: Dark Solar Flare (AOE + burn + blind), Shadow Clone ×2, Anubis Chains (immobilize)

Phase 3 (HP 39-0%) — "God of Oblivion"
  [TRANSITION: ร่างแตกเป็นทราย แล้วรวมกลับเป็นรูปแบบมืด]
  New: Eclipse (ดับแสง — ทั้ง arena มืด 5 turns), Void Ray (×6.0 unblockable once)
  Arena: ทรายดูด — ยืนนิ่งนานกว่า 2 turns → เริ่ม sink (SPD ลด → ลด → หยุด)
```

#### Band 5 Boss — Yamata no Orochi

```
Lore: งูแปดหัวที่ตื่นขึ้น ฟื้นจากที่ Susanoo พ่ายแพ้ไว้

Floor: 49  |  HP: 160,000 (Normal)  |  Arena: สวนซากุระ แม่น้ำไหลผ่าน

Phase 1 (HP 100-75%) — "One Head Rises" [1 หัวทำงาน]
Phase 2 (HP 74-50%) — "Three Heads Awaken" [3 หัว — 3 ประเภท elemental]
  [TRANSITION: หัวที่ 2-3 ผุดขึ้น แต่ละหัวมี element ต่างกัน]
Phase 3 (HP 49-25%) — "Six Heads Rage" [6 หัว — ต้องเลือก target ถูก]
  [TRANSITION: พื้นสั่น หัวที่เหลือโผล่ขึ้นพร้อมกัน]
  Mechanic: แต่ละหัวมี HP แยก — ต้องทำลายหัว "source" ก่อน ไม่งั้น regen
Phase 4 (HP 24-0%) — "Orochi Complete" [8 หัวพร้อมกัน]
  [TRANSITION: เลือดสีทองพุ่งออก ทุกหัวรวมร้องพร้อมกัน]
  New: Hydra Regeneration (ถ้า kill หัวที่ไม่ใช่ source → spawn หัวใหม่)
  Arena: แม่น้ำล้น — น้ำขึ้นสูง tile น้ำขยาย → Orochi DEF +30%
```

#### Band 6 Boss — The First Ascendant (ผู้ท้าชิงองค์แรก)

```
Lore: มนุษย์คนแรกที่ไต่หอสำเร็จและกลายเป็นส่วนหนึ่งของหอ
      ตอนนี้กลายเป็น Guardian สุดท้ายที่รักษาความลับของปฐมกาล

Floor: 50+  |  HP: 400,000 (Normal)  |  Arena: แกนกลางหอ — void ล้วน

Phase 1 (HP 100-75%) — "The Echo of Humanity"
  [Boss ใช้ skills เหมือนผู้เล่น — เหมือน mirror match]
  Patterns: Slash, Heavy Strike, Swift, พร้อม random skill จาก pool ของ boss

Phase 2 (HP 74-50%) — "Divinity Awakened"
  [TRANSITION: ร่างมนุษย์สลาย แสงทองพุ่งออก]
  New: Ascension Beam (×4.0), Divine Ward (damage immunity 1 turn ทุก 5 turns)
  Mechanic: Copy Cat — boss ลอกเลียน skill ล่าสุดของ player ใช้กลับ

Phase 3 (HP 49-25%) — "The Tower's Will"
  [TRANSITION: arena เปลี่ยนเป็น void สมบูรณ์]
  New: Void Collapse (AOE ×5.0, ลดพื้นที่ arena ทุก turn), Reality Shatter
  Mechanic: Memory Drain — steal 1 skill node passive ชั่วคราว (return เมื่อ boss ตาย)

Phase 4 (HP 24-0%) — "Primordial Sovereignty"
  [TRANSITION: Boss แตกออกเป็น light จากนั้น reform เป็น deity form]
  New: Big Bang (×8.0 charge 3 turns — ทั้ง arena), Time Stop (player ทำ action ไม่ได้ 2 turns)
  Mechanic: Eternal Challenge — ถ้า player ใช้ Flee → Boss block → "ไม่มีทางหนีจากที่นี่"
  Death: [cutscene — Boss พูด ก่อนสลายหายไป เปิดทางสู่ Divinity level 10]
```

---

### Mini-Boss Phase Design (General Rules)

```
Phase trigger: HP ลงถึง 50%
Phase 2 changes (mandatory ทุก mini-boss):
  1. Stat buff: ATK ×1.2-1.5, SPD ×1.1-1.3
  2. New attack pattern ≥ 1
  3. Arena mechanic เปลี่ยน หรือเพิ่มเงื่อนไขใหม่
  4. Phase Trait เปลี่ยน behavior

Template GDScript:
```
```gdscript
class_name MiniBoss extends BossEntity

func setup_phases() -> void:
    phases = [
        BossPhase.new({
            "trigger_hp_pct": 1.0,
            "name": "Phase 1",
            "atk_mult": 1.0,
            "spd_mult": 1.0,
            "attack_patterns": ["basic_attack", "special_1"],
            "on_enter": func(b): pass,
        }),
        BossPhase.new({
            "trigger_hp_pct": 0.5,  # เข้า Phase 2 ที่ HP 50%
            "name": "Phase 2",
            "atk_mult": 1.35,
            "spd_mult": 1.2,
            "attack_patterns": ["basic_attack", "special_1", "special_2", "rage_attack"],
            "on_enter": func(b):
                b.emit_signal("phase_transition", 2)
                b.apply_immunity(1.5)  # 1.5 วินาที immunity
                ToastManager.show(b.name + " — Phase 2!", "warning"),
        }),
    ]
```

---

### Score Calculation สำหรับ Boss (ดู §23 Hall of Fame)

```
boss_par_time (turns):
  Mini-boss: 15 turns
  Band 1 Boss: 25 turns
  Band 2 Boss: 30 turns
  Band 3-6 Boss: 35-50 turns (เพิ่มตาม complexity)

bonus_multiplier ตาม phase:
  ชนะใน Phase 1 (ไม่ถึง Phase 2): ×1.5 score bonus
  ชนะใน Phase 2 (mini-boss): ×1.0
  ชนะใน Phase 2 (boss): ×1.2 bonus
  ชนะใน Phase 3+: ×1.0
```

---

### Schema (schema_combat_v1.sql เพิ่ม)

```sql
CREATE TABLE boss_templates (
  id              TEXT PRIMARY KEY,           -- 'boss_band1' / 'miniboss_band1_naga'
  name            TEXT NOT NULL,
  name_th         TEXT NOT NULL,
  boss_type       TEXT NOT NULL,              -- 'boss' / 'mini_boss'
  band_number     INTEGER NOT NULL,
  floor_number    INTEGER,                    -- null = hunting zone
  base_hp         INTEGER NOT NULL,
  base_atk        INTEGER NOT NULL,
  base_def        INTEGER NOT NULL,
  base_spd        INTEGER NOT NULL,
  num_phases      INTEGER NOT NULL,
  enrage_turns    INTEGER,                    -- null = Normal mode ไม่มี enrage
  world_energy_cost INTEGER NOT NULL DEFAULT 10,
  respawn_hours   INTEGER NOT NULL DEFAULT 2,
  triggers_band_unlock BOOLEAN NOT NULL DEFAULT FALSE,
  par_time_turns  INTEGER NOT NULL DEFAULT 20
);

CREATE TABLE boss_phases (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  boss_id         TEXT NOT NULL REFERENCES boss_templates(id),
  phase_index     INTEGER NOT NULL,           -- 0-based
  phase_name      TEXT NOT NULL,
  trigger_hp_pct  NUMERIC NOT NULL,           -- 0.0-1.0
  atk_mult        NUMERIC NOT NULL DEFAULT 1.0,
  spd_mult        NUMERIC NOT NULL DEFAULT 1.0,
  def_mult        NUMERIC NOT NULL DEFAULT 1.0,
  hp_regen_pct    NUMERIC NOT NULL DEFAULT 0.0,
  attack_patterns JSONB NOT NULL DEFAULT '[]',
  arena_mechanic  TEXT,
  immunity_window_sec NUMERIC NOT NULL DEFAULT 1.5,
  PRIMARY KEY constraint via (boss_id, phase_index)
);

CREATE TABLE boss_drop_table (
  boss_id         TEXT NOT NULL REFERENCES boss_templates(id),
  difficulty      TEXT NOT NULL,
  guaranteed_rarity TEXT NOT NULL,            -- 'rare'/'epic'/'legendary'
  legendary_chance  NUMERIC NOT NULL DEFAULT 0.1,
  guarantee_stone_id TEXT,                   -- Guarantee Stone ที่ drop
  extra_drops     JSONB NOT NULL DEFAULT '[]',
  PRIMARY KEY (boss_id, difficulty)
);
```

---

## 52. Enemy AI System

### Design Philosophy
Enemy AI แบ่งเป็น **2 ชั้น** แยกกันชัดเจน:
- **Field AI** — พฤติกรรมใน field map (เดิน, detect, chase, aggro)
- **Combat AI** — พฤติกรรมใน ATB battle (เลือก action, ใช้ skill, target)

Enemy แต่ละตัวมี **AI Profile** ที่กำหนดทั้งสองชั้น — data-driven, ไม่ hardcode per enemy

---

### ชั้น 1 — Field AI

#### Detection & Aggro

```gdscript
# EnemyFieldAI.gd
enum AggroType { PASSIVE, AGGRESSIVE, TERRITORIAL, FLEE_ON_SIGHT }

var aggro_type: AggroType
var detect_radius: float   # tiles
var chase_radius: float    # ถ้า player ออกไปไกลกว่านี้ → abandon chase
var aggro_cooldown: float  # วินาทีหลัง abandon ก่อน reset patrol

func _process(delta: float) -> void:
    match state:
        State.PATROL:    _do_patrol(delta)
        State.ALERTED:   _do_alert(delta)
        State.CHASE:     _do_chase(delta)
        State.COMBAT:    pass  # ส่งให้ CombatAI จัดการ
        State.FLEE:      _do_flee(delta)
        State.RETURN:    _do_return_to_spawn(delta)
```

**AggroType:**
| Type | พฤติกรรม | ตัวอย่าง enemy |
|---|---|---|
| PASSIVE | ไม่โจมตีก่อน วิ่งหนีถ้าถูกตี | กระต่าย, กวาง, นกเล็ก |
| AGGRESSIVE | โจมตีทันทีที่เห็น player | ซอมบี้, demon, ยักษ์ |
| TERRITORIAL | โจมตีเฉพาะถ้า player เข้าในรัศมี | เสือ, งูใหญ่ |
| FLEE_ON_SIGHT | วิ่งหนีทันทีที่เห็น player | สัตว์หายาก, informant NPC |

**Detection modifier:**
```gdscript
# ปัจจัยที่กระทบ detect_radius
func get_effective_detect_radius() -> float:
    var r = base_detect_radius
    r *= 1.5 if is_night() else 1.0          # กลางคืน detect ไกลขึ้น
    r *= 0.7 if player.is_stealth() else 1.0 # stealth ลด radius
    r *= 1.3 if weather == "fog" else 1.0    # หมอก detect ไกลขึ้น (กลิ่น)
    r *= band_difficulty_mult                 # Band สูง detect ไกลขึ้น
    return r
```

#### Patrol Behavior
```gdscript
enum PatrolMode { STATIC, WANDER, PATH_FOLLOW, GUARD_POINT }

# STATIC: ยืนที่จุดเดิม หมุนตัวสุ่ม
# WANDER: เดินสุ่มใน radius จาก spawn point
# PATH_FOLLOW: เดินตาม waypoint list วนซ้ำ
# GUARD_POINT: เดินระหว่าง 2 จุด (ยาม)
```

---

### ชั้น 2 — Combat AI

#### AI Profile Structure

```gdscript
class CombatAIProfile:
    var archetype: String          # 'berserker'/'tactician'/'support'/'trickster'/'tank'
    var patterns: Array[AIPattern] # รายการ pattern ที่ใช้ได้
    var phase_overrides: Dictionary # phase_idx → modified patterns (สำหรับ boss)
    var target_priority: String    # 'lowest_hp'/'highest_hp'/'random'/'healer_first'
    var retreat_threshold: float   # HP% ที่จะเปลี่ยน behavior
```

#### Enemy Archetypes

**1. Berserker** — ตีหนัก ไม่ defensive
```
ลำดับ priority:
  1. ถ้า HP > 30%: โจมตีตลอด (heavy attack ถ้ามี CD หมด, basic attack ถ้าไม่มี)
  2. ถ้า HP < 30%: Enrage → ATK ×1.5, ไม่ใช้ skill defensive ใดๆ

Target: player ที่ HP สูงสุด (ชอบตีคนแข็งแรง)
ตัวอย่าง: หมูป่า, ยักษ์ธรรมดา, demon warrior
```

**2. Tactician** — อ่านสถานการณ์ เลือก action ฉลาด
```
ลำดับ priority:
  1. ถ้า player มี buff → ใช้ dispel / silence ก่อน
  2. ถ้า player HP < 30% → ใช้ finishing move
  3. ถ้า own HP < 50% → ใช้ defensive skill หรือ regen
  4. ถ้า player ใช้ skill เดิมซ้ำ → switch target pattern
  5. default: basic attack หรือ strongest available skill

Target: player ที่ HP ต่ำสุด (kill confirmation)
ตัวอย่าง: assassin spirit, elite guard, bandit captain
```

**3. Support** — เสริมเพื่อน ไม่ค่อยตีผู้เล่นตรงๆ
```
ลำดับ priority:
  1. ถ้ามี ally HP < 40% → heal/shield ally
  2. ถ้า ally ตาย → summon replacement
  3. ถ้าไม่มี ally → buff ตัวเอง → โจมตี
  4. ถ้า player target ตัวเอง → flee จาก player + call ally

Target: ally ที่ HP ต่ำสุด (heal priority)
ตัวอย่าง: shaman, forest spirit healer, necromancer
```

**4. Trickster** — หลอก, debuff, dodge
```
ลำดับ priority:
  1. รอบแรก → ใช้ blind/sleep/confuse เสมอ
  2. ถ้า player มี status effect → ซ้ำเติม status เดิม
  3. ถ้า player ไม่มี status → debuff ใหม่
  4. ทุก 3 turns → evasion buff ตัวเอง
  5. ถ้า HP < 20% → smoke screen + disappear (flee สำเร็จอัตโนมัติ)

Target: player ที่มี buff มากที่สุด (จะ dispel)
ตัวอย่าง: fox spirit, shadow rogue, phantom mage
```

**5. Tank** — DEF สูง, ปกป้อง ally
```
ลำดับ priority:
  1. ถ้ามี ally → taunt (force player to target self)
  2. ถ้าถูก taunt → defensive stance: DEF ×1.5, ตอบโต้ทุก hit
  3. ถ้า ally ตายหมด → berserk mode: ATK ×1.3 ลด DEF กลับปกติ
  4. default: slow heavy attack + shield bash (stun 20%)

Target: player ที่ต่อยตัวเอง (keep aggro)
ตัวอย่าง: stone golem, armored knight, guardian spirit
```

---

#### Pattern Selection Algorithm

```gdscript
func choose_action(enemy: CombatEntity, player: CombatEntity) -> AIAction:
    var profile = enemy.ai_profile
    var candidates: Array[AIPattern] = []

    # 1. กรอง pattern ที่ใช้ได้ (cooldown, condition)
    for p in profile.patterns:
        if p.cooldown_remaining > 0: continue
        if not p.condition.call(enemy, player): continue
        candidates.append(p)

    if candidates.is_empty():
        return AIAction.basic_attack()

    # 2. เรียง priority
    candidates.sort_custom(func(a, b):
        return a.get_priority(enemy, player) > b.get_priority(enemy, player))

    # 3. Weighted random ใน top 3 (ไม่ predictable 100%)
    var pool = candidates.slice(0, min(3, candidates.size()))
    var weights = pool.map(func(p): return p.get_priority(enemy, player))
    return pool[weighted_random_index(weights)].execute(enemy, player)
```

**Weighted random** ป้องกันไม่ให้ AI predictable เกินไป — enemy ไม่ได้ทำ optimal เสมอ

---

#### Elemental Resistance & Weakness

แต่ละ enemy type มี elemental profile:

```gdscript
var elemental_profile = {
    "fire_resist":      0.0,   # -1.0 = absorb, 0 = neutral, 1.0 = immune, 0.5 = resist 50%
    "ice_resist":       0.0,
    "lightning_resist": 0.0,
}

func calc_elemental_dmg(raw_dmg: int, element: String) -> int:
    var resist = elemental_profile.get(element + "_resist", 0.0)
    if resist >= 1.0: return 0          # immune
    if resist < 0:    return int(raw_dmg * (1.0 + abs(resist)))  # absorb = heal
    return int(raw_dmg * (1.0 - resist))
```

**ตัวอย่าง Band 1 elemental profiles:**
| Enemy | Fire | Ice | Lightning | หมายเหตุ |
|---|---|---|---|---|
| งูน้ำ | 0.5 | -0.3 | 0 | ต้านไฟ, อ่อนแอน้ำแข็ง |
| ยักษ์ไฟ | -0.5 | 0.8 | 0 | absorb ไฟ, ต้านน้ำแข็ง |
| นกพายุ | 0 | 0 | 1.0 | immune lightning |
| วิญญาณป่า | 0 | 0 | -0.5 | absorb lightning |
| โกเลมหิน | 0.3 | 0 | 0.5 | ต้านทั้งไฟและสายฟ้า |

**Combat AI ตอบสนองต่อ elemental:**
```gdscript
# ถ้า AI สังเกตว่า player ใช้ fire attack บ่อย → ปรับ behavior
func _update_player_model(last_action: AIAction) -> void:
    if last_action.element == "fire":
        player_model.preferred_element = "fire"
        # ถ้าตัวเองอ่อนแอต่อไฟ → เพิ่ม priority ของ defensive skill
        if elemental_profile.fire_resist < -0.2:
            _boost_pattern_priority("fire_shield", 2.0)
```

---

#### Enemy AI ตาม Camp Type

| Camp Type | Enemy Composition | AI Focus |
|---|---|---|
| normal | 2-4 ตัว random type | Berserker + Support ผสม |
| elite | 2-3 ตัว tier สูง | Tactician เป็นหลัก |
| mini_boss | 1 mini-boss + 0-2 adds | Boss ใช้ phase, adds ใช้ Support |
| boss | 1 boss | Phase-based AI |
| hunting_zone | สัตว์ป่า | Passive + Flee on sight |
| mystery | random event | varied |

**Multi-enemy Combat:**
```gdscript
# EnemyGroup.gd — จัดการ coordination ระหว่าง enemy
func coordinate_actions() -> void:
    # ถ้า healer ยังมีชีวิต → healer ไป front, tank taunt ก่อน
    # ถ้า tank ตาย → ทุกตัว switch priority เป็น aggro
    # ถ้า player HP < 20% → ทุกตัว focus fire
    var healer = get_alive_enemies().filter(func(e): return e.archetype == "support")
    var tanks   = get_alive_enemies().filter(func(e): return e.archetype == "tank")

    if not tanks.is_empty():
        tanks[0].set_override_action("taunt")  # tank taunt รอบแรก

    if healer and healer[0].ai_profile.retreat_triggered:
        healer[0].set_position_priority("back_row")
```

---

#### Night Behavior Modifier

กลางคืน (20:00-05:00 game time) → enemy AI เปลี่ยน:

```gdscript
func get_night_modifiers() -> Dictionary:
    return {
        "detect_radius_mult": 1.25,   # detect ไกลขึ้น 25%
        "aggro_threshold": 0.7,       # aggro ง่ายขึ้น
        "atk_mult": 1.1,              # ATK +10%
        "patrol_speed_mult": 1.2,     # เดินเร็วขึ้น
        "spawn_rate_mult": 1.5,       # spawn เพิ่ม 50%
    }
```

---

#### Schema (schema_combat_v1.sql เพิ่ม)

```sql
CREATE TABLE enemy_templates (
  id                  TEXT PRIMARY KEY,
  name                TEXT NOT NULL,
  name_th             TEXT NOT NULL,
  band_number         INTEGER NOT NULL,
  camp_types          TEXT[] NOT NULL,     -- camp types ที่ spawn ได้
  ai_archetype        TEXT NOT NULL,
    -- 'berserker'/'tactician'/'support'/'trickster'/'tank'
  aggro_type          TEXT NOT NULL,
    -- 'passive'/'aggressive'/'territorial'/'flee_on_sight'
  patrol_mode         TEXT NOT NULL DEFAULT 'wander',
  detect_radius       NUMERIC NOT NULL DEFAULT 3.0,
  chase_radius        NUMERIC NOT NULL DEFAULT 8.0,
  base_hp             INTEGER NOT NULL,
  base_atk            INTEGER NOT NULL,
  base_def            INTEGER NOT NULL,
  base_spd            INTEGER NOT NULL,
  elemental_profile   JSONB NOT NULL DEFAULT '{}',
  retreat_threshold   NUMERIC NOT NULL DEFAULT 0.2,
  target_priority     TEXT NOT NULL DEFAULT 'lowest_hp',
  drop_table          JSONB NOT NULL DEFAULT '[]',
  capture_rate        NUMERIC NOT NULL DEFAULT 0.3,
  durability_damage_mult NUMERIC NOT NULL DEFAULT 1.0
    -- 0.0=Slime, 1.0=Normal, 1.5=Armored/Stone, 2.0=Acid/Fire, 3.0=Mythic
);

CREATE TABLE enemy_patterns (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  enemy_id        TEXT NOT NULL REFERENCES enemy_templates(id),
  pattern_name    TEXT NOT NULL,
  action_type     TEXT NOT NULL,  -- 'attack'/'skill'/'buff'/'debuff'/'summon'/'flee'
  damage_mult     NUMERIC,
  element         TEXT,
  status_effect   TEXT,
  status_chance   NUMERIC,
  target_type     TEXT NOT NULL DEFAULT 'player',  -- 'player'/'self'/'ally'
  cooldown_turns  INTEGER NOT NULL DEFAULT 0,
  condition       TEXT,           -- 'always'/'hp_below_30'/'player_buffed' ฯลฯ
  base_priority   NUMERIC NOT NULL DEFAULT 1.0,
  aoe_radius      INTEGER NOT NULL DEFAULT 0
);

-- Band 1 enemies seed data (ตัวอย่าง)
INSERT INTO enemy_templates VALUES
  ('snake_water_b1', 'งูน้ำ', 'Water Snake', 1,
   ARRAY['normal','elite'], 'territorial', 'wander',
   3.0, 8.0, 80, 12, 6, 90,
   '{"fire_resist":0.5,"ice_resist":-0.3}', 0.3, 'lowest_hp',
   '[{"rarity":"common","rate":0.8},{"rarity":"uncommon","rate":0.2}]', 0.35),

  ('golem_stone_b1', 'โกเลมหิน', 'Stone Golem', 1,
   ARRAY['elite','mini_boss'], 'territorial', 'static',
   1.5, 10.0, 300, 50, 2, 40,
   '{"fire_resist":0.3,"lightning_resist":0.5}', 0.1, 'random',
   '[{"rarity":"uncommon","rate":0.7},{"rarity":"rare","rate":0.3}]', 0.1);
```

---

## 53. Party ATB Sync

### Core Design Problem

ATB combat solo ใช้ **pause-on-player-turn** — เกมหยุดรอ player เลือก action
Multiplayer มี player หลายคน → pause รอทุกคน = party อื่นนั่งรอ = รู้สึกแย่

**แนวทาง: Shared Timeline + Individual Action Window**
- ATB bar ทุกหน่วย (players + enemies) ชาร์จพร้อมกันบน shared timeline
- เมื่อ player ใดๆ ATB เต็ม → เฉพาะ player นั้น pause เลือก action (local pause)
- Player อื่นและ enemy ยัง tick ต่อไประหว่างนั้น
- มี action window จำกัด — หมดเวลา → auto-attack แทน

---

### Combat Session State Machine

```
[WAITING]         ← รอ party สร้างครบ (min 1, max 4)
     ↓ all_ready
[INITIALIZING]    ← server สร้าง combat_session, load enemies, assign positions
     ↓ init_complete
[ACTIVE]          ← combat loop วิ่ง
     │
     ├─ unit.atb ≥ 100 (player)  → [PLAYER_TURN:{player_id}]
     │       └─ action received / window expired → back [ACTIVE]
     │
     ├─ unit.atb ≥ 100 (enemy)   → [ENEMY_TURN] → resolve → back [ACTIVE]
     │
     └─ end condition met → [RESOLVING]
                                   ↓
                             [ENDED:{win/lose/fled/draw}]
                                   ↓
                             distribute rewards → combat_session.status = closed
```

---

### Shared Timeline Architecture

**tick_rate:** 20 ticks/วินาที (server-side)

```gdscript
# PartyATBManager.gd (runs on Dedicated Server / Host)
var tick: int = 0
var units: Array[CombatUnit] = []
var pending_actions: Dictionary = {}
var action_queue: Array = []

func process_tick() -> void:
    tick += 1
    action_queue.clear()

    for unit in units:
        if unit.is_dead: continue
        unit.atb    = min(100.0, unit.atb + unit.spd / 100.0)
        unit.energy = min(unit.max_energy, unit.energy + unit.energy_regen)
        unit.hp     = min(unit.max_hp, unit.hp + unit.hp_regen)
        _tick_status_effects(unit)

        if unit.atb >= 100.0:
            unit.atb = 0.0
            action_queue.append(unit)

    action_queue.sort_custom(func(a, b): return a.spd > b.spd)

    for unit in action_queue:
        if unit.is_player:
            _open_action_window(unit)
        else:
            _resolve_enemy_action(unit)

    _check_end_conditions()
    if tick % 5 == 0:
        _broadcast_state_snapshot()
```

---

### Action Window

| Difficulty | Window | หมดเวลา |
|---|---|---|
| Normal | 15 วินาที | Auto-basic-attack |
| Hard | 12 วินาที | Auto-basic-attack |
| Ascendant | 10 วินาที | Auto-basic-attack |
| Eternal Path | 8 วินาที | Auto-basic-attack |

**Auto-attack logic เมื่อ window หมด:**
```gdscript
func _auto_action(player: CombatUnit) -> Dictionary:
    if player.energy >= 3:
        var skill = player.get_available_skill()
        if skill: return {"type": "skill", "skill_id": skill.id,
                          "target": _pick_target(player)}
    return {"type": "attack", "target": _pick_target(player)}

func _pick_target(player: CombatUnit) -> String:
    return enemies.filter(func(e): return not e.is_dead)                   .min_by(func(e): return e.hp).id
```

**HUD:**
```
[Action Menu] ──────────── ⏱ 12s ████████░░░░ ────────────
│  ⚔️  โจมตี
│  ✨  ทักษะ   [Q] เพลิงพุ่ง ⚡5   [E] ฟาดหนัก ⚡4
│  🧪  ไอเทม
│  🏃  หนี     (⚡2/4)

[Party Panel]
  🗡️ สมชาย ⏱████░░  กำลังตัดสินใจ...
  🗡️ มานี  HP████░   ATB░░░░░░░░░
  🗡️ คุณ   HP█████   ATB███████░░ ← TURN
```

---

### Simultaneous Action Resolution

```gdscript
# หลาย player ATB เต็มใน tick เดียวกัน
# ทุกคนได้ window พร้อมกัน, resolve ตาม SPD order
func _resolve_queued_actions(queue: Array) -> void:
    for action in queue:
        if action.target.is_dead: continue  # skip ถ้า target ตายไปแล้ว
        _apply_action(action)

# ตัวอย่าง:
# สมชาย SPD 120 → Heavy Strike → enemy HP: 1000 → 700
# มานี   SPD 90  → Fire Skill  → enemy HP: 700 → 420 (รับผลจากสมชายแล้ว)
```

---

### Loot Distribution

**loot_mode เลือกโดย party leader ก่อนเข้า combat:**

| Mode | กฎ |
|---|---|
| Free-for-all | ใครเก็บก่อนได้ก่อน |
| Round Robin | หมุนสิทธิ์ตาม join_order |
| Need / Greed | roll dice — Need ชนะ Greed |
| Leader | leader แจกเอง |

**Need/Greed:**
```gdscript
func distribute_loot_need_greed(item: Item, party: Array) -> void:
    var need_rolls = {}
    var greed_rolls = {}
    for player in party:
        var choice = await _get_loot_choice(player, item, 15.0)
        if choice == "need":   need_rolls[player.id]  = randi_range(1, 100)
        elif choice == "greed": greed_rolls[player.id] = randi_range(1, 100)
    var winner = null
    if not need_rolls.is_empty():
        winner = need_rolls.keys().max_by(func(k): return need_rolls[k])
    elif not greed_rolls.is_empty():
        winner = greed_rolls.keys().max_by(func(k): return greed_rolls[k])
    if winner:
        InventoryManager.give_item(winner, item)
```

**Gold / EXP:**
```
gold_per_player = total_gold / party_size  (ปัดลง)
divinity_exp: ทุกคนได้เท่ากัน ไม่แบ่ง
proficiency_exp: ทุกคนได้เท่ากัน ไม่แบ่ง
quest_progress: ทุกคนนับ
```

---

### Death & Revive

```
player HP = 0 → "downed" (30 วิ):
  ├─ party member ใช้ Revive skill → ฟื้น 30% HP, revive_immunity 2 turns
  └─ ไม่มีใครช่วย → KO → ออก combat → checkpoint, ไม่ได้ loot

Eternal Path: downed = ตายจริง (death_locked) แม้อยู่ใน party
```

```gdscript
func use_revive(caster: CombatUnit, target: CombatUnit) -> void:
    if not target.is_downed: return
    target.hp = target.max_hp * 0.30
    target.is_downed = false
    target.apply_status("revive_immunity", 2)
    _broadcast("%s ฟื้น %s!" % [caster.name_th, target.name_th])
```

**KO player → Spectate Mode:**
- เห็น combat ต่อ ไม่มี action menu
- เห็น HP bar, ATB bar, damage numbers
- มีปุ่ม "กลับ spawn"

---

### Combat End Conditions

| ผล | เงื่อนไข | Loot | Gold | EXP |
|---|---|---|---|---|
| WIN | enemies ทั้งหมดตาย | ✅ ครบ | ✅ แบ่ง | ✅ ครบ |
| LOSE | players ทั้งหมด KO/fled | ❌ | ❌ | ❌ |
| ALL_FLED | ทุกคน flee สำเร็จ | ❌ | ❌ ลด rand(1-10)% | ❌ |
| KO บางคน + WIN | บางคน KO ก่อน win | ⚠️ KO ไม่ได้ loot | ✅ แบ่งเท่า | ⚠️ KO ได้ 50% |

---

### Disconnect Handling

```gdscript
func _handle_disconnect(player_id: String) -> void:
    var player = get_unit(player_id)
    player.is_disconnected = true
    player.reconnect_deadline = Time.get_unix_time_from_system() + 30.0
    player.ai_override = "auto_attack"

func _process_reconnect_deadline() -> void:
    for player in get_disconnected_players():
        if Time.get_unix_time_from_system() > player.reconnect_deadline:
            player.is_fled = true
            player.is_disconnected = false
            _check_end_conditions()
```

**Host disconnect (Friend Session P2P):**
```
รอ 30 วิ → reconnect: ต่อ / ไม่กลับ: combat ยกเลิก (draw)
vote migrate host ≥ 50% → member อื่นเป็น host แทน
```

**Late Join:** ไม่อนุญาต — เข้า combat ได้ตอนเริ่มเท่านั้น

---

### Network RPC Design

```gdscript
@rpc("any_peer", "reliable")
func submit_action(action_type: String, target_id: String,
                   skill_id: String, item_id: String) -> void:
    PartyATBManager.receive_player_action(
        multiplayer.get_remote_sender_id(),
        {"type": action_type, "target": target_id,
         "skill": skill_id, "item": item_id})

@rpc("authority", "reliable")
func broadcast_action_result(result: Dictionary) -> void:
    CombatRenderer.apply_result(result)
    PartyHUD.refresh_all()

@rpc("authority", "reliable")
func notify_your_turn(deadline: float) -> void:
    ActionMenu.show_with_countdown(deadline)

@rpc("authority", "unreliable")   # ส่งทุก 5 ticks
func sync_atb_state(snapshot: Dictionary) -> void:
    CombatRenderer.update_unit_bars(snapshot)

@rpc("authority", "reliable")
func request_loot_choice(item_data: Dictionary, deadline: float) -> void:
    LootChoiceDialog.show(item_data, deadline)

@rpc("any_peer", "reliable")
func submit_loot_choice(item_id: String, choice: String) -> void:
    PartyATBManager.receive_loot_choice(
        multiplayer.get_remote_sender_id(), item_id, choice)
```

**Bandwidth:** ~1.5 KB/s per player — รับได้สบาย

---

### Friendly Fire & Targeting

```gdscript
func get_valid_targets(caster: CombatUnit, skill: CombatSkill) -> Array:
    return units.filter(func(u):
        if u.is_dead: return false
        match skill.target_type:
            "enemy":       return u.party_id != caster.party_id
            "ally":        return u.party_id == caster.party_id and u != caster
            "self":        return u == caster
            "downed_ally": return u.party_id == caster.party_id and u.is_downed
        return false)
```

---

### Schema (schema_combat_v1.sql)

```sql
ALTER TABLE combat_sessions ADD COLUMN IF NOT EXISTS
    party_id          UUID,
    is_party_combat   BOOLEAN NOT NULL DEFAULT FALSE,
    action_window_sec INTEGER NOT NULL DEFAULT 15,
    loot_mode         TEXT NOT NULL DEFAULT 'round_robin',
    round_robin_next_idx INTEGER NOT NULL DEFAULT 0;

CREATE TABLE party_combat_members (
  session_id      UUID NOT NULL REFERENCES combat_sessions(id) ON DELETE CASCADE,
  player_id       UUID NOT NULL REFERENCES players(id),
  join_order      INTEGER NOT NULL,
  joined_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
  left_at         TIMESTAMPTZ,
  is_downed       BOOLEAN NOT NULL DEFAULT FALSE,
  is_fled         BOOLEAN NOT NULL DEFAULT FALSE,
  is_disconnected BOOLEAN NOT NULL DEFAULT FALSE,
  exit_reason     TEXT,
  loot_received   JSONB NOT NULL DEFAULT '[]',
  gold_received   INTEGER NOT NULL DEFAULT 0,
  PRIMARY KEY (session_id, player_id)
);

CREATE TABLE party_loot_rolls (
  session_id  UUID NOT NULL REFERENCES combat_sessions(id) ON DELETE CASCADE,
  item_id     UUID NOT NULL REFERENCES player_items(id),
  player_id   UUID NOT NULL REFERENCES players(id),
  choice      TEXT NOT NULL,
  roll_value  INTEGER,
  won         BOOLEAN NOT NULL DEFAULT FALSE,
  rolled_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_party_members_session ON party_combat_members (session_id);
CREATE INDEX idx_loot_rolls_session    ON party_loot_rolls (session_id, item_id);
```

---


## 54. Skill Node Content Pool

### Node Structure (ทุก node มีครบ 3 ส่วน)

```gdscript
var node = {
    "id": "uuid",
    "name_th": "ชื่อภาษาไทย",
    "tier": 1,                    # 1-5
    "rarity": "common",
    "band": 1,                    # 0 = universal, 1-6 = band-specific
    # 1. Stat bonus (passive ตลอดเวลา)
    "stat_bonus": {"atk": 5, "spd": 0, ...},
    # 2. Active skill (เพิ่ม combat hotbar slot ถ้ามี)
    "active_skill": null,         # หรือ skill_id
    # 3. Passive special effect
    "passive_effect": null,       # หรือ effect definition
}
```

**Node Type ตาม content:**
| Type | มี stat_bonus | มี active_skill | มี passive_effect |
|---|---|---|---|
| Stat Node | ✅ | ❌ | ❌ |
| Skill Node | ✅ (เล็กน้อย) | ✅ | ❌ |
| Passive Node | ✅ (เล็กน้อย) | ❌ | ✅ |
| Hybrid Node | ✅ | ❌ | ✅ |
| Ascension Node | ✅ (ใหญ่) | ✅ | ✅ |

---

### Tier 1 — Common Nodes (gold เท่านั้น, 200 gold)

**หลักการ:** stat bonus พื้นฐาน ไม่มี active skill ยังไม่มี special effect

#### Universal Nodes (ทุก Band ใช้ได้)

| # | ชื่อ | Stat Bonus | Passive Effect |
|---|---|---|---|
| U-01 | ร่างกายแข็งแกร่ง | HP +50 | — |
| U-02 | กล้ามเนื้อเหล็ก | ATK +3 | — |
| U-03 | หนังหนา | DEF +3 | — |
| U-04 | ก้าวย่างเบา | SPD +5 | — |
| U-05 | จังหวะโจมตี | CRIT_RATE +2% | — |
| U-06 | พลังฟื้นฟู | HP_REGEN +1/turn | — |
| U-07 | พลังงานภายใน | ENERGY +2 | — |
| U-08 | ฟื้นพลังเร็ว | ENERGY_REGEN +1/turn | — |
| U-09 | ความอึด | HP +30, DEF +1 | — |
| U-10 | ความคล่องแคล่ว | SPD +3, CRIT_RATE +1% | — |

#### Band 1 — Thai Pantheon Nodes (Tier 1)

| # | ชื่อ | Stat Bonus | Passive Effect |
|---|---|---|---|
| B1-01 | พลังศรัทธา | ATK +4 | — |
| B1-02 | เกราะเทวดา | DEF +4 | — |
| B1-03 | เท้าพายุ | SPD +6 | — |
| B1-04 | สายตาเทพ | CRIT_RATE +3% | — |
| B1-05 | เพลิงศักดิ์สิทธิ์ | FIRE_DMG +5% | — |
| B1-06 | น้ำแข็งนาคา | ICE_DMG +5% | — |
| B1-07 | สายฟ้าวัชระ | LIGHTNING_DMG +5% | — |
| B1-08 | ผิวหนังพลิ้ว | HP +40, SPD +2 | — |
| B1-09 | กำลังนักรบ | ATK +3, DEF +2 | — |
| B1-10 | จิตใจนักสู้ | ENERGY +3, HP +20 | — |

---

### Tier 2 — Uncommon Nodes (skill_node uncommon ×1, 600 gold)

**หลักการ:** stat bonus ดีขึ้น + เริ่มมี passive effect เบาๆ

#### Universal Nodes (Tier 2)

| # | ชื่อ | Stat Bonus | Passive Effect |
|---|---|---|---|
| U-11 | สัญชาตญาณนักล่า | ATK +6, CRIT_RATE +2% | เมื่อ HP เต็ม: ATK +5% |
| U-12 | เกราะแห่งเจตจำนง | DEF +6, HP +30 | เมื่อ DEF สูงกว่า enemy ATK: absorb 10% damage |
| U-13 | เท้าสายลม | SPD +10 | ทุก 3 turns: เคลื่อนที่ฟรี 1 ครั้ง (avoid AOE) |
| U-14 | หัวใจเหล็ก | HP +80, HP_REGEN +1 | HP < 50%: HP_REGEN ×2 |
| U-15 | ตาเหยี่ยว | CRIT_RATE +4%, CRIT_DMG +20% | CRIT ต่อเนื่อง 2 ครั้ง: ATK +10% turn ถัดไป |
| U-16 | พลังงานไหลเวียน | ENERGY +4, ENERGY_REGEN +1 | ใช้ Skill: regen 1 energy ทันที |
| U-17 | รูปแบบหลบหลีก | SPD +8, DEF +3 | miss ของ enemy → CRIT_RATE +5% turn ถัดไป |
| U-18 | แรงกระแทก | ATK +8 | โจมตีติดต่อกัน 3 ครั้ง: ครั้งที่ 3 ×1.5 |

#### Band 1 Nodes (Tier 2)

| # | ชื่อ | Stat Bonus | Passive Effect |
|---|---|---|---|
| B1-11 | เพลิงพิโรธ | ATK +5, FIRE_DMG +10% | Kill → FIRE_DMG +5% สะสม (max +20%, reset หลัง combat) |
| B1-12 | น้ำแข็งนิรันดร์ | DEF +5, ICE_DMG +10% | ถูกตี → 15% chance: enemy slow 1 turn |
| B1-13 | สายฟ้าพลิ้ว | SPD +8, LIGHTNING_DMG +10% | ใช้ lightning skill → SPD +5 turn ถัดไป |
| B1-14 | นักสู้แห่งศรัทธา | ATK +7, HP +40 | HP < 30%: ATK +15% |
| B1-15 | โล่แห่งธรรม | DEF +8, HP_REGEN +2 | ทุก turn ที่ไม่ถูกตี: DEF +3 สะสม (max +15, reset ถ้าถูกตี) |

---

### Tier 3 — Rare Nodes (skill_node rare ×1, 1,500 gold)

**หลักการ:** passive effect ชัดเจน + บาง node เริ่มให้ active skill

#### Universal Nodes (Tier 3)

| # | ชื่อ | Stat Bonus | Active Skill | Passive Effect |
|---|---|---|---|---|
| U-19 | พายุแห่งการโจมตี | ATK +12 | **พายุฟัน** (uncommon): ×1.5 ×3 hit rapid | — |
| U-20 | ป้อมปราการ | DEF +12, HP +60 | — | รับ damage > 20% HP ใน turn เดียว: shield 15% HP 2 turns |
| U-21 | จิตใจนักพิชิต | ATK +8, CRIT_DMG +30% | — | CRIT → heal 5% HP |
| U-22 | พลังงานไร้ขีดจำกัด | ENERGY +6 | — | ใช้ Skill: 20% chance ไม่เสีย energy |
| U-23 | ความเร็วแห่งสายฟ้า | SPD +15, CRIT_RATE +5% | — | ATB เต็มก่อน enemy → first strike: ATK +20% turn แรก |
| U-24 | นักเวทย์รบ | ATK +6, ALL_DMG +10% | **Arcane Strike** (rare): ×2.0, ignore DEF 30% | — |

#### Band 1 Nodes (Tier 3)

| # | ชื่อ | Stat Bonus | Active Skill | Passive Effect |
|---|---|---|---|---|
| B1-16 | เพลิงวิมาน | FIRE_DMG +20%, ATK +8 | **เปลวเพลิงสวรรค์** (rare): AOE FIRE ×1.8, burn 40% | — |
| B1-17 | นาคาน้ำแข็ง | ICE_DMG +20%, HP +60 | — | ถูกตี → 25% freeze enemy 1 turn |
| B1-18 | วัชรสายฟ้า | LIGHTNING_DMG +20%, SPD +10 | **สายฟ้าวัชระ** (rare): single ×2.2, shocked 50% | — |
| B1-19 | พลังยักษ์ | ATK +15, HP +80 | — | HP > 70%: ATK +10%. HP > 90%: ATK +20% |
| B1-20 | ครุฑนักล่า | CRIT_RATE +8%, CRIT_DMG +40% | — | ทุก 5 turns: guaranteed CRIT |
| B1-21 | วิญญาณนาค | ICE_DMG +15%, HP_REGEN +3 | — | รัก HP เกิน 80%: regen เพิ่มขึ้น ×2 |

---

### Tier 4 — Epic Nodes (skill_node epic ×1, 4,000 gold, divinity ≥ 3)

**หลักการ:** passive effect ทรงพลัง + active skill tier epic ทุก node

#### Universal Nodes (Tier 4)

| # | ชื่อ | Stat Bonus | Active Skill | Passive Effect |
|---|---|---|---|---|
| U-25 | ผู้ทำลายล้าง | ATK +20, CRIT_DMG +50% | **พิฆาต** (epic): ×3.5, execute ถ้า HP < 20% | kill → reset ATB ทันที (สู้ต่อได้ทันที) |
| U-26 | ป้อมปราการเทพ | DEF +20, HP +100 | **กำแพงเทพ** (epic): shield 30% HP 3 turns | ถูกตี ≥ 3 ครั้งใน combat → DEF permanent +10 |
| U-27 | จอมเวทย์ | ALL_DMG +20%, ENERGY +8 | **คลื่นพลังงาน** (epic): AOE ×2.5 ทุก enemy | Skill ทุกตัว cooldown -1 (min 0) |
| U-28 | นักล่าเลือด | ATK +15, CRIT_RATE +10% | **เงาพิฆาต** (epic): ×2.0 ×2, bleed 60% | bleed stack ≥ 3 → ATK +20% |
| U-29 | ราชาแห่งความเร็ว | SPD +25, CRIT_RATE +8% | **กระแสสายลม** (epic): self SPD ×2 3 turns | ATB เต็มก่อน enemy ทุก turn: ได้ action เพิ่ม 20% chance |

#### Band 1 Nodes (Tier 4)

| # | ชื่อ | Stat Bonus | Active Skill | Passive Effect |
|---|---|---|---|---|
| B1-22 | เจ้าแห่งเพลิง | FIRE_DMG +35%, ATK +15 | **มหาเพลิง** (epic): AOE FIRE ×2.8, burn ×2 stacks | burn stack ทุก stack บน enemy: player ATK +5% |
| B1-23 | นาคาอมตะ | ICE_DMG +35%, HP +100 | **น้ำแข็งนิรันดร์** (epic): AOE ICE ×2.5, freeze 30% | freeze enemy → player HP regen ×3 turn นั้น |
| B1-24 | เทพสายฟ้า | LIGHTNING_DMG +35%, SPD +15 | **สายฟ้ามรณะ** (epic): chain ×2.0 (กระโดดหา enemy อื่น) | CRIT ด้วย lightning → bonus LIGHTNING hit ×0.5 |
| B1-25 | ร่างทรงยักษ์ | HP +150, ATK +18 | **คำรามยักษ์** (epic): taunt all enemies 2 turns, DEF ×1.5 | HP < 50%: ทุก hit ที่รับ → สะสม rage → ATK สูงขึ้น (max +30%) |
| B1-26 | ครุฑราช | CRIT_RATE +12%, CRIT_DMG +60% | **ปีกครุฑ** (epic): dive bomb ×3.0 AOE 2×2 | หลัง CRIT: next attack guaranteed CRIT ด้วย |

---

### Tier 5 — Ascension Nodes (Legendary/Mythic)

#### Legendary Ascension Nodes (10,000 gold + skill_node legendary ×1, divinity ≥ 4)

**อัคคีเทพบุตร — เจ้าแห่งไฟ**
```
Band: 1 | Type: Ascension | Rarity: Legendary

Stat Bonus:
  FIRE_DMG +100%, ATK +30, ALL_DMG +30%

Active Skill — "พระอัคนีกำแหน่" (legendary):
  AOE ทุก enemy, FIRE ×4.0, guaranteed burn ×3 stacks
  cooldown: 8 turns | energy: 10

Passive:
  1. HP < 30% → FIRE_DMG +50% (เพิ่มจากที่มีอยู่แล้ว)
  2. burn enemy → player HP regen +5% per stack per turn
  3. Immune to burn debuff (ไฟเผาตัวเองไม่ได้)
```

**นาคเทพบุตร — เจ้าแห่งน้ำและน้ำแข็ง**
```
Band: 1 | Type: Ascension | Rarity: Legendary

Stat Bonus:
  ICE_DMG +100%, HP +200, HP_REGEN +5/turn

Active Skill — "คำสาปนาคา" (legendary):
  Single ×3.5 ICE, freeze 100%, สร้าง ice wall บน arena 3 turns
  cooldown: 7 turns | energy: 9

Passive:
  1. ทุก 20 damage ที่รับ → 1 ice charge (max 5)
  2. ใช้ ICE skill → consume all charges → bonus ×0.2 per charge
  3. freeze enemy → DEF +20% ชั่วคราว
```

**วัชรเทพบุตร — เจ้าแห่งสายฟ้า**
```
Band: 1 | Type: Ascension | Rarity: Legendary

Stat Bonus:
  LIGHTNING_DMG +100%, SPD +40, CRIT_RATE +15%

Active Skill — "วัชระมรณะ" (legendary):
  ×5.0 single, chain กระโดดไป 2 enemy อื่น ×2.5
  cooldown: 6 turns | energy: 8

Passive:
  1. ทุก CRIT → ชาร์จ lightning gauge +1 (max 10)
  2. gauge เต็ม → next skill free (ไม่เสีย energy) + LIGHTNING_DMG ×2
  3. SPD สูงกว่า enemy ≥ 30 → first strike ทุกครั้ง (ATB เต็มก่อนเสมอ)
```

#### Mythic Ascension Node (25,000 gold + skill_node mythic ×1, divinity ≥ 8)

**ทวยเทพบุตร — ผู้เหนือเทพ**
```
Band: 1 | Type: Ascension | Rarity: Mythic

Stat Bonus:
  ALL_DMG +50%, ATK +50, DEF +30, HP +200, SPD +20
  CRIT_RATE +15%, CRIT_DMG +50%

Active Skill — "พิฆาตทวยเทพ" (mythic):
  AOE ทุก enemy, ALL element ×6.0, bypass all resistance
  apply all status effects (burn + freeze + shocked + bleed + poison)
  cooldown: 10 turns | energy: 12

Passive:
  1. กลายเป็น "เทพปกรณัม" — title เปลี่ยน, aura effect รอบตัว
  2. HP < 10% → divine barrier: immune all damage 1 turn (1×/combat)
  3. kill enemy → restore 20% HP + 3 energy
  4. ทุก stat ของ player เพิ่มตาม Divinity level: +2% per level (max +20% at Div 10)
```

---

### Band 2-6 Ascension Nodes (ตัวอย่าง)

**Band 2 — Greek Pantheon**

| Node | Rarity | Stat หลัก | Active Skill | Passive Effect |
|---|---|---|---|---|
| ซุสเทพบดี (legendary) | Legendary | LIGHTNING +100%, ATK +30 | **สายฟ้าโอลิมปัส**: chain ×4.5 ทุก enemy | ทุก CRIT → thunder mark → สะสม 5 marks → free action |
| เอเธน่าแห่งปัญญา (legendary) | Legendary | DEF +50, ALL_DMG +25% | **盾 of Athena**: shield + reflect 30% damage | หลบ attack → counter ×1.0 อัตโนมัติ |
| อพอลโลทอง (legendary) | Legendary | CRIT +20%, SPD +30 | **ลูกศรอาทิตย์**: FIRE+LIGHTNING ×3.5, burn+shocked | ทุก turn แรกของ combat: guaranteed CRIT |
| ราชาโอลิมปัส (mythic) | Mythic | ALL stat +40%, ALL_DMG +60% | **Olympus Judgement**: ×7.0 single unblockable | immune to all status effects, HP < 5% → resurrect 1×/combat |

**Band 3 — Norse Pantheon**

| Node | Rarity | Stat หลัก | Active Skill | Passive Effect |
|---|---|---|---|---|
| โอดินผู้รอบรู้ (legendary) | Legendary | ALL_DMG +40%, CRIT +15% | **หอกกุนกนีร์**: ×4.0, pierce all DEF | ทุกต้นรอบ combat: รู้ pattern ถัดไปของ enemy |
| ทอร์สายฟ้า (legendary) | Legendary | LIGHTNING +120%, ATK +35 | **มโจลนีร์**: LIGHTNING AOE ×3.8, stun 50% | ทุก 4 turns: throw hammer ฟรี ×2.0 (no energy) |
| เฟรย่าแห่งสงคราม (legendary) | Legendary | ATK +30, HP +200 | **Valkyrie Call**: self revive 50% HP 1×/combat | kill → battle cry: party ATK +10% 3 turns |
| รากนาโรค (mythic) | Mythic | HP +400, ATK +60, DEF +40 | **World Serpent Bite**: ×7.5, poison ×5 stacks | ยิ่ง HP ต่ำ ยิ่ง ATK สูง (linear: HP 0% → ATK ×3.0) |

**Band 4 — Egyptian Pantheon**

| Node | Rarity | Stat หลัก | Active Skill | Passive Effect |
|---|---|---|---|---|
| รา-เทพดวงอาทิตย์ (legendary) | Legendary | FIRE +110%, ALL_DMG +30% | **Solar Barque**: FIRE AOE ×4.0, burn ×2, heal self 20% | กลางวัน: ALL_DMG +20%. กลางคืน: HP_REGEN ×3 |
| อานูบิสผู้พิพากษา (legendary) | Legendary | ATK +35, CRIT +18% | **Scale of Ma'at**: ถ้า enemy HP < 50% → instant kill chance 10% | kill → soul harvest: HP regen ×2 next 3 turns |
| ไอซิสแห่งเวทมนตร์ (legendary) | Legendary | ALL_DMG +35%, ENERGY +10 | **Resurrection**: revive self 40% HP 1×/combat | ทุก skill ที่ cast: cleanse 1 debuff จากตัวเอง |
| ฟาโรห์นิรันดร์ (mythic) | Mythic | DEF +60, HP +300, ATK +45 | **Eternal Pharaoh**: immune + counter all attacks 2 turns | ทุก turn: สะสม ankh charge → ทุก 5 charges = 1 free action |

**Band 5 — Japanese Pantheon**

| Node | Rarity | Stat หลัก | Active Skill | Passive Effect |
|---|---|---|---|---|
| อามาเทราสุ (legendary) | Legendary | ALL_DMG +45%, SPD +25 | **Divine Sunlight**: AOE ×4.0, blind all enemies 2 turns | ทุกรอบเช้า (05:00-12:00): ALL_DMG +30% bonus |
| ซูซาโนะ (legendary) | Legendary | ATK +40, LIGHTNING +100% | **Storm God**: LIGHTNING+WIND ×4.5, AOE chain | HP < 50%: unlock Berserk form: ATK ×1.5, DEF -30% |
| คิสึเนะจิ้งจอก (legendary) | Legendary | CRIT +20%, SPD +35 | **Fox Fire**: ICE+FIRE ×3.0 ×2 hit, confuse 40% | หลบ attack → invisible 1 turn (immune + next attack guaranteed CRIT) |
| ยามาโตะ-ทาเครุ (mythic) | Mythic | ATK +70, CRIT +25%, SPD +30 | **Kusanagi Slash**: ×8.0 single, split to 3 targets | ทุก 3rd attack: free extra attack ×1.5 (ไม่นับ CD) |

**Band 6 — Primordial**

| Node | Rarity | Stat หลัก | Active Skill | Passive Effect |
|---|---|---|---|---|
| กำเนิดไฟ (legendary) | Legendary | FIRE_DMG +150%, ATK +40 | **Primal Flame**: FIRE ×5.0, ทำลาย DEF enemy 3 turns | burn enemy → ทุก action ของ player heal 3% HP |
| ความมืดปฐมกาล (legendary) | Legendary | ALL_DMG +50%, HP +250 | **Void Embrace**: absorb damage แล้วปล่อยกลับ ×2.0 | immune darkness + blind. ในความมืด: ATK +40% |
| รากฐานโลก (legendary) | Legendary | DEF +70, HP +400 | **Bedrock Shield**: immune 3 turns + counter ×3.0 | ยิ่ง DEF สูง ยิ่งตี damage สูง (DEF ×0.5 เป็น bonus ATK) |
| ปฐมกาลทั้งปวง (mythic) | Mythic | ALL stat ×2 (ทุก stat เป็นสองเท่า) | **Big Crunch**: ×10.0 AOE, bypass everything | passive ทุก node ที่ unlock แล้ว → effect เพิ่ม 50% |

---

### Node Count Summary

| Band | Tier 1 | Tier 2 | Tier 3 | Tier 4 | Tier 5 | รวม |
|---|---|---|---|---|---|---|
| Universal | 10 | 8 | 6 | 5 | — | 29 |
| Band 1 (Thai) | 10 | 5 | 6 | 5 | 4 | 30 |
| Band 2 (Greek) | 8 | 5 | 4 | 4 | 4 | 25 |
| Band 3 (Norse) | 8 | 5 | 4 | 4 | 4 | 25 |
| Band 4 (Egyptian) | 8 | 5 | 4 | 4 | 4 | 25 |
| Band 5 (Japanese) | 8 | 5 | 4 | 4 | 4 | 25 |
| Band 6 (Primordial) | 6 | 4 | 4 | 4 | 4 | 22 |
| **รวมทั้งหมด** | **58** | **37** | **32** | **30** | **24** | **181** |

---

### SQL Seed Data (schema_skilltree_v2.sql — ตัวอย่าง Band 1)

```sql
-- ตัวอย่าง seed data format
INSERT INTO skill_nodes (id, name_th, tier, rarity, band, stat_bonus, active_skill_id, passive_effect) VALUES

-- Tier 1 Universal
('U-01', 'ร่างกายแข็งแกร่ง', 1, 'common', 0,
  '{"hp": 50}', NULL, NULL),

('U-04', 'ก้าวย่างเบา', 1, 'common', 0,
  '{"spd": 5}', NULL, NULL),

-- Tier 2 Universal — มี passive
('U-11', 'สัญชาตญาณนักล่า', 2, 'uncommon', 0,
  '{"atk": 6, "crit_rate": 0.02}', NULL,
  '{"type": "conditional", "condition": "hp_full", "effect": "atk_pct", "value": 0.05}'),

-- Tier 3 Band 1 — มี active skill
('B1-16', 'เพลิงวิมาน', 3, 'rare', 1,
  '{"fire_dmg": 0.20, "atk": 8}',
  'skill_flame_of_heaven',   -- FK ไปยัง skills table
  NULL),

-- Tier 4 Band 1 — ครบทั้งสาม
('B1-22', 'เจ้าแห่งเพลิง', 4, 'epic', 1,
  '{"fire_dmg": 0.35, "atk": 15}',
  'skill_great_fire',
  '{"type": "stack", "trigger": "burn_on_enemy", "effect": "atk_pct", "per_stack": 0.05}'),

-- Tier 5 Legendary
('B1-ascension-fire', 'อัคคีเทพบุตร', 5, 'legendary', 1,
  '{"fire_dmg": 1.0, "atk": 30, "all_dmg": 0.30}',
  'skill_agni_throne',
  '{"type": "multi", "effects": [
    {"condition": "hp_below_30pct", "effect": "fire_dmg_bonus", "value": 0.50},
    {"trigger": "burn_on_enemy", "effect": "hp_regen_per_stack", "value": 0.05},
    {"type": "immunity", "status": "burn"}
  ]}');
```

---

## 55. NPC Shop & Vendor System

### Overview

NPC แต่ละ role มี shop ของตัวเอง — ไม่ใช่ Merchant คนเดียวขายทุกอย่าง
ผู้เล่นสามารถ **ขายของ** ให้ NPC ได้ด้วย (ราคาตาม trading skill)

| NPC Role | Shop ที่ให้ | ขายของได้ไหม |
|---|---|---|
| Merchant | consumable, tool, seed, general | ✅ ซื้อ item ทุกประเภท |
| Blacksmith | repair kit, refine material, upgrade stone | ✅ ซื้อ equipment เท่านั้น |
| Nurse/Alchemist | potion tier สูง, status cure | ✅ ซื้อ material/herb |
| Storage Keeper | stash expansion | ❌ |
| Gate Keeper | travel permit | ❌ |
| Farmer (NPC) | seed, fertilizer | ✅ ซื้อ crop/produce |

---

### Sell to NPC — กฎการซื้อของ player

```
sell_price = item.base_value × trading_skill_multiplier × condition_multiplier

trading_skill_multiplier:
  level 1-24:  0.70
  level 25-49: 0.80
  level 50-74: 0.90
  level 75-99: 0.95
  level 100:   1.00  (Mastery = ราคาเต็ม)

condition_multiplier:
  item durability 100%:   ×1.0
  item durability 50-99%: ×0.8
  item durability 1-49%:  ×0.5
  item durability 0%:     ×0.2 (พัง)
  Unidentified item:      ×0.7 เสมอ (ไม่ขึ้นกับ trading skill)

ตัวอย่าง: ขาย rare sword (base 500g), trading 50, durability 80%
  = 500 × 0.90 × 0.8 = 360 gold
```

**NPC ปฏิเสธซื้อถ้า:**
- item category ไม่ตรง role ของ NPC นั้น
- item มี soulbound affix
- item เป็น Eternal-flagged (ต้องขายใน Eternal Marketplace เท่านั้น)

---

### Band 1 — แดนศรัทธาโบราณ (Thai Pantheon)

#### Merchant (ร้านค้าทั่วไป)

**Base Catalog — ซื้อได้เสมอ:**
| Item | ราคา | Qty | หมายเหตุ |
|---|---|---|---|
| HP Potion I | 80g | ∞ | HOT +30 HP/turn × 5 turns |
| Energy Potion I | 60g | ∞ | +4 battle energy ทันที |
| Escape Smoke | 150g | ∞ | +60% flee chance |
| Repair Kit (common) | 200g | ∞ | ซ่อม 25% × repair skill |
| Scroll of Revelation | 300g | ∞ | identify 1 item |
| Basic Fertilizer | 100g | ∞ | grow time -15% |
| Animal Feed (generic) | 50g | ∞ | pet happiness +10 |
| Torch | 30g | ∞ | แสงสว่าง 3 tiles |
| Rope | 40g | ∞ | Taming Item (×1.0 common) |

**Rotating Stock — restock ทุก 3 วันเกม (ตามฤดู):**
| ฤดู | Item | ราคา | Qty/restock |
|---|---|---|---|
| คิมหันต์ (ร้อน) | เมล็ดพริกไทยร้อน | 120g | 10 |
| คิมหันต์ | Cooling Potion | 180g | 5 |
| วัสสาน (ฝน) | เมล็ดบัวหลวง | 150g | 8 |
| วัสสาน | เหยื่อปลาฤดูฝน | 60g | 20 |
| เหมันต์ (หนาว) | เมล็ดเห็ดหิมะ | 200g | 6 |
| เหมันต์ | Warming Potion | 160g | 5 |
| ทุกฤดู | Lucky Charm (uncommon Taming) | 280g | 3 |

#### Blacksmith (ร้านช่างเหล็ก)

**Base Catalog:**
| Item | ราคา | Qty | หมายเหตุ |
|---|---|---|---|
| Repair Kit (uncommon) | 500g | ∞ | ซ่อม 50% × repair skill |
| Iron Ore | 80g | ∞ | crafting material |
| Rune Stone I | 150g | ∞ | upgrade material tier 1 |
| หินแห่งศรัทธา | 800g | ∞ | Guarantee Stone (uncommon) |
| Smithing Manual I | 200g | ∞ | smithing EXP +50 ทันที |

**Rotating Stock:**
| Item | ราคา | Qty | เงื่อนไข |
|---|---|---|---|
| Silver Ore | 150g | 5 | วันเกมคี่เท่านั้น |
| Tempered Rune I | 300g | 3 | ทุก 5 วันเกม |
| Blueprint: Iron Axe | 400g | 1 | rare — restock 7 วัน |

#### Nurse/Alchemist (ร้านยา)

**Base Catalog:**
| Item | ราคา | Qty | หมายเหตุ |
|---|---|---|---|
| HP Potion II | 200g | ∞ | HOT +60 HP/turn × 5 turns |
| Antidote | 120g | ∞ | cleanse poison/nausea |
| Stamina Herb | 80g | ∞ | Fatigue -20 |
| Pure Water Flask | 60g | ∞ | Thirst +40, ไม่มี debuff |
| Energy Tonic I | 180g | ∞ | +8 battle energy |

**Services (ไม่ใช่ item):**
| บริการ | ราคา | หมายเหตุ |
|---|---|---|
| รักษา HP เต็ม | 200g | ต้องมี alchemy skill ≥ 40 จึงทำเองได้ |
| ล้าง status (tier 1) | 100g | cleanse ทุก debuff tier 1 |
| ล้าง status (tier 2+) | 300g | cleanse debuff ทุกประเภท |

---

### Band 2 — วิหารแสงสุริยา (Greek Pantheon)

#### Merchant

| Item | ราคา | หมายเหตุ |
|---|---|---|
| HP Potion II | 200g | tier สูงขึ้น |
| Olive Oil (cooking) | 120g | Theros special ingredient |
| Laurel Wreath (uncommon Taming) | 400g | Greek pantheon animal |
| Lightning Flask | 250g | ขวดน้ำ LIGHTNING element |
| Scroll of Revelation | 300g | เหมือน Band 1 |

**Rotating (ตาม Greek seasons):**
| ฤดู | Item | ราคา |
|---|---|---|
| Earos (ใบไม้ผลิ) | Grape Seed | 180g |
| Theros (ร้อน) | Ambrosia Herb (epic) | 600g |
| Phthinoporon (ใบไม้ร่วง) | Mushroom Bundle | 140g |
| Cheimon (หนาว) | Nordic Fur (Band 3 preview) | 500g |

#### Blacksmith

| Item | ราคา | หมายเหตุ |
|---|---|---|
| Repair Kit (rare) | 1,200g | ซ่อม 75% × repair skill |
| Gold Ore | 200g | crafting tier 3 |
| Rune Stone II | 350g | upgrade material tier 2 |
| หินแห่งพลัง | 2,000g | Guarantee Stone (rare) |
| Mythril Shard | 800g | preview Band 3+ material |

---

### Band 3-6 — ตาม Pantheon (ตาราง condensed)

**หลักการ scaling ต่อ Band:**
```
item_price_band_N = item_price_band_1 × (1 + (N-1) × 0.6)
  Band 1: ×1.0 | Band 2: ×1.6 | Band 3: ×2.2 | Band 4: ×2.8 | Band 5: ×3.4 | Band 6: ×4.0

item_tier_band_N:
  Band 1: common/uncommon หลัก
  Band 2: uncommon/rare หลัก
  Band 3: rare หลัก
  Band 4: rare/epic หลัก
  Band 5: epic หลัก
  Band 6: epic/legendary หลัก
```

**Band 3-6 Merchant — exclusive items:**
| Band | Item พิเศษ | ราคา (approx) |
|---|---|---|
| 3 Norse | Wolf Bait (Taming), Yggdrasil Leaf (legendary herb) | 600-2,000g |
| 4 Egyptian | Nile Silt (super fertilizer), Anubis Charm | 800-3,000g |
| 5 Japanese | Sakura Extract (alch), Fox Whistle (Taming rare) | 1,000-4,000g |
| 6 Primordial | Primordial Seed, Void Crystal (crafting) | 3,000-8,000g |

---

### Sell Price Table (ตาม rarity)

| Rarity | Base Value | ตัวอย่าง |
|---|---|---|
| common | 20-100g | potion, basic material |
| uncommon | 100-400g | craft material, tool |
| rare | 400-1,500g | equipment, rare material |
| epic | 1,500-6,000g | epic equipment |
| legendary | 6,000-25,000g | legendary equipment |
| mythic | 25,000-100,000g | mythic equipment |

ราคาข้างต้นคือ **base value** — player ได้รับ 70-100% ตาม trading skill

---

### Shop UI

```
[ร้านค้าสมชาย — ผู้ค้า]  Band 1, Floor 5 Hub
──────────────────────────────────────────────────────
[ซื้อ] [ขาย] [Rotating ⏰ 2 วัน]    🪙 Gold: 3,400

Base Catalog:
  🧪 HP Potion I         80g   [ซื้อ]
  ⚡ Energy Potion I     60g   [ซื้อ]
  💨 Escape Smoke       150g   [ซื้อ]
  🔧 Repair Kit (C)     200g   [ซื้อ]
  📜 Scroll of Rev.     300g   [ซื้อ]

Rotating Stock (วัสสาน): [⏰ restock ใน 2 วัน]
  🌸 เมล็ดบัวหลวง      150g ×8  [ซื้อ]
  🐟 เหยื่อปลาฤดูฝน    60g ×20  [ซื้อ]
  🍀 Lucky Charm        280g ×3  [ซื้อ]

──── ขายของ ────
  [ลาก item มาวางที่นี่]
  ดาบเหล็ก (common, dur 80%) → 112g  [ขาย]
  ??อาวุธปริศนา (unidentified) → 84g  [ขาย]
```

**Batch sell:**
```gdscript
func sell_all_junk(player: Player, merchant: NPC) -> int:
    var total_gold = 0
    var junk = player.inventory.filter(func(item):
        return item.rarity == "common" and not item.is_equipped)
    for item in junk:
        total_gold += calc_sell_price(item, player.trading_skill)
    player.remove_items(junk)
    player.gold += total_gold
    return total_gold
```

---

### Restock Mechanic (Server-side)

```gdscript
# NPC Merchant restock ทุก N วันเกม
# เรียกโดย TimeManager เมื่อวันเกมเปลี่ยน

func check_restock(merchant_id: String, current_game_day: int) -> void:
    var catalog = DB.get_rotating_catalog(merchant_id)
    for entry in catalog:
        if current_game_day - entry.last_restock_day >= entry.restock_days:
            # reset stock qty
            DB.update_catalog_qty(entry.id, entry.max_qty)
            entry.last_restock_day = current_game_day
            # season filter
            if entry.season_filter and entry.season_filter != get_current_season():
                DB.set_catalog_visible(entry.id, false)
            else:
                DB.set_catalog_visible(entry.id, true)
```

**Player purchase limit (rotating stock):**
```sql
-- ป้องกัน player กักตุน rotating stock
CREATE TABLE player_merchant_purchases (
  player_id    UUID NOT NULL REFERENCES players(id),
  catalog_id   UUID NOT NULL REFERENCES merchant_catalog(id),
  qty_bought   INTEGER NOT NULL DEFAULT 0,
  restock_date DATE NOT NULL,  -- วันที่ restock ครั้งล่าสุด
  PRIMARY KEY (player_id, catalog_id, restock_date)
);

-- ถ้า qty_bought ≥ catalog.stock_qty → ซื้อไม่ได้จนกว่าจะ restock
```

---

### Schema ครบ (schema_npc_v1.sql เพิ่ม)

```sql
-- merchant_catalog ที่มีอยู่แล้ว — เพิ่ม column:
ALTER TABLE merchant_catalog ADD COLUMN IF NOT EXISTS
    npc_role         TEXT NOT NULL DEFAULT 'merchant',
      -- 'merchant'/'blacksmith'/'nurse'/'farmer'
    sell_category    TEXT[],   -- category ที่ NPC รับซื้อ
    visible          BOOLEAN NOT NULL DEFAULT TRUE,
    last_restock_day INTEGER NOT NULL DEFAULT 0;

-- item base_value สำหรับคำนวณ sell price
ALTER TABLE items ADD COLUMN IF NOT EXISTS
    base_value INTEGER NOT NULL DEFAULT 0;

-- NPC service (ไม่ใช่ item) เช่น รักษา HP
CREATE TABLE npc_services (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  npc_role        TEXT NOT NULL,
  band_number     INTEGER NOT NULL,
  service_name    TEXT NOT NULL,
  service_name_th TEXT NOT NULL,
  gold_cost       INTEGER NOT NULL,
  skill_required  TEXT,          -- null = ทุกคนใช้ได้
  skill_min_level INTEGER NOT NULL DEFAULT 0,
  effect_type     TEXT NOT NULL, -- 'heal_full'/'cleanse_tier1'/'cleanse_all'
  effect_value    INTEGER
);

-- seed data ตัวอย่าง
INSERT INTO npc_services VALUES
  (gen_random_uuid(), 'nurse', 1, 'Full Heal', 'รักษา HP เต็ม',
   200, NULL, 0, 'heal_full', NULL),
  (gen_random_uuid(), 'nurse', 1, 'Status Cleanse I', 'ล้าง status tier 1',
   100, NULL, 0, 'cleanse_tier1', 1),
  (gen_random_uuid(), 'nurse', 1, 'Status Cleanse II', 'ล้าง status ทุกประเภท',
   300, NULL, 0, 'cleanse_all', NULL);
```

---

## 56. Recipe List

### หลักการ Unlock Recipe

```
Tier 1 recipe: ปลดล็อกอัตโนมัติตั้งแต่เริ่ม
Tier 2 recipe: ปลดล็อกเมื่อ skill ≥ 25
Tier 3 recipe: ปลดล็อกเมื่อ skill ≥ 50
Tier 4 recipe: ปลดล็อกเมื่อ skill ≥ 75
Tier 5 (master): ปลดล็อกเมื่อ skill = 100 (Mastery)
Band-specific: ต้องอยู่ใน Band นั้นหรือเคยผ่านมา
```

---

### 🍳 Cooking Recipes (station: Campfire / Cooking Pot)

#### Tier 1 — Cooking 1+ (เริ่มต้น)

| Recipe ID | Output | วัตถุดิบ | Hunger | Buff | EXP |
|---|---|---|---|---|---|
| food_cooked_meat | เนื้อย่าง | Meat ×1 | +30 | — | 5 |
| food_roasted_root | มันเผา | Root Vegetable ×2 | +25 | — | 4 |
| food_herb_broth | น้ำสมุนไพร | Herb ×2, Water ×1 | +15, Thirst +20 | — | 6 |
| food_simple_bread | ขนมปัง | Grain ×3 | +35 | — | 8 |
| food_grilled_fish | ปลาย่าง | Fish (common) ×1 | +20 | — | 5 |

#### Tier 2 — Cooking 25+

| Recipe ID | Output | วัตถุดิบ | Hunger | Buff | EXP |
|---|---|---|---|---|---|
| food_herb_stew | สตูว์สมุนไพร | Meat ×1, Herb ×3, Water ×2 | +50 | HP Regen +2/turn (5 min) | 15 |
| food_fruit_salad | สลัดผลไม้ | Fruit ×3 | +30, Thirst +30 | SPD +5 (10 min) | 12 |
| food_fish_soup | ต้มปลา | Fish (uncommon) ×1, Herb ×2, Water ×2 | +45 | — | 18 |
| food_grain_porridge | โจ๊กข้าว | Grain ×2, Water ×3 | +40 | Fatigue -20 | 10 |
| food_roasted_bird | นกอบ | Bird Meat ×1, Herb ×1 | +40 | ATK +3 (10 min) | 16 |

#### Tier 3 — Cooking 50+

| Recipe ID | Output | วัตถุดิบ | Hunger | Buff | EXP |
|---|---|---|---|---|---|
| food_warrior_feast | อาหารนักรบ | Meat ×2, Root ×2, Herb ×2 | +70 | ATK +10%, SPD +5 (20 min) | 35 |
| food_magic_mushroom_dish | ผัดเห็ดมนตร์ | Magic Mushroom ×2, Herb ×2 | +40 | ALL_DMG +10% (15 min) | 40 |
| food_dragon_steak | สเต็กมังกรน้ำ | Dragon Meat ×1, Herb ×3, Spice ×1 | +80 | ATK +15%, FIRE_DMG +20% (30 min) | 60 |
| food_healing_soup | ซุปฟื้นฟู | Herb ×4, Bone ×2, Water ×3 | +50 | HP Regen +5/turn (10 min) | 45 |

#### Tier 4 — Cooking 75+ (Band-specific)

| Recipe ID | Output | Band | วัตถุดิบ | Buff | EXP |
|---|---|---|---|---|---|
| food_thai_lotus_curry | แกงบัวสวรรค์ | B1 | Lotus ×2, Coconut ×1, Spice ×3 | All stat +8% (30 min) | 80 |
| food_greek_ambrosia | อัมโบรเซีย | B2 | Ambrosia Herb ×2, Honey ×2, Water ×1 | HP max +20%, Regen +8 (60 min) | 120 |
| food_norse_mead | มี้ดไวกิ้ง | B3 | Berry ×4, Honey ×2, Water ×3 | ATK +20%, immune fear (30 min) | 100 |
| food_egyptian_offering | ของถวายเทพ | B4 | Sacred Grain ×3, Date ×2, Herb ×2 | Divinity EXP +50 (one-time) | 150 |
| food_japanese_bento | เบนโตะเทพ | B5 | Rice ×2, Fish (epic) ×1, Wasabi ×1 | CRIT +10%, SPD +10 (45 min) | 130 |

#### Tier 5 Master — Cooking 100

| Recipe ID | Output | วัตถุดิบ | Buff | EXP |
|---|---|---|---|---|
| food_divine_banquet | งานเลี้ยงแห่งเทพ | ส่วนผสม tier 4 ×2 ทุกชนิด | All stat +20%, Full HP/Energy restore, 60 min duration | 300 |

---

### ⚗️ Alchemy Recipes (station: Alchemy Table)

#### Tier 1 — Alchemy 1+

| Recipe ID | Output | วัตถุดิบ | Effect | EXP |
|---|---|---|---|---|
| potion_hp_1 | HP Potion I | Herb ×2, Water ×1 | HOT +30/turn × 5 | 8 |
| potion_energy_1 | Energy Potion I | Herb ×2, Crystal ×1 | +4 battle energy | 6 |
| item_antidote_1 | ยาแก้พิษ I | Herb ×3 | cleanse poison/nausea | 10 |
| item_stamina_herb | สมุนไพรแก้เหนื่อย | Herb ×2 | Fatigue -20 | 5 |
| potion_escape_smoke | ควันหมอก | Ash ×2, Herb ×1 | +60% flee chance | 12 |

#### Tier 2 — Alchemy 25+

| Recipe ID | Output | วัตถุดิบ | Effect | EXP |
|---|---|---|---|---|
| potion_hp_2 | HP Potion II | Herb ×3, Magic Flower ×1, Water ×1 | HOT +60/turn × 5 | 20 |
| potion_energy_2 | Energy Potion II | Herb ×2, Crystal ×2, Magic Flower ×1 | +8 battle energy | 18 |
| item_antidote_2 | ยาแก้พิษ II | Herb ×4, Crystal ×1 | cleanse ทุก debuff tier 1-2 | 25 |
| scroll_revelation | Scroll of Revelation | Herb ×3, Magic Flower ×1 | identify 1 item | 30 |
| item_basic_fertilizer | ปุ๋ยพื้นฐาน | Ash ×2, Bone ×1, Water ×1 | grow time -15% | 15 |

#### Tier 3 — Alchemy 50+

| Recipe ID | Output | วัตถุดิบ | Effect | EXP |
|---|---|---|---|---|
| potion_hp_3 | HP Potion III | Herb ×5, Rare Herb ×1, Magic Flower ×2 | HOT +100/turn × 5 | 50 |
| potion_crit | Crit Elixir | Crystal ×3, Rare Herb ×2 | CRIT +15% (30 min) | 55 |
| potion_speed | Speed Elixir | Magic Flower ×3, Feather ×2 | SPD +30 (20 min) | 60 |
| item_magic_fertilizer | ปุ๋ยมนตร์ | Rare Herb ×2, Crystal ×2, Magic Flower ×1 | grow time -30%, yield +50% | 70 |
| item_guarantee_stone_1 | หินแห่งศรัทธา | Herb ×10, Rune ×5 | Guarantee upgrade (uncommon) | 80 |

#### Tier 4 — Alchemy 75+

| Recipe ID | Output | วัตถุดิบ | Effect | EXP |
|---|---|---|---|---|
| potion_hp_4 | HP Potion IV | Rare Herb ×3, Dragon Blood ×1, Crystal ×3 | instant +50% HP + HOT +80/turn × 5 | 120 |
| potion_all_stat | All Stat Elixir | Rare Herb ×4, Magic Flower ×3, Gold Ore ×1 | All stat +15% (60 min) | 150 |
| potion_divine | Divine Water | Lotus ×2, Magic Flower ×4, Holy Water ×1 | Divinity EXP +30, HP/Energy full | 200 |
| item_repair_kit_epic | Repair Kit (epic) | Iron ×5, Crystal ×3, Magic Flower ×2 | ซ่อม 100% × repair skill | 180 |

#### Tier 5 Master — Alchemy 100

| Recipe ID | Output | วัตถุดิบ | Effect | EXP |
|---|---|---|---|---|
| potion_elixir_of_gods | อมฤตเทพ | Divine ingredient ×3 ทุกชนิด | Full restore + All stat +25% (120 min) + temporary Divinity +1 level (30 min) | 500 |

---

### ⚒️ Smithing Recipes (station: Forge)

#### Tier 1 — Smithing 1+ (Stone era)

| Recipe ID | Output | วัตถุดิบ | Skill Req | EXP |
|---|---|---|---|---|
| weapon_stone_sword | ดาบหิน | Stone ×4, Wood ×2 | smithing 1 | 10 |
| weapon_stone_axe | ขวานหิน | Stone ×3, Wood ×3 | smithing 1 | 10 |
| armor_leather_chest | เสื้อหนัง | Hide ×4, Rope ×2 | smithing 1 | 12 |
| tool_pickaxe_stone | จอบหิน | Stone ×3, Wood ×2 | smithing 1 | 8 |
| item_repair_kit_common | Repair Kit (common) | Wood ×3, Rope ×1 | smithing 1 | 6 |

#### Tier 2 — Smithing 25+ (Iron era)

| Recipe ID | Output | วัตถุดิบ | Rarity Output | EXP |
|---|---|---|---|---|
| weapon_iron_sword | ดาบเหล็ก | Iron Ore ×4, Wood ×2 | uncommon | 25 |
| weapon_iron_crossbow | หน้าไม้เหล็ก | Iron Ore ×3, Wood ×4, Rope ×2 | uncommon | 28 |
| weapon_iron_polearm | หอกเหล็ก | Iron Ore ×5, Wood ×3 | uncommon | 30 |
| armor_iron_chest | เสื้อเกราะเหล็ก | Iron Ore ×6, Leather ×2 | uncommon | 35 |
| armor_iron_helm | หมวกเหล็ก | Iron Ore ×4 | uncommon | 28 |
| tool_iron_axe | ขวานเหล็ก | Iron Ore ×3, Wood ×2 | — | 20 |
| tool_iron_pickaxe | จอบเหล็ก | Iron Ore ×3, Wood ×2 | — | 20 |
| item_repair_kit_uncommon | Repair Kit (uncommon) | Iron Ore ×2, Wood ×2 | — | 18 |

#### Tier 3 — Smithing 50+ (Silver/Gold era)

| Recipe ID | Output | วัตถุดิบ | Rarity Output | EXP |
|---|---|---|---|---|
| weapon_silver_wand | คฑาเงิน | Silver Ore ×4, Crystal ×2 | rare | 55 |
| weapon_gold_mace | กระบองทอง | Gold Ore ×4, Iron ×2 | rare | 60 |
| armor_gold_chest | เสื้อเกราะทอง | Gold Ore ×6, Leather ×3 | rare | 70 |
| weapon_silver_bow | ธนูเงิน | Silver Ore ×3, Wood ×4, Rope ×3 | rare | 58 |
| item_rune_stone_2 | Rune Stone II | Silver Ore ×3, Crystal ×2 | — | 45 |
| item_repair_kit_rare | Repair Kit (rare) | Silver Ore ×3, Crystal ×1 | — | 40 |

#### Tier 4 — Smithing 75+ (Mythril era)

| Recipe ID | Output | วัตถุดิบ | Rarity Output | EXP |
|---|---|---|---|---|
| weapon_mythril_sword | ดาบมิทริล | Mythril Ore ×5, Gold ×2, Crystal ×3 | epic | 120 |
| weapon_mythril_staff | คฑามิทริล | Mythril Ore ×4, Rare Herb ×2, Crystal ×4 | epic | 130 |
| armor_mythril_set | ชุดเกราะมิทริล | Mythril Ore ×8, Gold ×3 | epic | 150 |
| weapon_mythril_rod | คันเบ็ดมิทริล | Mythril Ore ×2, Magic Thread ×2 | — | 90 |
| item_repair_kit_epic | Repair Kit (epic) | Mythril Ore ×3, Crystal ×3, Magic Flower ×2 | — | 100 |

#### Tier 5 Master — Smithing 100

| Recipe ID | Output | วัตถุดิบ | Rarity Output | EXP |
|---|---|---|---|---|
| weapon_divine_blade | ดาบเทวา | Mythril ×8, Dragon Scale ×2, Phoenix Feather ×1 | legendary | 400 |
| armor_divine_set | ชุดเกราะเทวา | Mythril ×10, Dragon Scale ×3 | legendary | 500 |
| item_divine_repair_kit | Repair Kit (legendary) | Mythril ×5, Phoenix Feather ×1, Crystal ×5 | — | 350 |

---

### 🪵 Carpentry Recipes (station: Workbench / Sawmill)

#### Tier 1 — Carpentry 1+

| Recipe ID | Output | วัตถุดิบ | EXP |
|---|---|---|---|
| material_plank | ไม้แปรรูป ×4 | Wood ×2 | 4 |
| material_rope | เชือก | Fiber ×3 | 3 |
| building_campfire | แคมป์ไฟ | Wood ×3, Stone ×2 | 10 |
| furniture_chest_wood | หีบไม้ | Plank ×4, Rope ×2 | 12 |
| furniture_bed_simple | เตียงนอนง่าย | Plank ×6, Rope ×3 | 15 |
| tool_wood_axe | ขวานไม้ | Wood ×3, Stone ×2 | 8 |

#### Tier 2 — Carpentry 25+

| Recipe ID | Output | วัตถุดิบ | EXP |
|---|---|---|---|
| building_workbench | โต๊ะทำงาน | Plank ×8, Iron ×2 | 25 |
| building_sawmill | โรงเลื่อย | Plank ×12, Iron ×4 | 35 |
| furniture_chest_iron | หีบเหล็ก | Plank ×4, Iron ×4 | 20 |
| building_garden_bed | แปลงปลูกผัก | Plank ×4, Soil ×2 | 18 |
| building_water_trough | รางน้ำ | Plank ×2, Stone ×1 | 12 |
| trap_spike | กับดักหนาม | Wood ×4, Iron ×2 | 22 |

#### Tier 3 — Carpentry 50+

| Recipe ID | Output | วัตถุดิบ | EXP |
|---|---|---|---|
| building_greenhouse | เรือนกระจก | Plank ×8, Glass ×4 | 60 |
| building_barn | โรงนา | Plank ×20, Stone ×10 | 80 |
| building_stable | คอกม้า | Plank ×15, Stone ×5 | 65 |
| building_watchtower | หอสังเกตการณ์ | Plank ×12, Stone ×6, Iron ×4 | 75 |
| trap_snare | กับดักแบบบ่วง | Rope ×4, Wood ×2, Iron ×1 | 45 |

#### Tier 4 — Carpentry 75+

| Recipe ID | Output | วัตถุดิบ | EXP |
|---|---|---|---|
| building_forge | เตาหลอม | Stone ×20, Iron ×10, Plank ×8 | 120 |
| building_alchemy_table | โต๊ะเล่นแร่แปรธาตุ | Plank ×10, Crystal ×4, Iron ×4 | 130 |
| building_grain_mill | โรงสี | Plank ×6, Stone ×4, Iron ×2 | 100 |
| furniture_notice_board | กระดานประกาศ | Plank ×6, Iron ×2 | 50 |

---

### 🪨 Masonry Recipes (station: Stonecutter)

#### Tier 1 — Masonry 1+

| Recipe ID | Output | วัตถุดิบ | EXP |
|---|---|---|---|
| material_stone_brick ×4 | อิฐหิน | Stone ×2 | 4 |
| material_gravel ×4 | กรวด | Stone ×1 | 2 |
| building_stone_wall | กำแพงหิน | Stone Brick ×4 | 10 |
| building_stone_floor | พื้นหิน | Stone Brick ×2 | 6 |

#### Tier 2 — Masonry 25+

| Recipe ID | Output | วัตถุดิบ | EXP |
|---|---|---|---|
| material_iron_block | แท่งเหล็ก | Iron Ore ×3 | 20 |
| building_iron_wall | กำแพงเหล็ก | Iron Block ×4 | 30 |
| building_stone_gate | ประตูหิน | Stone Brick ×8, Iron ×2 | 35 |
| material_glass ×2 | กระจก | Sand ×4, Coal ×1 | 15 |

#### Tier 3 — Masonry 50+

| Recipe ID | Output | วัตถุดิบ | EXP |
|---|---|---|---|
| material_mythril_block | แท่งมิทริล | Mythril Ore ×3 | 60 |
| building_mythril_wall | กำแพงมิทริล | Mythril Block ×4 | 80 |
| building_stone_tower | หอหิน | Stone Brick ×20, Iron Block ×5 | 100 |

---

### 🌾 Farming Recipes (ใช้ใน Garden Bed — ไม่ต้องมี station)

| Recipe ID | Output | วัตถุดิบ (seed) | Grow Time | Yield | Season |
|---|---|---|---|---|---|
| crop_herb | Herb ×3-6 | Herb Seed ×1 | 2 ชม. | ×farming_skill | ทุกฤดู |
| crop_grain | Grain ×5-10 | Grain Seed ×1 | 8 ชม. | ×farming_skill | ทุกฤดู |
| crop_fruit | Fruit ×3-8 | Fruit Seed ×1 | 12 ชม. | ×farming_skill | ทุกฤดู |
| crop_magic_flower | Magic Flower ×1-3 | Magic Seed ×1 | 24 ชม. | ×farming_skill | ≥ farming 25 |
| crop_lotus_b1 | Lotus ×1-2 | Lotus Seed ×1 | 16 ชม. | ×farming_skill | วัสสาน (Band 1) |
| crop_sacred_grain_b4 | Sacred Grain ×3-6 | Sacred Seed ×1 | 20 ชม. | ×farming_skill | Akhet (Band 4) |

---

### SQL Seed Data (schema_crafting_v1.sql)

```sql
INSERT INTO crafting_recipes
  (id, name, station_type, output_item_id, output_qty,
   craft_time_seconds, proficiency_skill, proficiency_exp, proficiency_required)
VALUES
-- Hand Craft
('recipe_rope',        'เชือก',       NULL,          [fiber_item_id], 1,  2,  'carpentry', 3,  1),
-- Campfire recipes
('recipe_cooked_meat', 'เนื้อย่าง',   'campfire',    [meat_item_id],  1,  10, 'cooking',   5,  1),
('recipe_herb_stew',   'สตูว์สมุนไพร','campfire',    [stew_item_id],  1,  30, 'cooking',   15, 25),
-- Forge
('recipe_iron_sword',  'ดาบเหล็ก',   'forge',       [sword_item_id], 1,  60, 'smithing',  25, 25),
('recipe_mythril_sword','ดาบมิทริล',  'forge',       [msword_item_id],1, 120, 'smithing', 120, 75),
-- Alchemy
('recipe_hp_pot_1',    'HP Potion I', 'alchemy_table',[hp1_item_id],  1,  20, 'alchemy',   8,  1),
('recipe_divine_water','Divine Water','alchemy_table',[divine_item_id],1, 300, 'alchemy', 200, 75),
-- Workbench
('recipe_workbench',   'โต๊ะทำงาน',  'workbench',   [wb_item_id],   1, 120, 'carpentry', 25, 25),
('recipe_spike_trap',  'กับดักหนาม', 'workbench',   [trap_item_id], 1,  45, 'carpentry', 22, 25);

-- recipe inputs
INSERT INTO crafting_recipe_inputs (recipe_id, item_id, qty) VALUES
('recipe_iron_sword', [iron_ore_id], 4),
('recipe_iron_sword', [wood_id], 2),
('recipe_herb_stew',  [meat_id], 1),
('recipe_herb_stew',  [herb_id], 3),
('recipe_herb_stew',  [water_id], 2);
```

---

### 🧵 Tailoring Recipes (station: Loom / Workbench)

#### Tier 1 — Tailoring 1+

| Recipe ID | Output | วัตถุดิบ | EXP |
|---|---|---|---|
| cloth_leather_boots | รองเท้าหนัง | Hide ×2, Rope ×1 | 8 |
| cloth_leather_gloves | ถุงมือหนัง | Hide ×2 | 6 |
| cloth_simple_bag | กระเป๋าเดินทาง (+5 slots) | Fiber ×4, Rope ×2 | 10 |
| cloth_hood | ผ้าคลุมศีรษะ | Fiber ×3 | 7 |
| cloth_woven_cloth ×3 | ผ้าทอ | Fiber ×4 | 4 |

#### Tier 2 — Tailoring 25+

| Recipe ID | Output | วัตถุดิบ | Rarity Output | EXP |
|---|---|---|---|---|
| cloth_leather_chest | เสื้อหนังตัดเย็บ | Hide ×4, Woven Cloth ×2 | uncommon | 20 |
| cloth_leather_legs | กางเกงหนัง | Hide ×3, Woven Cloth ×2 | uncommon | 18 |
| cloth_mage_robe | เสื้อคลุมเวทย์ | Woven Cloth ×6, Rope ×2 | uncommon | 22 |
| cloth_medium_bag | กระเป๋าขนาดกลาง (+10 slots) | Leather ×3, Rope ×3 | — | 25 |
| cloth_taming_rope | Taming Rope (uncommon) | Rope ×4, Magic Fiber ×1 | — | 30 |

#### Tier 3 — Tailoring 50+

| Recipe ID | Output | วัตถุดิบ | Rarity Output | EXP |
|---|---|---|---|---|
| cloth_silk_robe | เสื้อคลุมผ้าไหม | Silk ×4, Crystal Thread ×2 | rare | 55 |
| cloth_enchanted_vest | เสื้อกั๊กมนตร์ | Woven Cloth ×4, Magic Flower ×2, Crystal ×1 | rare | 60 |
| cloth_ranger_set | ชุดนักล่า | Leather ×6, Feather ×3, Rope ×4 | rare | 70 |
| cloth_large_bag | กระเป๋าขนาดใหญ่ (+15 slots) | Leather ×5, Magic Thread ×2 | — | 65 |
| cloth_magic_thread ×2 | ด้ายมนตร์ | Silk ×1, Crystal ×1 | — | 30 |

#### Tier 4 — Tailoring 75+

| Recipe ID | Output | วัตถุดิบ | Rarity Output | EXP |
|---|---|---|---|---|
| cloth_mythril_robe | เสื้อคลุมมิทริล | Mythril Thread ×4, Silk ×3, Crystal ×2 | epic | 120 |
| cloth_shadow_cloak | เสื้อคลุมเงา | Shadow Silk ×3, Dark Crystal ×2 | epic | 130 |
| cloth_divine_sash | สายคาดเทพ (accessory) | Golden Fiber ×3, Magic Flower ×3 | epic | 110 |
| cloth_infinite_bag | กระเป๋าไร้ก้น (+25 slots) | Mythril Thread ×2, Magic Flower ×4 | — | 150 |

#### Tier 5 Master — Tailoring 100

| Recipe ID | Output | วัตถุดิบ | Rarity Output | EXP |
|---|---|---|---|---|
| cloth_celestial_robe | เสื้อคลุมสวรรค์ | Mythril Thread ×6, Phoenix Feather ×1, All element crystal ×1 | legendary | 400 |

---

### Recipe Count Summary (อัปเดต)

| Skill | Tier 1 | Tier 2 | Tier 3 | Tier 4 | Tier 5 | รวม |
|---|---|---|---|---|---|---|
| Cooking | 5 | 5 | 4 | 5 | 1 | 20 |
| Alchemy | 5 | 5 | 5 | 4 | 1 | 20 |
| Smithing | 5 | 8 | 6 | 5 | 3 | 27 |
| Carpentry | 6 | 6 | 5 | 4 | — | 21 |
| Masonry | 4 | 4 | 3 | — | — | 11 |
| Farming | 6 | — | — | — | — | 6 |
| **Tailoring** | **5** | **5** | **5** | **4** | **1** | **20** |
| **รวมทั้งหมด** | **36** | **33** | **28** | **22** | **6** | **125** |



---

## 57. Auto-Hunt System

### Design Philosophy
Auto-hunt คือ **AFK progress** แบบมีขอบเขต — ผู้เล่นสั่งให้ตัวละครล่าสัตว์อัตโนมัติใน field map โดยไม่ต้องควบคุม
Inspired by Ragnarok Online แต่ปรับให้เข้ากับ energy system และ survival mechanics ของเกม

**หลักการ:**
- Auto-hunt ให้ผลน้อยกว่า manual play เสมอ (~60-70% efficiency)
- มี session limit และ safety recall ป้องกัน abuse
- ผู้เล่นยังต้องกลับมาจัดการ inventory, repair, energy เป็นระยะ
- ไม่มีใน Eternal Path (hardcore ต้องเล่นด้วยตัวเอง)

---

### เงื่อนไขเริ่ม Auto-Hunt

```
ผู้เล่นต้องมีครบก่อนกด [Auto-Hunt]:
  1. ⚡ World Energy ≥ 20 (เพียงพอต่อ session สั้น)
  2. 🔋 Battle Energy เต็ม 100%
  3. HP ≥ 50% ของ max HP
  4. Hunger ≥ 30 (ไม่หิวมาก)
  5. Thirst ≥ 30
  6. Inventory ว่าง ≥ 10 slots
  7. ไม่ได้อยู่ใน Eternal Path
  8. อยู่ใน field map ที่มี enemy (ไม่ใช่ Hub หรือ Checkpoint)
```

---

### Auto-Hunt Session

เมื่อเริ่ม auto-hunt → ผู้เล่นตั้งค่า **session parameters** ก่อน:

```
[Auto-Hunt Setup]
┌──────────────────────────────────────┐
│  Target Camp: Floor 3 Elite Camp     │
│                                      │
│  Session Duration:                                │
│  [━━━━━━━━━━━━━━━━━━━━━━━●━━━━━━━━] 3 ชั่วโมง   │
│   15 นาที ◄──────────────────────────► 12 ชั่วโมง │
│                                                   │
│  ⚡ World Energy ที่จะใช้: ~48                     │
│  ⏳ Cooldown หลัง session: ~1.5 ชั่วโมง           │
│                                      │
│  Safety Recall ถ้า:                  │
│   ☑ HP < 20%                         │
│   ☑ Battle Energy = 0                │
│   ☑ Inventory เต็ม                   │
│   ☑ Hunger < 10                      │
│                                      │
│  Auto-use Item:                      │
│   ☑ HP Potion ถ้า HP < 40%           │
│   ☐ Energy Potion ถ้า Energy < 20%   │
│                                      │
│  [เริ่ม Auto-Hunt]  [ยกเลิก]        │
└──────────────────────────────────────┘
```

---

### Session Limit

**Duration:** ผู้เล่นเลือกอิสระ **15 นาที ถึง 12 ชั่วโมง** ด้วย slider (step 15 นาที)

**World Energy Cost (คำนวณจาก duration):**
```
hours = duration_minutes / 60

world_energy_cost = CEIL(hours × 20)
  # 15 นาที  = 0.25h × 20 = CEIL(5)  = 5
  # 30 นาที  = 0.5h  × 20 = CEIL(10) = 10
  # 1 ชั่วโมง = 1.0h  × 20 = 20
  # 2 ชั่วโมง = 2.0h  × 20 = 40
  # 4 ชั่วโมง = 4.0h  × 20 = 80
  # 8 ชั่วโมง = 8.0h  × 20 = 160
  # 12 ชั่วโมง= 12.0h × 20 = 240

# ถ้า World Energy ไม่พอ → duration ถูก cap อัตโนมัติ:
max_affordable_hours = current_world_energy / 20
```

**Cooldown หลัง session (proportional):**
```
cooldown_minutes = CEIL(duration_minutes × 0.25)
  # 15 นาที   → cooldown 4 นาที
  # 1 ชั่วโมง → cooldown 15 นาที
  # 4 ชั่วโมง → cooldown 60 นาที
  # 12 ชั่วโมง→ cooldown 180 นาที (3 ชั่วโมง)
```

**Daily cap:** World Energy เป็นตัว limit ธรรมชาติ — ไม่มี session count limit
```
max_world_energy = 100
max_hours_per_day_if_full = 100 / 20 = 5 ชั่วโมง

# ถ้าต้องการ 12 ชั่วโมง ต้องสะสม World Energy 240
# → ต้องรอ regen (1 energy/5 นาที) = 1,200 นาที = 20 ชั่วโมง
# → ไม่สามารถ auto-hunt 12 ชั่วโมงทุกวันได้โดยไม่มีการสะสม
```

**GDScript:**
```gdscript
func calc_session_cost(duration_min: int) -> Dictionary:
    var hours = duration_min / 60.0
    var energy_cost = ceil(hours * 20.0)
    var cooldown_min = ceil(duration_min * 0.25)
    return {
        "energy_cost": energy_cost,
        "cooldown_minutes": cooldown_min,
        "affordable": player.world_energy >= energy_cost
    }

# UI: อัปเดต preview แบบ real-time เมื่อ slider เปลี่ยน
func _on_duration_slider_changed(value: float) -> void:
    var duration_min = int(value) * 15  # step 15 นาที
    var cost = calc_session_cost(duration_min)
    $EnergyLabel.text = "⚡ %d" % cost.energy_cost
    $CooldownLabel.text = "⏳ %d นาที" % cost.cooldown_minutes
    $StartButton.disabled = not cost.affordable
    if not cost.affordable:
        $WarningLabel.text = "Energy ไม่พอ — max %.1f ชั่วโมง" % (player.world_energy / 20.0)
```

---

### Auto-Hunt AI Loop

```gdscript
# AutoHuntManager.gd
enum AutoHuntState { IDLE, SEARCHING, MOVING, IN_COMBAT, LOOTING, RECALLING }

var session_start_time: float
var session_duration_sec: float
var items_collected: Array = []
var combat_count: int = 0

func _process(delta: float) -> void:
    if not is_auto_hunting: return

    # ตรวจ session หมดเวลา
    if Time.get_unix_time_from_system() - session_start_time >= session_duration_sec:
        _end_session("time_up")
        return

    # ตรวจ safety recall conditions
    if _should_recall():
        _end_session("safety_recall")
        return

    match state:
        AutoHuntState.SEARCHING: _do_search()
        AutoHuntState.MOVING:    _do_move()
        AutoHuntState.IN_COMBAT: _do_combat()
        AutoHuntState.LOOTING:   _do_loot()

func _do_search() -> void:
    # หา enemy ที่ใกล้ที่สุดที่ยังมีชีวิต
    var targets = get_enemies_in_camp().filter(func(e):
        return not e.is_dead and not e.is_fleeing)
    if targets.is_empty():
        # camp clear ชั่วคราว → รอ respawn
        await get_tree().create_timer(10.0).timeout
        return
    var nearest = targets.min_by(func(e): return position.distance_to(e.position))
    move_target = nearest
    state = AutoHuntState.MOVING

func _do_combat() -> void:
    # ใช้ basic attack เสมอ ไม่ใช้ skill (efficiency ต่ำกว่า manual)
    # ยกเว้น: ถ้า HP < 40% และมี HP Potion → ใช้ potion (ถ้า setting เปิด)
    ATBCombat.auto_action(player, combat_target, use_skills: false)
    if player.hp_pct < 0.4 and settings.auto_use_hp_potion:
        _use_best_hp_potion()

func _should_recall() -> bool:
    return (
        player.hp_pct < 0.20 or
        player.battle_energy == 0 or
        player.inventory_free_slots < 3 or
        player.hunger < 10 or
        player.thirst < 10
    )
```

---

### Reward Formula (AFK Efficiency)

Auto-hunt ได้ผลน้อยกว่า manual เสมอ:

```
# Item drop rate
auto_hunt_drop_rate = manual_drop_rate × 0.65

# EXP (proficiency — combat skills)
auto_hunt_exp_rate = manual_exp_rate × 0.70

# Gold: ได้จาก auto-pickup (ดูหัวข้อถัดไป) — เหมือน manual
# ถุงเงินจาก player อื่น (multiplayer): auto-pickup เช่นกัน ถ้าเดินผ่าน

# Divinity EXP:
#   camp clear ครั้งแรก (first clear): ได้ตามปกติ (+2)
#   boss first kill: ไม่ได้ (boss node ข้าม)
#   kill ทั่วไป: ไม่ได้

# Bestiary: ได้เมื่อ kill enemy ใหม่ครั้งแรก (first kill entry)
# Capture: ไม่ได้ — ต้องเล่น manual เท่านั้น

# Boss/Mini-boss: auto-hunt ข้ามไป — ไม่โจมตี boss node
```

**เหตุผลที่ลด efficiency:**
- AI ใช้ basic attack อย่างเดียว ไม่ใช้ skill
- ไม่เลือก target ฉลาด (แค่ nearest)
- Capture ทำไม่ได้ (ต้องใช้ dice minigame แบบ manual)

---

### Auto-Pickup System (Manual & Auto-Hunt)

**Manual play:** ตัวละครเดินผ่าน item หรือถุงเงินบนพื้น → **เก็บอัตโนมัติทันที**
**Auto-hunt:** เดินไปหา enemy → ถ้าเจอ item/ถุงเงินระหว่างทาง → เก็บอัตโนมัติ

#### Item / Gold บนพื้น (World Object)

```
Item world object อยู่บนพื้น:
  - มองเห็นเป็น sprite ใน field map (สีตาม rarity)
  - หายไปใน 5 นาที real time (ถ้าไม่มีใครเก็บ)
  - pickup radius: 0.5 tile (แตะ tile เดียวกันหรือติดกัน)
```

```gdscript
# FieldMap.gd
func _on_player_moved(new_position: Vector2i) -> void:
    # ตรวจ item/gold ในรัศมี pickup
    var nearby = world_objects.filter(func(obj):
        return obj.position.distance_to(new_position) <= 0.5
              and obj.type in ["item_drop", "money_bag"])
    for obj in nearby:
        _auto_pickup(obj)

func _auto_pickup(obj: WorldObject) -> void:
    match obj.type:
        "item_drop":
            if player.inventory_free_slots > 0:
                player.add_item(obj.item_id)
                obj.queue_free()
                ToastManager.show("เก็บ %s" % obj.item_name, "loot")
            else:
                ToastManager.show("Inventory เต็ม — ไม่สามารถเก็บได้", "warning")
        "money_bag":
            player.gold += obj.gold_amount
            obj.queue_free()
            ToastManager.show("+%d gold" % obj.gold_amount, "gold")

# Auto-hunt: เรียก _auto_pickup ทุกครั้งที่ player step
# ผลลัพธ์: ถุงเงินและ item drop ที่เดินผ่านระหว่างล่าจะถูกเก็บอัตโนมัติ
```

#### Multiplayer — Item ที่ player อื่น drop

ถุงเงินที่ drop จากผู้เล่นคนอื่น (flee fail, ตาย):
- เป็น world object ที่ **ใครเก็บก่อนได้ก่อน**
- auto-pickup ทำงานเหมือนกัน — เดินผ่านก็เก็บได้ทันที
- Auto-hunt ก็เก็บได้เช่นกัน ถ้าเส้นทางล่าผ่านตำแหน่งนั้น

#### Inventory เต็ม

```gdscript
func _auto_pickup(obj: WorldObject) -> void:
    if obj.type == "item_drop" and player.inventory_free_slots == 0:
        # ไม่เก็บ item แต่ยัง "เก็บ" gold เสมอ (gold ไม่ใช้ slot)
        ToastManager.show("⚠ Inventory เต็ม — ข้าม %s" % obj.item_name, "warning")
        if auto_hunt_active:
            _trigger_recall_if_needed()  # Safety recall ถ้าของเต็ม
        return
    # gold เก็บได้เสมอ
    if obj.type == "money_bag":
        player.gold += obj.gold_amount
        obj.queue_free()
```

#### HUD Indicator

```
Manual play: toast popup ขวาล่าง
  [🟣 เก็บ Uncommon Sword]
  [🪙 +85 gold]

Auto-hunt: เพิ่มลง Field Log แทน (ไม่ spam toast)
  10:14  เก็บ Hide ×3, Iron Ore ×1, +40 gold
```

---

### Safety Recall Conditions (ครบชุด)

| เงื่อนไข | เกณฑ์ | ผลที่เกิด |
|---|---|---|
| HP ต่ำ | HP < 20% | recall ทันที, หยุดต่อสู้กลาง combat |
| Battle Energy หมด | Energy = 0 | recall (ต่อสู้ต่อไม่ได้ดี) |
| Inventory เต็ม | free slots < 3 | recall (ของ drop ทิ้ง) |
| Hunger วิกฤต | Hunger < 10 | recall |
| Thirst วิกฤต | Thirst < 10 | recall |
| Session หมดเวลา | elapsed ≥ duration | จบ session ปกติ |
| ผู้เล่น reconnect | player กด manual input | หยุด auto-hunt ทันที |
| เกมปิด / disconnect | — | auto-hunt หยุด, ไม่มีผล offline |

**Recall animation:** ตัวละครเดินกลับ spawn point อัตโนมัติ → สรุป session

---

### Session Summary UI

เมื่อ session จบ (ทุกเงื่อนไข):

```
[สรุป Auto-Hunt]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⏱ เวลาที่ล่า: 47 นาที 23 วินาที
⚔️  ศัตรูที่สังหาร: 34 ตัว
🎯 เหตุที่หยุด: Inventory เกือบเต็ม

📦 Item ที่ได้รับ:
  🟤 Hide ×12         🟤 Bone ×8
  🟢 Herb ×6          🔵 Iron Ore ×3
  🟣 Uncommon Sword   [คลิกเพื่อดู]

⚡ World Energy ที่ใช้: -25
🔋 Battle Energy เหลือ: 3/10
❤️  HP เหลือ: 45/80

[รับของและกลับเล่น]  [Auto-Hunt อีกครั้ง]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

### Offline Auto-Hunt

**ไม่มี** — auto-hunt ทำงานได้เฉพาะขณะ client online
เหตุผล:
1. World Energy ต้องใช้จริง (server ตรวจ)
2. Combat ต้อง resolve บน server
3. ป้องกัน exploit offline progress

---

### Field Log

ทุก session บันทึกลง **Field Log** (UI ที่เห็นได้ใน Adventure Log):

```
[Field Log]  Floor 3 Elite Camp  —  วันที่ 14 คิมหันต์

09:32  เริ่ม Auto-Hunt (60 นาที)
09:45  สังหาร งูน้ำ ×8 — ได้ Hide ×4, Bone ×2
10:01  สังหาร โกเลมหิน ×3 — ได้ Stone Ore ×6
10:15  ⚠️ HP < 30% — ใช้ HP Potion I
10:31  ได้ Uncommon Sword (ยังไม่ identify)
10:32  ⚠️ Inventory เกือบเต็ม (5 slots ว่าง)
10:35  หยุด Auto-Hunt — Inventory limit
       รวม: 37 ตัว, 48 item, 47 นาที
```

---

### GDScript Key Files

```
scripts/systems/AutoHuntManager.gd  ← state machine, reward formula, recall logic
scripts/ui/AutoHuntPanel.gd         ← setup UI, session summary
scripts/ui/FieldLog.gd              ← log display
```

---

### Schema (schema_world_v1.sql เพิ่ม)

```sql
CREATE TABLE auto_hunt_sessions (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  player_id         UUID NOT NULL REFERENCES players(id) ON DELETE CASCADE,
  camp_id           UUID NOT NULL REFERENCES tower_camps(id),
  duration_target   INTEGER NOT NULL,  -- วินาที
  duration_actual   INTEGER NOT NULL DEFAULT 0,
  started_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  ended_at          TIMESTAMPTZ,
  end_reason        TEXT,
    -- 'time_up'/'safety_hp'/'safety_energy'/'safety_inventory'
    -- 'safety_hunger'/'safety_thirst'/'manual_stop'/'disconnect'
  kills_count       INTEGER NOT NULL DEFAULT 0,
  items_collected   JSONB NOT NULL DEFAULT '[]',  -- [{item_id, qty}]
  world_energy_used INTEGER NOT NULL DEFAULT 0,
  sessions_today    INTEGER NOT NULL DEFAULT 0    -- 1-3
);

CREATE INDEX idx_auto_hunt_player ON auto_hunt_sessions
    (player_id, started_at DESC);

-- นับ session วันนี้ (reset 00:00)
CREATE OR REPLACE FUNCTION get_auto_hunt_count_today(p_player_id UUID)
RETURNS INTEGER AS $$
  SELECT COUNT(*)::INTEGER
  FROM auto_hunt_sessions
  WHERE player_id = p_player_id
    AND started_at >= CURRENT_DATE::TIMESTAMPTZ
    AND end_reason IS NOT NULL;  -- จบแล้วเท่านั้น
$$ LANGUAGE SQL;
```

---

## 58. Food Quality & Spoilage System

### Food States

อาหารทุกชิ้นมี **state** ที่เปลี่ยนได้ตามเวลา:

```
[Raw]  →  [Cooked/Processed]  →  [Stale]  →  [Spoiled]
                                              (กินได้แต่เสี่ยง)   (กินไม่ได้)
```

| State | สี item icon | กินได้ | ผล |
|---|---|---|---|
| Fresh (Raw) | ปกติ | ✅ (แบบดิบ) | Hunger ต่ำ, risk nausea |
| Cooked / Processed | ✅ สีทอง | ✅ | Hunger + buff เต็ม |
| Stale | 🟡 สีเหลือง | ✅ | Hunger 50%, buff ลด 50%, ไม่มี risk |
| Spoiled | 🔴 สีแดง/เทา | ⚠️ | Hunger 10%, nausea 60% chance, DEF -10% 5 นาที |
| Rotten | ⬛ สีดำ | ❌ | กินไม่ได้ — ต้องทิ้งหรือ Compost |

---

### Spoilage Timer

เวลาหมดอายุ (real time) ของ food แต่ละประเภท:

| ประเภท | Fresh → Stale | Stale → Spoiled | Spoiled → Rotten |
|---|---|---|---|
| Raw Meat | 30 นาที | 1 ชั่วโมง | 2 ชั่วโมง |
| Raw Fish | 20 นาที | 45 นาที | 1.5 ชั่วโมง |
| Raw Vegetable/Herb | 2 ชั่วโมง | 4 ชั่วโมง | 8 ชั่วโมง |
| Fruit | 1 ชั่วโมง | 3 ชั่วโมง | 6 ชั่วโมง |
| Grain/Seed | ไม่เน่า | ไม่เน่า | ไม่เน่า |
| Cooked Meat/Fish | 2 ชั่วโมง | 4 ชั่วโมง | 8 ชั่วโมง |
| Cooked Vegetables | 4 ชั่วโมง | 8 ชั่วโมง | 24 ชั่วโมง |
| Stew/Soup/Curry | 3 ชั่วโมง | 6 ชั่วโมง | 12 ชั่วโมง |
| Bread/Pastry | 8 ชั่วโมง | 16 ชั่วโมง | 48 ชั่วโมง |
| Potion/Alch item | ไม่เน่า | ไม่เน่า | ไม่เน่า |
| Honey/Salt preserve | ไม่เน่า | ไม่เน่า | ไม่เน่า |

**Offline spoilage:** ดำเนินต่อในขณะ offline
```gdscript
# เมื่อ login คืน:
elapsed = now - player.last_logout_time
for item in player.inventory.filter(func(i): return i.is_food):
    item.spoilage_timer -= elapsed
    item.food_state = calc_food_state(item)
```

---

### Storage Slows Spoilage

**Chest/Storage** ภายในแคมป์ช่วยชะลอการเน่า:

| Storage Type | Spoilage Rate Multiplier |
|---|---|
| ถือใน inventory | ×1.0 (ปกติ) |
| วางใน Wood Chest | ×0.5 (ช้าลง 2×) |
| วางใน Ice Box (craftable) | ×0.1 (ช้าลง 10×) |
| วางใน Magic Preservation Chest | ×0 (หยุดเน่า) |

```gdscript
# spoilage_rate ปรับตาม location ของ item
func get_spoilage_rate(item: Item) -> float:
    if item.is_in_inventory:      return 1.0
    if item.storage_type == "wood_chest":   return 0.5
    if item.storage_type == "ice_box":      return 0.1
    if item.storage_type == "magic_chest":  return 0.0
    return 1.0
```

**Ice Box** — craftable ด้วย Carpentry 40:
- วัตถุดิบ: Plank ×8, Ice Crystal ×4 (drop จาก ice-type enemy)
- รองรับ 20 food items
- ต้องวางใน camp building

---

### Food Quality Tier (ผลของ Cooking Skill × Ingredient Rarity)

```gdscript
func calc_food_quality(recipe: CraftingRecipe, player: Player) -> Dictionary:
    var rarity_mult = {
        "common": 1.0, "uncommon": 1.3, "rare": 1.6,
        "epic": 2.0, "legendary": 2.5, "mythic": 3.0
    }
    # ใช้ rarity ของ ingredient หลัก (ingredient แรกใน recipe)
    var main_rarity  = get_main_ingredient_rarity(recipe)
    var skill_factor = player.cooking_level / 100.0  # 0.01 – 1.0

    var hunger_restore = recipe.base_hunger × rarity_mult[main_rarity] × (0.5 + skill_factor × 0.5)
    var buff_duration  = recipe.base_buff_duration × rarity_mult[main_rarity] × skill_factor
    var buff_magnitude = recipe.base_buff_value × (0.7 + skill_factor × 0.3)

    return {
        "hunger_restore": int(hunger_restore),
        "buff_duration":  int(buff_duration),
        "buff_magnitude": buff_magnitude,
        "quality_tier":   _get_quality_tier(skill_factor, main_rarity)
    }
```

**Quality Tier (แสดงบน item tooltip):**

| Tier | เงื่อนไข | Label |
|---|---|---|
| Poor | skill < 25 | "ฝีมือยังไม่ดี" |
| Normal | skill 25-49 | "ธรรมดา" |
| Good | skill 50-74 | "ฝีมือดี" |
| Excellent | skill 75-99 | "ยอดเยี่ยม" |
| Master | skill 100 | "⭐ ฝีมือปรมาจารย์" |

**ตัวอย่าง — เนื้อย่าง (base Hunger +30, ไม่มี buff):**
```
cooking 1  + common Meat:   Hunger +15   (ไหม้นิดหน่อย)
cooking 50 + common Meat:   Hunger +30   (ตามสูตร)
cooking 100+ common Meat:   Hunger +30   (master: ไม่ได้เพิ่มมากกว่าเพราะ common)

cooking 50 + uncommon Meat: Hunger +39   (×1.3 × 0.75 factor)
cooking 100+ rare Meat:     Hunger +48   (×1.6 × 1.0 factor)
```

---

### Eating Raw Food

**กินแบบดิบได้** แต่ผลแย่กว่า cooked:

| Raw Item | Hunger | Risk |
|---|---|---|
| Raw Meat | +10 | Nausea 50% (DEF -10%, SPD -10% 3 นาที) |
| Raw Fish | +8 | Nausea 40% |
| Raw Vegetable | +5 | ไม่มี risk |
| Fruit | +15 | ไม่มี risk |
| Herb | +3 | ไม่มี risk (ใช้ดิบได้ปกติ) |

---

### Compost System

**Spoiled/Rotten food → Compost → Fertilizer**

```gdscript
# Compost Bin building (Carpentry tier 1)
# ใส่ food ที่ spoiled หรือ rotten ลงไป
func add_to_compost(item: Item) -> void:
    if item.food_state not in ["spoiled", "rotten"]: return
    compost_bin.compost_points += item.compost_value
    item.queue_free()
    # เมื่อ compost_points ≥ 10 → ได้ Basic Fertilizer ×1
    if compost_bin.compost_points >= 10:
        compost_bin.compost_points -= 10
        player.add_item("basic_fertilizer")
```

**Compost value ต่อ food:**
```
raw meat/fish:     2 points
raw vegetable:     1 point
cooked food:       3 points
spoiled/rotten:    +50% points (เน่าแล้วปุ๋ยดี)
```

---

### HUD & Notification

**Item icon แสดง spoilage state:**
```
[🥩] Fresh cooked meat    ← icon ปกติ
[🥩🟡] Stale cooked meat  ← icon มีจุดเหลือง
[🥩🔴] Spoiled meat       ← icon มีจุดแดง, tooltip เตือน
[🥩⬛] Rotten meat        ← icon greyed out, กินไม่ได้
```

**Notification เมื่อของในกระเป๋าใกล้เน่า (ถ้า food > 10 ชิ้น):**
```
⚠️ เนื้อย่าง 3 ชิ้น — จะเสียภายใน 30 นาที
   [กิน] [วางใน Ice Box] [ทิ้ง]
```

**Tooltip:**
```
เนื้อย่าง (Good Quality)
Hunger +30  |  ATK +3 (10 นาที)
🟡 Stale — Hunger 50%, buff ลด 50%
⏳ จะ Spoiled ใน 1:23
```

---

### Schema (schema_crafting_v1.sql เพิ่ม)

```sql
ALTER TABLE items ADD COLUMN IF NOT EXISTS
    is_food              BOOLEAN NOT NULL DEFAULT FALSE,
    base_hunger_restore  INTEGER NOT NULL DEFAULT 0,
    base_thirst_restore  INTEGER NOT NULL DEFAULT 0,
    base_buff_type       TEXT,     -- 'atk_pct'/'spd'/'all_stat' ฯลฯ
    base_buff_value      NUMERIC,
    base_buff_duration   INTEGER,  -- วินาที
    nausea_chance        NUMERIC NOT NULL DEFAULT 0,  -- Raw food เท่านั้น
    compost_value        INTEGER NOT NULL DEFAULT 0;

ALTER TABLE player_items ADD COLUMN IF NOT EXISTS
    food_state           TEXT NOT NULL DEFAULT 'fresh',
      -- 'fresh'/'stale'/'spoiled'/'rotten'
    spoilage_timer_sec   INTEGER,  -- วินาทีที่เหลือก่อนเปลี่ยน state
    quality_tier         TEXT,     -- 'poor'/'normal'/'good'/'excellent'/'master'
    hunger_restore       INTEGER,  -- คำนวณแล้วตาม quality
    buff_duration        INTEGER,
    buff_magnitude       NUMERIC,
    storage_type         TEXT NOT NULL DEFAULT 'inventory';
      -- 'inventory'/'wood_chest'/'ice_box'/'magic_chest'
```

---

## 59. Building Defense — Trap & Watchtower Mechanics

### Overview

Defense building ทำงานใน **Raid Mode** เท่านั้น (opt-in ต่อ server)
แบ่งเป็น 2 ประเภท:
- **Passive Trap** — วางบนพื้น activate เมื่อ monster เดินผ่าน (one-time หรือ reset ได้)
- **Watchtower** — building สูง ยิง monster ที่อยู่ใน range อัตโนมัติ ตลอดการ raid

---

### Passive Trap — Damage Formula

#### Trap Types & Base Stats

| Trap | วัสดุ | Tier | Base DMG | Effect | Reset |
|---|---|---|---|---|---|
| Spike Trap | Wood ×4, Iron ×2 | Wood | 40 | — | ❌ one-time |
| Snare Trap | Rope ×4, Wood ×2, Iron ×1 | Wood | 10 | Slow 50% × 3 turns | ✅ reset 5 นาที |
| Iron Spike Trap | Iron ×6, Stone ×2 | Stone | 80 | Bleed 20% | ❌ one-time |
| Flame Trap | Iron ×4, Coal ×4, Crystal ×1 | Iron | 60 | Burn 2 stacks | ✅ reset 10 นาที |
| Lightning Rod Trap | Mythril ×3, Crystal ×3 | Mythril | 120 | Shocked + Stun 1 turn | ✅ reset 8 นาที |

#### Damage Formula

```gdscript
func calc_trap_damage(trap: Building, monster: CombatEntity) -> int:
    var base = trap.base_damage

    # 1. Construction skill ของ player ที่วางกับดัก
    var skill_mult = 0.5 + (player.construction_level / 200.0)
    # construction 1   → ×0.505
    # construction 50  → ×0.75
    # construction 100 → ×1.0

    # 2. Material tier bonus
    var tier_mult = {
        "wood": 1.0, "stone": 1.3, "iron": 1.6, "mythril": 2.0
    }[trap.material_tier]

    # 3. Monster armor resistance
    var dmg_after_def = max(1, base * skill_mult * tier_mult - monster.def * 0.3)
    # กับดักไม่ bypass DEF ทั้งหมด แต่ลดผลกระทบจาก DEF ลง

    # 4. Enemy-type modifier (เหมือน weapon durability)
    var type_mult = monster.structure_damage_resist
    # slime/small: ×0.5 (ตัวเล็ก หลบกับดักได้บ้าง)
    # normal:      ×1.0
    # armored:     ×0.7 (ป้องกันได้บ้าง)
    # elite/boss:  ×0.5 (ไม่ค่อยสนกับดัก)

    return int(dmg_after_def * type_mult)
```

**ตัวอย่าง:**
```
Iron Spike Trap (base 80), construction 50, material iron:
  = max(1, 80 × 0.75 × 1.6 - monster.def × 0.3)
  ถ้า monster.def = 20:
  = max(1, 96 - 6) = 90 damage

Lightning Rod Trap (base 120), construction 100, material mythril:
  = max(1, 120 × 1.0 × 2.0 - 20 × 0.3) = 234 damage + stun
```

#### Trap Placement Rules

```
- วางได้บน floor tile ว่างเท่านั้น
- ไม่วางซ้อนกันได้
- monster เดินผ่าน tile → trigger ทันที
- player เดินผ่าน trap ของตัวเอง → ไม่ trigger
- player เดินผ่าน trap ของ player อื่น (multiplayer, raid mode ปิด) → ไม่ trigger
- กับดักมองไม่เห็นสำหรับ monster (ไม่มี detection AI)
```

#### Trap Durability

```
Trap ใช้ได้ N ครั้งก่อนพัง:
  Wood tier:   3 activations
  Stone/Iron:  5 activations
  Mythril:     10 activations

หลังพัง → sprite เปลี่ยน, ต้อง craft ใหม่ หรือ repair ด้วย construction skill
repair_cost_material = trap.tier_material × 1 unit
```

---

### Watchtower — Auto-Attack Formula

#### Watchtower Stats

| Tier | วัสดุ | HP | ATK | Range | Attack Rate | จำนวน target |
|---|---|---|---|---|---|---|
| Wood Watchtower | Plank ×12, Stone ×6, Iron ×4 | 300 | 25 | 5 tiles | 1 ยิง/3 turns | 1 |
| Stone Watchtower | Stone ×20, Iron ×8 | 600 | 50 | 7 tiles | 1 ยิง/2 turns | 1 |
| Iron Watchtower | Iron ×16, Stone ×8 | 1,000 | 90 | 9 tiles | 1 ยิง/2 turns | 2 |
| Mythril Watchtower | Mythril ×10, Iron ×8 | 2,000 | 160 | 12 tiles | 1 ยิง/1 turn | 3 |

#### Damage Formula

```gdscript
func calc_watchtower_damage(tower: Building, monster: CombatEntity) -> int:
    var base = tower.base_atk

    # 1. Construction skill ของ player ที่สร้าง
    var skill_mult = 0.6 + (player.construction_level / 250.0)
    # construction 1   → ×0.604
    # construction 50  → ×0.80
    # construction 100 → ×1.0

    # 2. Tower tier bonus (ใช้ค่า ATK จาก tier table แทน)

    # 3. Range penalty — monster ไกลกว่า 60% ของ range → damage ลด
    var dist = tower.position.distance_to(monster.position)
    var range_factor = 1.0 if dist <= tower.range * 0.6 \
                       else lerp(1.0, 0.6, (dist - tower.range * 0.6) / (tower.range * 0.4))
    # ระยะใกล้: ×1.0 | ระยะขอบ: ×0.6

    # 4. DEF reduction
    var dmg_after_def = max(1, base * skill_mult * range_factor - monster.def * 0.5)

    # 5. Elite/Boss resistance
    if monster.is_elite: dmg_after_def *= 0.7
    if monster.is_boss:  dmg_after_def *= 0.4

    return int(dmg_after_def)
```

**ตัวอย่าง:**
```
Iron Watchtower (ATK 90), construction 75, monster DEF 20, ระยะใกล้:
  skill_mult = 0.6 + 75/250 = 0.90
  = max(1, 90 × 0.90 × 1.0 - 20 × 0.5) = max(1, 81 - 10) = 71 damage

Mythril Watchtower (ATK 160), construction 100, ระยะไกล 90% range:
  skill_mult = 1.0
  range_factor = lerp(1.0, 0.6, (90%-60%)/(40%)) = lerp(1.0, 0.6, 0.75) = 0.7
  = max(1, 160 × 1.0 × 0.7 - 20 × 0.5) = max(1, 112 - 10) = 102 damage
```

#### Target Priority

```gdscript
func pick_watchtower_target(tower: Building, monsters: Array) -> CombatEntity:
    var in_range = monsters.filter(func(m):
        return tower.position.distance_to(m.position) <= tower.range
               and not m.is_dead)

    if in_range.is_empty(): return null

    # Priority: monster ที่ใกล้ building สำคัญมากที่สุด (ไม่ใช่ใกล้ tower)
    # คิดจากระยะถึง Hub/Campfire — protect core buildings ก่อน
    return in_range.min_by(func(m): return m.position.distance_to(hub_position))
```

#### Watchtower โดน monster attack

Watchtower เป็น building — monster ใน Raid Mode อาจ target tower ด้วย:
```
monster_attack_watchtower:
  damage = monster.atk - tower.def (tower.def = tower.hp / 50)
  tower.hp -= damage
  tower.hp = 0 → tower destroyed, ไม่ยิงอีก
  ซ่อม: construction_skill + material (เหมือน repair building ปกติ)
```

---

### Defense Building Placement Strategy

**แนะนำ layout สำหรับ camp defense:**

```
[ขอบ camp]
  Wall ─── Wall ─── Wall ─── Wall
  │                               │
  Wall    Spike Trap ×3           Wall
  │       Snare Trap ×2           │
  Wall    [Watchtower]            Wall
  │                               │
  Wall ─── Gate ──── Wall ─── Wall
              ↑
         จุดเข้า monster (ไม่มีกำแพง → monster เข้าทาง Gate ก่อน)
         → Trap วางหน้า Gate
         → Watchtower ยิงระหว่างที่ monster ผ่าน trap
```

**Synergy:**
- Snare Trap (slow) + Watchtower (auto-attack) = monster ช้าลง → โดนยิงเพิ่ม
- Flame Trap (burn) + Iron Spike (bleed) = DOT stack บน monster

---

### Construction Skill Milestone ที่เกี่ยวข้อง

| Construction Level | ปลดล็อก |
|---|---|
| 1 | Spike Trap, Snare Trap, Wood Watchtower |
| 25 | Iron Spike Trap, Stone Watchtower |
| 50 | Flame Trap, Iron Watchtower |
| 75 | Lightning Rod Trap |
| 100 | Mythril Watchtower, ป้องกัน elite +30% |

**Mastery bonus (construction 100):**
- Trap damage ×1.5 (ใช้ skill_mult เต็ม)
- Watchtower attack rate +1 (ยิงเร็วขึ้น 1 ครั้ง/N turns)
- ซ่อม building ใช้วัสดุ -50%

---

### Schema (schema_crafting_v1.sql เพิ่ม)

```sql
ALTER TABLE camp_buildings ADD COLUMN IF NOT EXISTS
    base_damage           INTEGER,    -- Trap: damage per activation
    base_atk              INTEGER,    -- Watchtower: ATK stat
    attack_range          NUMERIC,    -- Watchtower: tile range
    attack_rate_turns     INTEGER,    -- Watchtower: ยิงทุก N turns
    max_targets           INTEGER NOT NULL DEFAULT 1,
    activation_count      INTEGER NOT NULL DEFAULT 0,  -- Trap: ครั้งที่ activate
    max_activations       INTEGER,    -- Trap: null = ไม่จำกัด (snare)
    reset_seconds         INTEGER,    -- Trap: วินาทีก่อน reset (null = one-time)
    effect_type           TEXT,       -- 'bleed'/'burn'/'slow'/'shocked'/'stun'
    effect_chance         NUMERIC NOT NULL DEFAULT 0,
    material_tier         TEXT NOT NULL DEFAULT 'wood',
    structure_damage_resist NUMERIC NOT NULL DEFAULT 1.0,
    builder_player_id     UUID REFERENCES players(id);
    -- เก็บ construction skill ของ player ที่ build ไว้ใช้คำนวณ damage
```

---

## 60. Achievement System

### Structure

Achievement แต่ละตัวมี:
- **Condition** — เงื่อนไขที่ต้องทำ (server-side verify)
- **Reward** — Gem, gold, หรือ cosmetic badge
- **Badge** — แสดงข้าง portrait ใน HUD เลือกได้ 1 ใน 3 slot

```gdscript
var achievement = {
    "id":          "ach_first_kill",
    "name_th":     "นักล่าหน้าใหม่",
    "description": "สังหารศัตรูครั้งแรก",
    "category":    "combat",
    "condition":   {"type": "kill_count", "value": 1},
    "reward_gem":  50,
    "reward_gold": 0,
    "badge_id":    "badge_sword",
    "is_secret":   false,
}
```

---

### หมวด Combat

| ID | ชื่อ | เงื่อนไข | Gem | Badge |
|---|---|---|---|---|
| ach_first_kill | นักล่าหน้าใหม่ | kill ศัตรู 1 ตัว | 50 | ⚔️ |
| ach_kill_100 | นักรบผู้ชำนาญ | kill สะสม 100 ตัว | 100 | 🗡️ |
| ach_kill_1000 | เทพแห่งการล่า | kill สะสม 1,000 ตัว | 300 | 💀 |
| ach_no_damage_win | ไร้รอยขีดข่วน | ชนะ combat โดยไม่โดน damage | 150 | 🛡️ |
| ach_crit_10 | ตาเหยี่ยว | CRIT ต่อเนื่อง 10 ครั้งใน combat เดียว | 100 | 🎯 |
| ach_first_boss | ผู้พิชิต | kill Boss ครั้งแรก | 200 | 👑 |
| ach_all_boss | ราชาแห่งหอ | kill Boss ทุกตัว (Band 1-6) | 500 | 🏆 |
| ach_first_capture | นักจับ | capture monster ครั้งแรก | 80 | 🪤 |
| ach_capture_50 | ผู้เชี่ยวชาญกับดัก | capture สะสม 50 ตัว | 200 | 🔗 |
| ach_dice_20 | โชคเทพ | ทอยเต๋าได้ 20 (Critical) | 100 | 🎲 |
| ach_exhausted_win | ล้าแต่ไม่แพ้ | ชนะ combat ขณะ Exhausted (energy=0) | 150 | ⚡ |
| ach_flee_success_low | เร็วกว่าสายตา | หนีสำเร็จขณะ HP < 10% | 120 | 💨 |

---

### หมวด Progression

| ID | ชื่อ | เงื่อนไข | Gem | Badge |
|---|---|---|---|---|
| ach_divinity_1 | ผู้แสวงหา | Divinity level 1 | 100 | ✨ |
| ach_divinity_5 | เซียน | Divinity level 5 | 300 | 🌟 |
| ach_divinity_10 | เทพปกรณัม | Divinity level 10 | 1,000 | 🌠 |
| ach_node_10 | ปลุกทักษะ | ปลดล็อก skill node 10 ตัว | 100 | 🕸️ |
| ach_ascension_first | ก้าวข้ามขีดจำกัด | ปลดล็อก Ascension node แรก | 200 | 🔥 |
| ach_all_ascension_b1 | เทพแห่งศรัทธา | ปลดล็อก Ascension node ครบ Band 1 | 400 | 🪔 |
| ach_refine_max | ฝีมือช่างแห่งเทพ | refine equipment ถึง level สูงสุด | 300 | ⚒️ |
| ach_item_legendary | สัมผัสตำนาน | ได้รับ legendary item ครั้งแรก | 200 | 💜 |
| ach_item_mythic | ของแห่งปฐมกาล | ได้รับ mythic item ครั้งแรก | 500 | 🌌 |
| ach_gacha_pity | ความเพียร | ทำ pity pull (pull ที่ 50) | 150 | 🎰 |

---

### หมวด Exploration

| ID | ชื่อ | เงื่อนไข | Gem | Badge |
|---|---|---|---|---|
| ach_floor_10 | นักสำรวจมือใหม่ | ถึง Floor 10 | 100 | 🗺️ |
| ach_floor_30 | ผู้ท้าทายความมืด | ถึง Floor 30 | 300 | 🌑 |
| ach_floor_50 | ผู้พิชิตหอ | ถึง Floor 50 | 600 | 🏰 |
| ach_band_2 | ก้าวสู่โอลิมปัส | เข้า Band 2 ครั้งแรก | 150 | ⚡ |
| ach_all_bands | พเนจรแห่งมิติ | เข้าทุก Band (1-6) | 500 | 🌐 |
| ach_treasure_10 | นักล่าสมบัติ | ขุด Treasure Spot สะสม 10 จุด | 100 | 💰 |
| ach_camp_clear_50 | นักล้างแคมป์ | clear camp สะสม 50 แคมป์ | 150 | 🔑 |
| ach_night_survivor | ราตรีผู้กล้า | อยู่รอดกลางคืน 10 คืนโดยไม่ตาย | 200 | 🌙 |
| ach_band_sacrifice | เสียสละ | สละ Divinity EXP ข้าม Band ครั้งแรก | 120 | ⚖️ |
| ach_server_first | ผู้บุกเบิก | kill Boss ได้เป็นคนแรกบน server | 500 | 👁️ |

---

### หมวด Survival & Crafting

| ID | ชื่อ | เงื่อนไข | Gem | Badge |
|---|---|---|---|---|
| ach_first_cook | ครัวเรือน | ทำอาหารครั้งแรก | 50 | 🍳 |
| ach_master_chef | เชฟระดับเทพ | cooking skill 100 | 300 | 👨‍🍳 |
| ach_brew_100 | นักปรุงยา | alchemy skill 100 | 300 | ⚗️ |
| ach_blacksmith_100 | ช่างเทพ | smithing skill 100 | 300 | 🔨 |
| ach_first_build | บ้านแรก | สร้าง building แรก | 80 | 🏠 |
| ach_full_farm | ไร่นาสวนสรรค์ | มี farm plot ≥ 10 แปลง | 150 | 🌾 |
| ach_fish_legendary | ปลาตำนาน | จับปลา legendary ครั้งแรก | 200 | 🐟 |
| ach_tame_animal | เพื่อนรัก | tame สัตว์ครั้งแรก | 100 | 🐾 |
| ach_all_skills_50 | ผู้รอบรู้ | Life Skill ทุกตัว ≥ 50 | 400 | 📚 |
| ach_food_no_spoil | ครัวสะอาด | ไม่มี food เน่าใน inventory 7 วัน | 150 | ✅ |

---

### หมวด Social

| ID | ชื่อ | เงื่อนไข | Gem | Badge |
|---|---|---|---|---|
| ach_first_friend | เพื่อนคนแรก | add friend สำเร็จ 1 คน | 50 | 👫 |
| ach_friends_10 | ขาใหญ่ | มีเพื่อน 10 คน | 150 | 🤝 |
| ach_party_win | พลังแห่งมิตรภาพ | ชนะ combat ในโหมด party | 100 | 🎮 |
| ach_party_boss | ล่าบอสพร้อมกัน | kill Boss ในโหมด party | 200 | 🗡️🗡️ |
| ach_donate_treasury | ผู้ใจบุญ | donate gold เข้า Town Treasury สะสม 1,000g | 100 | 💎 |
| ach_bounty_collect | นักล่าเงินรางวัล | จับ Bounty target สำเร็จ 5 คน | 200 | 🎯 |

---

### หมวด Eternal Path (Hardcore)

| ID | ชื่อ | เงื่อนไข | Gem | Badge |
|---|---|---|---|---|
| ach_eternal_start | ทางนักรบ | เริ่ม Eternal Path character | 100 | ☠️ |
| ach_eternal_floor20 | ผู้ไม่ยอมแพ้ | ถึง Floor 20 ใน Eternal Path | 300 | 🩸 |
| ach_eternal_boss | นิรันดร์แห่งเทพ | kill Boss ใน Eternal Path | 500 | 💀👑 |
| ach_eternal_divinity5 | อมตะ | Divinity 5 ใน Eternal Path | 600 | ∞ |

---

### หมวด Secret (숨겨진)

ไม่แสดงใน achievement list จนกว่าจะ unlock:

| ID | ชื่อ | เงื่อนไข (ซ่อน) | Gem |
|---|---|---|---|
| ach_secret_dice1 | "ชะตากรรม" | ทอยเต๋าได้ 1 (Critical Fail) 10 ครั้ง | 100 |
| ach_secret_slime | "นักล่าสไลม์" | kill slime สะสม 500 ตัว | 100 |
| ach_secret_flee_boss | "กลยุทธ์ถอย" | หนีจาก Boss สำเร็จ | 200 |
| ach_secret_rotten | "ปากสู้" | กิน Rotten food 5 ครั้งโดยไม่ nausea | 150 |
| ach_secret_naked | "ต้นกำเนิด" | เข้า combat โดยไม่สวมใส่ equipment ชนะ | 300 |

---

### Badge Display System

ผู้เล่นเลือกแสดง badge ข้าง portrait ได้ **3 slot**:

```
[Portrait] [🏆][💀][⭐]  สมชาย  เซียน (Div.5)
```

- Badge unlock อัตโนมัติเมื่อ achievement สำเร็จ
- เลือกแสดงได้จาก Badge Collection UI
- Badge หายาก (Eternal Path, Server First) มี visual effect พิเศษ (glow/animation)
- badge_slot_1, badge_slot_2, badge_slot_3 เก็บใน players table

---

### Schema (schema_crafting_v1.sql / schema_social_v1.sql เพิ่ม)

```sql
CREATE TABLE achievements (
  id              TEXT PRIMARY KEY,
  name_th         TEXT NOT NULL,
  description_th  TEXT NOT NULL,
  category        TEXT NOT NULL,
    -- 'combat'/'progression'/'exploration'/'survival'/'social'/'eternal'/'secret'
  condition_type  TEXT NOT NULL,
    -- 'kill_count'/'skill_level'/'floor_reached'/'item_rarity'/'friend_count' ฯลฯ
  condition_value JSONB NOT NULL,
  reward_gem      INTEGER NOT NULL DEFAULT 0,
  reward_gold     INTEGER NOT NULL DEFAULT 0,
  badge_id        TEXT,
  is_secret       BOOLEAN NOT NULL DEFAULT FALSE,
  is_active       BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE player_achievements (
  player_id       UUID NOT NULL REFERENCES players(id) ON DELETE CASCADE,
  achievement_id  TEXT NOT NULL REFERENCES achievements(id),
  unlocked_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (player_id, achievement_id)
);

ALTER TABLE players ADD COLUMN IF NOT EXISTS
  badge_slot_1  TEXT,  -- achievement badge_id
  badge_slot_2  TEXT,
  badge_slot_3  TEXT;

CREATE INDEX idx_player_ach ON player_achievements (player_id, achievement_id);
```

---

## 61. Analytics & Telemetry

### Design Philosophy
Track เฉพาะ **gameplay event ที่จำเป็น** สำหรับ balance tuning และ live ops
ไม่ track PII (ชื่อจริง, email) — ใช้ player_id (UUID) เท่านั้น
ผู้เล่นรับรู้ว่ามีการเก็บ gameplay data (ระบุใน Privacy Policy ตอน account registration)

---

### Event Categories

#### A — Combat Events

| Event | Trigger | Data ที่เก็บ |
|---|---|---|
| `combat_started` | เริ่ม combat | camp_id, enemy_ids, player_divinity, difficulty, is_party |
| `combat_ended` | จบ combat | result(win/lose/fled), turns_taken, hp_remaining_pct, energy_remaining, items_dropped_count |
| `combat_action` | player ทำ action | action_type, skill_id, is_crit, is_miss, damage, hp_after |
| `player_death` | HP = 0 | floor, enemy_id, cause, hp_before, equipped_items_rarity |
| `boss_killed` | kill boss | boss_id, difficulty, clear_time_turns, score, is_party, party_size |
| `flee_attempt` | กด flee | success, dice_roll, energy_cost, gold_dropped |
| `capture_attempt` | กด capture | success, capture_item_rarity, dice_roll, enemy_id |

#### B — Progression Events

| Event | Trigger | Data ที่เก็บ |
|---|---|---|
| `divinity_level_up` | level เพิ่ม | new_level, total_exp, source |
| `skill_node_unlocked` | unlock node | node_id, tier, band, gold_spent, divinity_level_at_unlock |
| `band_ascension` | ข้าม band | from_band, to_band, exp_sacrificed, level_before, level_after |
| `gacha_pull` | pull gacha | rarity, item_type, pity_count, banner_id |
| `item_equipped` | equip item | item_rarity, slot, affix_count, durability |
| `upgrade_attempt` | upgrade/refine | item_id, item_rarity, result(success/fail_t1/t2/t3), used_guarantee_stone |

#### C — Economy Events

| Event | Trigger | Data ที่เก็บ |
|---|---|---|
| `gold_earned` | ได้ gold | source(sell/chest/money_bag), amount, item_rarity_sold |
| `gold_spent` | เสีย gold | sink(node_unlock/repair/warp/identify/npc_buy), amount |
| `item_sold` | ขายของ NPC | item_rarity, sell_price, trading_skill_level |
| `npc_purchase` | ซื้อจาก NPC | item_id, price, npc_role, band |

#### D — Survival Events

| Event | Trigger | Data ที่เก็บ |
|---|---|---|
| `hunger_critical` | Hunger < 10 | location, food_in_inventory, play_duration_today |
| `food_cooked` | ทำอาหาร | recipe_id, cooking_level, quality_tier |
| `food_spoiled` | food เน่า | item_id, food_type, time_in_inventory_sec |
| `building_placed` | สร้าง building | building_type, band, construction_level |
| `raid_started` | raid เริ่ม | band, monster_count, player_count_defending |
| `raid_ended` | raid จบ | result, buildings_destroyed, monsters_killed |

#### E — Session Events

| Event | Trigger | Data ที่เก็บ |
|---|---|---|
| `session_start` | login | platform, client_version, is_guest, divinity_level, current_floor |
| `session_end` | logout/disconnect | session_duration_sec, floors_explored, combats_won, gold_delta |
| `auto_hunt_started` | เริ่ม auto-hunt | duration_target, camp_id, world_energy_used |
| `auto_hunt_ended` | จบ auto-hunt | duration_actual, kills, items_count, end_reason |

---

### Implementation (Godot → Supabase)

```gdscript
# AnalyticsManager.gd (autoload singleton)
const BATCH_SIZE = 20       # ส่งทีละ 20 events
const FLUSH_INTERVAL = 60.0 # หรือทุก 60 วินาที

var event_queue: Array = []
var flush_timer: float = 0.0

func track(event_name: String, properties: Dictionary = {}) -> void:
    var event = {
        "event":      event_name,
        "player_id":  GameState.player_id,  # UUID ไม่ใช่ชื่อ
        "session_id": GameState.session_id,
        "timestamp":  Time.get_unix_time_from_system(),
        "band":       GameState.current_band,
        "floor":      GameState.current_floor,
        "properties": properties,
    }
    event_queue.append(event)
    if event_queue.size() >= BATCH_SIZE:
        _flush()

func _process(delta: float) -> void:
    flush_timer += delta
    if flush_timer >= FLUSH_INTERVAL and not event_queue.is_empty():
        flush_timer = 0.0
        _flush()

func _flush() -> void:
    if event_queue.is_empty(): return
    var batch = event_queue.duplicate()
    event_queue.clear()
    # ส่ง batch ไป Supabase Edge Function แบบ fire-and-forget
    SupabaseClient.post_analytics(batch)

# ตัวอย่างการใช้งาน:
func on_combat_ended(result: String, turns: int, hp_pct: float) -> void:
    AnalyticsManager.track("combat_ended", {
        "result": result,
        "turns_taken": turns,
        "hp_remaining_pct": hp_pct,
        "camp_id": current_camp_id,
        "difficulty": GameState.difficulty,
    })
```

---

### Schema (Supabase — แยก table ต่างหากจาก game data)

```sql
-- analytics table ควรอยู่ใน schema แยก หรือ Supabase project แยก
-- เพื่อ query ไม่กระทบ game server performance

CREATE TABLE analytics_events (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event       TEXT NOT NULL,
  player_id   UUID NOT NULL,     -- ไม่ FK ไป players (analytics อ่านอย่างเดียว)
  session_id  UUID NOT NULL,
  band        INTEGER,
  floor       INTEGER,
  properties  JSONB NOT NULL DEFAULT '{}',
  ts          TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- partition by month (Supabase declarative partitioning)
CREATE INDEX idx_analytics_event_ts ON analytics_events (event, ts DESC);
CREATE INDEX idx_analytics_player   ON analytics_events (player_id, ts DESC);
```

---

### Key Metrics ที่ใช้ Balance

| Metric | คำนวณจาก | ใช้สำหรับ |
|---|---|---|
| Combat win rate per floor | combat_ended.result | ปรับ enemy difficulty |
| Average clear time per boss | boss_killed.clear_time_turns | ปรับ enrage timer |
| Most used skill | combat_action.skill_id | ปรับ skill balance |
| Gold income/session | session_end.gold_delta | ปรับ economy |
| Item sell rarity breakdown | item_sold.item_rarity | ปรับ drop rate |
| Auto-hunt end reason | auto_hunt_ended.end_reason | ปรับ safety recall threshold |
| Food spoilage rate | food_spoiled.food_type | ปรับ spoilage timer |
| Upgrade fail rate per tier | upgrade_attempt.result | ปรับ success rate |
| Gacha pity distribution | gacha_pull.pity_count | ตรวจ pity ทำงานถูกต้อง |
| Band ascension sacrifice | band_ascension | ดู player behavior กดข้าม band บ่อยแค่ไหน |

---

### Privacy & Data Retention

```
- ไม่เก็บ: ชื่อ, email, IP address, device fingerprint
- เก็บ: player_id (UUID), gameplay events เท่านั้น
- Retention: 90 วัน (หลังจากนั้น purge อัตโนมัติ)
- Guest player: เก็บด้วย UUID เดียวกัน ถ้า link account → UUID เดิม
- ผู้เล่นขอลบได้: ส่ง request → purge analytics_events WHERE player_id = ?
```

---

## 62. Weather System

### Design Philosophy
Weather เป็น **random event layer ซ้อนบน season** — season กำหนดว่าอะไรเกิดได้บ้าง, weather กำหนดว่าจะเกิดจริงหรือไม่และนานแค่ไหน

```
Season  →  กำหนด weather pool ที่เป็นไปได้
Weather →  สุ่มจาก pool ทุก 2-6 ชั่วโมงเกม → ใช้งาน N ชั่วโมง → หมด
```

Weather ไม่ lock ผู้เล่น — เป็น **soft modifier** เพิ่มความหลากหลาย

---

### Weather Types & Effects

| Weather | Symbol | Field Effect | Combat Effect | Gathering | Farming |
|---|---|---|---|---|---|
| Clear (ปกติ) | ☀️ | — | — | ×1.0 | ×1.0 |
| Cloudy (มีเมฆ) | ☁️ | visibility -10% | — | ×1.0 | ×1.0 |
| Light Rain (ฝนเบา) | 🌦️ | movement -5%, slippery | — | Herb ×1.2 | grow -20% time |
| Heavy Rain (ฝนหนัก) | 🌧️ | movement -15%, visibility -20% | FIRE_DMG -30%, LIGHTNING_DMG +20% | Herb ×1.5, Fish ×1.5 | grow -30% time |
| Fog (หมอก) | 🌫️ | visibility -40%, enemy detect +30% | miss chance +10% (both sides) | Mushroom ×1.5 | — |
| Thunderstorm (พายุฟ้าผ่า) | ⛈️ | movement -20%, visibility -25% | LIGHTNING_DMG +40%, random lightning strike (AOE) | ❌ ออกเก็บไม่ได้ | crop damage 20% |
| Sandstorm (พายุทราย) | 🌪️ | visibility -60%, movement -25% | miss chance +20% (both) | ❌ | ❌ |
| Blizzard (พายุหิมะ) | ❄️ | movement -35%, Hypothermia risk | SPD -20%, ICE_DMG +30% | ❌ | crop freeze, damage |
| Heat Wave (คลื่นความร้อน) | 🔥 | Thirst drain ×2, Fatigue ×1.5 | FIRE_DMG +20%, HP regen ลด | Herb บางชนิดตาย | crop water need ×2 |
| Aurora (แสงเหนือ) | 🌌 | +20% Divinity EXP ทุก source | — | Magic Flower ×2 | Magic crop ×1.5 |

---

### Weather Pool per Season/Band

#### Band 1 (Thai)

| ฤดู | Weather ที่เป็นไปได้ | โอกาส |
|---|---|---|
| คิมหันต์ (ร้อน) | Clear 40%, Heat Wave 30%, Cloudy 20%, Light Rain 10% | — |
| วัสสาน (ฝน) | Heavy Rain 30%, Light Rain 30%, Thunderstorm 20%, Fog 15%, Clear 5% | — |
| เหมันต์ (หนาว) | Fog 35%, Cloudy 30%, Light Rain 20%, Clear 15% | — |

#### Band 2 (Greek)

| ฤดู | Weather Pool |
|---|---|
| Earos | Clear 40%, Light Rain 30%, Cloudy 20%, Fog 10% |
| Theros | Clear 50%, Heat Wave 30%, Thunderstorm 20% |
| Phthinoporon | Cloudy 40%, Light Rain 30%, Fog 20%, Clear 10% |
| Cheimon | Blizzard 20%, Fog 30%, Cloudy 30%, Clear 20% |

#### Band 3 (Norse)

| ฤดู | Weather Pool |
|---|---|
| Vor | Light Rain 40%, Fog 30%, Clear 20%, Thunderstorm 10% |
| Sumar | Clear 60%, Thunderstorm 25%, Aurora 15% |
| Haust | Thunderstorm 40%, Heavy Rain 30%, Fog 20%, Clear 10% |
| Vetr | Blizzard 50%, Heavy Rain (sleet) 30%, Fog 15%, Aurora 5% |

#### Band 4 (Egyptian)

| ฤดู | Weather Pool |
|---|---|
| Akhet | Heavy Rain 40%, Fog 30%, Light Rain 20%, Clear 10% |
| Shemu | Clear 30%, Heat Wave 30%, Sandstorm 30%, Cloudy 10% |

#### Band 5 (Japanese)

| ฤดู | Weather Pool |
|---|---|
| Haru | Light Rain 40%, Clear 30%, Cherry Blossom Storm 20%, Fog 10% |
| Natsu | Clear 40%, Thunderstorm 30%, Heat Wave 20%, Heavy Rain 10% |
| Aki | Clear 35%, Fog 30%, Light Rain 25%, Cloudy 10% |
| Fuyu | Blizzard 35%, Heavy Rain 30%, Fog 20%, Clear 15% |

#### Band 6 (Primordial)

| Weather Pool | สภาพแวดล้อมไม่แน่นอน |
|---|---|
| Void Storm | visibility 0%, movement -50%, ALL_DMG +30% (ทั้ง sides) |
| Primordial Heat | HP drain 1%/min, FIRE_DMG +50% |
| Eternal Fog | ไม่มี detect radius, enemy detect ไม่ได้จนกว่าจะชน |
| Cosmic Aurora | Divinity EXP ×3, item drop ×1.5 (rare bonus) |

---

### Weather Duration & Transition

```gdscript
# WeatherManager.gd (autoload)
var current_weather: String = "clear"
var weather_end_time: float  # Unix timestamp

func roll_next_weather() -> void:
    var pool = get_weather_pool(current_band, current_season)
    current_weather = weighted_random(pool)
    # duration: 2-6 ชั่วโมงเกม สุ่ม
    var game_hours = randi_range(2, 6)
    var real_seconds = game_hours * TimeManager.GAME_HOUR_SECONDS
    weather_end_time = Time.get_unix_time_from_system() + real_seconds
    _broadcast_weather_change(current_weather, real_seconds)
    _apply_weather_effects()

func _process(delta: float) -> void:
    if Time.get_unix_time_from_system() >= weather_end_time:
        roll_next_weather()

func get_weather_pool(band: int, season: String) -> Dictionary:
    return WEATHER_POOLS[band][season]  # data-driven จาก JSON/table
```

**Transition Effect:**
- Weather เปลี่ยนแบบ gradual (30 วินาที real time) — ไม่ pop ทันที
- แสดง notification: "🌧️ ฝนเริ่มตก..."
- Visual: sky color, particle effect (rain drop, snow, sand) ผ่าน Godot Environment

---

### Special Mechanics

#### ⛈️ Thunderstorm — Lightning Strike
```gdscript
# ทุก 60-120 วินาที: ฟ้าผ่าตกที่ random tile ใน field map
func _spawn_lightning(field_map: TileMap) -> void:
    var target_tile = Vector2i(randi() % field_map.width, randi() % field_map.height)
    # visual: flash + thunder sound
    # damage: ทุก unit ใน 1.5 tile radius รับ LIGHTNING_DMG ×1.0 unblockable
    var affected = get_units_in_radius(target_tile, 1.5)
    for unit in affected:
        unit.take_damage(lightning_base_dmg, "lightning", bypass_def: true)
    # tile ที่โดนฟ้าผ่า: wet สถานะ 3 นาที (chain lightning สำหรับ Titan fight ใน §51)
```

#### 🌫️ Fog — Ambush Mechanic
```
Fog visibility -40% → enemy detect radius ×1.3 (กลิ่นชดเชย)
→ enemy อาจ appear ใกล้กว่าปกติ โดย player ไม่เห็นล่วงหน้า
→ AGGRESSIVE enemy ใน fog: พุ่งใส่ทันทีโดยไม่มี alert animation ก่อน
```

#### ❄️ Blizzard — Hypothermia
```
ถ้า player อยู่กลางแจ้ง (ไม่อยู่ใน building) ระหว่าง Blizzard:
  ทุก 30 วินาที: Hypothermia stack +1
  stack 3:  SPD -10%, CRIT_RATE -5%
  stack 6:  DEF -15%, HP Regen หยุด
  stack 10: HP drain 1%/นาที

ป้องกัน: อยู่ใน building, ใส่ Winter Armor (recipe tailoring 50), กิน Warming Potion
clear stack: เข้า building + อยู่ใกล้ Campfire 1 นาที
```

#### 🔥 Heat Wave — Dehydration
```
Thirst drain ×2 (วัสสาน อยู่แล้ว)
ถ้า Thirst = 0 ระหว่าง Heat Wave:
  Fatigue drain ×3 (เพิ่มจาก ×1.5 ปกติ)
  HP Regen ลด 50%
ป้องกัน: พกน้ำ Flask ×2+, กิน Cooling Potion, อยู่ใน Shade tile (ต้นไม้/building)
```

#### 🌪️ Sandstorm (Band 4)
```
visibility -60% → mini-map ไม่แสดง enemy position
movement -25%
gathering/farming ทำไม่ได้ (ทราย)
หาก outdoor นาน > 5 นาที: eye irritation debuff (miss chance +15%)
ป้องกัน: Goggles (recipe), building, หรือซ่อนตัวหลัง large structure
```

---

### Weather HUD

```
[ด้านบน field map]
☁️ มีเมฆ     🕐 อีก 1:24 ชั่วโมงเกม
(คลิก → รายละเอียด weather effects)
```

Weather panel เมื่อ expand:
```
☁️ มีเมฆ (Cloudy)
ผล:  visibility -10%
ระยะเวลา: อีก 1 ชั่วโมง 24 นาที (เกม)
ถัดไปอาจเป็น: 🌧️ ฝนหนัก (40%) หรือ ☀️ แจ่มใส (30%)
```

---

### Schema (schema_world_v1.sql เพิ่ม)

```sql
ALTER TABLE world_time_config ADD COLUMN IF NOT EXISTS
    current_weather      TEXT NOT NULL DEFAULT 'clear',
    weather_end_at       TIMESTAMPTZ,
    weather_transition   BOOLEAN NOT NULL DEFAULT FALSE;

CREATE TABLE weather_pool (
  band_number  INTEGER NOT NULL,
  season_name  TEXT NOT NULL,
  weather_type TEXT NOT NULL,
  weight       NUMERIC NOT NULL,   -- relative weight สำหรับ weighted random
  min_hours    INTEGER NOT NULL DEFAULT 2,
  max_hours    INTEGER NOT NULL DEFAULT 6,
  PRIMARY KEY (band_number, season_name, weather_type)
);

-- Seed data Band 1
INSERT INTO weather_pool VALUES
  (1, 'hot',  'clear',       40, 2, 8),
  (1, 'hot',  'heat_wave',   30, 3, 6),
  (1, 'hot',  'cloudy',      20, 2, 4),
  (1, 'hot',  'light_rain',  10, 2, 4),
  (1, 'rain', 'heavy_rain',  30, 3, 6),
  (1, 'rain', 'light_rain',  30, 2, 5),
  (1, 'rain', 'thunderstorm',20, 2, 4),
  (1, 'rain', 'fog',         15, 3, 6),
  (1, 'rain', 'clear',        5, 1, 3),
  (1, 'cold', 'fog',         35, 3, 8),
  (1, 'cold', 'cloudy',      30, 2, 6),
  (1, 'cold', 'light_rain',  20, 2, 4),
  (1, 'cold', 'clear',       15, 2, 4);
```

---

## 63. Mystery Camp Event Table

### Design Philosophy
Mystery camp คือ "surprise" ในแผนที่ — ผู้เล่นไม่รู้ว่าจะเจออะไรจนกว่าจะเข้า
Event อาจดีหรือแย่ก็ได้ เพิ่ม tension และ replayability

**World Energy cost:** 2 (ถูกกว่า normal camp)
**หน้าตาบน map:** ❓ icon — ไม่แสดงว่าเป็น event อะไร

---

### Event Categories

| Category | โอกาส | ลักษณะ |
|---|---|---|
| Treasure | 25% | ได้ item หรือ gold โดยไม่ต่อสู้ |
| Encounter | 30% | ต้องต่อสู้ แต่ผลพิเศษ |
| Shrine / Blessing | 20% | buff หรือ Divinity EXP |
| Curse / Trap | 15% | penalty หรือ debuff |
| Merchant Special | 10% | ร้านค้าพิเศษ (item หายาก) |

---

### Treasure Events (25%)

| Event | เงื่อนไข | ผล |
|---|---|---|
| **กล่องสมบัติลับ** | — | Treasure Chest tier สุ่ม (common-epic) |
| **ถุงทอง** | — | Gold rand(100-500) × floor_depth_mult |
| **ซากนักเดินทาง** | — | item random 1-3 ชิ้น (Unidentified) |
| **สายน้ำศักดิ์สิทธิ์** | Thirst < 80 | Thirst เต็ม + HP Regen +3/turn (10 นาที) |
| **ต้นไม้มหัศจรรย์** | — | Magic Flower ×2-4 + Rare Herb ×1 |
| **แร่ซ่อนเร้น** | มี Pickaxe | Ore ×5-10 (tier ตาม Band) |
| **ตราสัญลักษณ์โบราณ** | — | Divinity EXP +10 |

---

### Encounter Events (30%)

| Event | เงื่อนไข | ผล |
|---|---|---|
| **กองโจรแห่งมิติ** | — | ต่อสู้กับ 3 enemy Trickster — ชนะได้ Gold ×2 ปกติ |
| **สัตว์ร้ายที่บาดเจ็บ** | — | เลือก [ช่วย] หรือ [สังหาร]<br>ช่วย → healing item + friend buff<br>สังหาร → item drop ปกติ |
| **นักเดินทางหลงทาง** | — | NPC ขอความช่วยเหลือ → [ช่วย] Gold -50, ได้ rare item หรือ[ปฏิเสธ] ไม่มีผล |
| **罠 กับดักลับ** | — | trigger trap อัตโนมัติ: HP -15%, เสีย Gold rand(1-5)% |
| **การเผชิญหน้าในความมืด** | กลางคืน | enemy Aggressive ×1 หรือ ×2 ตัว — drop bonus ×1.5 |
| **ราชาหมอก** | weather=fog | rare enemy (Trickster) ×1 ตัว — capture ได้ |
| **นักล่าผี** | Band ≥ 3 | ต่อสู้กับ spirit enemy — drop Magic item |

---

### Shrine / Blessing Events (20%)

| Event | ผล |
|---|---|
| **ศาลเทพารักษ์** | buff สุ่ม 1 ใน 3: ATK +10% / DEF +10% / SPD +10 — นาน 30 นาที |
| **ตราเทพ Band 1** | FIRE_DMG +15% หรือ ICE_DMG +15% หรือ LIGHTNING_DMG +15% — ตาม Band Pantheon — 60 นาที |
| **บ่อน้ำพิเศษ** | HP เต็ม + Thirst เต็ม |
| **สถานที่ศักดิ์สิทธิ์** | Divinity EXP +20 |
| **รูปสลักโบราณ** | สุ่ม skill node ที่ยัง lock: ได้ hint ว่า node นั้น stat อะไร (ไม่ปลดล็อก แค่ preview) |
| **ไฟนิรันดร์** | HP Regen +5/turn + Energy Regen +2/turn — 20 นาที |
| **เสียงกระซิบแห่งเทพ** | ได้ Crafting recipe ที่ยังไม่มี (สุ่มจาก recipe ที่ยัง lock ตาม skill level) |
| **ดาวตก** | Gem +5-15 |

---

### Curse / Trap Events (15%)

| Event | ผล | หลีกเลี่ยงได้ไหม |
|---|---|---|
| **กับดักหีบ Mimic** | เปิดหีบ → เป็น monster (Trickster ×1) ซุ่มโจมตี | ❌ ต้องต่อสู้ |
| **คำสาปของนักเดินทาง** | random debuff 1 ชิ้น: SPD -10 / CRIT_RATE -5% / HP_REGEN 0 — 30 นาที | ❌ |
| **หลุมกับดัก** | HP -20%, inventory สุ่ม item หล่น 1 ชิ้นบนพื้น | ❌ แต่เก็บ item กลับได้ |
| **เขตสาป** | ออกไม่ได้ 30 วินาที → มี random encounter combat | ❌ |
| **วิญญาณขโมย** | Gold -rand(5-15)% ทันที | ❌ |
| **ก๊าซพิษ** | Poison 3 stacks ทันที (ลด HP/turn 5 turns) | ❌ มี Antidote ในกระเป๋า → ลด 1 stack |
| **แสงลวงตา** | World Map ซ่อน mystery camp ถัดไปใน floor — ต้องเดินสำรวจหาเอง 10 นาที | ❌ |

---

### Merchant Special Events (10%)

| Event | สินค้า | ราคา |
|---|---|---|
| **พ่อค้าพเนจร** | item rare 1-3 ชิ้น (Identified) ราคาปกติ | ปกติ |
| **พ่อค้าลึกลับ** | item epic 1 ชิ้น (หมุนทุก floor) | ราคา ×1.5 |
| **พ่อค้าแลกเปลี่ยน** | แลก item common/uncommon ของผู้เล่น → item สุ่ม rarity สูงกว่า | — |
| **พ่อค้าความลับ** | Guarantee Stone tier สูง (rare/epic) | ราคา ×2 |
| **พ่อค้า Eternal** (Eternal Path เท่านั้น) | item ที่ player อื่นใน Eternal Marketplace วางขายไว้ | ราคา marketplace |

---

### Band-specific Events

#### Band 1 (Thai)
| Event | ผล |
|---|---|
| **ศาลพระภูมิ** | เลือก offer Gold 100 → ได้ blessing Band 1 (ATK หรือ DEF +10% 1 ชั่วโมง) |
| **พระเอก-นางเอกล่าสมบัติ** | NPC 2 คน ชวน party ชั่วคราว (+1 ally combat ×1 ครั้ง) |
| **ต้นโพธิ์ศักดิ์สิทธิ์** | ฝึกสมาธิ (กด confirm รอ 5 วิ) → Divinity EXP +15, Fatigue -30 |

#### Band 2 (Greek)
| Event | ผล |
|---|---|
| **วิหารโอลิมปัส** | roll d6: ได้ buff ตาม deity สุ่ม (Zeus=Lightning, Athena=DEF, Apollo=SPD) |
| **ลาบิรินธ์ขนาดย่อ** | mini maze 3×3 tile หา exit ใน 60 วิ → ได้ Gold 300, ล้มเหลว → HP -10% |
| **เทพทูต Hermes** | world energy +15 ทันที |

#### Band 3 (Norse)
| Event | ผล |
|---|---|
| **ต้น Yggdrasil กิ่งเล็ก** | HP เต็ม + HP_REGEN +3 (1 ชั่วโมง) |
| **ซากไวกิ้ง** | item uncommon ×2 + Gold 80 |
| **Valkyrie ปรากฏ** | ถ้า HP < 30% → ฟื้น 50% HP, ถ้า HP ≥ 30% → ATK +20% (20 นาที) |

#### Band 4 (Egyptian)
| Event | ผล |
|---|---|
| **Oasis** | HP/Thirst เต็ม + Thirst drain หยุด 30 นาที |
| **มัมมี่ตื่น** | combat กับ elite mummy — ถ้าชนะ: ได้ Egyptian item epic chance |
| **ปริศนา Sphinx** | ตอบปัญหา (True/False 3 ข้อ สุ่มจาก pool) ถูกทุกข้อ → Gold 500 |

#### Band 5 (Japanese)
| Event | ผล |
|---|---|
| **ศาลเจ้า Inari** | offer Rice ×3 → Fox blessing: CRIT +10%, SPD +10 (45 นาที) |
| **Tanuki พเนจร** | แลก Gold 200 → item สุ่ม (อาจดีมากหรือแย่มาก) |
| **จดหมายซามูไร** | ได้ Bushido scroll → passive: first strike ทุก combat วันนี้ |

#### Band 6 (Primordial)
| Event | ผล |
|---|---|
| **รอยแตกแห่งมิติ** | เลือก [เข้าไป] → combat กับ Void enemy ×2 — ชนะ: Primordial item / [หลีก] → ไม่มีผล |
| **ความทรงจำปฐมกาล** | Divinity EXP +50 ทันที |
| **ประตูที่ไม่มีชื่อ** | teleport ไปยัง random camp บน floor เดียวกัน (อาจดีหรือแย่) |

---

### Event Resolution Flow

```gdscript
# MysteryEventManager.gd
func enter_mystery_camp(camp_id: String) -> void:
    var category = weighted_random({
        "treasure": 25, "encounter": 30,
        "shrine":   20, "curse":     15, "merchant": 10
    })
    var event_pool = get_events_by_category(category, current_band, current_weather)
    var event = random_from(event_pool)

    # band-specific events เพิ่ม weight
    if event.band == current_band:
        event.weight *= 2.0

    _execute_event(event)
    AnalyticsManager.track("mystery_camp_entered", {
        "camp_id": camp_id, "category": category,
        "event_id": event.id, "band": current_band
    })

func _execute_event(event: MysteryEvent) -> void:
    match event.type:
        "treasure": _show_treasure_ui(event)
        "encounter": CombatManager.start_combat(event.enemies)
        "shrine":   _apply_blessing(event)
        "curse":    _apply_curse(event)
        "merchant": MerchantUI.open_special(event.stock)
```

---

### Schema (schema_world_v1.sql เพิ่ม)

```sql
CREATE TABLE mystery_events (
  id              TEXT PRIMARY KEY,
  name_th         TEXT NOT NULL,
  description_th  TEXT NOT NULL,
  category        TEXT NOT NULL,
    -- 'treasure'/'encounter'/'shrine'/'curse'/'merchant'
  band_specific   INTEGER,   -- null = ทุก Band, 1-6 = Band เฉพาะ
  weight          INTEGER NOT NULL DEFAULT 10,
  condition       JSONB,     -- {weather, time_of_day, player_hp_pct_max ฯลฯ}
  effect          JSONB NOT NULL,
  is_active       BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE player_mystery_log (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  player_id   UUID NOT NULL REFERENCES players(id) ON DELETE CASCADE,
  event_id    TEXT NOT NULL REFERENCES mystery_events(id),
  camp_id     UUID NOT NULL REFERENCES tower_camps(id),
  outcome     JSONB NOT NULL DEFAULT '{}',
  logged_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_mystery_log_player ON player_mystery_log (player_id, logged_at DESC);
```

---

## 64. Guild System (Phase 3)

> **Feature Flag:** `GUILD_ENABLED = false` — ปิดอยู่จนถึง Phase 3
> ออกแบบล่วงหน้าเพื่อวาง schema foundation ตั้งแต่ต้น

### Overview

Guild คือกลุ่มผู้เล่น (สูงสุด 30 คน) ที่ร่วมกันไต่หอ, แชร์ทรัพยากร, และแข่งขันกับ guild อื่น
เน้น **collective progress** ไม่ใช่แค่ social club

---

### Guild Creation & Management

```
สร้าง Guild: ต้องมี Divinity Level ≥ 3 + เสีย Gold 1,000
Guild Name: ตั้งชื่อเองได้ (ตรวจ filter คำหยาบ)
Guild Tag: 3-5 ตัวอักษร (แสดงข้าง portrait [TAG] สมชาย)
Max members: 30 คน
```

**Roles:**
| Role | สิทธิ์ |
|---|---|
| Guild Master | ทุกสิทธิ์, kick member, ยุบ guild |
| Officer | invite/kick member, จัดการ Guild Stash |
| Member | เข้าร่วม Guild Quest, ใช้ Guild Stash (อ่าน) |
| Recruit | ทำ Guild Quest ไม่ได้จนกว่าจะ promote |

---

### Guild Stash (คลังกลาง)

ที่เก็บ item/gold ร่วมกันของ guild:

```
Guild Stash: 4 tab × 20 slots = 80 slots
Gold Vault: สะสม gold ร่วมกัน
Permission: Guild Master และ Officer จัดการได้เต็ม, Member อ่านอย่างเดียว
Log: บันทึกทุก action (ใครเอาอะไรไป/เข้ามา)
```

---

### Guild Quest (รายสัปดาห์)

Guild Quest สุ่มทุกสัปดาห์จาก pool ร่วมกัน:

| Quest Type | ตัวอย่าง | Reward (Guild) |
|---|---|---|
| Kill collective | guild รวมกัน kill 500 ตัวภายใน 7 วัน | Guild EXP +200, Gold Vault +1,000 |
| Boss first kill | สมาชิกคนใดคนหนึ่ง kill boss ที่กำหนด | Guild EXP +500 |
| Craft collective | craft item รวม 50 ชิ้น | Gold Vault +500 |
| Ecosystem care | รักษา Thriving Ecosystem ≥ 3 floors | Guild EXP +300 |
| Floor depth | สมาชิกคนใดถึง Floor ที่กำหนด | Guild EXP +400 |

**Guild EXP → Guild Level (1-20):**
```
Guild Level ปลดล็อก:
  Level 5:   Guild Buff I (ATK +2% ทุก member ในเกม)
  Level 10:  Guild Stash tab เพิ่ม (+20 slots)
  Level 15:  Guild Buff II (DROP_RATE +5%)
  Level 20:  Guild Hall (special building ใน Band 1 Hub)
```

---

### Guild vs Guild — Guild Wars

```
เปิดใช้: Guild Master กด [ประกาศสงคราม] → target guild ยืนยัน
ระยะเวลา: 3 วัน
Victory condition: guild ที่ทำ "war score" สูงกว่าชนะ

War Score มาจาก:
  kill member ของ guild ศัตรูใน PvP zone (ถ้าเปิด PvP)
  หรือ kill boss ก่อน guild ศัตรู (PvE race mode)
  หรือ เก็บ resource ได้มากกว่าใน shared floor

ผล:
  ฝ่ายชนะ: Gold จาก war deposit ของ guild ที่แพ้ (10%)
  ฝ่ายแพ้: Gold deposit หาย 10%
```

> **Phase 3 Note:** PvP mechanics ยังไม่ออกแบบละเอียด — Guild War อาจเริ่มจาก PvE race mode ก่อน

---

### Guild Hall (Guild Level 20)

Building พิเศษใน Band 1 Hub ที่เป็น "บ้านของ guild":

```
Guild Hall ให้:
  - NPC Vendor พิเศษ (guild-exclusive item)
  - Guild Notice Board (quest, announcement)
  - Trophy Room (แสดง boss kill records ของ guild)
  - Guild Crafting Station (bonus yield +10%)
  - Decoration ที่ guild customise เองได้
```

---

### Schema (schema_social_v1.sql เพิ่ม — feature flag ปิด)

```sql
-- ทั้งหมดนี้สร้างแต่ยังไม่ใช้จนกว่า GUILD_ENABLED = true

CREATE TABLE guilds (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name          TEXT NOT NULL UNIQUE,
  tag           TEXT NOT NULL UNIQUE,  -- 3-5 chars
  master_id     UUID NOT NULL REFERENCES players(id),
  guild_level   INTEGER NOT NULL DEFAULT 1,
  guild_exp     INTEGER NOT NULL DEFAULT 0,
  gold_vault    INTEGER NOT NULL DEFAULT 0,
  description   TEXT,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  is_active     BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE guild_members (
  guild_id    UUID NOT NULL REFERENCES guilds(id) ON DELETE CASCADE,
  player_id   UUID NOT NULL REFERENCES players(id) ON DELETE CASCADE,
  role        TEXT NOT NULL DEFAULT 'recruit',
    -- 'master'/'officer'/'member'/'recruit'
  joined_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
  contribution_exp   INTEGER NOT NULL DEFAULT 0,
  contribution_gold  INTEGER NOT NULL DEFAULT 0,
  PRIMARY KEY (guild_id, player_id)
);

CREATE TABLE guild_stash_items (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  guild_id    UUID NOT NULL REFERENCES guilds(id) ON DELETE CASCADE,
  item_id     UUID NOT NULL REFERENCES player_items(id),
  tab_index   INTEGER NOT NULL DEFAULT 0,
  deposited_by UUID NOT NULL REFERENCES players(id),
  deposited_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE guild_stash_log (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  guild_id    UUID NOT NULL REFERENCES guilds(id) ON DELETE CASCADE,
  player_id   UUID NOT NULL REFERENCES players(id),
  action      TEXT NOT NULL,  -- 'deposit'/'withdraw'/'gold_deposit'/'gold_withdraw'
  item_id     UUID REFERENCES player_items(id),
  gold_amount INTEGER,
  logged_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE guild_quests (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  guild_id      UUID NOT NULL REFERENCES guilds(id) ON DELETE CASCADE,
  quest_type    TEXT NOT NULL,
  target_value  INTEGER NOT NULL,
  current_value INTEGER NOT NULL DEFAULT 0,
  reward_exp    INTEGER NOT NULL,
  reward_gold   INTEGER NOT NULL,
  week_start    DATE NOT NULL,
  completed_at  TIMESTAMPTZ
);

CREATE INDEX idx_guild_members_player ON guild_members (player_id);
CREATE INDEX idx_guild_quests_active  ON guild_quests (guild_id, week_start);
```

---

## 65. Daily/Weekly Leaderboard & Ladder Reset

### Overview

แยกเป็น 3 ระบบ leaderboard ที่ทำงานคู่กัน:

| ระบบ | Reset | ขอบเขต | ใช้สำหรับ |
|---|---|---|---|
| **Hall of Fame** (§23) | ไม่ reset ถาวร | per boss, per server | Server-first kill, best clear time, best score |
| **Daily Leaderboard** | รีเซ็ตทุกวัน 00:00 | per server | kills/day, gold/day, crafts/day |
| **Weekly Ladder** | รีเซ็ตทุกวันจันทร์ 00:00 | per server | weekly score สะสม, boss score |

---

### Daily Leaderboard

รีเซ็ตทุกวัน — แสดง Top 10 ต่อหมวด:

| หมวด | วัดจาก | รางวัล Top 3 |
|---|---|---|
| 🗡️ Most Kills | kill count วันนี้ | Gold 200/150/100 |
| 🪙 Gold Earned | gold income รวม (ขาย+chest+ถุงเงิน) | Gem 10/7/5 |
| 🍳 Master Chef | จำนวน food ที่ cook (quality ≥ Good) | Gem 5/3/2 |
| 🎣 Best Fisher | จำนวนปลาที่จับ × rarity weight | Gold 150/100/50 |
| ⚒️ Crafter | จำนวน item ที่ craft × tier weight | Gold 150/100/50 |

**รางวัล** จ่าย server time 00:05 (5 นาทีหลัง reset) ผ่าน notification

**ไม่มี rank ถาวร** — Daily เป็นแค่ fun competition ไม่กระทบ progression

---

### Weekly Ladder

รีเซ็ตทุกวันจันทร์ 00:00 — แสดง Top 20, มี rank badge ชั่วคราว:

#### Weekly Score Formula

```gdscript
func calc_weekly_score(player_id: String, week_start: Date) -> int:
    var kills     = get_kills_this_week(player_id)        # ×1 point/kill
    var boss_score = get_boss_scores_this_week(player_id) # ×10 point/boss score unit
    var craft_pts = get_crafts_this_week(player_id)       # ×2 point/craft (tier 2+)
    var explore   = get_new_camps_this_week(player_id)    # ×5 point/new camp cleared
    var divinity  = get_divinity_gained_this_week(player_id) # ×3 point/EXP

    return kills + boss_score * 10 + craft_pts * 2 + explore * 5 + divinity * 3
```

#### Weekly Rewards (จ่ายตอน reset วันจันทร์)

| Rank | Reward |
|---|---|
| 🥇 #1 | Gem 200 + badge "แชมป์สัปดาห์" (ชั่วคราว 7 วัน) |
| 🥈 #2 | Gem 150 |
| 🥉 #3 | Gem 100 |
| #4-10 | Gem 50 |
| #11-20 | Gem 20 |
| ทุกคนที่เล่น | Weekly Login Bonus +5 Gem (เล่น ≥ 3 วัน/สัปดาห์) |

**Badge "แชมป์สัปดาห์":** แสดงบน portrait เหมือน achievement badge — หายไปเองเมื่อสัปดาห์ใหม่เริ่ม

---

### Ladder Season (Monthly Reset)

ทุกต้นเดือน — reset Weekly Ladder ประจำเดือน พร้อม **Season Reward:**

```
Season = 1 เดือน (4-5 สัปดาห์)
Season Score = ผลรวม Weekly Score ทั้งเดือน

Season Reward:
  #1-3:   Legendary Guarantee Stone + Gem 300 + Season Badge (ถาวร)
  #4-10:  Epic Guarantee Stone + Gem 150
  #11-30: Gem 50
  ทุกคนที่เล่น ≥ 2 สัปดาห์: Season Participation Badge (ถาวร แต่ไม่ exclusive)
```

**Season Badge** บันทึกถาวรใน achievement แม้ไม่ใช่ Top 3 ก็ยังมีให้เก็บ

---

### Leaderboard UI

```
[Leaderboard]  ──────────────────────────────
[Daily] [Weekly] [Season] [Hall of Fame]

Weekly Ladder — สัปดาห์ที่ 3 (รีเซ็ต: จันทร์ 00:00 อีก 2 วัน 14 ชม.)

#   ชื่อ             Band  คะแนน    เปลี่ยน
1.  👑 สมชาย         B3    48,200   ▲+2
2.  🥈 มานี          B2    41,550   —
3.  🥉 วิชัย         B3    38,900   ▼-1
...
47. (คุณ) นภา        B1    12,400   ▲+5

[ดูอันดับของคุณ]  [History]
```

---

### Reset Flow (Server-side)

```sql
-- pg_cron: ทุกวัน 00:00 UTC
SELECT cron.schedule('daily_leaderboard_reset', '0 0 * * *', $$
    -- 1. คำนวณและจ่าย daily rewards
    WITH daily_winners AS (
        SELECT player_id, category, rank_pos, reward_gem, reward_gold
        FROM calc_daily_winners()  -- function คำนวณ rank
    )
    INSERT INTO player_reward_queue (player_id, gem, gold, source)
    SELECT player_id, reward_gem, reward_gold, 'daily_leaderboard'
    FROM daily_winners WHERE rank_pos <= 3;

    -- 2. Archive daily scores
    INSERT INTO leaderboard_history (type, period_start, scores)
    SELECT 'daily', CURRENT_DATE - 1, jsonb_agg(row_to_json(s))
    FROM daily_scores s;

    -- 3. Reset daily counters
    UPDATE player_daily_stats SET
        kills_today = 0,
        gold_today = 0,
        crafts_today = 0,
        fish_today = 0,
        reset_at = now();
$$);

-- pg_cron: ทุกวันจันทร์ 00:05 UTC (หลัง daily reset)
SELECT cron.schedule('weekly_ladder_reset', '5 0 * * 1', $$
    -- 1. คำนวณ weekly score + rank
    WITH weekly_rank AS (
        SELECT player_id,
               calc_weekly_score(player_id, DATE_TRUNC('week', now() - INTERVAL '1 week')) AS score,
               RANK() OVER (ORDER BY score DESC) AS rank_pos
        FROM players WHERE is_active = TRUE
    )
    -- 2. จ่าย rewards
    INSERT INTO player_reward_queue (player_id, gem, source)
    SELECT player_id,
        CASE WHEN rank_pos = 1 THEN 200
             WHEN rank_pos = 2 THEN 150
             WHEN rank_pos = 3 THEN 100
             WHEN rank_pos <= 10 THEN 50
             WHEN rank_pos <= 20 THEN 20
             ELSE 0 END,
        'weekly_ladder'
    FROM weekly_rank WHERE rank_pos <= 20;

    -- 3. Archive + reset
    INSERT INTO leaderboard_history (type, period_start, scores)
    SELECT 'weekly', DATE_TRUNC('week', now() - INTERVAL '1 week'),
           jsonb_agg(row_to_json(r)) FROM weekly_rank r;
$$);
```

---

### Schema (schema_social_v1.sql เพิ่ม)

```sql
CREATE TABLE player_daily_stats (
  player_id     UUID PRIMARY KEY REFERENCES players(id) ON DELETE CASCADE,
  kills_today   INTEGER NOT NULL DEFAULT 0,
  gold_today    INTEGER NOT NULL DEFAULT 0,
  crafts_today  INTEGER NOT NULL DEFAULT 0,
  fish_today    INTEGER NOT NULL DEFAULT 0,
  score_today   INTEGER NOT NULL DEFAULT 0,
  reset_at      DATE NOT NULL DEFAULT CURRENT_DATE
);

CREATE TABLE player_weekly_stats (
  player_id     UUID NOT NULL REFERENCES players(id) ON DELETE CASCADE,
  week_start    DATE NOT NULL,
  weekly_score  INTEGER NOT NULL DEFAULT 0,
  kills_week    INTEGER NOT NULL DEFAULT 0,
  boss_score    INTEGER NOT NULL DEFAULT 0,
  crafts_week   INTEGER NOT NULL DEFAULT 0,
  divinity_week INTEGER NOT NULL DEFAULT 0,
  PRIMARY KEY (player_id, week_start)
);

CREATE TABLE leaderboard_history (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  type         TEXT NOT NULL,  -- 'daily'/'weekly'/'season'
  period_start DATE NOT NULL,
  scores       JSONB NOT NULL,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE player_reward_queue (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  player_id  UUID NOT NULL REFERENCES players(id),
  gem        INTEGER NOT NULL DEFAULT 0,
  gold       INTEGER NOT NULL DEFAULT 0,
  source     TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  claimed_at TIMESTAMPTZ
);

CREATE INDEX idx_daily_stats    ON player_daily_stats (score_today DESC);
CREATE INDEX idx_weekly_stats   ON player_weekly_stats (week_start, weekly_score DESC);
CREATE INDEX idx_reward_queue   ON player_reward_queue (player_id, claimed_at) WHERE claimed_at IS NULL;
```

---

## 66. In-Game News & Patch Note System

### Overview

ผู้เล่นรับรู้ข้อมูลสำคัญโดยไม่ต้องออกจากเกม:
- **Patch Notes** — เมื่อ client update มี version ใหม่
- **Event Announcements** — seasonal event, double EXP weekend
- **Server News** — maintenance, server broadcast
- **Game Tips** — hint สำหรับผู้เล่นใหม่

---

### Entry Points

```
1. Main Menu → ปุ่ม [📰 ข่าวสาร] — แสดง badge จำนวนข่าวที่ยังไม่อ่าน
2. Login (ครั้งแรกของวัน) → popup อัตโนมัติถ้ามีข่าว unread
3. In-game HUD → bell icon มี dot แดงถ้ามีข่าวใหม่
4. Settings → About → Version + Patch Notes ทั้งหมด
```

---

### News Types & UI

```
[ข่าวสาร]  ─────────────────────────────
[ทั้งหมด] [อัปเดต] [อีเวนท์] [ทิป]   🔴3

📌 [สำคัญ] บำรุงรักษาระบบ
   วันศุกร์ 02:00-04:00 น. — server offline ชั่วคราว
   14 ม.ค. 2026 • ยังไม่อ่าน

🎉 [อีเวนท์] วันหยุดยาวพิเศษ!
   Divinity EXP ×2 ตลอดสัปดาห์นี้
   10 ม.ค. 2026 • อ่านแล้ว

📋 [อัปเดต] v1.2.3 — สิ่งที่เปลี่ยนแปลง
   ปรับสมดุล Boss Band 1, แก้ bug Fishing Rod
   8 ม.ค. 2026 • อ่านแล้ว

💡 [ทิป] รู้หรือไม่?
   ถุงเงินบนพื้นหายใน 5 นาที อย่าลืมเก็บ!
   ─────────────────────────────────────
```

---

### Patch Note Format

```markdown
# v1.2.3 — ปรับสมดุลและแก้ไขบั๊ก
_8 มกราคม 2026_

## 🔧 ปรับสมดุล
- Boss Band 1 (มหายักษ์ทรนง): Phase 3 HP regen ลดจาก 2% → 1% ต่อ turn
- Auto-hunt drop rate ปรับจาก ×0.60 → ×0.65

## 🐛 แก้ไขบั๊ก
- Fishing Rod Mythril: แก้ไขกรณี effective_power คำนวณผิดเมื่อ fishing skill < 10
- Food spoilage: แก้ไข timer ไม่นับขณะ offline ใน Ice Box

## ✨ ปรับปรุง UI
- Weekly Leaderboard: เพิ่มแสดงอันดับของตัวเองด้านล่าง Top 20
- Weather HUD: countdown แสดง real minutes แทน game hours
```

---

### Game Tips Pool

Tips แสดงแบบ rotating ใน Main Menu และ loading screen:

| หมวด | ตัวอย่าง Tip |
|---|---|
| Combat | "ถ้า SPD ต่ำกว่า enemy โจมตีพลาดได้ถึง 40% ลอง equip อาวุธที่ให้ SPD bonus" |
| Economy | "ถุงเงินบนพื้นหายใน 5 นาที ถ้าสังเกตเห็นอย่าเดินผ่าน!" |
| Survival | "Heat Wave ทำให้ Thirst หมดเร็ว ×2 พกน้ำ Flask ให้พอก่อนออกสำรวจ" |
| Crafting | "Food ที่ทำด้วย rare+ ingredient จะมี buff นานกว่าของ common ถึง 60%" |
| Progression | "camp clear ครั้งแรก ให้ Divinity EXP +2 — สำรวจให้ทั่วทุก floor" |
| Social | "เพื่อนใน party ทำ Need/Greed แทน Free-for-all ป้องกันปัญหา loot" |
| Defense | "Snare Trap + Watchtower ทำงานร่วมกันดีมาก — trap slow monster ให้ tower ยิงได้นานขึ้น" |
| Auto-Hunt | "Auto-hunt หยุดเองถ้า inventory เหลือ < 3 slots ล้าง inventory ก่อน AFK" |

---

### Backend — Supabase Table

```sql
CREATE TABLE game_news (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  news_type     TEXT NOT NULL,
    -- 'patch'/'event'/'maintenance'/'tip'/'announcement'
  title_th      TEXT NOT NULL,
  body_th       TEXT NOT NULL,   -- Markdown
  is_pinned     BOOLEAN NOT NULL DEFAULT FALSE,
  is_active     BOOLEAN NOT NULL DEFAULT TRUE,
  target_version TEXT,           -- null = ทุก version, '1.2.3' = เฉพาะ version นั้น
  published_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  expires_at    TIMESTAMPTZ      -- null = ไม่หมดอายุ
);

CREATE TABLE player_news_read (
  player_id  UUID NOT NULL REFERENCES players(id) ON DELETE CASCADE,
  news_id    UUID NOT NULL REFERENCES game_news(id) ON DELETE CASCADE,
  read_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (player_id, news_id)
);

CREATE INDEX idx_news_active ON game_news (is_active, published_at DESC)
    WHERE is_active = TRUE;

-- View: unread count per player
CREATE OR REPLACE FUNCTION get_unread_news_count(p_player_id UUID)
RETURNS INTEGER AS $$
    SELECT COUNT(*)::INTEGER
    FROM game_news n
    WHERE n.is_active = TRUE
      AND (n.expires_at IS NULL OR n.expires_at > now())
      AND NOT EXISTS (
          SELECT 1 FROM player_news_read r
          WHERE r.player_id = p_player_id AND r.news_id = n.id
      );
$$ LANGUAGE SQL;
```

---

### Godot Implementation

```gdscript
# NewsManager.gd (autoload)
var unread_count: int = 0

func refresh() -> void:
    var count = await SupabaseClient.rpc("get_unread_news_count",
        {"p_player_id": GameState.player_id})
    unread_count = count
    HUDManager.update_news_badge(unread_count)

func fetch_news(limit: int = 20) -> Array:
    return await SupabaseClient.from("game_news") \
        .select("*") \
        .eq("is_active", true) \
        .order("is_pinned", ascending: false) \
        .order("published_at", ascending: false) \
        .limit(limit) \
        .execute()

func mark_read(news_id: String) -> void:
    await SupabaseClient.from("player_news_read") \
        .insert({"player_id": GameState.player_id, "news_id": news_id}) \
        .execute()
    unread_count = max(0, unread_count - 1)
    HUDManager.update_news_badge(unread_count)
```

**Patch Note auto-popup:**
```gdscript
# ตรวจเมื่อ login:
var last_seen = GameState.last_seen_version  # เก็บใน local settings
var current   = ProjectSettings.get("application/config/version")
if last_seen != current:
    NewsPanel.open(filter: "patch")
    GameState.last_seen_version = current
    Settings.save()
```

---

*จบ GAME_DESIGN.md — ออกแบบครบทุกระบบแล้วทั้ง 66 sections พร้อม implement*

