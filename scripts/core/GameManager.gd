extends Node

signal roll_requested(player_index: int)
signal roll_submitted(roll_value: int)

@export var player_scene: PackedScene

var turn_delay := 2.0

var players = []
var current_player_index: int = 0
var current_turn: int = 0
var game_over: bool = false

var current_board = null
var current_map_data = null
var skip_turn_players := []
var players_node = null
var processing_turn := false
var waiting_for_roll := false
var current_roll_session: int = 0

func _ready():
	set_process_unhandled_input(true)

func initialize_game():
	if current_board == null or current_map_data == null:
		push_error("Game cannot start: missing board or map data")
		return
	if players_node == null:
		push_error("[SYSTEM] Players node not assigned!")
		return
	_setup_players()
	_start_game()

func set_board(board):
	current_board = board

func set_map_data(map_data):
	current_map_data = map_data

func _setup_players():
	players.clear()
	current_player_index = 0
	current_turn = 0
	skip_turn_players.clear()
	game_over = false
	waiting_for_roll = false

	var count = GlobalData.player_count
	for i in range(count):
		var player = player_scene.instantiate()
		player.name = "Player " + str(i + 1)

		# Spawn players in turn order using selected avatar IDs from GlobalData.
		var character_id := i
		if GlobalData.turn_order.size() == count and GlobalData.selected_characters.size() == count:
			character_id = GlobalData.get_character_for_turn(i)
		player.set("character_id", character_id)

		player.set("board", current_board)
		player.set("max_tile", current_map_data.total_tiles if current_map_data != null else 0)
		players_node.add_child(player)

		# Place players so that turn 0 is visually "in front" and later turns stack behind.
		var school_pos = current_board.get_school_position()
		var stack_offset = Vector2(0, -16) # vertical offset per player (tweak if needed)
		# Pass an offsetted school position so the player's internal TILE_OFFSET applies consistently.
		player.setup(current_board, school_pos + stack_offset * i)
		# Use z_index so earlier turns render above later turns (front-most drawn last/highest z).
		player.z_index = 100 - i
		players.append(player)

func _start_game():
	_play_turn()

func _play_turn():
	if game_over or processing_turn:
		return

	processing_turn = true

	var player = players[current_player_index]

	if player in skip_turn_players:
		skip_turn_players.erase(player)
		processing_turn = false
		await get_tree().create_timer(turn_delay).timeout
		_next_turn()
		return

	# Wait for user input to roll (Space by default via input action 'roll_dice').
	# Log turn start (use player.name so logs match displayed names)
	print("[GAME] Turn %d - %s starting at tile %d" % [current_turn, player.name, player.get("grid_position")])

	# Start a fresh roll session so only rolls produced during this window are accepted
	current_roll_session += 1
	waiting_for_roll = true
	print("[GAME] waiting_for_roll session", current_roll_session)
	emit_signal("roll_requested", current_player_index)
	# Wait for dice UI (dice.gd) to submit the roll after animation
	var roll = await roll_submitted
	waiting_for_roll = false

	print("[GAME] %s rolled %d" % [player.name, roll])
	player.take_turn(roll)

	# Predict destination using the player's last confirmed position (avoid races)
	var last_pos = player.get("last_position")
	var predicted = min(last_pos + roll, player.get("max_tile"))
	print("[GAME] %s will move from %d to %d (steps %d)" % [player.name, last_pos, predicted, roll])

	await _wait_for_player(player)

	# Log actual landing position after move
	print("[GAME] %s landed on tile %d" % [player.name, player.get("grid_position")])

	await resolve_tile_effect(player)

	# Log position after resolving tile effects (may have changed)
	print("[GAME] %s position after effects %d" % [player.name, player.get("grid_position")])

	if player.get("grid_position") >= player.get("max_tile"):
		_win_game(player)
		return

	current_turn += 1
	processing_turn = false
	await get_tree().create_timer(turn_delay).timeout
	_next_turn()

func _wait_for_player(player) -> void:
	while player.get("is_moving"):
		await get_tree().process_frame

func _roll_dice() -> int:
	return randi() % 6 + 1


func submit_roll(roll_value: int, session_id: int = -1) -> void:
	# Optionally require session token to avoid accepting stale rolls
	if session_id != -1 and session_id != current_roll_session:
		print("[GAME] Ignoring roll from stale session", session_id, "current", current_roll_session)
		return
	if not waiting_for_roll or processing_turn == false:
		return
	if roll_value < 1 or roll_value > 6:
		return
	print("[GAME] submit_roll received:", roll_value, "from dice")
	emit_signal("roll_submitted", roll_value)


func _unhandled_input(_event):
	# Input is handled by the dice UI which submits the roll after its animation.
	# GameManager intentionally does not auto-submit on input to avoid mismatched rolls.
	return

func _next_turn():
	current_player_index = (current_player_index + 1) % players.size()
	_play_turn()

func _win_game(player):
	game_over = true
	# Persist winner name for external UI / result screens
	if player.name != "":
		GlobalData.winner_name = str(player.name)
		print("[GAME] Winner saved to GlobalData.winner_name:", GlobalData.winner_name)
	player.move_to_tile(player.max_tile)
	await _wait_for_player(player)
	player.target_position = current_board.get_home_position()
	player.is_moving = true
	await _wait_for_player(player)
	player.celebrate_win()

	# All other players do sleep animation
	for p in players:
		if p != player:
			p.play_sleep_reaction()

	print("[WIN] ", player.name, " WINS!")

