class_name Enemy
extends Node3D

const SPAWN_HEIGHT: int = 10

@onready var grid: HexGrid = $"/root/Game/World/HexGrid"

# Tile-based position tracking
var current_tile: Vector2i # Stores the axial coordinates (q, r)

# Click detection
var is_mouse_over: bool = false
var has_hit_ground: bool = false # Track if enemy has landed

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Set up input handling
	set_process_input(true)

func move_to_tile(q: int, r: int):
	# Update tile position
	current_tile = Vector2i(q, r)
	# Get world position for this tile
	var world_pos = grid.axial_to_world(q, r)
	
	# Animate to the new position
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "position", world_pos, 0.3)

	
func spawn_above_ground(q: int, r: int):
	# Set position without animation (for spawning)
	current_tile = Vector2i(q, r)
	position = grid.axial_to_world(q, r)
	position.y = SPAWN_HEIGHT
	fall_after_spawn()


func fall_after_spawn():
	var target_pos = Vector3(position.x, 0, position.z) # Keep X and Z, set Y to 0
	
	var total_duration = 0.5
	var impact_time = total_duration * 0.4 # Approximate first impact time
	
	# Create the bounce tween
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(self, "position", target_pos, total_duration)
	
	# Schedule the impact sound to play at first contact
	get_tree().create_timer(impact_time).timeout.connect(func():
		if not has_hit_ground:
			has_hit_ground = true
			Signals.enemy_hit_ground.emit()
	)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			if is_mouse_over:
				Signals.enemy_died.emit(self)

func shrink_and_free_enemy():
	# Shrink and delete
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector3(0.001, 0.001, 0.001), 0.2)
	tween.tween_callback(queue_free)

func _on_area_3d_mouse_entered() -> void:
	is_mouse_over = true

func _on_area_3d_mouse_exited() -> void:
	is_mouse_over = false

func melee_attack_player():
	Signals.enemy_attacked_player.emit(self, 1)
