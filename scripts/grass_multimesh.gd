class_name GrassPatch extends MultiMeshInstance3D

@export var grass_count_per_hex: int = 2500
@export var hex_radius: float = 0.58

@export var hex_grid: HexGrid

# Track which grass instances belong to each tile
var grass_instances_by_tile: Dictionary = {} # Vector2i -> Array[int]
var original_transforms: Dictionary = {} # int -> Transform3D

func _ready() -> void:
	generate_grass()

func generate_grass():
	var total_instances = hex_grid.tiles.size() * grass_count_per_hex
	multimesh.instance_count = total_instances
	print(total_instances)
	
	var i = 0
	for hex_pos in hex_grid.tiles:
		# Get the tile coordinate for this hex position
		var tile_coord = hex_grid.world_to_axial(hex_pos)
		
		# Initialize array for this tile if not exists
		if not grass_instances_by_tile.has(tile_coord):
			grass_instances_by_tile[tile_coord] = []
		
		for n in grass_count_per_hex:
			var pos = _get_random_point_in_hex(hex_pos)
			var xform = Transform3D(Basis(), pos)
			# Random rotation and scale for natural look
			xform = xform.rotated_local(Vector3.UP, randf() * PI)
			xform = xform.scaled_local(Vector3(1, randf_range(0.8, 1.2), 1))
			
			multimesh.set_instance_transform(i, xform)
			original_transforms[i] = xform
			
			# Track this instance for this tile
			grass_instances_by_tile[tile_coord].append(i)
			i += 1

func _get_random_point_in_hex(center: Vector3) -> Vector3:
	while true:
		# 1. Get random point in the bounding box of the hex
		var x = randf_range(-hex_radius, hex_radius)
		var z = randf_range(-hex_radius, hex_radius)
		
		# 2. Reject points outside the hex boundaries
		# (Formula for a flat-topped hexagon)
		var q2x = abs(x)
		if q2x > hex_radius * 0.866:
			continue # sqrt(3)/2
		if 0.5 * q2x + 0.866 * abs(z) > hex_radius * 0.866:
			continue
		return center + Vector3(x, 0, z)
	return center

func hide_grass_on_tile(coord: Vector2i):
	if not grass_instances_by_tile.has(coord):
		return
	
	for instance_idx in grass_instances_by_tile[coord]:
		# Hide by scaling to zero
		var xform = multimesh.get_instance_transform(instance_idx)
		xform = xform.scaled_local(Vector3.ZERO)
		multimesh.set_instance_transform(instance_idx, xform)

func show_grass_on_tile(coord: Vector2i):
	if not grass_instances_by_tile.has(coord):
		return
	
	for instance_idx in grass_instances_by_tile[coord]:
		# Restore original transform
		if original_transforms.has(instance_idx):
			multimesh.set_instance_transform(instance_idx, original_transforms[instance_idx])
