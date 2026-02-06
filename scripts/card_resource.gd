class_name CardResource extends Resource

@export var card_type: CardManager.CardType
@export var texture: Texture2D
@export var melee_damage: int
@export var is_special: bool = false
@export var is_autoplay: bool = false

const HALO_SCENE = preload("res://scenes/Halo.tscn")

func moat():
	var tree = Signals.get_tree()
	if not tree: return
	
	var root = tree.root
	var player_tower = root.get_node_or_null("Game/PlayerTower")
	var hex_grid = root.get_node_or_null("Game/World/HexGrid")
	var enemy_manager = root.get_node_or_null("Game/EnemyManager")
	
	if not player_tower or not hex_grid or not enemy_manager:
		print("Missing dependencies for moat")
		return

	print("Activating Moat...")
	
	# Get player position
	var center_coord = player_tower.current_tile
	
	# Get all tiles at distance 2
	var targets = []
	var distance = 2
	for q in range(-distance, distance + 1):
		for r in range(-distance, distance + 1):
			if (abs(q) + abs(r) + abs(q + r)) / 2 == distance:
				targets.append(Vector2i(q, r))
	
	for n in targets:
		var target_coord = center_coord + n
		
		# Check if occupied by enemy
		var enemy_on_tile = null
		for enemy in enemy_manager.enemies_in_play:
			if enemy.current_tile == target_coord:
				enemy_on_tile = enemy
				break
		
		if enemy_on_tile:
			# Damage enemy
			print("Moat blocked by enemy at ", target_coord, ". Dealing damage.")
			enemy_on_tile.take_damage(melee_damage)
		else:
			# Turn into moat
			print("Creating moat at ", target_coord)
			hex_grid.set_tile_as_moat(target_coord, true)

func halo():
	print("haloooo")
	var tree = Signals.get_tree()
	if not tree: return
	
	var root = tree.root
	var player_tower = root.get_node_or_null("Game/PlayerTower")
	var world = root.get_node_or_null("Game/World")
	
	if not player_tower or not world:
		print("Missing dependencies for halo")
		return
		
	var halo_instance = HALO_SCENE.instantiate()
	world.add_child(halo_instance)
	# Position at y = 3.5 (roughly half height of player tower which is usually around y=0 to y=something)
	# User requested "y = half of player mash height". Assuming 3.5 based on Cannonball offset.
	halo_instance.global_position = player_tower.global_position + Vector3(0, 1, 0)
	
	if "damage" in halo_instance:
		halo_instance.damage = melee_damage

const CANNONBALL_SCENE = preload("res://scenes/Cannonball.tscn")

func cannonball(target_pos: Vector3):
	var tree = Signals.get_tree()
	if not tree: return
	
	var root = tree.root
	var player_tower = root.get_node_or_null("Game/PlayerTower")
	var world = root.get_node_or_null("Game/World")
	
	if not player_tower or not world:
		print("Missing dependencies for cannonball")
		return

	if target_pos:
		var ball = CANNONBALL_SCENE.instantiate()
		world.add_child(ball)
		ball.global_position = player_tower.global_position + Vector3(0, 3.5, 0)
		ball.target_pos = target_pos
		ball.damage = melee_damage
		print("Cannonball fired at ", target_pos)
		return ball
	return null

func landmines():
	var tree = Signals.get_tree()
	if not tree: return
	
	var root = tree.root
	var enemy_manager = root.get_node_or_null("Game/EnemyManager")
	var hex_grid = root.get_node_or_null("Game/World/HexGrid")
	var particle_manager = root.get_node_or_null("Game/ParticleManager")
	
	if not enemy_manager or not hex_grid:
		print("Missing dependencies for landmines")
		return
	
	print("Triggering landmines...")
	
	# 1. Spawn explosions on ALL dirt tiles
	if particle_manager:
		var dirt_tiles = hex_grid.get_all_dirt_tiles()
		
		# Sort by distance from center (0,0) for wave effect
		dirt_tiles.sort_custom(func(a, b): return a.length() < b.length())
		
		var batch_size = 5
		for i in range(dirt_tiles.size()):
			var coord = dirt_tiles[i]
			var world_pos = hex_grid.axial_to_world(coord.x, coord.y)
			particle_manager.spawn_small_explosion(world_pos)
			
			# Yield every batch_size iterations
			if i % batch_size == 0:
				await tree.process_frame
	
	# 2. Damage enemies on dirt tiles
	var hit_count = 0
	for enemy in enemy_manager.enemies_in_play:
		if is_instance_valid(enemy):
			if hex_grid.is_dirt(enemy.current_tile):
				enemy.take_damage(melee_damage)
				hit_count += 1
	
	print("Landmines hit ", hit_count, " enemies.")

func do_special_attack():
	match card_type:
		CardManager.CardType.Halo:
			halo()
		CardManager.CardType.Moat:
			moat()
		CardManager.CardType.Cannonball:
			pass # Handled via targeting mode in card.gd
		CardManager.CardType.Landmines:
			landmines()
		_:
			return
