extends Node

@export var enemy_manager: EnemyManager

enum GameState {
  MainMenu,
  PlayerTurn,
  Resolve,
  EnemiesTurn,
  Paused
}

var state: GameState
var round_number: int

func _ready() -> void:
  state = GameState.PlayerTurn

func _process(_delta: float) -> void:
  if state == GameState.PlayerTurn and Input.is_action_just_pressed("next turn"):
   next_turn()

func next_turn():
  enemy_manager.enemies_move_or_attack()
  pass
