class_name GameManager extends Node

@export var enemy_manager: EnemyManager

enum GameState {
  MainMenu,
  Spawning,
  PlayerTurn,
  Resolve,
  EnemiesTurn,
  Paused
}

static var state: GameState
var round_number: int

func _ready() -> void:
  state = GameState.Spawning

func _process(_delta: float) -> void:
  if state == GameState.PlayerTurn and Input.is_action_just_pressed("next turn"):
   next_turn()
   state = GameState.Spawning

func next_turn():
  enemy_manager.enemies_move_or_attack()
  pass
