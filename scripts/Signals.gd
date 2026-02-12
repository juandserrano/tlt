extends Node

# Event Bus - Autoload singleton for game-wide signal management
# This allows decoupled communication between different game systems

# ============================================================================
# ENEMY SIGNALS
# ============================================================================

signal mouse_hover_enemy(enemy: Enemy)
signal mouse_unhover_enemy(enemy: Enemy)

# Emitted when an enemy spawns at a specific tile
signal enemy_spawned(enemy: Enemy, q: int, r: int)

# Emitted when an enemy moves to a new tile
signal enemy_moved(enemy: Enemy, from_q: int, from_r: int, to_q: int, to_r: int)

# Emitted when an enemy takes damage
signal enemy_damaged(enemy: Enemy, damage: int)

# Emitted when an enemy dies
signal enemy_died(enemy: Enemy)

# Emitted when all enemies in a wave are defeated
signal wave_cleared(wave_number: int)

signal enemy_hit_ground(enemy: Enemy)

# ============================================================================
# PLAYER SIGNALS
# ============================================================================

# Emitted when player moves to a new tile
signal player_moved(from_q: int, from_r: int, to_q: int, to_r: int)

# Emitted when player takes damage
signal player_damaged(player: Player, damage: int)

# Emitted when player health changes
signal player_health_changed(current_health: int, max_health: int)

# Emitted when player dies
signal player_died()

# ============================================================================
# COMBAT SIGNALS
# ============================================================================

# Emitted when combat begins between player and enemy
signal combat_started(enemy: Enemy)

# Emitted when combat ends
signal combat_ended(victory: bool)

# Emitted when an attack is performed
signal enemy_attacked_player(attacker: Enemy, impact_pos: Vector3, damage: int)

# ============================================================================
# TURN MANAGEMENT SIGNALS
# ============================================================================

# Emitted when a new turn begins
signal turn_started(turn_number: int, is_player_turn: bool)

# Emitted when a turn ends
signal player_turn_ended()

# Emitted when player's turn begins
signal player_turn_started()

# Emitted when enemy's turn begins
signal enemy_turn_started()

# Emitted when a new round starts
signal round_started(round_number: int)

# ============================================================================
# CARD/ABILITY SIGNALS
# ============================================================================

# Emitted when a card is played
signal card_played(card_type: String, target_q: int, target_r: int)

# Emitted when a card effect is applied
signal card_effect_applied(card_type: String, affected_tiles: Array)

# ============================================================================
# TILE/GRID SIGNALS
# ============================================================================

# Emitted when a tile is selected
signal tile_selected(q: int, r: int)

# Emitted when a tile is hovered
signal tile_hovered(q: int, r: int)

# Emitted when a tile state changes (e.g., becomes walkable/unwalkable)
signal tile_state_changed(q: int, r: int, new_state: String)

# ============================================================================
# UI SIGNALS
# ============================================================================

# Emitted when UI needs to update
signal ui_update_requested()

# Emitted when a message should be displayed
signal message_displayed(message: String, duration: float)

# Emitted when game state changes
signal game_state_changed(new_state: String)

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

# Helper to emit signals safely with error handling
func emit_safe(signal_name: String, args: Array = []) -> void:
	if has_signal(signal_name):
		callv("emit_signal", [signal_name] + args)
	else:
		push_error("Signal '%s' does not exist in Signals autoload" % signal_name)
