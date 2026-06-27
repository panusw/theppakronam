extends Node
class_name ATBCombat
## FF7-style ATB combat manager.
## Handles turn queue, action resolution, win/lose/flee/capture logic.
## Add as a child node of the combat scene; wire signals to UI.

enum State { RUNNING, PLAYER_TURN, WIN, LOSE, FLED, ENDED }

const ATB_RATE := 2.0   # ATB units per second per 1 SPD (tune to taste)

var player:    CombatEntity
var enemies:   Array[CombatEntity] = []
var state:     State = State.RUNNING
var turn_count: int = 0

# Signals —————————————————————————————————————————————
## Emitted once when the player's ATB fills.
signal player_turn_ready
## Emitted after any unit acts.
signal action_resolved(actor: String, data: Dictionary)
## Emitted any time a CombatEntity's stats change (HP/energy/ATB).
signal entity_updated(entity: CombatEntity)
## Emitted when combat ends.
signal combat_ended(result: String, rewards: Dictionary)
# ——————————————————————————————————————————————————————


func _process(delta: float) -> void:
	if state != State.RUNNING:
		return
	_charge_atb(delta)
	_dispatch_ready_units()


# ---------------------------------------------------------------------------
# ATB charging
# ---------------------------------------------------------------------------

func _charge_atb(delta: float) -> void:
	for unit in _all_units():
		if not unit.is_alive():
			continue
		unit.atb = minf(100.0, unit.atb + unit.spd * delta * ATB_RATE)
	entity_updated.emit(player)  # update bars every frame
	for e in enemies:
		if e.is_alive():
			entity_updated.emit(e)


func _dispatch_ready_units() -> void:
	# Collect units at 100 ATB, sorted by SPD descending (faster acts first)
	var ready: Array = []
	for unit in _all_units():
		if unit.is_alive() and unit.atb >= 100.0:
			ready.append(unit)
	ready.sort_custom(func(a: CombatEntity, b: CombatEntity) -> bool:
		return a.spd > b.spd)

	for unit in ready:
		if state != State.RUNNING:
			return
		if not unit.is_alive():
			continue
		unit.atb = 0.0
		unit.tick_regen()
		turn_count += 1

		if unit == player:
			state = State.PLAYER_TURN
			_update_capture_visibility()
			player_turn_ready.emit()
			return
		else:
			_resolve_enemy_turn(unit)


# ---------------------------------------------------------------------------
# Enemy turn
# ---------------------------------------------------------------------------

func _resolve_enemy_turn(enemy: CombatEntity) -> void:
	var action := EnemyCombatAI.pick_action(enemy, player)
	var result := _apply_action(action)
	action_resolved.emit(enemy.name_th, result)
	entity_updated.emit(player)
	entity_updated.emit(enemy)
	if not player.is_alive():
		state = State.LOSE
		combat_ended.emit("lose", {})


# ---------------------------------------------------------------------------
# Player actions (called from CombatScene button handlers)
# ---------------------------------------------------------------------------

func execute_attack() -> void:
	if state != State.PLAYER_TURN:
		return
	var target := _first_alive_enemy()
	if target == null:
		_check_win()
		return

	var action := {"type": "attack", "attacker": player, "target": target,
				   "dmg_mult": 1.0, "energy_cost": 0}
	var result := _apply_action(action)
	action_resolved.emit("player", result)
	entity_updated.emit(player)
	entity_updated.emit(target)
	_finish_player_turn()


func execute_item(hot_hp_per_turn: int, hot_turns: int) -> void:
	if state != State.PLAYER_TURN:
		return
	player.add_hot(hot_hp_per_turn, hot_turns)
	var result := {"type": "item", "hp_per_turn": hot_hp_per_turn, "turns": hot_turns}
	action_resolved.emit("player", result)
	entity_updated.emit(player)
	_finish_player_turn()


func execute_flee(dice_roll: int = -1) -> void:
	if state != State.PLAYER_TURN:
		return
	if player.current_energy < 2:
		return  # not enough energy even to try

	var main_enemy  := _first_alive_enemy()
	var base_chance := 0.20
	var spd_bonus   := 0.0
	if main_enemy != null:
		spd_bonus = maxf(0.0,
			float(player.spd - main_enemy.spd) / 10.0 * 0.01)

	var flee_chance    := base_chance + spd_bonus
	var free_energy    := false
	var dice_modifier  := 0.0
	var result_data: Dictionary = {"type": "flee_attempt", "roll": dice_roll}

	if dice_roll >= 1:
		dice_modifier = MinigameDice.get_flee_modifier(dice_roll)
		result_data["dice_modifier"] = dice_modifier
		if MinigameDice.is_critical(dice_roll):
			free_energy = true

		# Critical fail: enemy immediately counter-attacks
		if MinigameDice.is_critical_fail(dice_roll) and main_enemy != null:
			var counter := {"type": "attack", "attacker": main_enemy,
							"target": player, "dmg_mult": 1.0, "energy_cost": 0}
			var cresult := _apply_action(counter)
			action_resolved.emit(main_enemy.name_th, cresult)
			entity_updated.emit(player)
			if not player.is_alive():
				state = State.LOSE
				combat_ended.emit("lose", {})
				return

	flee_chance = minf(1.0, flee_chance + dice_modifier)
	var success := randf() < flee_chance
	result_data["success"] = success

	if success:
		if not free_energy:
			player.spend_energy(2)
		state = State.FLED
		action_resolved.emit("player", result_data)
		entity_updated.emit(player)
		combat_ended.emit("fled", {})
	else:
		# Fail: deduct energy (up to 4, or all remaining if < 4)
		player.spend_energy(mini(4, player.current_energy))
		action_resolved.emit("player", result_data)
		entity_updated.emit(player)
		_finish_player_turn()


