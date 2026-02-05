class_name CardManager extends Node

enum CardType {
	Pawn,
	Knight,
	Bishop,
	King,
	Queen,
	Halo,
	Moat,
	Cannonball,
	Landmines,
	Fog
}

var card_scene: PackedScene = preload("res://scenes/Card.tscn")

#########################################
########    DRAW DECK    ################
#########################################

#########################################
########    PLAYER HAND  ################
#########################################
var player_hand: Array[Card]
var cards_for_discard: Array[Card]
var max_discards: int = 2
var currently_selected_card: Card = null

# Grid positioning system
var card_container: Control = null
var grid_columns: int = 5
var card_spacing: Vector2 = Vector2(5, 0) # Horizontal spacing between cards
var grid_start_position: Vector2 = Vector2(0, 0) # Will be calculated based on container
var card_grid_slots: Array[Dictionary] = [] # {position: Vector2, card: Card, occupied: bool}
var camera: Camera3D = null # Reference to the main camera for raycasting

#########################################
########   DISCARD PILE  ################
#########################################
var discard_pile: Array[Card]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Get reference to the card container
	card_container = get_node("/root/Game/GameplayUI/GridContainer")
	
	# Get reference to the camera for raycasting
	camera = get_node("/root/Game/Camera3D")
	
	# Initialize the grid
	initialize_grid()
	
	# Position existing cards in the scene
	await get_tree().process_frame # Wait for cards to be ready
	# position_existing_cards()
	draw_cards_to_available_slots()


# Called every frame. 'delta' is the elapsed time since the previous frame.
	if Input.is_action_just_pressed("Draw"):
		draw_cards_to_available_slots()

var targeting_mode_card: Card = null
var targeting_input_cooldown: int = 0

func start_special_targeting(card: Card):
	targeting_mode_card = card
	targeting_input_cooldown = 10 # Prevent immediate firing from the same click
	# Could add visual cursor change here

func _process(delta: float) -> void:
	if targeting_input_cooldown > 0:
		targeting_input_cooldown -= 1

	if Input.is_action_just_pressed("Execute Discard"):
		discard_cards()
		
	if targeting_mode_card != null:
		if Input.is_action_just_pressed("spawn_enemy") and targeting_input_cooldown == 0: # Left click
			var ground_click_pos = get_ground_position_under_mouse()
			if ground_click_pos != null:
				targeting_mode_card.finish_special_attack(ground_click_pos)
				var hex_grid = get_node("/root/Game/World/HexGrid")
				if hex_grid: hex_grid.clear_highlights()
				destroy_card_after_use(targeting_mode_card)
				targeting_mode_card = null
		
		# Visualize targeting
		if targeting_mode_card != null:
			var ground_hover_pos = get_ground_position_under_mouse()
			if ground_hover_pos != null:
				var hex_grid = get_node("/root/Game/World/HexGrid")
				if hex_grid:
					var coord = hex_grid.world_to_axial(Vector3(ground_hover_pos.x, 0, ground_hover_pos.z))
					hex_grid.highlight_tiles(coord)
		
		# Cancel on right click?
		elif Input.is_action_just_pressed("Execute Discard"): # Right click usually context sensitive
			targeting_mode_card = null
			var hex_grid = get_node("/root/Game/World/HexGrid")
			hex_grid.clear_highlights()
			
	elif currently_selected_card != null:
		if Input.is_action_just_pressed("spawn_enemy"):
			var target_enemy = get_enemy_under_mouse()
			if target_enemy != null:
				currently_selected_card.attack_enemy(target_enemy)

	if Input.is_action_just_pressed("Draw"):
		draw_cards_to_available_slots()

func get_ground_position_under_mouse():
	if camera == null: return null
	var mouse_pos = get_viewport().get_mouse_position()
	var from = camera.project_ray_origin(mouse_pos)
	var dir = camera.project_ray_normal(mouse_pos)
	var ground_plane = Plane(Vector3.UP, 0)
	return ground_plane.intersects_ray(from, dir)

# Returns only the first (closest) enemy hit, or null if no enemy is hit
func get_enemy_under_mouse() -> Enemy:
	if camera == null:
		return null
	
	# Get the mouse position in viewport coordinates
	var mouse_pos = get_viewport().get_mouse_position()
	
	# Create a ray from the camera through the mouse position
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * 1000.0 # Ray length of 1000 units
	
	# Set up the raycast query
	var space_state = camera.get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.collide_with_areas = false # Only hit physics bodies
	query.collide_with_bodies = true
	
	# Perform the raycast
	var result = space_state.intersect_ray(query)
	
	# Check if we hit something and if it's an enemy
	if result.is_empty():
		return null
	
	var collider = result.get("collider")
	
	# Check if it's an Enemy or if its parent/ancestor is an Enemy
	# var current_node = collider
	# while current_node != null:
	if collider is Enemy:
		return collider
		# current_node = current_node.get_parent()
	
	return null

