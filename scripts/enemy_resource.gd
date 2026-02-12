class_name EnemyResource extends Resource 

@export var max_health: int
@export var mesh: Mesh
@export var moves_per_turn: int
@export_range(0, 1, 0.01) var evade_probability: float 

