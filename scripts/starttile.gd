# StartTile.gd
class_name StartTile
extends "res://scripts/Tile.gd"

func on_land(player) -> void:
	print("Player %s is at Start." % player.name)
	# No effect — starting position
