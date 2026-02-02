class_name EnemyManager extends Node

@export var player_tower: Player
@export var audio_stream_player: AudioStreamPlayer

var enemies_in_play: Array[Enemy]
var enemy_bag: Array[Enemy]
var enemies_container: Node3D # Container to hold all enemy scene instances
var enemy_scene: PackedScene = preload("res://scenes/enemy.tscn")
var pawn_mesh = preload("res://resources/models/enemies/pawn_mesh.tres")
var knight_mesh = preload("res://resources/models/enemies/knight_mesh.tres")
var bishop_mesh = preload("res://resources/models/enemies/bishop_mesh.tres")

const sound_falling_impact = preload("res://resources/sounds/falling_impact.wav")

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

func _on_enemy_died(enemy: Enemy):
	# Remove from EnemyManager's tracking array
	if enemies_in_play.has(enemy):
		enemies_in_play.erase(enemy)
		enemy.shrink_and_free_enemy()
	
func _process(_delta: float) -> void:
	if GameManager.state == GameManager.GameState.Spawning and Input.is_action_just_pressed("spawn_enemy"):
		spawn_round_wave(1)

func spawn_round_wave(round_number: int):
	var tween = create_tween()
	if round_number == 1:
		for i in range(3):
			tween.tween_callback(func():
				spawn_enemy_of_class(EnemyClass.values().pick_random())
			)
			tween.tween_interval(0.2)
	tween.tween_callback(func(): GameManager.state = GameManager.GameState.PlayerTurn)

func _on_enemy_hit_ground():
	audio_stream_player.stream = sound_falling_impact
	audio_stream_player.play()

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
	var spawn_pos = get_random_free_hex_at_distance(SPAWN_RADIUS)
	enemy.spawn_above_ground(spawn_pos.x, spawn_pos.y)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#Subscribe to signals
	Signals.enemy_died.connect(_on_enemy_died)
	Signals.enemy_hit_ground.connect(_on_enemy_hit_ground)

	# Create and add the container for enemy instances
	enemies_container = Node3D.new()
	enemies_container.name = "EnemiesContainer"
	add_child(enemies_container)

# Get a random hexagonal coordinate at exactly 'distance' tiles from origin (0, 0)
func get_random_free_hex_at_distance(distance: int) -> Vector2i:
	var possible_coords: Array[Vector2i] = []
	
	# Generate all hexes at exactly this distance
	for q in range(-distance, distance + 1):
		for r in range(-distance, distance + 1):
			# Calculate hex distance using axial coordinate formula
			var dist = (abs(q) + abs(r) + abs(q + r)) / 2
			if dist == distance and not is_tile_occupied(q, r):
				possible_coords.append(Vector2i(q, r))
	
	# Pick a random coordinate from the list
	if possible_coords.size() > 0:
		return possible_coords[randi() % possible_coords.size()]
	else:
		return Vector2i(0, 0) # Fallback (shouldn't happen for distance > 0)
	
func is_tile_occupied(q: int, r: int) -> bool:
	for enemy in enemies_in_play:
		if enemy.current_tile == Vector2i(q, r):
			return true
	return false

func enemies_move_or_attack():
	for enemy in enemies_in_play:
		#Check if enemy is at striking distance from player
		if hex_distance(enemy.current_tile, player_tower.current_tile) == 2:
			enemy.melee_attack_player()
			await get_tree().create_timer(0.1).timeout
			continue

		# Otherwise try to move
		var sorted_neighbors = get_neighbors_sorted_by_distance(enemy.current_tile, player_tower.current_tile)
		
		# Try each neighbor in order of closeness to target
		var moved = false
		for neighbor in sorted_neighbors:
			if not is_tile_occupied(neighbor.x, neighbor.y):
				enemy.move_to_tile(neighbor.x, neighbor.y)
				await get_tree().create_timer(0.1).timeout
				moved = true
				break
		
		# If no valid move found, enemy stays in place
		if not moved:
			pass # Enemy cannot move this turn

# Returns all neighboring tiles sorted by distance to target (closest first)
func get_neighbors_sorted_by_distance(from_tile: Vector2i, target_coord: Vector2i) -> Array[Vector2i]:
	# Define the 6 neighbors in axial coordinates for hexagonal grids
	var neighbors: Array[Vector2i] = [
		Vector2i(from_tile.x + 1, from_tile.y), # East
		Vector2i(from_tile.x - 1, from_tile.y), # West
		Vector2i(from_tile.x, from_tile.y + 1), # Southeast
		Vector2i(from_tile.x, from_tile.y - 1), # Northwest
		Vector2i(from_tile.x + 1, from_tile.y - 1), # Northeast
		Vector2i(from_tile.x - 1, from_tile.y + 1) # Southwest
	]
	
	# Create array of [neighbor, distance] pairs
	var neighbor_distances: Array = []
	for neighbor in neighbors:
		var distance = hex_distance(neighbor, target_coord)
		neighbor_distances.append({"tile": neighbor, "distance": distance})
	
	# Sort by distance (ascending)
	neighbor_distances.sort_custom(func(a, b): return a["distance"] < b["distance"])
	
	# Extract just the tiles in sorted order
	var sorted_neighbors: Array[Vector2i] = []
	for item in neighbor_distances:
		sorted_neighbors.append(item["tile"])
	
	return sorted_neighbors

# Calculate hexagonal distance between two axial coordinates
func hex_distance(a: Vector2i, b: Vector2i) -> int:
	return (abs(a.x - b.x) + abs(a.x + a.y - b.x - b.y) + abs(a.y - b.y)) / 2