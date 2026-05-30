extends Node2D

func _ready():
	print("[BOARD] Ready — " + str(get_tree().get_nodes_in_group("tiles").size()) + " tiles in group")

func get_tile_world_position(tile_num: int) -> Vector2:
	for tile in get_tree().get_nodes_in_group("tiles"):
		if tile.get("tile_number") == tile_num:
			return tile.global_position
	push_error("[BOARD] Tile " + str(tile_num) + " not found!")
	return Vector2.ZERO

func get_school_position() -> Vector2:
	for node in get_tree().get_nodes_in_group("tiles"):
		if node.name == "School":
			return node.global_position
	# Fallback — search whole tree
	var school = _find_by_name(get_tree().get_root(), "School")
	if school == null:
		push_error("[BOARD] School node not found!")
		return Vector2.ZERO
	return school.global_position

func get_home_position() -> Vector2:
	var home = _find_by_name(get_tree().get_root(), "Home")
	if home == null:
		push_error("[BOARD] Home node not found!")
		return Vector2.ZERO
	return home.global_position

func _find_by_name(node: Node, target: String) -> Node2D:
	if node.name == target:
		return node as Node2D
	for child in node.get_children():
		var result = _find_by_name(child, target)
		if result:
			return result
	return null
