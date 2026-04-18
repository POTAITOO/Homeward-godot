# GameManager.gd
extends Node

@export var player_count: int = 3
@export var max_turns: int = 10
@export var turn_delay: float = 1.5

var players = []
var current_player_index: int = 0
var current_turn: int = 0
var waiting_for_roll: bool = false   # NEW

@onready var map = $"../Map"
@onready var dice = $"../Dice"
@onready var roll_button = $"../RollButton"   # NEW

func _ready():
	randomize()
	print("Game Started")
	setup_players()
	print("Map found: ", has_node("../Map"))
	print("Dice found: ", has_node("../Dice"))
	if has_node("../Dice"):
		$"../Dice".roll_completed.connect(_on_dice_rolled)
		print("Signal connected!")
	# Connect button press to roll
	roll_button.pressed.connect(_on_roll_button_pressed)
	roll_button.disabled = true   # disable until game starts
	await get_tree().process_frame
	start_game()

func setup_players():
	for i in range(player_count):
		players.append({
			"name": "Player " + str(i + 1),
			"position": 0,
			"skip_turn": false,
			"roll_again": false,
			"half_move": false,
			"waypoint_blocked": false,
			"obstacle_immune": false,
			"safe_zone": false,
			"last_roll": 0,
			"pending_choice": ""
		})
	print(players)

func start_game():
	print("\nGame Started!!!\n")
	play_turn()

func play_turn():
	var player = players[current_player_index]

	if player["skip_turn"]:
		print(player["name"] + " skips their turn!")
		player["skip_turn"] = false
		current_turn += 1
		next_turn()
		return

	# Tell current player to press the button
	print(player["name"] + "'s turn! Press Roll Dice.")
	roll_button.text = player["name"] + " — Roll Dice!"
	roll_button.disabled = false   # enable button for current player
	waiting_for_roll = true

func _on_roll_button_pressed():
	if not waiting_for_roll:
		return
	waiting_for_roll = false
	roll_button.disabled = true   # disable while rolling
	dice.roll()

func _on_dice_rolled(result: int):
	var player = players[current_player_index]
	player["last_roll"] = result

	var move_amount = result
	if player["half_move"]:
		move_amount = max(1, int(result / 2.0))
		player["half_move"] = false

	var total_tiles = map.COLS * map.ROWS
	player["position"] = min(player["position"] + move_amount, total_tiles - 1)

	print(player["name"] + " rolled " + str(result) + " -> position: " + str(player["position"]))

	land_on_tile(player)

	if check_win(player):
		return

	if player["roll_again"]:
		player["roll_again"] = false
		print(player["name"] + " rolls again!")
		# Let player press button again for roll again
		waiting_for_roll = true
		roll_button.text = player["name"] + " — Roll Again!"
		roll_button.disabled = false
		return

	current_turn += 1
	next_turn_delayed()

func land_on_tile(player: Dictionary) -> void:
	if map.tile_path.size() == 0:
		print("WARNING: tile_path is empty!")
		return
	if player["position"] >= map.tile_path.size():
		print("WARNING: position out of tile range!")
		return
	var tile = map.tile_path[player["position"]]
	if tile == null:
		print("WARNING: tile is null at index ", player["position"])
		return
	print("Landing on tile: ", player["position"], " type: ", tile.name)
	tile.on_land(player)

func check_win(player: Dictionary) -> bool:
	var total_tiles = map.COLS * map.ROWS
	if player["position"] >= total_tiles - 1:
		print("🎉 " + player["name"] + " reached Home and WINS!")
		roll_button.disabled = true
		return true
	return false

func next_turn_delayed():
	var timer = get_tree().create_timer(turn_delay)
	timer.timeout.connect(next_turn)

func next_turn():
	current_player_index = (current_player_index + 1) % players.size()
	play_turn()
