extends Node2D

func _ready():
	print("[BOARD] My name: ", name)
	print("[BOARD] My child count: ", get_child_count())
	
	# Find the actual board content node (the 6x6 scene root)
	var actual_board = _find_actual_board()
	print("[BOARD] Actual board found: ", actual_board)

func _find_actual_board() -> Node:
	# The 6x6 scene root is a child of this node
	for child in get_children():
		print("[BOARD] Child: ", child.name)
	return null

func _recursive_find(node: Node, target_name: String) -> Node2D:
	if node.name == target_name:
		return node as Node2D
	for child in node.get_children():
		var result = _recursive_find(child, target_name)
		if result:
			return result
	return null

func get_tile_world_position(tile_num: int) -> Vector2:
	# Search from scene root instead of self
	var root = get_tree().get_root()
	var all_tiles = get_tree().get_nodes_in_group("tiles")
	for tile in all_tiles:
		if tile.get("tile_number") == tile_num:
			return tile.global_position
	# Fallback: recursive search from root
	return _find_tile_recursive(root, tile_num)

func _find_tile_recursive(node: Node, tile_num: int) -> Vector2:
	if node.get("tile_number") == tile_num:
		return (node as Node2D).global_position
	for child in node.get_children():
		var result = _find_tile_recursive(child, tile_num)
		if result != Vector2.ZERO:
			return result
	return Vector2.ZERO

func get_school_position() -> Vector2:
	var school = _recursive_find(get_tree().get_root(), "School")
	if school == null:
		push_error("School node missing in Board!")
		return Vector2.ZERO
	return school.global_position

func get_home_position() -> Vector2:
	var home = _recursive_find(get_tree().get_root(), "Home")
	if home == null:
		push_error("Home node missing in Board!")
		return Vector2.ZERO
	return home.global_position
