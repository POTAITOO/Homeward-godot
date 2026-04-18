# WaypointTile.gd
class_name WaypointTile
extends "res://scripts/Tile.gd"

@export var waypoint_id: int = 0              # tiles sharing the same ID are linked
@export var linked_tile_index: int = -1       # index of the destination tile

func on_land(player) -> void:
	if linked_tile_index != -1:
		print("Waypoint: Teleporting %s to tile %d" % [player.name, linked_tile_index])
		player.teleport_to(linked_tile_index)
	else:
		print("Waypoint %d has no linked tile set!" % waypoint_id)
