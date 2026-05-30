extends Node

@export var player_count: int = 3
@export var max_turns: int = 10
@export var turn_delay: float = 3.5
@export var player_scenes: Array[PackedScene] = []

var players = []
var player_nodes = []
var current_player_index: int = 0
var current_turn: int = 0
var game_over: bool = false

# Loaded from MapData
var tile_index: Dictionary = {}
var bus_pairs: Dictionary = {}
var home_tile: int = 37

@onready var board    = get_node("/root/Main/Board")
@onready var map_data = get_node("/root/Main/Board/MapData")
@onready var school   = get_node("/root/Main/Board/Layer1/School") 
@onready var home     = get_node("/root/Main/Board/Layer6/Home") 

func _ready() -> void:
	randomize()
	await get_tree().process_frame
	_load_map_data()
	setup_players()
	start_game()

func _load_map_data() -> void:
	tile_index = map_data.tile_index
	bus_pairs  = map_data.bus_pairs
	home_tile  = map_data.home_tile
	print("Map loaded: " + map_data.map_name + " | Tiles: " + str(map_data.total_tiles))

func setup_players() -> void:
	var school_pos = school.global_position
	for i in range(player_count):
		players.append({
			"name":           "Player " + str(i + 1),
			"current_tile":   0,
			"previous_tile":  0,
			"skip_next_turn": false,
			"roll_again":     false,
		})
		if i < player_scenes.size():
			var node = player_scenes[i].instantiate()
			get_node("/root/Main").add_child(node)
			node.name = "Player" + str(i + 1)
			node.setup(board, school_pos)
			node.global_position = school_pos + Vector2(i * 16, 0)
			player_nodes.append(node)
		else:
			player_nodes.append(null)
	print("Players spawned at School!")

func start_game() -> void:
	print("\nGame Started!!!\n")
	play_turn()

func play_turn() -> void:
	if game_over:
		return
	if current_turn >= max_turns:
		print("Max turns reached — Game Over")
		return

	var player = players[current_player_index]
	var node   = player_nodes[current_player_index]

	if player["skip_next_turn"]:
		player["skip_next_turn"] = false
		print(player["name"] + " skips! (Traffic Light 🚦)")
		current_turn += 1
		await get_tree().create_timer(turn_delay).timeout
		next_turn()
		return

	var roll = roll_dice()
	print("\n" + player["name"] + " rolled " + str(roll))
	await _move_player(player, node, roll)

	if player["roll_again"]:
		player["roll_again"] = false
		print(player["name"] + " rolls again! 🥤")
		await get_tree().create_timer(turn_delay).timeout
		var bonus = roll_dice()
		print(player["name"] + " bonus roll: " + str(bonus))
		await _move_player(player, node, bonus)

	if game_over:
		return

	current_turn += 1
	await get_tree().create_timer(turn_delay).timeout
	next_turn()

func _move_player(player: Dictionary, node, roll: int) -> void:
	player["previous_tile"] = player["current_tile"]
	var new_pos = player["current_tile"] + roll

	if new_pos >= home_tile:
		player["current_tile"] = home_tile
		if node != null:
			node.target_position = home.global_position
			node.is_moving = true
			await _wait_for_movement(node)
		print(player["name"] + " reached HOME! 🏠 WINNER!")
		game_over = true
		_end_game()
		return

	player["current_tile"] = new_pos
	print("  → tile " + str(new_pos) + " (" + get_tile_type(new_pos) + ")")

	if node != null:
		node.move_to_tile(new_pos)
		await _wait_for_movement(node)

	var tile_node = get_tile_node(new_pos)
	if tile_node and tile_node.has_method("on_player_landed"):
		tile_node.on_player_landed(player)

	_apply_tile_effect(player)

	if node != null and player["current_tile"] != new_pos:
		node.move_to_tile(player["current_tile"])
		await _wait_for_movement(node)

func _wait_for_movement(node) -> void:
	while not node.is_done_moving():
		await get_tree().process_frame

func _apply_tile_effect(player: Dictionary) -> void:
	var tile_num  = player["current_tile"]
	var tile_type = get_tile_type(tile_num)

	match tile_type:
		"bus_stop_green", "bus_stop_orange", "bus_stop_violet":
			if bus_pairs.has(tile_num):
				player["current_tile"] = bus_pairs[tile_num]
				print("  🚌 Bus! → tile " + str(player["current_tile"]))
			else:
				print("  🚌 Bus! No pair found.")

		"vending":
			player["roll_again"] = true
			print("  🥤 Vending Machine! Roll again.")

		"bike":
			var ahead = _get_player_ahead(player)
			if ahead != null:
				player["current_tile"] = max(1, ahead["current_tile"] - 1)
				print("  🚲 Bicycle! → tile " + str(player["current_tile"]))
			else:
				print("  🚲 Bicycle! No one ahead.")

		"puddle":
			player["current_tile"] = max(1, player["current_tile"] - 2)
			print("  💧 Puddle! → tile " + str(player["current_tile"]))

		"traffic":
			player["skip_next_turn"] = true
			print("  🚦 Traffic Light! Skip next turn.")

		"dog":
			player["current_tile"] = player["previous_tile"]
			print("  🐕 Stray Dog! → tile " + str(player["current_tile"]))

		"plain", "school":
			pass

func get_tile_type(tile_num: int) -> String:
	return tile_index.get(tile_num, "plain")

func get_tile_node(tile_num: int) -> Node:
	for tile in get_tree().get_nodes_in_group("tiles"):
		if tile.tile_number == tile_num:
			return tile
	return null

func _get_player_ahead(player: Dictionary):
	var best = null
	var best_pos = -1
	for p in players:
		if p["name"] == player["name"]:
			continue
		if p["current_tile"] > player["current_tile"] and p["current_tile"] > best_pos:
			best = p
			best_pos = p["current_tile"]
	return best

func roll_dice() -> int:
	return randi() % 6 + 1

func next_turn() -> void:
	current_player_index = (current_player_index + 1) % players.size()
	play_turn()

func _end_game() -> void:
	print("\n--- GAME OVER ---")
	for p in players:
		print(p["name"] + " → tile " + str(p["current_tile"]))