func draw_cards_to_available_slots():
	while true:
		var slot = get_next_available_slot()
		if slot < 0: return
		# For now pick random card
		var cType = CardType.values().pick_random()
		await draw_card_to_slot(cType, slot)

func draw_card_to_slot(card_type: CardType, slot: int):
	var card: Card = card_scene.instantiate()
	card.card_resource = get_card_resource(card_type)
	card_container.add_child(card)
	add_card_to_grid(card, slot)
	
	# Start card off-screen to the left and slightly up
	var start_offset = Vector2(-800, -100)
	card.position = card.base_position + start_offset
	
	# Animate card into position and wait for it to complete
	await card.animate_draw_to_position()

func get_card_resource(card_type: CardType) -> CardResource:
	match card_type:
		CardType.Pawn:
			return preload("res://resources/cards/attack_pawn.tres")
		CardType.Knight:
			return preload("res://resources/cards/attack_knight.tres")
		CardType.Bishop:
			return preload("res://resources/cards/attack_bishop.tres")
		CardType.Queen:
			return preload("res://resources/cards/attack_queen.tres")
		CardType.King:
			return preload("res://resources/cards/attack_king.tres")
		CardType.Fog:
			return preload("res://resources/cards/fog.tres")
		CardType.Halo:
			return preload("res://resources/cards/halo.tres")
		CardType.Moat:
			return preload("res://resources/cards/moat.tres")
		CardType.Cannonball:
			return preload("res://resources/cards/cannonball.tres")
		CardType.Landmines:
			return preload("res://resources/cards/landmines.tres")
		_:
			return null


# Initialize grid slots
func initialize_grid() -> void:
	card_grid_slots.clear()
	
	# Calculate starting position (centered in container)
	var card_size = Vector2(150, 214) # Approximate card size
	var total_width = (card_size.x * grid_columns) + (card_spacing.x * (grid_columns - 1))
	grid_start_position = Vector2((card_container.size.x - total_width) / 2.0, 0)
	
	# Create grid slots
	for i in range(grid_columns):
		var slot_position = grid_start_position + Vector2(i * (card_size.x + card_spacing.x), 0)
		card_grid_slots.append({
			"position": slot_position,
			"card": null,
			"occupied": false
		})

# Position existing cards that are already in the scene
func position_existing_cards() -> void:
	var children = card_container.get_children()
	for i in range(min(children.size(), card_grid_slots.size())):
		if children[i] is Card:
			add_card_to_grid(children[i], i)

# Get the next available grid slot index
func get_next_available_slot() -> int:
	for i in range(card_grid_slots.size()):
		if not card_grid_slots[i]["occupied"]:
			return i
	return -1

# Add a card to a specific grid slot
func add_card_to_grid(card: Card, slot_index: int = -1) -> void:
	if slot_index == -1:
		slot_index = get_next_available_slot()
	
	if slot_index == -1 or slot_index >= card_grid_slots.size():
		push_error("No available grid slot for card")
		return
	
	# Set card's grid slot
	card.grid_slot_index = slot_index
	card.base_position = card_grid_slots[slot_index]["position"]
	
	# Position the card
	card.position = card.base_position
	
	# Mark slot as occupied
	card_grid_slots[slot_index]["card"] = card
	card_grid_slots[slot_index]["occupied"] = true
	
	# Add to cards in hand if not already there
	if not player_hand.has(card):
		player_hand.append(card)

# Remove a card from the grid (keeps slot empty)
func remove_card_from_grid(card: Card) -> void:
	var slot_index = card.grid_slot_index
	if slot_index >= 0 and slot_index < card_grid_slots.size():
		card_grid_slots[slot_index]["card"] = null
		card_grid_slots[slot_index]["occupied"] = false
	
	player_hand.erase(card)

func destroy_card_after_use(card):
	remove_card_from_grid(card)
	currently_selected_card = null
	card.destroy()

# Position all cards in hand to their assigned grid slots
func position_cards() -> void:
	for card in player_hand:
		if card.grid_slot_index >= 0 and card.grid_slot_index < card_grid_slots.size():
			card.position = card.base_position

func discard_cards():
	print(cards_for_discard)
	for i in range(len(cards_for_discard) - 1, -1, -1):
		var card = cards_for_discard[i]
		discard_pile.append(card)
		remove_card_from_grid(card) # Remove from grid tracking
		card.destroy()
		cards_for_discard.remove_at(i)

# Handle card selection - ensures only one card is selected at a time
func select_card_for_play(card: Card) -> void:
	if card.card_resource.is_autoplay: return
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
	
	if card.card_type == CardType.Cannonball:
		start_special_targeting(card)

func select_card_for_discard(card: Card) -> void:
	if card.card_resource.is_autoplay: return
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