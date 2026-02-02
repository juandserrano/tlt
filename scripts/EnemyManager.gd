extends Node

var enemies_in_play: Array[Enemy]
var enemy_bag: Array[Enemy]
var enemies_container: Node3D # Container to hold all enemy scene instances
var enemy_scene: PackedScene = preload("res://scenes/enemy.tscn")
var pawn_mesh = preload("res://resources/models/enemies/pawn_mesh.tres")
var knight_mesh = preload("res://resources/models/enemies/knight_mesh.tres")
var bishop_mesh = preload("res://resources/models/enemies/bishop_mesh.tres")

const SPAWN_RADIUS: int = 10

enum EnemyClass {
	Pawn,
	Knight,
	Bishop,
	Queen,
	King
}

enum EnemyVariant {
	Standard,
	Volatile,
	Enraged,
	Armored
}

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("spawn_enemy"):
		spawn_round_wave(1)

func spawn_round_wave(round_number: int):
	spawn_enemy_of_class(EnemyClass.values().pick_random())
	pass


func spawn_enemy_of_class(enemy_class: EnemyClass) -> void:
	var enemy = enemy_scene.instantiate() as Enemy
	var mesh_instance = enemy.get_node("MeshInstance3D") as MeshInstance3D
	match enemy_class:
		EnemyClass.Pawn:
			mesh_instance.mesh = pawn_mesh
		EnemyClass.Knight:
			mesh_instance.mesh = knight_mesh
		EnemyClass.Bishop:
			mesh_instance.mesh = bishop_mesh
		_:
			mesh_instance.mesh = pawn_mesh
	
	enemies_container.add_child(enemy)
	enemies_in_play.append(enemy)
	var spawn_pos = get_random_hex_at_distance(SPAWN_RADIUS) 
	enemy.spawn_above_ground(spawn_pos.x, spawn_pos.y)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Create and add the container for enemy instances
	enemies_container = Node3D.new()
	enemies_container.name = "EnemiesContainer"
	add_child(enemies_container)

# Get a random hexagonal coordinate at exactly 'distance' tiles from origin (0, 0)
func get_random_hex_at_distance(distance: int) -> Vector2i:
	var possible_coords: Array[Vector2i] = []
	
	# Generate all hexes at exactly this distance
	for q in range(-distance, distance + 1):
		for r in range(-distance, distance + 1):
			# Calculate hex distance using axial coordinate formula
			var hex_distance = (abs(q) + abs(r) + abs(q + r)) / 2
			if hex_distance == distance:
				possible_coords.append(Vector2i(q, r))
	
	# Pick a random coordinate from the list
	if possible_coords.size() > 0:
		return possible_coords[randi() % possible_coords.size()]
	else:
		return Vector2i(0, 0)  # Fallback (shouldn't happen for distance > 0)