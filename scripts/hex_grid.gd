class_name HexGrid extends MultiMeshInstance3D

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

var noise = FastNoiseLite.new()

var tiles: Array[Vector3]

func _ready():
	# Configure Noise
	noise.seed = randi()
	noise.frequency = 0.1 # Lower = larger "blobs" of color
	
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
			var pos = Global.axial_to_world(q, r)
			multimesh.set_instance_transform(index, Transform3D(Basis(), pos))
			
			# 2. Color based on Noise
			var val = noise.get_noise_2d(q, r)
			var color = dirt_color
			if val < noise_threshold:
				tiles.append(pos)
				color = grass_color
			multimesh.set_instance_color(index, color)
			
			index += 1
