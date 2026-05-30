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
	setup_players()
	start_game()

func set_board(board):
	current_board = board
	print("[BOARD] Board assigned")

func set_map_data(map_data):
	current_map_data = map_data
	print("[MAP] MapData assigned: tiles = " + str(map_data.total_tiles))

func set_player_count(count: int):
	player_count = count
	print("[CONFIG] Player count set to: " + str(count))

func setup_players():
	print("[PLAYERS] Spawning " + str(player_count) + " players")
	for i in range(player_count):
		var player = player_scene.instantiate()
		player.name = "Player" + str(i + 1)
		player.board = current_board
		if current_map_data != null:
			player.max_tile = current_map_data.total_tiles
		player.global_position = current_board.get_school_position()
		players_node.add_child(player)
		players.append(player)
		print("[PLAYER] " + player.name + " spawned at School")
	print("[PLAYERS] Total spawned: " + str(players.size()))

func start_game():
	print("[SYSTEM] Game started")
	play_turn()

func play_turn():
	if game_over or processing_turn:
		return

	processing_turn = true
	print("[TURN] Turn " + str(current_turn + 1))

	var player = players[current_player_index]

	# Skip turn check
	if player in skip_turn_players:
		print("[TRAFFIC] " + player.name + " skipped turn")
		skip_turn_players.erase(player)
		processing_turn = false
		await get_tree().create_timer(turn_delay).timeout
		next_turn()
		return

	# Roll and move tile by tile
	var roll = roll_dice()
	print("[ROLL] " + player.name + " rolled " + str(roll))
	player.take_turn(roll)

	# Wait for stepping movement to finish
	await _wait_for_player(player)
	print("[MOVE] " + player.name + " finished at tile " + str(player.grid_position))

	# Apply tile effect and wait for any effect movement
	await resolve_tile_effect(player)

	# Win check AFTER effect movement is done
	if player.grid_position >= player.max_tile:
		win_game(player)
		return

	current_turn += 1
	processing_turn = false
	await get_tree().create_timer(turn_delay).timeout
	next_turn()

func _wait_for_player(player) -> void:
	while player.is_moving:
		await get_tree().process_frame

func roll_dice() -> int:
	return randi() % 6 + 1

func next_turn():
	current_player_index = (current_player_index + 1) % players.size()
	print("[TURN] Next player index = " + str(current_player_index))
	play_turn()

func win_game(player):
	game_over = true
	processing_turn = false
	print("[WIN] " + player.name + " WINS!")
	player.is_moving = true
	player.target_position = current_board.get_home_position()

# Returns after effect movement finishes
func resolve_tile_effect(player) -> void:
	var tile_type = current_map_data.tile_index.get(player.grid_position, "plain")
	print("[TILE] Effect: " + tile_type)

	match tile_type:
		"bus_stop_green", "bus_stop_orange", "bus_stop_violet":
			apply_bus_stop(player)
			await _wait_for_player(player)

		"vending":
			await apply_vending(player)

		"bike":
			apply_bike(player)
			await _wait_for_player(player)

		"puddle":
			apply_puddle(player)
			await _wait_for_player(player)

		"traffic":
			apply_traffic(player)
			# No movement to wait for

		"dog":
			apply_dog(player)
			await _wait_for_player(player)

		_:
			pass

# --- TILE EFFECTS ---

func apply_bus_stop(player):
	var tile = player.grid_position
	if current_map_data.bus_pairs.has(tile):
		var dest = current_map_data.bus_pairs[tile]
		print("[BUS] " + str(tile) + " → " + str(dest))
		player.grid_position = dest
		player.target_position = current_board.get_tile_world_position(dest)
		player.is_moving = true

func apply_vending(player) -> void:
	var roll = roll_dice()
	print("[VENDING] Extra roll: " + str(roll))
	# Step tile by tile for the bonus roll too
	player.take_turn(roll)
	await _wait_for_player(player)
	print("[VENDING] Landed on tile " + str(player.grid_position))

func apply_bike(player):
	var front = get_player_in_front(player)
	if front == null:
		print("[BIKE] No player ahead")
		return
	print("[BIKE] Catching up to " + front.name)
	player.grid_position = max(1, front.grid_position - 1)
	player.target_position = current_board.get_tile_world_position(player.grid_position)
	player.is_moving = true

func apply_puddle(player):
	player.grid_position = max(1, player.grid_position - 2)
	player.target_position = current_board.get_tile_world_position(player.grid_position)
	player.is_moving = true
	print("[PUDDLE] Slipped to tile " + str(player.grid_position))

func apply_traffic(player):
	print("[TRAFFIC] " + player.name + " will skip next turn")
	skip_turn_players.append(player)

func apply_dog(player):
	print("[DOG] Sending " + player.name + " back to tile " + str(player.last_position))
	player.grid_position = player.last_position
	player.target_position = current_board.get_tile_world_position(player.grid_position)
	player.is_moving = true

func get_player_in_front(player):
	var best = null
	var highest = -1
	for p in players:
		if p == player:
			continue
		if p.grid_position > player.grid_position and p.grid_position > highest:
			highest = p.grid_position
			best = p
	return best
