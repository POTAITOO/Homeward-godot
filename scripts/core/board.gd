extends Node2D

const GRID_SIZE = 6
const TILE_SIZE = 120

var tiles = []

func get_tile_position(index: int) -> Vector2:
	var clamped_index := clamp(index, 0, GRID_SIZE * GRID_SIZE - 1)
	var x := clamped_index % GRID_SIZE
	var y := int(clamped_index / GRID_SIZE)
	return Vector2(x * TILE_SIZE, y * TILE_SIZE)
