extends Node2D

var player_id: int
var player_name: String
var position_index: int = 0

#Future ready (optional for now)
var energy: int = 100
var money: int = 0

func _init(id: int, name: String):
	player_id = id
	player_name = name
	
func move(steps: int):
	position_index += steps
	print(player_name, "moved to Tile:", position_index)
