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
	print("SYSTEM ", "GameManager initialized")

	print("SYSTEM ", "Waiting for external initialization...")

func initialize_game():
	print("SYSTEM ", "Initializing game...")

	if current_board == null or current_map_data == null:
		push_error("Game cannot start: missing board or map data")
		return

	setup_players()
	start_game()

func set_board(board):
	current_board = board
	print("BOARD ", "Board assigned")	

func set_map_data(map_data):
	current_map_data = map_data
	print("MAP ", "MapData assigned: tiles = " + str(map_data.total_tiles))

func set_player_count(count: int):
	player_count = count
	print("CONFIG Player count set to:", count)
	
func setup_players():
	print("PLAYERS", "Spawning " + str(player_count) + " players")
	for i in range(player_count):

		var player = player_scene.instantiate()
		player.name = "Player" + str(i + 1)

		# Assign board
		player.board = current_board

		# Assign board size
		if current_map_data != null:
			player.max_tile = current_map_data.total_tiles

		# SPAWN AT SCHOOL (IMPORTANT)
		player.global_position = current_board.get_school_position()
		
		players_node.add_child(player)
		players.append(player)
		print("PLAYER ", player.name + " spawned at School")
	print("Players spawned: ", players.size())

func start_game():
	print("SYSTEM ", "Game started")
	play_turn()


func play_turn():

	if game_over or processing_turn:
		return
		
	processing_turn = true
	
	print("TURN ", "Turn " + str(current_turn + 1))
	var player = players[current_player_index]

	# SKIP TURN CHECK
	if player in skip_turn_players:
		print("[TRAFFIC] ", player.name, " skipped turn")
		skip_turn_players.erase(player)
		processing_turn = false
		next_turn()
		return
		
	var roll = roll_dice()

	print("ROLL ", player.name + " rolled " + str(roll))

	player.take_turn(roll)

	while player.is_moving:
		await get_tree().process_frame
	print("MOVE ", player.name + " finished movement at tile " + str(player.grid_position))
	
	# TILE EFFECT TRIGGER
	var tile_type = current_map_data.tile_index[player.grid_position]
	resolve_tile_effect(player, tile_type)
	
	# WIN CHECK
	if player.grid_position >= player.max_tile:
		win_game(player)
		return
	
	current_turn += 1
	processing_turn = false
	next_turn()

func roll_dice():
	return randi() % 6 + 1

func next_turn():

	current_player_index = (current_player_index + 1) % players.size()
	print("TURN ", "Next player index = " + str(current_player_index))
	
	if current_player_index >= players.size():
		current_player_index = 0

	await get_tree().create_timer(turn_delay).timeout

	play_turn()
	
func win_game(player):
	game_over = true
	print("WIN ", player.name + " WINS!")

	player.is_moving = true
	player.target_position = current_board.get_home_position()

func resolve_tile_effect(player, tile_type: String):

	print("[TILE] Effect:", tile_type)

	match tile_type:

		"bus_stop_green", "bus_stop_orange", "bus_stop_violet":
			apply_bus_stop(player)

		"vending":
			apply_vending(player)

		"bike":
			apply_bike(player)

		"puddle":
			apply_puddle(player)

		"traffic":
			apply_traffic(player)

		"dog", "dog_left":
			apply_dog(player)

		_:
			pass

# ADVANTAGES
func apply_bus_stop(player):

	var tile = player.grid_position

	if current_map_data.bus_pairs.has(tile):

		var dest = current_map_data.bus_pairs[tile]

		print("[BUS] ", tile, " → ", dest)

		player.grid_position = dest
		player.target_position = current_board.get_tile_world_position(dest)
		player.is_moving = true

func apply_vending(player):

	print("[VENDING] extra move")

	var roll = roll_dice()

	player.grid_position += roll
	player.grid_position = clamp(player.grid_position, 1, player.max_tile)

	player.target_position = current_board.get_tile_world_position(player.grid_position)
	player.is_moving = true

func apply_bike(player):

	var front = get_player_in_front(player)

	if front == null:
		print("[BIKE] no player ahead")
		return

	print("[BIKE] catch up to ", front.name)

	player.grid_position = max(1, front.grid_position - 1)
	player.target_position = current_board.get_tile_world_position(player.grid_position)
	player.is_moving = true


# DISADVANTAGES
func apply_puddle(player):

	player.grid_position = max(1, player.grid_position - 2)

	player.target_position = current_board.get_tile_world_position(player.grid_position)
	player.is_moving = true


func apply_traffic(player):

	print("[TRAFFIC] skip next turn")
	skip_turn_players.append(player)

func apply_dog(player):

	if not "last_position" in player:
		print("[DOG] missing last_position in player")
		return

	print("[DOG] sending back to last position:", player.last_position)

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
