# BaseMap.gd
extends Node2D

@export var COLS: int = 6
@export var ROWS: int = 6
@export var TILE_SIZE: int = 96

const TILE_SCENES = {
	"normal":    preload("res://scenes/NormalTile.tscn"),
	"power":     preload("res://scenes/PowerTile.tscn"),
	"waypoint":  preload("res://scenes/WaypointTile.tscn"),
	"home":      preload("res://scenes/HomeTile.tscn"),
	"start":     preload("res://scenes/StartTile.tscn"),
}

# Fixed power tile assignments for 6x6 map
# Key = tile index, Value = PowerType enum int
const POWER_TILE_ASSIGNMENTS = {
	7:  0,  # BUS_STOP        → +3 forward
	14: 5,  # HEAVY_TRAFFIC   → -2 backward
	21: 2,  # ENERGY_DRINK    → roll again
	28: 6,  # RAIN_SHOWER     → skip turn
	35: 3,  # FRIENDS_BIKE    → move by last roll (won't reach, home is 35 — shift if needed)
	# Additional power tiles using other multiples
	4:  4,  # GREEN_LIGHT     → immune to obstacles
	9:  7,  # FORGOT_HOMEWORK → back to prev waypoint
	13: 8,  # CONSTRUCTION    → half move
	18: 9,  # LOST_PHONE      → no waypoints
	22: 10, # MYSTERY_TILE    → random effect
	26: 11, # RIDE_SHARE      → choose +2 or swap
	30: 12, # SAFE_ZONE       → protected 1 turn
	33: 13, # STUDY_BREAK     → choose roll or +2
	16: 14, # GROUP_STUDY     → both players roll
	20: 1,  # SHORTCUT_ALLEY → next waypoint
}

var tile_path: Array = []

func _ready() -> void:
	generate_map()

func generate_map() -> void:
	var positions = get_snaking_positions()
	for i in range(positions.size()):
		var tile_type = get_tile_type(i)
		var tile = TILE_SCENES[tile_type].instantiate()
		tile.tile_index = i
		tile.position = positions[i]
		tile.name = tile_type + "_" + str(i)

		# Assign fixed power type if it's a power tile
		if tile_type == "power" and POWER_TILE_ASSIGNMENTS.has(i):
			tile.power_type = POWER_TILE_ASSIGNMENTS[i]
			print("Power tile at %d assigned type: %d" % [i, tile.power_type])

		$TileContainer.add_child(tile)
		tile_path.append(tile)
	print("Map generated! Total tiles: ", tile_path.size())

func get_tile_type(index: int) -> String:
	var total = COLS * ROWS
	if index == 0:
		return "start"
	elif index == total - 1:
		return "home"
	elif POWER_TILE_ASSIGNMENTS.has(index):
		return "power"      # use assignment dict to decide power tiles
	elif index % 11 == 0:
		return "waypoint"
	else:
		return "normal"

func get_snaking_positions() -> Array:
	var positions = []
	var offset = Vector2(
		(get_viewport().size.x - COLS * TILE_SIZE) / 2,
		(get_viewport().size.y - ROWS * TILE_SIZE) / 2
	)
	for row in range(ROWS - 1, -1, -1):
		var cols = range(COLS) if (ROWS - 1 - row) % 2 == 0 else range(COLS - 1, -1, -1)
		for col in cols:
			positions.append(offset + Vector2(col * TILE_SIZE, row * TILE_SIZE))
	return positions
