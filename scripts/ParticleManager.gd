class_name ParticleManager extends Node

const explosion_scene = preload("res://scenes/explosion.tscn")

func spawn_explosion(pos: Vector3):
	var explosion = explosion_scene.instantiate() as GPUParticles3D
	add_child(explosion)
	explosion.global_position = pos
	explosion.emitting = true
	
	# Auto-cleanup when particles finish
	explosion.finished.connect(explosion.queue_free)
