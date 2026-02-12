class_name Player extends StaticBody3D

var current_tile: Vector2i
var max_health: int = 20
var current_health: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_health = max_health
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func damage_player(damage: int):
	current_health -= damage
	Signals.player_damaged.emit(self, damage)