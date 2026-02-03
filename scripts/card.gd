class_name Card extends Area2D

var is_mouse_over: bool = false
var is_selected: bool = false
var base_position: Vector2
var hover_position: Vector2
var selected_position: Vector2
var rot: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	base_position = position
	hover_position = base_position + Vector2(0, -10)
	selected_position = base_position + Vector2(0, -30)
	rot = deg_to_rad(10)
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_area_3d_mouse_entered() -> void:
	is_mouse_over = true
	if is_selected:
		position = selected_position
	else:
		position = hover_position

func _on_area_3d_mouse_exited() -> void:
	is_mouse_over = false
	position = base_position
	if is_selected:
		position = selected_position

func toggle_select_card():
	is_selected = !is_selected
	if is_selected:
		position = selected_position
		rotation = rot
	elif is_mouse_over:
		position = hover_position
		rotation = 0
	else:
		position = base_position
		rotation = 0

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				if is_mouse_over:
					toggle_select_card()
					if is_selected:
						print("click card")
	
	if event is InputEventKey:
		if event.keycode == KEY_P and event.pressed and is_selected:
			var tween = create_tween()
			tween.tween_property(self, "global_position", Vector2(-10, -10), 1)
