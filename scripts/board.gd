extends Node2D

const TILE_SIZE = 80
const GAP       = 4
const COLS      = 6
const ROWS      = 6

const TileScene = preload("res://scenes/Tile.tscn")

const TILE_TYPES = {
	1: "normal",     2: "bus_green",  3: "normal",
	4: "puddle",     5: "normal",     6: "normal",
	7: "bicycle",    8: "normal",     9: "traffic",
	10: "normal",   11: "normal",    12: "normal",
	13: "normal",   14: "vending",   15: "normal",
	16: "normal",   17: "stray_dog", 18: "normal",
	19: "bus_violet",20: "normal",   21: "normal",
	22: "normal",   23: "bicycle",   24: "normal",
	25: "bus_green", 26: "normal",   27: "traffic",
	28: "bicycle",   29: "normal",   30: "normal",
	31: "normal",    32: "vending",  33: "normal",
	34: "bus_violet",35: "puddle",   36: "normal",
}

func _ready() -> void:
	for n in range(1, 37):
		var tile = TileScene.instantiate()
		add_child(tile)
		tile.setup(n, TILE_TYPES.get(n, "normal"))
		tile.position = _get_position(n)

func _get_position(n: int) -> Vector2:
	var idx = n - 1
	var row = idx / COLS
	var col = idx % COLS
	if row % 2 == 1:
		col = (COLS - 1) - col
	var step = TILE_SIZE + GAP
	return Vector2(col * step, (ROWS - 1 - row) * step)
