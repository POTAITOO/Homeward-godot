extends Node

@export var player_scene: PackedScene

var player_count := 3
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

func _ready():
	print("[SYSTEM] GameManager initialized")
	print("[SYSTEM] Waiting for external initialization...")

func initialize_game():
	print("[SYSTEM] Initializing game...")
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
	print("[BOARD] Board assigned")

func set_map_data(map_data):
	current_map_data = map_data
	print("[MAP] MapData assigned: tiles = " + str(map_data.total_tiles))

func set_player_count(count: int):
	player_count = count
	print("[CONFIG] Player count set to: " + str(count))

func _setup_players():
	print("[PLAYERS] Spawning " + str(player_count) + " players")
	for i in range(player_count):
		var player = player_scene.instantiate()
		player.name = "Player " + str(i + 1)
		player.set("character_id", i)
		player.set("board", current_board)
		player.set("max_tile", current_map_data.total_tiles if current_map_data != null else 0)
		players_node.add_child(player)
		player.setup(current_board, current_board.get_school_position())
		players.append(player)
		print("[PLAYER] " + player.name + " spawned at School")
	print("[PLAYERS] Total spawned: " + str(players.size()))

func _start_game():
	print("[SYSTEM] Game started")
	_play_turn()

func _play_turn():
	if game_over or processing_turn:
		return

	processing_turn = true
	print("[TURN] Turn " + str(current_turn + 1))

	var player = players[current_player_index]

	if player in skip_turn_players:
		print("[TRAFFIC] " + player.name + " skipped turn")
		skip_turn_players.erase(player)
		processing_turn = false
		await get_tree().create_timer(turn_delay).timeout
		_next_turn()
		return

	var roll = _roll_dice()
	print("[ROLL] " + player.name + " rolled " + str(roll))
	player.take_turn(roll)

	await _wait_for_player(player)
	print("[MOVE] " + player.name + " finished at tile " + str(player.get("grid_position")))

	await resolve_tile_effect(player)

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

func _next_turn():
	current_player_index = (current_player_index + 1) % players.size()
	print("[TURN] Next player index = " + str(current_player_index))
	_play_turn()

func _win_game(player):
	game_over = true
	player.move_to_tile(player.get("max_tile"))
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
	var tile_type = current_map_data.tile_index.get(player.get("grid_position"), "plain")
	print("[TILE] Effect: " + tile_type)

	match tile_type:
		"bus_stop_green", "bus_stop_orange", "bus_stop_violet":
			await apply_bus_stop(player)
			await _wait_for_player(player)
		"vending":
			await apply_vending(player)
		"bike":
			await apply_bike(player)
			await _wait_for_player(player)
		"puddle":
			await apply_puddle(player)
			await _wait_for_player(player)
		"traffic":
			await apply_traffic(player)
		"dog":
			await apply_dog(player)
			await _wait_for_player(player)
		_:
			pass

# ─── Bus Stop: jump reaction → tile-by-tile travel ───────────────────────────
func apply_bus_stop(player) -> void:
	var tile = player.get("grid_position")
	if current_map_data.bus_pairs.has(tile):
		var dest = current_map_data.bus_pairs[tile]
		print("[BUS] " + str(tile) + " → " + str(dest))

		# 1. Jump animation first (advantage reaction)
		await player.play_jump_reaction()

		# 2. Move tile-by-tile to destination
		player.move_to_tile_stepwise(dest)

# ─── Vending: jump → extra roll ──────────────────────────────────────────────
func apply_vending(player) -> void:
	await player.play_jump_reaction()

	var roll = _roll_dice()
	print("[VENDING] Extra roll: " + str(roll))
	player.take_turn(roll)
	await _wait_for_player(player)
	print("[VENDING] Landed on tile " + str(player.get("grid_position")))

	# Re-resolve whatever tile the extra roll landed on
	await resolve_tile_effect(player)
# ─── Bike: jump → catch up ───────────────────────────────────────────────────
func apply_bike(player) -> void:
	var front = get_player_in_front(player)
	if front == null:
		print("[BIKE] No player ahead")
		return

	await player.play_jump_reaction()

	print("[BIKE] Catching up to " + front.name)
	var dest = max(1, front.get("grid_position") - 1)
	player.move_to_tile_stepwise(dest)
	await _wait_for_player(player)

	# Re-resolve whatever tile the bike landed on
	await resolve_tile_effect(player)

# ─── Puddle: sleep → step back 2 tiles ───────────────────────────────────────
func apply_puddle(player) -> void:
	await player.play_sleep_reaction()

	var dest = max(1, player.get("grid_position") - 2)
	print("[PUDDLE] Slipped to tile " + str(dest))
	player.move_backward_stepwise(dest)

# ─── Traffic: sleep → skip next turn ─────────────────────────────────────────
func apply_traffic(player) -> void:
	await player.play_sleep_reaction()
	print("[TRAFFIC] " + player.name + " will skip next turn")
	skip_turn_players.append(player)

# ─── Dog: sleep → sent back to last position ─────────────────────────────────
func apply_dog(player) -> void:
	await player.play_sleep_reaction()

	var dest = player.get("last_position")
	print("[DOG] Sending " + player.name + " back to tile " + str(dest))
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
