extends Area3D

var target: Node3D # Can be Enemy
var damage: int
var speed: float = 25.0

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
			target.take_damage(damage)
		queue_free()
		return

	global_position += direction * speed * delta
