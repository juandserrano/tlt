class_name Card extends Area3D

var is_mouse_over: bool = false
var is_selected: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Ensure the Area2D can receive mouse input
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_area_3d_mouse_entered() -> void:
	is_mouse_over = true
	print("entered")

func _on_area_3d_mouse_exited() -> void:
	is_mouse_over = false
	print("exited")

func toggle_select_card():
	is_selected = !is_selected