เทพปกรณัม (Theppakronam) — Tower of Convergence
=================================================

PC RPG แนว survival-craft + gacha + ATB combat
ผู้เล่นรับบทเป็น "ผู้ท้าชิงนิรนาม" ไต่หอเทวภพ สุ่ม gacha รับ item/weapon/armor/skill node
ปลดล็อก passive skill tree จนกลายเป็นเทพ — มีระบบ gathering/farming/building/hunting/fishing เสริม


Stack
-----
Game engine : Godot 4.7 (GDScript)
Backend / DB : Supabase (PostgreSQL + REST API)
Art style    : 16-bit pixel art — Sunnyside World (danieldiggle)
Platform     : PC (Windows / Mac)


Core Systems
------------
- Gacha        : สุ่ม item/weapon/armor/skill node (ไม่มีตัวละคร), pity ทุก 50 pulls
- Skill Tree   : Graph-based 181 nodes, 5 tiers, ascension → Divinity level 0-10
- ATB Combat   : FF7-style, 2 energy types (World / Battle), party sync
- Tower Map    : Band → Floor → Camp, 6 Pantheons (thai/greek/norse/japanese/egyptian/primordial)
- Life Skills  : smithing, fishing, farming, hunting, cooking, crafting และอื่น ๆ
- Multiplayer  : Friend Session (ENet P2P) + Server List (dedicated)


Progression
-----------
- Band unlock  : server-wide เมื่อ boss first kill
- Boss Gate    : ต้องครบ 2 ใน 3 เงื่อนไข (camps cleared / mini-bosses / specific camps)
- Divinity     : สะสม EXP → level 0-10 → title "เทพปกรณัม" เมื่อ max
- Difficulty   : Normal / Hard / Ascendant / Eternal Path (hardcore one-life)


Asset Credits
-------------
Character & Environment sprites: Sunnyside World by danieldiggle
  https://danieldiggle.itch.io/sunnyside
  License: commercial OK — ห้าม resell หรือใช้เพื่อ AI training

Palette swap: character_palette.gdshader (3 layers: Body / Outfit / Hair)


Design Documents
----------------
GAME_DESIGN.md  — Game Design Document ฉบับสมบูรณ์ (§1-§66)
HANDOVER.md     — ประวัติการออกแบบและบริบทการพัฒนา
CLAUDE.md       — คำแนะนำสำหรับ AI assistant ที่ทำงานในโปรเจกต์นี้
sql/            — Supabase schema files (reference)


Contact
-------
panus.w@gmail.com
