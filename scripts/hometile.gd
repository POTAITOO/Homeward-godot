# HomeTile.
class_name HomeTile
extends "res://scripts/Tile.gd"


func on_land(player) -> void:
	print("Player %s reached Home! 🎉" % player.name)
	player.has_won = true
	# You can emit a signal here to notify the GameManager
	# GameManager.declare_winner(player)
