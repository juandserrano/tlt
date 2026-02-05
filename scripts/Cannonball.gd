extends Area3D

var target: Node3D # Can be Enemy
var target_pos: Vector3
var damage: int
var speed: float = 15.0

var final_target_pos: Vector3

func _process(delta: float) -> void:
	final_target_pos = target_pos
	
	if is_instance_valid(target):
		final_target_pos = target.global_position
		final_target_pos.y += 0.5
	
	var direction = (final_target_pos - global_position).normalized()
	var distance = global_position.distance_to(final_target_pos)
	
	# If close to target
	if distance < 0.5:
		_explode_and_damage()
		queue_free()
		return

	global_position += direction * speed * delta

func _explode_and_damage():
	var particle_manager = get_node("/root/Game/ParticleManager")
	if particle_manager:
		particle_manager.spawn_explosion(final_target_pos)

	# Direct hit (backup)
	if is_instance_valid(target) and target.has_method("take_damage"):
		target.take_damage(damage)
	
	# AoE Damage
	var hex_grid = get_node("/root/Game/World/HexGrid")
	var enemy_manager = get_node("/root/Game/EnemyManager")
	
	if not hex_grid or not enemy_manager:
		return

	var center_axial = hex_grid.world_to_axial(final_target_pos)
	
	# Determine affected tiles (Center + 6 Neighbors)
	var affected_tiles = [center_axial]
	var neighbors = [
		Vector2i(1, 0), Vector2i(1, -1), Vector2i(0, -1),
		Vector2i(-1, 0), Vector2i(-1, 1), Vector2i(0, 1)
	]
	for n in neighbors:
		affected_tiles.append(center_axial + n)
	
	# Apply damage to enemies on these tiles
	# Copy list to safe iterate if they die? enemy_manager should handle safe removal
	for enemy in enemy_manager.enemies_in_play:
		if is_instance_valid(enemy) and enemy.current_tile in affected_tiles:
			enemy.take_damage(damage)
