extends Area3D

var damage: int = 0
var max_radius: float = 30.0 # Approximate hex grid extent
var expansion_speed: float = 15.0
var current_radius: float = 1.0

@onready var collision_shape = $CollisionShape3D
@onready var mesh_instance = $MeshInstance3D

func _ready():
	# Connect signal if not already connected via editor
	body_entered.connect(_on_body_entered)
	
	# Initial setup
	scale = Vector3(0.1, 1.0, 0.1)
	
	# Create a unique material for fading
	if mesh_instance and mesh_instance.mesh:
		# Ensure mesh is unique too to modify radius if needed, 
		# but scaling Area3D handles resizing.
		# Just duplicate material for fading
		var mat = mesh_instance.mesh.surface_get_material(0)
		if mat:
			mesh_instance.material_override = mat.duplicate()
		elif mesh_instance.mesh.material:
			mesh_instance.material_override = mesh_instance.mesh.material.duplicate()
			
func _process(delta):
	# Expansion
	if current_radius < max_radius:
		current_radius += expansion_speed * delta
		# Scale the whole Area3D to expand both visual and collider
		scale = Vector3(current_radius, 1.0, current_radius)
	else:
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
	if mat:
		var current_alpha = mat.albedo_color.a
		current_alpha -= delta * 2.0 # Fade speed
		mat.albedo_color.a = current_alpha
		if current_alpha <= 0:
			queue_free()
	else:
		queue_free()
