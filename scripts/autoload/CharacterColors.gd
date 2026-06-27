extends Node
## Singleton — character palette presets and runtime palette texture builder.
## Source colors verified against actual pixel values in the sprite sheets.

# ---------------------------------------------------------------------------
# SOURCE COLORS — pixel-exact values from base_idle_strip9.png
# (verified with System.Drawing pixel scan, not derived)
# ---------------------------------------------------------------------------

# ผิวหนัง (BODY layer)
const SKIN_SHAD:    Color = Color(0.7843, 0.4980, 0.3569)  # #C87F5B  เงาผิว
const SKIN_MID:     Color = Color(0.9098, 0.6784, 0.4902)  # #E8AD7D  ผิวกลาง

# เอี้ยม / overalls (ชั้นนอก)
const OUTFIT_SHAD:  Color = Color(0.1412, 0.1686, 0.2588)  # #242B42  เงาเอี้ยม
const OUTFIT_MID:   Color = Color(0.2157, 0.2667, 0.3922)  # #374464  เอี้ยมกลาง
const OUTFIT_HIGH:  Color = Color(0.2196, 0.2706, 0.3961)  # #384565  ไฮไลท์เอี้ยม

# เสื้อตัวใน / shirt (ชั้นใน)
const OUTFIT2_SHAD: Color = Color(0.6471, 0.1216, 0.2000)  # #A51F33  เงาเสื้อ
const OUTFIT2_MID:  Color = Color(0.9137, 0.1961, 0.2706)  # #E93245  เสื้อกลาง
const OUTFIT2_HIGH: Color = Color(0.9804, 0.4431, 0.4784)  # #FA717A  ไฮไลท์เสื้อ

# ผม — pixel-exact จาก bowlhair_idle_strip9.png
const HAIR_DARK: Color = Color(0.247, 0.153, 0.192)    # #3f2731 เงา / ด้านข้าง
const HAIR_MID:  Color = Color(0.459, 0.235, 0.224)    # #753c39 สีหลัก / ด้านบน
const HAIR_HIGH: Color = Color(0.733, 0.427, 0.325)    # #bb6d53 แสงสะท้อน

# ---------------------------------------------------------------------------
# PRESETS — skin tone (3 shades: shadow / midtone / highlight)
# ---------------------------------------------------------------------------
const SKIN_PRESETS: Dictionary = {
	"light":  [Color("#c89070"), Color("#e8ad7d"), Color("#f5cfa0")],
	"medium": [Color("#a06840"), Color("#c07850"), Color("#daa070")],
	"tan":    [Color("#805030"), Color("#9c6840"), Color("#c09060")],
	"dark":   [Color("#583820"), Color("#784830"), Color("#9c6848")],
	"deep":   [Color("#30180a"), Color("#4a2818"), Color("#6c3c28")],
}

# ---------------------------------------------------------------------------
# PRESETS — outfit outer / เอี้ยม (3 shades)
# ---------------------------------------------------------------------------
const OUTFIT_PRESETS: Dictionary = {
	"navy":   [Color("#263040"), Color("#374464"), Color("#4e6080")],
	"brown":  [Color("#3a2818"), Color("#5a3c26"), Color("#7a5838")],
	"black":  [Color("#0e1018"), Color("#1e2030"), Color("#303248")],
	"white":  [Color("#909098"), Color("#b8bcc8"), Color("#dde0e8")],
	"green":  [Color("#1a3020"), Color("#2a4c30"), Color("#3c6840")],
	"red":    [Color("#501010"), Color("#742020"), Color("#9e4040")],
	"purple": [Color("#2a1838"), Color("#40285a"), Color("#583e78")],
	"grey":   [Color("#303038"), Color("#484858"), Color("#606070")],
}

