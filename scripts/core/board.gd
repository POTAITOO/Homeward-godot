extends Node2D

var tile_map: Dictionary = {}
var school_node: Node2D = null
var home_node: Node2D = null

func _ready():
	_cache_nodes()
	print("[BOARD] Ready — " + str(tile_map.size()) + " tiles cached")


func _cache_nodes():
	# Clear old cache
	tile_map.clear()
	school_node = null
	home_node = null

	# Cache tiles
	for tile in get_tree().get_nodes_in_group("tiles"):
		if tile.has_method("get") and tile.get("tile_number") != null:
			tile_map[tile.get("tile_number")] = tile

	# Cache School using groups or fallback search
	var schools = get_tree().get_nodes_in_group("school")
	if schools.size() > 0:
		school_node = schools[0]
	else:
		# Fallback if groups are not fully loaded or for explicit naming checks
		for node in get_tree().get_nodes_in_group("tiles"):
			if node.name == "School" or (node.name == "Home" and node.get_parent() != null and node.get_parent().name == "Layer1"):
				school_node = node
				break

	# Cache Home using groups or fallback search (making sure it's not the school node)
	var homes = get_tree().get_nodes_in_group("home")
	if homes.size() > 0:
		home_node = homes[0]
	else:
		# Fallback
		for node in get_tree().get_nodes_in_group("tiles"):
			if node.name == "Home" and node != school_node:
				home_node = node
				break


func get_tile_world_position(tile_num: int) -> Vector2:
	if tile_map.has(tile_num):
		return tile_map[tile_num].global_position

	push_error("[BOARD] Tile " + str(tile_num) + " not found!")
	return Vector2.ZERO


func get_school_position() -> Vector2:
	if school_node != null:
		return school_node.global_position

	# Fallback if cache is null
	var schools = get_tree().get_nodes_in_group("school")
	if schools.size() > 0:
		return schools[0].global_position

	for node in get_tree().get_nodes_in_group("tiles"):
		if node.name == "School" or (node.name == "Home" and node.get_parent() != null and node.get_parent().name == "Layer1"):
			return node.global_position

	push_error("[BOARD] School not found!")
	return Vector2.ZERO


func get_home_position() -> Vector2:
	if home_node != null:
		return home_node.global_position

	# Fallback search in home group
	var homes = get_tree().get_nodes_in_group("home")
	if homes.size() > 0:
		return homes[0].global_position

	# Fallback if no separate home node exists (e.g. 8x8, 10x10 maps)
	# Return the last tile position on the board
	var last_tile_num = tile_map.size()
	if tile_map.has(last_tile_num):
		return tile_map[last_tile_num].global_position

	push_error("[BOARD] Home not found in group 'home' and no fallback tile!")
	return Vector2.ZERO

func get_board_size() -> Vector2:
	var tiles = get_tree().get_nodes_in_group("tiles")

	if tiles.is_empty():
		return Vector2.ZERO

	var min_x = INF
	var max_x = -INF
	var min_y = INF
	var max_y = -INF

	for t in tiles:
		var p = t.global_position
		min_x = min(min_x, p.x)
		max_x = max(max_x, p.x)
		min_y = min(min_y, p.y)
		max_y = max(max_y, p.y)

	return Vector2(max_x - min_x, max_y - min_y)
