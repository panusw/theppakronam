extends RefCounted
class_name EnemyCombatAI
## Stateless helper — picks enemy action based on archetype and phase.
## Returns an action dict consumed by ATBCombat.

const HEAVY_ENERGY_COST := 3


## Pick action for the given enemy targeting the given player.
## Returns a Dictionary describing the action.
static func pick_action(enemy: CombatEntity, player: CombatEntity) -> Dictionary:
	match enemy.archetype:
		"berserker":  return _berserker(enemy, player)
		"tactician":  return _tactician(enemy, player)
		"trickster":  return _trickster(enemy, player)
		"tank":       return _tank(enemy, player)
		"support":    return _support(enemy, player)
		_:            return _basic_attack(enemy, player)


static func _berserker(enemy: CombatEntity, player: CombatEntity) -> Dictionary:
	# Below 30% HP: always heavy attack if energy available
	if enemy.hp_pct() < 0.30 and enemy.current_energy >= HEAVY_ENERGY_COST:
		return _heavy_attack(enemy, player)
	# Otherwise 70% basic, 30% heavy
	if enemy.current_energy >= HEAVY_ENERGY_COST and randf() < 0.30:
		return _heavy_attack(enemy, player)
	return _basic_attack(enemy, player)


static func _tactician(enemy: CombatEntity, player: CombatEntity) -> Dictionary:
	# If player energy low → standard attack (player is already weakened)
	if player.is_exhausted():
		return _heavy_attack(enemy, player) if enemy.current_energy >= HEAVY_ENERGY_COST \
			else _basic_attack(enemy, player)
	# Default: mix
	if enemy.current_energy >= HEAVY_ENERGY_COST and randf() < 0.40:
		return _heavy_attack(enemy, player)
	return _basic_attack(enemy, player)


static func _trickster(enemy: CombatEntity, _player: CombatEntity) -> Dictionary:
	# High crit chance, basic attacks only but can hit twice (Phase 2+ feature)
	return _basic_attack(enemy, _player)


static func _tank(enemy: CombatEntity, player: CombatEntity) -> Dictionary:
	# Rarely heavy-attacks, high defense means it can absorb hits
	if enemy.current_energy >= HEAVY_ENERGY_COST and randf() < 0.15:
		return _heavy_attack(enemy, player)
	return _basic_attack(enemy, player)


static func _support(enemy: CombatEntity, player: CombatEntity) -> Dictionary:
	# For Phase 1: just basic attack (healer support logic in Phase 2)
	return _basic_attack(enemy, player)


# ---------------------------------------------------------------------------
# Action builders
# ---------------------------------------------------------------------------

static func _basic_attack(attacker: CombatEntity, target: CombatEntity) -> Dictionary:
	return {
		"type":     "attack",
		"attacker": attacker,
		"target":   target,
		"dmg_mult": 1.0,
		"energy_cost": 0,
	}


static func _heavy_attack(attacker: CombatEntity, target: CombatEntity) -> Dictionary:
	return {
		"type":     "heavy_attack",
		"attacker": attacker,
		"target":   target,
		"dmg_mult": 1.6,
		"energy_cost": HEAVY_ENERGY_COST,
	}
