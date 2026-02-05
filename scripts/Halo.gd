extends Area3D

var damage: int = 0
var max_radius: float = 30.0 # Approximate hex grid extent
var fade_radius: float = 20.0
var expansion_speed: float = 15.0
var current_radius: float = 1.0

@onready var collision_shape = $CollisionShape3D
@onready var mesh_instance = $MeshInstance3D

func _ready():
	# Connect signal if not already connected via editor
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
	
	# Create a unique material for fading and radius control
	if mesh_instance and mesh_instance.mesh:
		var mat = mesh_instance.mesh.material
		if mat:
			mesh_instance.material_override = mat.duplicate()
	
	# Set Mesh to maximum size (so shader can draw up to max_radius)
	# PlaneMesh size is (2,2) -> radius 1 in model space.
	# We want model radius to be max_radius.
	mesh_instance.scale = Vector3(max_radius, 1.0, max_radius)
	
	# Initial collision size
	collision_shape.scale = Vector3(0.1, 1.0, 0.1)

func _process(delta):
	# Expansion
	if current_radius < max_radius:
		current_radius += expansion_speed * delta
		
		# Update Shader Radius (Normalized 0..1 relative to max_radius)
		# We subtract a bit to keep it inside the mesh bounds
		var normalized_radius = (current_radius / max_radius) * 0.9
		var normalized_thickness = 0.2 / max_radius # Thinner ring (was 0.5)
		
		# User wanted edge radius smaller (thinner), so small thickness
		
		var mat = mesh_instance.material_override
		if mat:
			mat.set_shader_parameter("radius", normalized_radius)
			mat.set_shader_parameter("thickness", normalized_thickness)
			
		# Update Collision (Scale to fit)
		collision_shape.scale = Vector3(current_radius, 1.0, current_radius)
		
	if current_radius > fade_radius:
		# Fade out and destroy
		_fade_and_destroy(delta)

func _on_body_entered(body):
	if body is Enemy:
		# Check if we haven't hit this enemy yet? 
		# Area3D body_entered implies we just touched it.
		# Since the ring expands, we touch new things.
		# However, if an enemy moves INTO the ring, they get hit.
		# We essentially want to damage anything that touches the ring.
		if body.has_method("take_damage"):
			body.take_damage(damage)
			print("Halo hit enemy: ", body.name)

func _fade_and_destroy(delta):
	var mat = mesh_instance.material_override
	if mat is ShaderMaterial:
		var current_dissolve = mat.get_shader_parameter("dissolve")
		current_dissolve += delta * 1.5 # Fade speed
		mat.set_shader_parameter("dissolve", current_dissolve)
		
		if current_dissolve >= 1.0:
			queue_free()
	else:
		# Fallback
		queue_free()
