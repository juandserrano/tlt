extends Node3D

# Static fog cloud that blocks visibility and mouse clicks

@onready var fog_volume = $FogVolume
@onready var area = $Area3D

func _ready():
	# Set up the area to block clicks
	if area:
		# Make sure the area is on a layer that will block raycasts
		area.input_ray_pickable = true
		# Collision layer 2 so it doesn't interfere with enemies
		area.collision_layer = 2
		area.collision_mask = 0


func _on_ttl_timer_timeout() -> void:
	var tween = create_tween()
	var fogmat : FogMaterial = fog_volume.material
	tween.tween_property(fogmat, "density", 0, 2)
	await tween.finished
	queue_free()
