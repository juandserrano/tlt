extends Camera3D

var camera_speed: float = 10
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_pressed("camera_forward"):
		position.z -= camera_speed * delta
	if Input.is_action_pressed("camera_backwards"):
		position.z += camera_speed * delta
	if Input.is_action_pressed("camera_left"):
		position.x -= camera_speed * delta
	if Input.is_action_pressed("camera_right"):
		position.x += camera_speed * delta
