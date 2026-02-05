class_name ParticleManager extends Node

const explosion_scene = preload("res://scenes/explosion.tscn")
const explosion_small_scene = preload("res://scenes/explosion_small.tscn")

func spawn_explosion(pos: Vector3):
	_spawn(explosion_scene, pos)

func spawn_small_explosion(pos: Vector3):
	_spawn(explosion_small_scene, pos)

func _spawn(scene, pos: Vector3):
	var explosion = scene.instantiate()
	add_child(explosion)
	explosion.global_position = pos
	var debris = explosion.get_node("Debris") as GPUParticles3D
	var sparks = explosion.get_node("Sparks") as GPUParticles3D
	debris.emitting = true
	sparks.emitting = true
	
	# Auto-cleanup when particles finish
	debris.finished.connect(explosion.queue_free)
