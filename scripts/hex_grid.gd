@tool
class_name HexGrid extends MultiMeshInstance3D

const DEFAULT_TILE_SIZE: float = 0.58

@export var grid_radius: int = 20:
	set(value):
		grid_radius = value
		if Engine.is_editor_hint(): # Only run in editor if we're actually in the editor
			setup_grid()
@export var noise_threshold: float = 0.2:
	set(value):
		noise_threshold = value
		if Engine.is_editor_hint(): # Only run in editor if we're actually in the editor
			setup_grid() # Adjust this to change green/brown balance
@export var noise_frequency: float = 0.05:
	set(value):
		noise_frequency = value
		if Engine.is_editor_hint(): # Only run in editor if we're actually in the editor
			setup_grid() # Adjust this to change green/brown balance
@export var grass_color: Color = Color(0, 0.4, 0, 1):
	set(value):
		grass_color = value
		if Engine.is_editor_hint(): # Only run in editor if we're actually in the editor
			setup_grid() # Adjust this to change green/brown balance
@export var dirt_color: Color = Color(0.1, 0.03, 0, 1):
	set(value):
		dirt_color = value
		if Engine.is_editor_hint(): # Only run in editor if we're actually in the editor
			setup_grid() # Adjust this to change green/brown balance
@export var pawn: Enemy
@export var grass_patch: GrassPatch

var noise = FastNoiseLite.new()

var tiles: Array[Vector3]

func _ready():
	# Configure Noise
	noise.seed = randi()
	noise.frequency = noise_frequency # Lower = larger "blobs" of color
	
	setup_grid()

func setup_grid():
	noise.frequency = noise_frequency # Lower = larger "blobs" of color
	var hex_count = 3 * grid_radius * (grid_radius + 1) + 1
	#multimesh.use_colors = true # Essential for per-instance coloring
	multimesh.instance_count = hex_count
	
	tile_indices.clear()
	var index = 0
	for q in range(-grid_radius, grid_radius + 1):
		var r1 = max(-grid_radius, -q - grid_radius)
		var r2 = min(grid_radius, -q + grid_radius)
		for r in range(r1, r2 + 1):
			# 1. Position
			var pos = axial_to_world(q, r)
			multimesh.set_instance_transform(index, Transform3D(Basis(), pos))
			
			# 2. Color based on Noise
			var val = noise.get_noise_2d(q, r)
			var color = dirt_color
			if val < noise_threshold:
				tiles.append(pos)
				color = grass_color
			multimesh.set_instance_color(index, color)
			
			tile_indices[Vector2i(q, r)] = index
			index += 1
	
	# Add single large water plane
	if not has_node("WaterPlane"):
		var water = water_plane_scene.instantiate()
		water.name = "WaterPlane"
		add_child(water)
		# Calculate approximate size to cover grid
		# Radius * TileSize * 2 roughly
		var size = grid_radius * DEFAULT_TILE_SIZE
		water.scale = Vector3(size, 1, size)
		water.position = Vector3(0, -0.25, 0) # Slightly below lowered tile level (-1.0 + 0.4 buffer?) NO, tile lowers by 1.0. Ground is 0. So lowered is -1. Water should be at -0.3 approx.

func axial_to_world(q: int, r: int) -> Vector3:
	var x = DEFAULT_TILE_SIZE * (sqrt(3.0) * q + sqrt(3.0) / 2.0 * r)
	var z = DEFAULT_TILE_SIZE * (3.0 / 2.0 * r)
	return Vector3(x, 0, z)

var tile_indices: Dictionary = {}
var highlighted_indices: Array[int] = []
var original_colors: Dictionary = {} # index: Color

func world_to_axial(pos: Vector3) -> Vector2i:
	var q = (sqrt(3.0) / 3.0 * pos.x - 1.0 / 3.0 * pos.z) / DEFAULT_TILE_SIZE
	var r = (2.0 / 3.0 * pos.z) / DEFAULT_TILE_SIZE
	return _hex_round(q, r)

func _hex_round(uq: float, ur: float) -> Vector2i:
	var us = - uq - ur
	
	var q = round(uq)
	var r = round(ur)
	var s = round(us)
	
	var q_diff = abs(q - uq)
	var r_diff = abs(r - ur)
	var s_diff = abs(s - us)
	
	if q_diff > r_diff and q_diff > s_diff:
		q = -r - s
	elif r_diff > s_diff:
		r = -q - s
	
	return Vector2i(int(q), int(r))

func highlight_tiles(center_coord: Vector2i):
	clear_highlights()
	
	var coords_to_highlight = [center_coord]
	# Add neighbors
	var neighbors = [
		Vector2i(1, 0), Vector2i(1, -1), Vector2i(0, -1),
		Vector2i(-1, 0), Vector2i(-1, 1), Vector2i(0, 1)
	]
	for n in neighbors:
		coords_to_highlight.append(center_coord + n)
	
	for coord in coords_to_highlight:
		if tile_indices.has(coord):
			var idx = tile_indices[coord]
			# Store original color if not already stored (to handle overlapping highlights if we ever have them)
			# But here we clear first, so it's simple.
			# Actually we need to recover the color from the multimesh if we don't store it globally.
			# But we can assume we only highlight once.
			
			if not original_colors.has(idx):
				original_colors[idx] = multimesh.get_instance_color(idx)
			
			multimesh.set_instance_color(idx, Color(1, 0.5, 0)) # Highlight color (Orange)
			highlighted_indices.append(idx)

func clear_highlights():
	for idx in highlighted_indices:
		if original_colors.has(idx):
			multimesh.set_instance_color(idx, original_colors[idx])
	highlighted_indices.clear()
	original_colors.clear()

func is_dirt(coord: Vector2i) -> bool:
	var val = noise.get_noise_2d(coord.x, coord.y)
	return val >= noise_threshold

func get_all_dirt_tiles() -> Array[Vector2i]:
	var dirt_tiles: Array[Vector2i] = []
	for tile_coord in tile_indices.keys():
		if is_dirt(tile_coord):
			dirt_tiles.append(tile_coord)
	return dirt_tiles

# --- MOAT FUNCTIONALITY ---
var moat_tiles: Dictionary = {} # tile_coord: bool
var water_plane_scene: PackedScene = preload("res://scenes/WaterPlane.tscn")

func set_tile_as_moat(coord: Vector2i, is_moat_tile: bool):
	if not tile_indices.has(coord): return
	
	var idx = tile_indices[coord]
	var current_y = multimesh.get_instance_transform(idx).origin.y
	
	if is_moat_tile:
		if moat_tiles.has(coord): return # Already a moat
		
		# Animate lowering
		animate_tile_y(idx, current_y, current_y - 0.7)
		moat_tiles[coord] = true
		
		# Hide grass on this tile
		if grass_patch:
			grass_patch.hide_grass_on_tile(coord)
		
	else:
		if not moat_tiles.has(coord): return # Not a moat
		
		# Animate raising
		animate_tile_y(idx, current_y, current_y + 0.7)
		moat_tiles.erase(coord)
		
		# Show grass on this tile
		if grass_patch:
			grass_patch.show_grass_on_tile(coord)

func animate_tile_y(instance_idx: int, start_y: float, end_y: float):
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_method(func(y): _set_tile_y(instance_idx, y), start_y, end_y, 0.5)

func _set_tile_y(instance_idx: int, y: float):
	var transf = multimesh.get_instance_transform(instance_idx)
	transf.origin.y = y
	multimesh.set_instance_transform(instance_idx, transf)


func is_moat(coord: Vector2i) -> bool:
	return moat_tiles.has(coord)
