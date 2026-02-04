extends Node

var card_scene: PackedScene = preload("res://scenes/Card.tscn")

var cards_in_hand: Array[Card]
var currently_selected_card: Card = null
var cards_for_discard: Array[Card]
var max_discards: int = 2


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("Execute Discard"):
		discard_cards()

func discard_cards():
	print(cards_for_discard)
	for i in range(len(cards_for_discard) - 1, -1, -1):
		cards_for_discard[i].destroy()
		print(cards_for_discard[i])
		cards_for_discard.remove_at(i)

# Handle card selection - ensures only one card is selected at a time
func select_card_for_play(card: Card) -> void:
	# Don't let play cards while discarding
	if len(cards_for_discard) > 0: return
	# If clicking the same card, deselect it
	if currently_selected_card == card:
		card.deselect()
		currently_selected_card = null
		return
	
	# Deselect the previously selected card
	if currently_selected_card != null:
		currently_selected_card.deselect()
	
	# Select the new card
	card.select_for_play()
	currently_selected_card = card

func select_card_for_discard(card: Card) -> void:
	# Don't let discard while playing cards
	if currently_selected_card != null: return
	
	# If clicking the same card, deselect it
	for c in cards_for_discard:
		if c == card:
			card.deselect_for_discard()
			cards_for_discard.erase(card)
			print(cards_for_discard)
			return
	
	# Only check max limit when trying to select a new card
	if len(cards_for_discard) > max_discards - 1: return
	
	# Select the new card
	card.select_for_discard()
	cards_for_discard.append(card)
	print(cards_for_discard)