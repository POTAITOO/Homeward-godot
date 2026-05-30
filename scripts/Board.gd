extends Node2D

func get_tile_world_position(tile_num: int) -> Vector2:
	for tile in get_tree().get_nodes_in_group("tiles"):
		if tile.tile_number == tile_num:
			return tile.global_position
	print("WARNING: Tile " + str(tile_num) + " not found!")
	return Vector2.ZERO
