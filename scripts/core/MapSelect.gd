extends Control

func _on_6x6_pressed():

	GlobalData.selected_map = "6x6"

	start_game()

func _on_8x8_pressed():

	GlobalData.selected_map = "8x8"

	start_game()

func _on_10x10_pressed():

	GlobalData.selected_map = "10x10"

	start_game()

func start_game():

	get_tree().change_scene_to_file(
		"res://scenes/GameScene.tscn"
	)
