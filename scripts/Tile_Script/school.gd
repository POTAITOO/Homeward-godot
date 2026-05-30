extends Node2D

# School is the start point — players spawn here
# No tile_number needed, no group needed

func get_spawn_position() -> Vector2:
	return global_position
