# NormalTile.gd
class_name NormalTile
extends "res://scripts/Tile.gd"

func on_land(player) -> void:
	print("Player %s landed on Normal Tile %d" % [player.name, tile_index])
	# No special effect