# ---------------------------------------------------------------------------
# PRESETS — outfit inner / เสื้อตัวใน (3 shades)
# ---------------------------------------------------------------------------
const OUTFIT2_PRESETS: Dictionary = {
	"red":    [Color("#a81830"), Color("#e93245"), Color("#f07070")],
	"white":  [Color("#989898"), Color("#c8c8c8"), Color("#ebebeb")],
	"blue":   [Color("#1a3060"), Color("#2a4a90"), Color("#4a70c0")],
	"black":  [Color("#0a0a0a"), Color("#1a1a1a"), Color("#303030")],
	"yellow": [Color("#806010"), Color("#b88c20"), Color("#dab840")],
	"green":  [Color("#104820"), Color("#186830"), Color("#2a9048")],
	"purple": [Color("#381060"), Color("#5a1c90"), Color("#7c30b8")],
	"pink":   [Color("#903060"), Color("#c84880"), Color("#e870a0")],
}

# ---------------------------------------------------------------------------
# PRESETS — hair color (สำหรับ hair layer sprites: bowlhair_*, curlyhair_*, ฯลฯ)
# 3 shades ต่อ option
# ---------------------------------------------------------------------------
const HAIR_PRESETS: Dictionary = {
	"black":   [Color("#0a0808"), Color("#1e1818"), Color("#382c28")],
	"brown":   [Color("#2a1a0e"), Color("#5c3420"), Color("#8a5030")],
	"auburn":  [Color("#3a1208"), Color("#6b2010"), Color("#9a3c1c")],
	"blonde":  [Color("#5c4818"), Color("#8c7030"), Color("#c0a048")],
	"grey":    [Color("#282828"), Color("#484848"), Color("#707070")],
	"white":   [Color("#686868"), Color("#909090"), Color("#c0c0c0")],
	"blue":    [Color("#0c1a30"), Color("#182848"), Color("#304888")],
	"gold":    [Color("#483000"), Color("#786010"), Color("#b89030")],
}

# Layer ที่ shader ใช้
enum Layer { BODY, HAIR }

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

## สร้าง ImageTexture 1×N จาก Array of Color — ใช้เป็น shader uniform
func build_texture(colors: Array) -> ImageTexture:
	var img := Image.create(colors.size(), 1, false, Image.FORMAT_RGBA8)
	for i in colors.size():
		img.set_pixel(i, 0, colors[i])
	return ImageTexture.create_from_image(img)


## ตั้ง shader uniforms บน ShaderMaterial ของ sprite layer ที่ระบุ
##
## BODY layer: src = 9 pixel-exact colors (3 per group: skin / outfit / shirt)
## HAIR layer: src = 3 pixel-exact hair colors
func apply_to_material(
		mat:         ShaderMaterial,
		skin_key:    String,
		outfit_key:  String,
		outfit2_key: String,
		hair_key:    String,
		layer:       Layer
) -> void:
	var src: Array
	var tgt: Array

	match layer:
		Layer.BODY:
			# ใช้ค่าสีจริงจากสไปรต์ (pixel-exact) — ไม่ derive จาก midtone
			src = [SKIN_SHAD,    SKIN_MID,    SKIN_MID,
			       OUTFIT_SHAD,  OUTFIT_MID,  OUTFIT_HIGH,
			       OUTFIT2_SHAD, OUTFIT2_MID, OUTFIT2_HIGH]
			tgt = (SKIN_PRESETS.get(skin_key,     SKIN_PRESETS["light"])
				 + OUTFIT_PRESETS.get(outfit_key,  OUTFIT_PRESETS["navy"])
				 + OUTFIT2_PRESETS.get(outfit2_key, OUTFIT2_PRESETS["red"]))

		Layer.HAIR:
			src = [HAIR_DARK, HAIR_MID, HAIR_HIGH]
			tgt = HAIR_PRESETS.get(hair_key, HAIR_PRESETS["brown"])

	mat.set_shader_parameter("source_palette", build_texture(src))
	mat.set_shader_parameter("target_palette", build_texture(tgt))
	mat.set_shader_parameter("palette_size",   src.size())


func get_shader() -> Shader:
	return load("res://assets/shaders/character_palette.gdshader")


func make_material() -> ShaderMaterial:
	var mat := ShaderMaterial.new()
	mat.shader = get_shader()
	return mat
