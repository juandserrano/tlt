@tool
extends MultiMeshInstance3D

@export var grid_radius: int = 20:
	set(value):
		grid_radius = value
		if Engine.is_editor_hint(): # Only run in editor if we're actually in the editor
			setup_grid()
@export var tile_size: float = 1.0:
	set(value):
		tile_size = value
		if Engine.is_editor_hint(): # Only run in editor if we're actually in the editor
			setup_grid()
@export var noise_threshold: float = 0.2:
	set(value):
		noise_threshold = value
		if Engine.is_editor_hint(): # Only run in editor if we're actually in the editor
			setup_grid() # Adjust this to change green/brown balance

var noise = FastNoiseLite.new()

func _ready():
	# Configure Noise
	noise.seed = randi()
	noise.frequency = 0.05 # Lower = larger "blobs" of color
	
	setup_grid()

func setup_grid():
	var hex_count = 3 * grid_radius * (grid_radius + 1) + 1
	#multimesh.use_colors = true # Essential for per-instance coloring
	multimesh.instance_count = hex_count
	
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
			var color = Color.FOREST_GREEN
			if val > noise_threshold:
				color = Color.SADDLE_BROWN
			multimesh.set_instance_color(index, color)
			
			index += 1

func axial_to_world(q, r):
	var x = tile_size * (sqrt(3.0) * q + sqrt(3.0)/2.0 * r)
	var z = tile_size * (3.0/2.0 * r)
	return Vector3(x, 0, z)
