class_name GameManager extends Node

@export_category("Scenes")
@export var enemy_manager: EnemyManager
@export var player: Player
@export var audio_stream_player: AudioStreamPlayer
@export var particle_manager: ParticleManager
@export var card_manager: CardManager
@export_category("Timers")
@export var base_round_time: float

@onready var round_timer: Timer = $RoundTimer

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
var round_number: int = 1
var processing_enemies: bool = false

func _on_enemy_attacked_player(_enemy: Enemy, impact_pos: Vector3, damage: int):
	player.damage_player(damage)
	if particle_manager:
		particle_manager.spawn_explosion(impact_pos)
	audio_stream_player.stream = sound_falling_impact
	audio_stream_player.play()


func _ready() -> void:
	round_timer.wait_time = base_round_time
	round_timer.start()
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
	# enemy_manager.spawn_round_wave(1)
	state = GameState.PlayerTurn

func do_player_turn():
	if card_manager and card_manager.is_qte_active: return

# Handle input during player turn (only fires if GUI didn't consume the event)
# func _unhandled_input(event: InputEvent) -> void:
# 	if state == GameState.PlayerTurn:
# 		if event.is_action_pressed("next turn"):
# 			state = GameState.Resolve
# 			get_viewport().set_input_as_handled()

func do_enemies_turn():
	if processing_enemies: return
	processing_enemies = true
	await enemy_manager.enemies_move_or_attack()
	state = GameState.Spawning
	processing_enemies = false

func do_resolve_phase() -> void:
	# Handle autoplay cards (like fog)
	if card_manager:
		# Iterate backwards so we can safely remove cards while iterating
		for i in range(card_manager.player_hand.size() - 1, -1, -1):
			var card = card_manager.player_hand[i]
			if card.card_resource.is_autoplay:
				if card.card_type == CardManager.CardType.Fog:
					print("fog card played")
					# Call the new_fog_cloud function
					card.card_resource.new_fog_cloud()
					card_manager.destroy_card_after_use(card)
	
	state = GameState.EnemiesTurn


func _on_round_timer_timeout() -> void:
	if state == GameState.PlayerTurn:
			state = GameState.Resolve


func _on_enemy_spawn_timer_timeout() -> void:
	enemy_manager.spawn_round_wave(round_number)
