extends Node

var player_count := 2
var selected_characters := []  # avatar indices in selection order
var turn_order := []           # randomized, maps turn position → selection order
var selected_map := "6x6"
var winner_name := ""
var selected_names := []      # human display names corresponding to selected_characters

func reset():
	player_count = 2
	selected_characters.clear()
	turn_order.clear()
	selected_map = "6x6"
	winner_name = ""
	selected_names.clear()

func get_character_for_turn(turn_index: int) -> int:
	# Returns the avatar character_id for a given turn position
	if turn_index < 0 or turn_index >= turn_order.size():
		push_error("Invalid turn index: %d" % turn_index)
		return -1
	var selection_index = turn_order[turn_index]
	if selection_index < 0 or selection_index >= selected_characters.size():
		push_error("Invalid selection index: %d" % selection_index)
		return -1
	return selected_characters[selection_index]
