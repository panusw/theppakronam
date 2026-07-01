extends Node
## Singleton — character palette presets + mask-based color swap.
## Shader: character_mask.gdshader
## Mask format — body sprites: R=skin  G=outfit  B=shirt
##               hair sprites: R=hair  G=shirt-boundary  B=outfit-boundary

# ---------------------------------------------------------------------------
# PRESETS — skin tone  [shadow, midtone, highlight]
# ---------------------------------------------------------------------------
const SKIN_PRESETS: Dictionary = {
	"light":  [Color("#c89070"), Color("#e8ad7d"), Color("#f5cfa0")],
	"medium": [Color("#a06840"), Color("#c07850"), Color("#daa070")],
	"tan":    [Color("#805030"), Color("#9c6840"), Color("#c09060")],
	"dark":   [Color("#583820"), Color("#784830"), Color("#9c6848")],
	"deep":   [Color("#30180a"), Color("#4a2818"), Color("#6c3c28")],
}

# ---------------------------------------------------------------------------
# PRESETS — outfit outer / เอี้ยม  [shadow, midtone, highlight]
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
# PRESETS — outfit inner / เสื้อตัวใน  [shadow, midtone, highlight]
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
# PRESETS — hair color  [shadow, midtone, highlight]
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

# ---------------------------------------------------------------------------
# Luminance ranges — ค่าความสว่างต่ำสุด/สูงสุดของแต่ละ region ในสไปรต์ต้นฉบับ
# (คำนวณจาก pixel scan ของ Sunnyside World sprites)
# ---------------------------------------------------------------------------
const BODY_LUM1_MIN := 0.507  # skin  (#BB6D53 / #C87F5B darkest)
const BODY_LUM1_MAX := 0.726  # skin  (#E8AD7D lightest)
const BODY_LUM2_MIN := 0.171  # outfit (#242B42 darkest)
const BODY_LUM2_MAX := 0.270  # outfit (#384565 lightest)
const BODY_LUM3_MIN := 0.24   # shirt  (#a81830 darkest — lum ≈ 0.273; 0.24 gives headroom)
const BODY_LUM3_MAX := 0.62   # shirt  (#f07070 lightest — lum ≈ 0.589; 0.62 gives headroom)

const HAIR_LUM1_MIN := 0.186  # hair (#3F2731 darkest)
const HAIR_LUM1_MAX := 0.507  # hair (#BB6D53 lightest)

# ---------------------------------------------------------------------------
# Public API
# ---------------------------------------------------------------------------

## สร้าง ShaderMaterial สำหรับ body sprite (base / tools)
func make_body_material() -> ShaderMaterial:
	var mat := ShaderMaterial.new()
	mat.shader = _get_mask_shader()
	mat.set_shader_parameter("lum1_min", BODY_LUM1_MIN)
	mat.set_shader_parameter("lum1_max", BODY_LUM1_MAX)
	mat.set_shader_parameter("lum2_min", BODY_LUM2_MIN)
	mat.set_shader_parameter("lum2_max", BODY_LUM2_MAX)
	mat.set_shader_parameter("lum3_min", BODY_LUM3_MIN)
	mat.set_shader_parameter("lum3_max", BODY_LUM3_MAX)
	return mat


## สร้าง ShaderMaterial สำหรับ hair sprite
func make_hair_material() -> ShaderMaterial:
	var mat := ShaderMaterial.new()
	mat.shader = _get_mask_shader()
	mat.set_shader_parameter("lum1_min", HAIR_LUM1_MIN)
	mat.set_shader_parameter("lum1_max", HAIR_LUM1_MAX)
	# boundary pixels ใน hair sprite: G=shirt, B=outfit (ใช้ range เดียวกันกับ body)
	mat.set_shader_parameter("lum2_min", BODY_LUM3_MIN)
	mat.set_shader_parameter("lum2_max", BODY_LUM3_MAX)
	mat.set_shader_parameter("lum3_min", BODY_LUM2_MIN)
	mat.set_shader_parameter("lum3_max", BODY_LUM2_MAX)
	return mat


## ตั้งสีบน body material — region1=skin  region2=outfit  region3=shirt
func apply_body_colors(
		mat:         ShaderMaterial,
		skin_key:    String,
		outfit_key:  String,
		outfit2_key: String
) -> void:
	var sk:  Array = SKIN_PRESETS.get(skin_key,       SKIN_PRESETS["light"])
	var ok:  Array = OUTFIT_PRESETS.get(outfit_key,   OUTFIT_PRESETS["navy"])
	var s2k: Array = OUTFIT2_PRESETS.get(outfit2_key, OUTFIT2_PRESETS["red"])
	mat.set_shader_parameter("color1_dark",  sk[0])
	mat.set_shader_parameter("color1_light", sk[2])
	mat.set_shader_parameter("color2_dark",  ok[0])
	mat.set_shader_parameter("color2_light", ok[2])
	mat.set_shader_parameter("color3_dark",  s2k[0])
	mat.set_shader_parameter("color3_light", s2k[2])


## ตั้งสีบน hair material — region1=hair  region2=shirt-boundary  region3=outfit-boundary
func apply_hair_colors(
		mat:         ShaderMaterial,
		hair_key:    String,
		outfit_key:  String,
		outfit2_key: String
) -> void:
	var hk:  Array = HAIR_PRESETS.get(hair_key,       HAIR_PRESETS["brown"])
	var ok:  Array = OUTFIT_PRESETS.get(outfit_key,   OUTFIT_PRESETS["navy"])
	var s2k: Array = OUTFIT2_PRESETS.get(outfit2_key, OUTFIT2_PRESETS["red"])
	mat.set_shader_parameter("color1_dark",  hk[0])
	mat.set_shader_parameter("color1_light", hk[2])
	mat.set_shader_parameter("color2_dark",  s2k[0])   # G channel = shirt boundary
	mat.set_shader_parameter("color2_light", s2k[2])
	mat.set_shader_parameter("color3_dark",  ok[0])    # B channel = outfit boundary
	mat.set_shader_parameter("color3_light", ok[2])


# ---------------------------------------------------------------------------
# Shirt-only material (hue-detection — no mask file needed)
# ---------------------------------------------------------------------------

## สร้าง ShaderMaterial สำหรับ body/tool sprite ที่ต้องการเปลี่ยนสีเสื้อ
func make_shirt_material() -> ShaderMaterial:
	var mat := ShaderMaterial.new()
	mat.shader = load("res://assets/shaders/shirt_color.gdshader")
	return mat


## ตั้งสีเสื้อตัวใน (outfit2) บน material
func apply_shirt_color(mat: ShaderMaterial, outfit2_key: String) -> void:
	var s2: Array = OUTFIT2_PRESETS.get(outfit2_key, OUTFIT2_PRESETS["red"])
	mat.set_shader_parameter("shirt_dark",  s2[0])
	mat.set_shader_parameter("shirt_light", s2[2])


# ---------------------------------------------------------------------------
# Private
# ---------------------------------------------------------------------------

func _get_mask_shader() -> Shader:
	return load("res://assets/shaders/character_mask.gdshader")
