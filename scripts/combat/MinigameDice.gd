extends RefCounted
class_name MinigameDice
## d20 dice minigame — used for Flee (optional) and Capture (required).
## All methods are static; no instance needed.

const FLEE_TABLE: Dictionary = {
	1: -0.25,  2: -0.15,  3: -0.15,  4: -0.08,  5: -0.08,
	6: -0.03,  7: -0.03,  8: -0.03,
	9:  0.00, 10:  0.00, 11:  0.00, 12:  0.00,
	13: 0.10, 14:  0.10, 15:  0.10,
	16: 0.20, 17:  0.20, 18:  0.20,
	19: 0.30, 20:  0.40,
}

const CAPTURE_TABLE: Dictionary = {
	1: -0.30,  2: -0.16,  3: -0.16,  4: -0.08,  5: -0.08,
	6: -0.04,  7: -0.04,  8: -0.04,
	9:  0.00, 10:  0.00, 11:  0.00, 12:  0.00,
	13: 0.12, 14:  0.12, 15:  0.12,
	16: 0.28, 17:  0.28, 18:  0.28,
	19: 0.38, 20:  0.50,
}

const FLEE_FLAVOUR: Dictionary = {
	1:  "หกล้มกลิ้งไปชนศัตรู!",
	2:  "มือสั่น — สะดุดตีนตัวเอง",
	3:  "มือสั่น — สะดุดตีนตัวเอง",
	4:  "ลังเลนิดหน่อย",
	5:  "ลังเลนิดหน่อย",
	6:  "พอใช้ได้...",
	7:  "พอใช้ได้...",
	8:  "พอใช้ได้...",
	9:  "ไม่ดีไม่เลว",
	10: "ไม่ดีไม่เลว",
	11: "ไม่ดีไม่เลว",
	12: "ไม่ดีไม่เลว",
	13: "ตัดสินใจฉับพลัน",
	14: "ตัดสินใจฉับพลัน",
	15: "ตัดสินใจฉับพลัน",
	16: "จังหวะดีมาก!",
	17: "จังหวะดีมาก!",
	18: "จังหวะดีมาก!",
	19: "สัมผัสของนักล่า!",
	20: "⭐ เทพช่วย!",
}

const CAPTURE_FLAVOUR: Dictionary = {
	1:  "กับดักระเบิด — มอนสเตอร์ตกใจหนี!",
	2:  "มือสั่น — กับดักหลุดมือ",
	3:  "มือสั่น — กับดักหลุดมือ",
	4:  "ลังเลนิดหน่อย",
	5:  "ลังเลนิดหน่อย",
	6:  "การจับไม่แม่นนัก",
	7:  "การจับไม่แม่นนัก",
	8:  "การจับไม่แม่นนัก",
	9:  "ไม่ดีไม่เลว",
	10: "ไม่ดีไม่เลว",
	11: "ไม่ดีไม่เลว",
	12: "ไม่ดีไม่เลว",
	13: "จังหวะการโยนดี",
	14: "จังหวะการโยนดี",
	15: "จังหวะการโยนดี",
	16: "มอนสเตอร์เหนื่อยล้า!",
	17: "มอนสเตอร์เหนื่อยล้า!",
	18: "มอนสเตอร์เหนื่อยล้า!",
	19: "สัมผัสของนักล่า!",
	20: "⭐ เทพช่วย! — ได้ไอเทมโบนัสด้วย!",
}


static func roll() -> int:
	return randi_range(1, 20)


static func get_flee_modifier(die_result: int) -> float:
	return float(FLEE_TABLE.get(die_result, 0.0))


static func get_capture_modifier(die_result: int) -> float:
	return float(CAPTURE_TABLE.get(die_result, 0.0))


static func get_flee_flavour(die_result: int) -> String:
	return FLEE_FLAVOUR.get(die_result, "")


static func get_capture_flavour(die_result: int) -> String:
	return CAPTURE_FLAVOUR.get(die_result, "")


## Returns true if dice roll is a critical fail (1).
static func is_critical_fail(die_result: int) -> bool:
	return die_result == 1


## Returns true if dice roll is a natural 20.
static func is_critical(die_result: int) -> bool:
	return die_result == 20


## Grade label for display.
static func get_grade(die_result: int) -> String:
	if   die_result == 1:            return "✗ Critical Fail!"
	elif die_result <= 5:            return "✗ Bad"
	elif die_result <= 8:            return "△ Below Avg"
	elif die_result <= 12:           return "— Average"
	elif die_result <= 15:           return "○ Good"
	elif die_result <= 18:           return "◎ Great!"
	elif die_result == 19:           return "★ Excellent!"
	else:                            return "⭐ Critical!"
