class_name CardResource extends Resource

@export var card_type: CardManager.CardType
@export var texture: Texture2D
@export var melee_damage: int
@export var is_special: bool = false
@export var is_autoplay: bool = false

func halo():
		print("haloooo")

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

func do_special_attack():
	match card_type:
		CardManager.CardType.Halo:
			halo()
		CardManager.CardType.Moat:
			pass
		CardManager.CardType.Cannonball:
			pass # Handled via targeting mode in card.gd
		CardManager.CardType.Landmines:
			pass
		_:
			return
