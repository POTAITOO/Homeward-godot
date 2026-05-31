extends Node

var player_count := 2
var selected_characters := []  # avatar indices in selection order
var turn_order := []           # randomized, maps turn position → selection order
var selected_map := "6x6"
var winner_name := ""

func reset():
	selected_characters.clear()
	turn_order.clear()
	winner_name = ""

func get_character_for_turn(turn_index: int) -> int:
	# Returns the avatar character_id for a given turn position
	var selection_index = turn_order[turn_index]
	return selected_characters[selection_index]
