extends Control

func _ready():
	print("[MAPSELECT] Ready. selected_map=", GlobalData.selected_map)
	# Start map-page animations in idle loop
	var animated_nodes = [
		"BG",
		"Window/Easy/AnimatedSprite2D",
		"Window/Chaotic/AnimatedSprite2D",
		"Window/Fun/AnimatedSprite2D"
	]
	for path in animated_nodes:
		var anim = get_node_or_null(path)
		if anim:
			anim.play("idle")
		else:
			print("[MAPSELECT] AnimatedSprite2D not found: ", path)

	# connect buttons safely for the real select_map.tscn layout
	var easy_button = get_node_or_null("Window/Easy/TextureButton")
	var chaotic_button = get_node_or_null("Window/Chaotic/TextureButton")
	var fun_button = get_node_or_null("Window/Fun/TextureButton")

	if easy_button:
		easy_button.pressed.connect(_on_easy_pressed)
		print("[MAPSELECT] Connected Easy button")
	else:
		print("[MAPSELECT] Easy button not found")
	if chaotic_button:
		chaotic_button.pressed.connect(_on_chaotic_pressed)
		print("[MAPSELECT] Connected Chaotic button")
	else:
		print("[MAPSELECT] Chaotic button not found")
	if fun_button:
		fun_button.pressed.connect(_on_fun_pressed)
		print("[MAPSELECT] Connected Fun button")
	else:
		print("[MAPSELECT] Fun button not found")

	var back_button = get_node_or_null("Window/Back")
	if back_button:
		back_button.pressed.connect(_on_back_pressed)
		print("[MAPSELECT] Connected Back button")
	else:
		print("[MAPSELECT] Back button not found")

	var help_button = get_node_or_null("Window/Help")
	if help_button:
		help_button.pressed.connect(_on_help_pressed)
		print("[MAPSELECT] Connected Help button")
	else:
		print("[MAPSELECT] Help button not found")


func _on_easy_pressed():
	GlobalData.selected_map = "6x6"
	print("[MAPSELECT] Easy selected -> selected_map=6x6")
	start_game()

func _on_chaotic_pressed():
	GlobalData.selected_map = "8x8"
	print("[MAPSELECT] Chaotic selected -> selected_map=8x8")
	start_game()

func _on_fun_pressed():
	GlobalData.selected_map = "10x10"
	print("[MAPSELECT] Fun selected -> selected_map=10x10")
	start_game()

func start_game():
	print("[MAPSELECT] Starting game with selected_map=", GlobalData.selected_map)
	# load the main game scene
	get_tree().change_scene_to_file("res://scenes/main/game_scene.tscn")


func _on_back_pressed() -> void:
	print("[MAPSELECT] Back pressed -> returning to avatar select")
	get_tree().change_scene_to_file("res://scenes/Scene_UI/select_avatar.tscn")


func _on_help_pressed() -> void:
	print("[MAPSELECT] Help pressed")
