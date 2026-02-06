class_name QTEGauge extends Control

signal qte_result(success: bool)

@onready var gauge_bg = $Background
@onready var zone = $Background/Zone
@onready var indicator = $Background/Indicator

var indicator_speed = 300.0
var indicator_direction = 1
var is_active = true

func _ready():
	# Randomize zone position
	var max_y = gauge_bg.size.y - zone.size.y
	zone.position.y = randf_range(0, max_y)
	
	# Randomize indicator start pos
	indicator.position.y = randf_range(0, gauge_bg.size.y - indicator.size.y)
	
	# Randomize direction
	if randf() > 0.5:
		indicator_direction = -1

func _process(delta):
	if not is_active: return
	
	indicator.position.y += indicator_speed * indicator_direction * delta
	
	var max_y = gauge_bg.size.y - indicator.size.y
	
	if indicator.position.y <= 0:
		indicator.position.y = 0
		indicator_direction = 1
	elif indicator.position.y >= max_y:
		indicator.position.y = max_y
		indicator_direction = -1

func check_success():
	is_active = false
	
	var indicator_center = indicator.position.y + (indicator.size.y / 2.0)
	var zone_top = zone.position.y
	var zone_bottom = zone.position.y + zone.size.y
	
	var success = false
	if indicator_center >= zone_top and indicator_center <= zone_bottom:
		success = true
		indicator.color = Color.GREEN
	else:
		indicator.color = Color.RED

	emit_signal("qte_result", success)
	
	# Fade out
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	await tween.finished
	queue_free()


func _input(event):
	if not is_active: return
	
	if event.is_action_pressed("ui_accept"): # Spacebar usually
		get_viewport().set_input_as_handled()
		check_success()
