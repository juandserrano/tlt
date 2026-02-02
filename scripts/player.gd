class_name Player extends StaticBody3D

var current_tile: Vector2i
var max_health: int = 20
var current_health: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_health = max_health
	Signals.enemy_attacked_player.connect(_on_enemy_attacked_player)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_enemy_attacked_player(enemy: Enemy, damage: int):
	current_health -= damage