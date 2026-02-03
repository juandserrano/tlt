class_name ParticleManager extends Node

const explosion_scene = preload("res://scenes/explosion.tscn")

func spawn_explosion(pos: Vector3):
	var explosion = explosion_scene.instantiate()
	add_child(explosion)
	explosion.global_position = pos
	var debris = explosion.get_node("Debris") as GPUParticles3D
	var sparks = explosion.get_node("Sparks") as GPUParticles3D
	debris.emitting = true
	sparks.emitting = true
	
	# Auto-cleanup when particles finish
	debris.finished.connect(explosion.queue_free)
