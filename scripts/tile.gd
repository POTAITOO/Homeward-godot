# Tile.gd
extends Node2D

@export var tile_index: int = 0       # position in the board sequence
@export var tile_label: String = ""   # optional display name

# Called when a player lands on this tile
# Override this in each subclass
# Tile.gd
func on_land(_player) -> void:
	pass

func on_pass(_player) -> void:
	pass
