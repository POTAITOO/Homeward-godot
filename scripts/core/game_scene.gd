extends Node2D

@onready var game_manager = $GameManager
@onready var board = $Board
@onready var players = $Players

func _ready():
	
	# Dynamically load and instantiate the selected map scene
	for child in board.get_children():
		child.queue_free()
		
	var map_scene_path = "res://scenes/main/" + GlobalData.selected_map + ".tscn"
	var map_scene = ResourceLoader.load(map_scene_path, "", ResourceLoader.CACHE_MODE_IGNORE)
	if map_scene:
		var map_instance = map_scene.instantiate()
		board.add_child(map_instance)
	else:
		push_error("[GameScene] Failed to load map scene: " + map_scene_path)

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

	# Wait a frame for new map nodes to enter the tree and call their _ready()
	await get_tree().process_frame

	# Re-cache the newly instanced board tiles and school/home positions
	board._cache_nodes()

	game_manager.initialize_game()