func execute_capture(item_rarity: String, dice_roll: int) -> void:
	if state != State.PLAYER_TURN:
		return
	var target := _first_alive_enemy()
	if target == null or not target.show_capture_btn():
		return
	if player.current_energy < 5:
		return

	player.spend_energy(5)

	const BASE_RATES := {
		"common": 0.20, "uncommon": 0.35, "rare": 0.50,
		"epic": 0.65, "legendary": 0.80
	}
	var base      := float(BASE_RATES.get(item_rarity, 0.20))
	var modifier  := MinigameDice.get_capture_modifier(dice_roll)
	var bonus_drop := MinigameDice.is_critical(dice_roll)

	var result_data := {"type": "capture_attempt", "roll": dice_roll,
						"modifier": modifier, "target": target.name_th}

	if MinigameDice.is_critical_fail(dice_roll):
		# Trap explodes — enemy flees
		result_data["success"] = false
		result_data["enemy_fled"] = true
		action_resolved.emit("player", result_data)
		entity_updated.emit(player)
		state = State.WIN
		combat_ended.emit("win", {"captured": false, "enemy_fled": true,
								   "items": [], "divinity_exp": 0})
		return

	var final_chance := clampf(base + modifier, 0.05, 0.95)
	var success      := randf() < final_chance
	result_data["final_chance"] = final_chance
	result_data["success"] = success

	action_resolved.emit("player", result_data)
	entity_updated.emit(player)

	if success:
		state = State.WIN
		var rewards := _generate_rewards(bonus_drop)
		rewards["captured"]      = true
		rewards["captured_name"] = target.name_th
		combat_ended.emit("win", rewards)
	else:
		# Capture failed — enemy survives but combat continues
		_finish_player_turn()


# ---------------------------------------------------------------------------
# Internal helpers
# ---------------------------------------------------------------------------

func _apply_action(action: Dictionary) -> Dictionary:
	var attacker: CombatEntity = action["attacker"]
	var target:   CombatEntity = action["target"]
	var dmg_mult: float        = float(action.get("dmg_mult", 1.0))
	var energy_cost: int       = int(action.get("energy_cost", 0))
	var action_type: String    = action.get("type", "attack")

	if energy_cost > 0:
		attacker.spend_energy(energy_cost)

	# Miss check (based on speed ratio)
	var miss_chance := 0.0
	if attacker == player:
		miss_chance = maxf(0.0,
			float(target.spd - player.spd) / maxf(1.0, float(target.spd)) * 0.4)
		miss_chance += player.miss_modifier()
	else:
		# Enemy miss based on player SPD advantage
		miss_chance = maxf(0.0,
			float(player.spd - attacker.spd) / maxf(1.0, float(player.spd)) * 0.4)
	miss_chance = minf(miss_chance, 0.90)

	if randf() < miss_chance:
		return {"type": action_type + "_miss", "miss": true,
				"hp_after": target.current_hp, "energy_after": attacker.current_energy}

	# Damage calc
	var raw    := int(float(attacker.atk + randi_range(-3, 3)) * dmg_mult)
	var is_crit := randf() < attacker.crit_rate
	if is_crit:
		raw = int(float(raw) * (1.0 + attacker.crit_dmg))

	var taken  := target.take_damage(raw, attacker.all_dmg)
	return {
		"type":         action_type,
		"damage":       taken,
		"is_crit":      is_crit,
		"miss":         false,
		"target_name":  target.name_th,
		"hp_after":     target.current_hp,
		"energy_after": attacker.current_energy,
	}


func _finish_player_turn() -> void:
	_check_win()
	if state == State.RUNNING or state == State.WIN:
		state = State.RUNNING   # let ATB resume


func _check_win() -> void:
	var all_dead := enemies.all(func(e: CombatEntity) -> bool: return not e.is_alive())
	if all_dead and not enemies.is_empty():
		state = State.WIN
		var rewards := _generate_rewards(false)
		combat_ended.emit("win", rewards)


func _generate_rewards(bonus_item: bool) -> Dictionary:
	var exp := 100 + turn_count * 5  # placeholder divinity EXP
	return {"items": [], "divinity_exp": exp, "bonus_item": bonus_item, "captured": false}


func _update_capture_visibility() -> void:
	var target := _first_alive_enemy()
	# CombatScene listens to entity_updated and checks show_capture_btn()
	if target != null:
		entity_updated.emit(target)


func _first_alive_enemy() -> CombatEntity:
	for e in enemies:
		if e.is_alive():
			return e
	return null


func _all_units() -> Array:
	var units: Array = [player]
	units.append_array(enemies)
	return units
