class_name Card extends Button

@export var angle_x_max: float = 15.0
@export var angle_y_max: float = 15.0
@export var max_offset_shadow: float = 50.0

# @export_category("Oscillator")
# @export var spring: float = 150.0
# @export var damp: float = 10.0
# @export var velocity_multiplier: float = 2.0

# var displacement: float = 0.0
# var oscillator_velocity: float = 0.0

var tween_rot: Tween
var tween_hover: Tween
var tween_destroy: Tween
var tween_float: Tween # For play selection animation
var tween_shake: Tween # For discard selection animation
# var tween_handle: Tween

var last_mouse_pos: Vector2
var mouse_velocity: Vector2
var is_selected: bool = false
var is_selected_for_discard: bool = false
var last_pos: Vector2
var velocity: Vector2
const selected_card_offset: Vector2 = Vector2(0, -20)

# Grid positioning
var base_position: Vector2 = Vector2.ZERO # Assigned grid position
var grid_slot_index: int = -1 # Which grid slot this card occupies

@onready var card_texture: TextureRect = $Texture
@onready var card_manager: Node = get_node("/root/Game/CardManager")
# @onready var shadow = $Shadow
# @onready var collision_shape = $DestroyArea/CollisionShape2D

func _ready() -> void:
	# Convert to radians because lerp_angle is using that
	angle_x_max = deg_to_rad(angle_x_max)
	angle_y_max = deg_to_rad(angle_y_max)
	# collision_shape.set_deferred("disabled", true)
	
	# Create a unique material instance for this card so shader changes don't affect other cards
	if card_texture.material:
		card_texture.material = card_texture.material.duplicate()

func _process(delta: float) -> void:
	# rotate_velocity(delta)
	# follow_mouse(delta)
	# handle_shadow(delta)
	pass
	
func destroy() -> void:
	print("destroying")
	card_texture.use_parent_material = true
	if tween_destroy and tween_destroy.is_running():
		tween_destroy.kill()
	tween_destroy = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween_destroy.tween_property(material, "shader_parameter/dissolve_value", 0.0, 1.0).from(1.0)
	tween_destroy.finished.connect(queue_free)

# func rotate_velocity(delta: float) -> void:
# 	if not following_mouse: return
# 	var center_pos: Vector2 = global_position - (size / 2.0)
# 	print("Pos: ", center_pos)
# 	print("Pos: ", last_pos)
# 	# Compute the velocity
# 	velocity = (position - last_pos) / delta
# 	last_pos = position
	
# 	print("Velocity: ", velocity)
# 	oscillator_velocity += velocity.normalized().x * velocity_multiplier
	
# 	# Oscillator stuff
# 	var force = - spring * displacement - damp * oscillator_velocity
# 	oscillator_velocity += force * delta
# 	displacement += oscillator_velocity * delta
	
# 	rotation = displacement

# func handle_shadow(delta: float) -> void:
# 	# Y position is enver changed.
# 	# Only x changes depending on how far we are from the center of the screen
# 	var center: Vector2 = get_viewport_rect().size / 2.0
# 	var distance: float = global_position.x - center.x
	
# 	# shadow.position.x = lerp(0.0, -sign(distance) * max_offset_shadow, abs(distance/(center.x)))

# func follow_mouse(delta: float) -> void:
# 	if not following_mouse: return
# 	var mouse_pos: Vector2 = get_global_mouse_position()
# 	global_position = mouse_pos - (size / 2.0)

func select_for_discard() -> void:
	if is_selected or is_selected_for_discard:
		return
	is_selected_for_discard = true
	position = base_position + selected_card_offset
	card_texture.material.set_shader_parameter("show_glow", true)
	card_texture.material.set_shader_parameter("is_discard_glow", true)
	
	# Start subtle shake animation
	start_shake_animation()

func select_for_play() -> void:
	if is_selected or is_selected_for_discard:
		return
	is_selected = true
	position = base_position + selected_card_offset
	card_texture.material.set_shader_parameter("show_glow", true)
	
	# Start slow float animation
	start_float_animation()

func deselect() -> void:
	if not is_selected and not is_selected_for_discard:
		return
	is_selected = false
	is_selected_for_discard = false
	
	# Stop animations
	stop_animations()
	
	position = base_position
	card_texture.material.set_shader_parameter("show_glow", false)
	card_texture.material.set_shader_parameter("is_discard_glow", false)

