extends Node2D

@onready var game_manager = $GameManager
@onready var board = $Board
@onready var players = $Players

func _ready():
	print("[GameScene] Starting setup...")
	
	game_manager.set_board(board)
	game_manager.players_node = players
	
	var MapData = load("res://scripts/core/MapData_6x6.gd")
	var map_data = MapData.new()
	game_manager.set_map_data(map_data)
	game_manager.set_player_count(3)
	
	# ✅ Wait one frame so Board._ready() finishes and all @onready vars resolve
	await get_tree().process_frame
	
	game_manager.initialize_game()
	print("[GameScene] Ready")
