class_name CardResource extends Resource

@export var card_type: CardManager.CardType
@export var texture: Texture2D
@export var melee_damage: int
@export var is_autoplay: bool = false

func halo():
	if card_type == CardManager.CardType.Halo:
		print("haloooo")

func do_special_attack():
	match card_type:
		CardManager.CardType.Halo:
			halo()
		CardManager.CardType.Moat:
			pass
		CardManager.CardType.Cannonball:
			pass
		CardManager.CardType.Landmines:
			pass
		_:
			return
