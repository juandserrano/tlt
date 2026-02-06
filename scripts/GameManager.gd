class_name GameManager extends Node

@export var enemy_manager: EnemyManager
@export var player: Player
@export var audio_stream_player: AudioStreamPlayer
@export var particle_manager: ParticleManager
@export var card_manager: CardManager

const sound_falling_impact = preload("res://resources/sounds/falling_impact.wav")

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
var processing_enemies: bool = false

func _on_enemy_attacked_player(_enemy: Enemy, impact_pos: Vector3, damage: int):
	player.damage_player(damage)
	if particle_manager:
		particle_manager.spawn_explosion(impact_pos)
	audio_stream_player.stream = sound_falling_impact
	audio_stream_player.play()


func _ready() -> void:
	if not particle_manager:
		particle_manager = get_tree().current_scene.find_child("ParticleManager")
	
	if not card_manager:
		card_manager = get_tree().current_scene.find_child("CardManager", true, false)

	Signals.enemy_attacked_player.connect(_on_enemy_attacked_player)
	state = GameState.Spawning

func _process(_delta: float) -> void:
	match state:
		GameState.Spawning:
			do_spawn_phase()
		GameState.PlayerTurn:
			do_player_turn()
		GameState.Resolve:
			do_resolve_phase()
		GameState.EnemiesTurn:
			do_enemies_turn()

func do_spawn_phase():
	enemy_manager.spawn_round_wave(1)

func do_player_turn():
	if card_manager and card_manager.is_qte_active: return
	
	if Input.is_action_just_pressed("next turn"):
		state = GameState.Resolve

func do_enemies_turn():
	if processing_enemies: return
	processing_enemies = true
	await enemy_manager.enemies_move_or_attack()
	state = GameState.Spawning
	processing_enemies = false

func do_resolve_phase() -> void:
	state = GameState.EnemiesTurn