func resolve_tile_effect(player) -> void:
	# Allow chaining of multiple tile effects in the same turn (stacking), up to a safety limit
	var max_chains := 12
	var visited := {}
	var visited_tiles := []
	for i in range(max_chains):
		var pos = player.get("grid_position")
		var tile_type = current_map_data.tile_index.get(pos, "plain")

		# Prevent re-processing the same tile within this resolution to avoid loops
		if pos in visited_tiles:
			print("[CHAIN] tile", pos, "already visited this chain; stopping to avoid loop")
			break
		visited_tiles.append(pos)

		print("[CHAIN] Iteration", i, "Player", players.find(player), "at tile", pos, "type", tile_type)
		visited[pos] = true

		var did_move := false

		match tile_type:
			"bus_stop_green", "bus_stop_orange", "bus_stop_violet":
				print("[CHAIN] apply_bus_stop for player", players.find(player), "on tile", pos)
				await apply_bus_stop(player)
				await _wait_for_player(player)
				print("[CHAIN] after bus_stop player", players.find(player), "now on", player.get("grid_position"))
				did_move = true
			"vending":
				print("[CHAIN] apply_vending for player", players.find(player), "on tile", pos)
				await apply_vending(player)
				await _wait_for_player(player)
				print("[CHAIN] after vending player", players.find(player), "now on", player.get("grid_position"))
				did_move = true
			"bike":
				print("[CHAIN] apply_bike for player", players.find(player), "on tile", pos)
				await apply_bike(player)
				await _wait_for_player(player)
				print("[CHAIN] after bike player", players.find(player), "now on", player.get("grid_position"))
				did_move = true
			"puddle":
				print("[CHAIN] apply_puddle for player", players.find(player), "on tile", pos)
				await apply_puddle(player)
				await _wait_for_player(player)
				print("[CHAIN] after puddle player", players.find(player), "now on", player.get("grid_position"))
				did_move = true
			"traffic":
				print("[CHAIN] apply_traffic for player", players.find(player), "on tile", pos)
				await apply_traffic(player)
				print("[CHAIN] after traffic (no move) player", players.find(player), "on", player.get("grid_position"))
			"dog":
				print("[CHAIN] apply_dog for player", players.find(player), "on tile", pos)
				await apply_dog(player)
				await _wait_for_player(player)
				print("[CHAIN] after dog player", players.find(player), "now on", player.get("grid_position"))
				did_move = true
			_:
				# plain or unrecognized tile -> nothing to do
				print("[CHAIN] no special tile at", pos)
				pass

		# If the player moved as part of this effect, loop again to resolve the new tile.
		if did_move:
			continue

		# No movement-causing effect left; stop chaining.
		break

# ─── Bus Stop: jump reaction → tile-by-tile travel ───────────────────────────
func apply_bus_stop(player) -> void:
	var tile = player.get("grid_position")
	if current_map_data.bus_pairs.has(tile):
		var dest = current_map_data.bus_pairs[tile]

		# 1. Jump animation first (advantage reaction)
		await player.play_jump_reaction()

		# 2. Move tile-by-tile to destination
		player.move_to_tile_stepwise(dest)
		# movement is awaited by the central resolver

# ─── Vending: jump → extra roll ──────────────────────────────────────────────
func apply_vending(player) -> void:
	await player.play_jump_reaction()

	# Request an extra roll from the player (use the dice UI animation)
	waiting_for_roll = true
	current_roll_session += 1
	print("[GAME] vending extra roll session", current_roll_session)
	emit_signal("roll_requested", current_player_index)
	var roll = await roll_submitted
	waiting_for_roll = false

	player.take_turn(roll)
	# movement is awaited by the central resolver
# ─── Bike: jump → catch up ───────────────────────────────────────────────────
func apply_bike(player) -> void:
	var front = get_player_in_front(player)
	if front == null:
		return

	await player.play_jump_reaction()

	var dest = max(1, front.get("grid_position") - 1)
	player.move_to_tile_stepwise(dest)
	# movement is awaited by the central resolver

# ─── Puddle: sleep → step back 2 tiles ───────────────────────────────────────
func apply_puddle(player) -> void:
	await player.play_sleep_reaction()

	# Move player back 3 tiles (or to tile 1 minimum)
	var dest = max(1, player.get("grid_position") - 3)
	print("[GAME] Puddle: Player", players.find(player), "stepped back to", dest)
	player.move_backward_stepwise(dest)

	# movement is awaited by the central resolver

# ─── Traffic: sleep → skip next turn ─────────────────────────────────────────
func apply_traffic(player) -> void:
	await player.play_sleep_reaction()
	skip_turn_players.append(player)

# ─── Dog: sleep → sent back to last position ─────────────────────────────────
func apply_dog(player) -> void:
	await player.play_sleep_reaction()

	var dest = player.get("last_position")
	player.move_backward_stepwise(dest)

func get_player_in_front(player):
	var best = null
	var highest = -1
	for p in players:
		if p == player:
			continue
		if p.get("grid_position") > player.get("grid_position") and p.get("grid_position") > highest:
			highest = p.get("grid_position")
			best = p
	return best
