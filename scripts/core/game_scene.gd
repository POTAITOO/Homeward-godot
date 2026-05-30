extends Node2D

@onready var game_manager = $GameManager
@onready var board = $Board
@onready var players = $Players

func _ready():
	print("[GameScene] Starting setup...")
	
	game_manager.set_board(board)
	game_manager.players_node = players
	
	var map_data

	match GlobalData.selected_map:

		"6x6":
			map_data = load(
				"res://scripts/core/MapData_6x6.gd"
			).new()

		"8x8":
			map_data = load(
				"res://scripts/core/MapData_8x8.gd"
			).new()

		"10x10":
			map_data = load(
				"res://scripts/core/MapData_10x10.gd"
			).new()

	game_manager.set_map_data(map_data)

	game_manager.player_count = GlobalData.player_count

	await get_tree().process_frame

	game_manager.initialize_game()
	print("[GameScene] Ready")
