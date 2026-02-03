extends Node3D

var card_scene: PackedScene = preload("res://scenes/Card.tscn")

var cards_in_hand: Array[Card]

@export var card_x: float
@export var card_y: float
@export var card_z: float

var card_pos: Array[Vector3] = [Vector3(card_x, card_y - 1, -2 + card_z + 0.01),
Vector3(card_x - 0.5, card_y - 1, -2 + card_z + 0.03),
Vector3(card_x - 1, card_y - 1, -2 + card_z + 0.02),
Vector3(card_x + 0.5, card_y - 1, -2 + card_z),
Vector3(card_x + 1, card_y - 1, -2 + card_z - 0.01)]

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var i = 0
			for card in cards_in_hand:
				if card.is_mouse_over:
					card.toggle_select_card()
					if card.is_selected:
						card.position.y = -1 + 0.02
					else:
						card.position.y = card_pos[i].y
				i += 1
				print("click card")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var camera = get_viewport().get_camera_3d()
	if camera:
		for i in range(5):
			var card = card_scene.instantiate() as Card
			card.position = card_pos[i]
			cards_in_hand.append(card)
			camera.add_child(card)

	else:
		print("CardManager: Warning - Camera not found, card not positioned")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