func deselect_for_discard() -> void:
	if not is_selected_for_discard:
		return
	is_selected = false
	is_selected_for_discard = false
	
	# Stop animations
	stop_animations()
	
	position = base_position
	card_texture.material.set_shader_parameter("show_glow", false)
	card_texture.material.set_shader_parameter("is_discard_glow", false)

# Start slow up/down float animation for play selection
func start_float_animation() -> void:
	if tween_float and tween_float.is_running():
		tween_float.kill()
	
	var float_offset = 5.0 # Pixels to float up and down
	var float_duration = 1.5 # Seconds for one complete cycle
	
	tween_float = create_tween().set_loops().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween_float.tween_property(self, "position:y", base_position.y + selected_card_offset.y - float_offset, float_duration / 2.0)
	tween_float.tween_property(self, "position:y", base_position.y + selected_card_offset.y + float_offset, float_duration / 2.0)

# Start subtle shake animation for discard selection
func start_shake_animation() -> void:
	if tween_shake and tween_shake.is_running():
		tween_shake.kill()
	
	var shake_amount = 1.0 # Pixels to shake left and right
	var shake_duration = 0.05 # Seconds for one shake
	
	tween_shake = create_tween().set_loops().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween_shake.tween_property(self, "position:x", base_position.x + shake_amount, shake_duration)
	tween_shake.tween_property(self, "position:x", base_position.x - shake_amount, shake_duration)
	tween_shake.tween_property(self, "position:x", base_position.x, shake_duration)

# Stop all selection animations
func stop_animations() -> void:
	if tween_float and tween_float.is_running():
		tween_float.kill()
	if tween_shake and tween_shake.is_running():
		tween_shake.kill()

func handle_left_mouse_click(event: InputEvent) -> void:
	if not event is InputEventMouseButton: return
	if event.button_index != MOUSE_BUTTON_LEFT: return
	
	if event.is_pressed():
		# Notify CardManager to handle selection (ensures only one card selected)
		card_manager.select_card_for_play(self)

func handle_right_mouse_click(event: InputEvent) -> void:
	if not event is InputEventMouseButton: return
	if event.button_index != MOUSE_BUTTON_RIGHT: return
	
	if event.is_pressed():
		# Notify CardManager to handle selection (ensures only one card selected)
		card_manager.select_card_for_discard(self)

func _gui_input(event: InputEvent) -> void:
	handle_left_mouse_click(event)
	handle_right_mouse_click(event)
	
	if not event is InputEventMouseMotion: return
	
	# Handles rotation
	# Get local mouse pos
	var mouse_pos: Vector2 = get_local_mouse_position()
	#print("Mouse: ", mouse_pos)
	#print("Card: ", position + size)
	# var diff: Vector2 = (position + size) - mouse_pos

	var lerp_val_x: float = remap(mouse_pos.x, 0.0, size.x, 0, 1)
	var lerp_val_y: float = remap(mouse_pos.y, 0.0, size.y, 0, 1)
	#print("Lerp val x: ", lerp_val_x)
	#print("lerp val y: ", lerp_val_y)

	var rot_x: float = rad_to_deg(lerp_angle(-angle_x_max, angle_x_max, lerp_val_x))
	var rot_y: float = rad_to_deg(lerp_angle(angle_y_max, -angle_y_max, lerp_val_y))
	#print("Rot x: ", rot_x)
	#print("Rot y: ", rot_y)
	
	card_texture.material.set_shader_parameter("x_rot", rot_y)
	card_texture.material.set_shader_parameter("y_rot", rot_x)

func _on_mouse_entered() -> void:
	if tween_hover and tween_hover.is_running():
		tween_hover.kill()
	tween_hover = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween_hover.tween_property(self, "scale", Vector2(1.05, 1.05), 0.5)

func _on_mouse_exited() -> void:
	# Reset rotation
	if tween_rot and tween_rot.is_running():
		tween_rot.kill()
	tween_rot = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK).set_parallel(true)
	tween_rot.tween_property(card_texture.material, "shader_parameter/x_rot", 0.0, 0.5)
	tween_rot.tween_property(card_texture.material, "shader_parameter/y_rot", 0.0, 0.5)
	
	# Reset scale
	if tween_hover and tween_hover.is_running():
		tween_hover.kill()
	tween_hover = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween_hover.tween_property(self, "scale", Vector2.ONE, 0.55)
