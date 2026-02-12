extends Area3D

var target: Node3D # Can be Enemy
var damage: int
var speed: float = 25.0
@onready var enemy_manager: EnemyManager = $"/root/Game/EnemyManager"

func _process(delta: float) -> void:
	if not is_instance_valid(target):
		queue_free()
		return
	
	var target_pos = target.global_position
	# Aim for the center/body
	target_pos.y += 0.5
	
	var direction = (target_pos - global_position).normalized()
	var distance = global_position.distance_to(target_pos)
	
	# Look at the target
	look_at(target_pos)
	
	if distance < 0.5:
		if is_instance_valid(target) and target.has_method("take_damage"):
			var enemy: Enemy = target
			if enemy.enemy_class != EnemyManager.EnemyClass.Knight:
				enemy.take_damage(damage)
			else:
				if randf_range(0, 1) < enemy.evade_probability:
					enemy_manager.knight_evade(enemy)
				else:
					enemy.take_damage(damage)
		queue_free()
		return

	global_position += direction * speed * delta
