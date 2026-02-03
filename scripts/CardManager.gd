extends Node3D

var card_scene: PackedScene = preload("res://scenes/Card.tscn")

var cards_in_hand: Array[Card]

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			for card in cards_in_hand:
				if card.is_mouse_over:
					print("click card")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var card = card_scene.instantiate() as Card
	cards_in_hand.append(card)
	add_child(card)
	card.position.y = 6
	print("CardManager: Card instantiated and added to PlayerHand UI")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
