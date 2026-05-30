extends Node2D

var tile_map: Dictionary = {}
var school_node: Node2D = null
var home_node: Node2D = null

func _ready():
	_cache_nodes()
	print("[BOARD] Ready — " + str(tile_map.size()) + " tiles cached")


func _cache_nodes():
	# Cache tiles
	for tile in get_tree().get_nodes_in_group("tiles"):
		if tile.has_method("get") and tile.get("tile_number") != null:
			tile_map[tile.get("tile_number")] = tile

	# Cache School/Home using groups (RECOMMENDED)
	var schools = get_tree().get_nodes_in_group("school")
	if schools.size() > 0:
		school_node = schools[0]

	var homes = get_tree().get_nodes_in_group("home")
	if homes.size() > 0:
		home_node = homes[0]


func get_tile_world_position(tile_num: int) -> Vector2:
	if tile_map.has(tile_num):
		return tile_map[tile_num].global_position

	push_error("[BOARD] Tile " + str(tile_num) + " not found!")
	return Vector2.ZERO


func get_school_position() -> Vector2:
	for node in get_tree().get_nodes_in_group("tiles"):
		if node.name == "School":
			return node.global_position

	push_error("[BOARD] School not found!")
	return Vector2.ZERO


func get_home_position() -> Vector2:
	if home_node != null:
		return home_node.global_position

	push_error("[BOARD] Home not found in group 'home'")
	return Vector2.ZERO
