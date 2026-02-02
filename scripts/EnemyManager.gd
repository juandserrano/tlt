extends Node

var enemies_in_play: Array[Enemy]
var enemy_bag: Array[Enemy]
var enemies_container: Node3D # Container to hold all enemy scene instances
var enemy_scene: PackedScene = preload("res://scenes/enemy.tscn")
var pawn_mesh = preload("res://resources/models/enemies/pawn_mesh.tres")
var knight_mesh = preload("res://resources/models/enemies/knight_mesh.tres")
var bishop_mesh = preload("res://resources/models/enemies/bishop_mesh.tres")

enum EnemyClass {
	Pawn,
	Knight,
	Bishop,
	Queen,
	King
}

enum EnemyVariant {
	Standard,
	Volatile,
	Enraged,
	Armored
}

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("spawn_enemy"):
			spawn_enemy_of_class(EnemyClass.Pawn)
			# get_viewport().set_input_as_handled() # Prevent double processing



func spawn_enemy_of_class(enemy_class: EnemyClass) -> void:
	var enemy = enemy_scene.instantiate() as Enemy
	var mesh_instance = enemy.get_node("MeshInstance3D") as MeshInstance3D
	match enemy_class:
		EnemyClass.Pawn:
			mesh_instance.mesh = pawn_mesh
		EnemyClass.Knight:
			mesh_instance.mesh = knight_mesh
		EnemyClass.Bishop:
			mesh_instance.mesh = bishop_mesh
		_:
			mesh_instance.mesh = pawn_mesh
	
	enemies_container.add_child(enemy)
	enemies_in_play.append(enemy)
	enemy.spawn_above_ground(0, 0)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Create and add the container for enemy instances
	enemies_container = Node3D.new()
	enemies_container.name = "EnemiesContainer"
	add_child(enemies_container)
