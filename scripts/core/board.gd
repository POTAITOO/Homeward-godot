extends Node2D

const GRID_SIZE = 6
const TILE_SIZE = 120

var tiles = []

#func _ready():
#	generate_board()

#func generate_board():
#	for i in range(GRID_SIZE * GRID_SIZE):
#		var tile = get_child(i)
#		tile.position_index = i
#		tiles.append(tile)

#func get_tile_position(index: int) -> Vector2:
	#var x = index % GRID_SIZE
	#var y = int(index / GRID_SIZE)
	#return Vector2(x * TILE_SIZE, y * TILE_SIZE)
