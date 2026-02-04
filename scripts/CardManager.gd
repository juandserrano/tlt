extends Node

var card_scene: PackedScene = preload("res://scenes/Card.tscn")

var cards_in_hand: Array[Card]
var currently_selected_card: Card = null


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

# Handle card selection - ensures only one card is selected at a time
func select_card(card: Card) -> void:
	# If clicking the same card, deselect it
	if currently_selected_card == card:
		card.deselect_card()
		currently_selected_card = null
		return
	
	# Deselect the previously selected card
	if currently_selected_card != null:
		currently_selected_card.deselect_card()
	
	# Select the new card
	card.select_card()
	currently_selected_card = card
