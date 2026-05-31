extends Control

func _ready():

	GlobalData.turn_order.clear()

	for i in range(GlobalData.player_count):
		GlobalData.turn_order.append(i)

	GlobalData.turn_order.shuffle()

	show_turn_order()

func show_turn_order():

	print("TURN ORDER")

	for i in GlobalData.turn_order.size():

		var player_name = GlobalData.selected_characters[
			GlobalData.turn_order[i]
		]

		print(
			str(i + 1) + ". " + player_name
		)

func _on_continue_pressed():

	get_tree().change_scene_to_file(
		"res://scenes/MapSelect.tscn"
	)
