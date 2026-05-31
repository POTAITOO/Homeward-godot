extends Control

# Preload all 4 spritesheets for preview
var avatar_frames := [
	preload("res://assets/Players/Student_1.tres"),
	preload("res://assets/Players/Student_2.tres"),
	preload("res://assets/Players/Student_3.tres"),
	preload("res://assets/Players/Student_4.tres")
]

# Tracks which avatar each slot has selected (-1 = not yet selected)
var selections := []

# Tracks how many players have confirmed so far
var confirmed_count := 0
var selection_complete := false
@export var deterministic_seed: int = -1

@onready var background_sprite: AnimatedSprite2D = $BG
@onready var preview_sprite: AnimatedSprite2D = $Window/Mascot/TextureRect/AnimatedSprite2D
@onready var back_button: TextureButton = $Window/Back
@onready var help_button: TextureButton = $Window/Help
@onready var continue_button: TextureButton = $Window/Continue
@onready var slot_nodes = [
	$Window/P1,
	$Window/P2,
	$Window/P3,
	$Window/P4,
]

@onready var slot_buttons = [
	$Window/P1/CollisionShape2D/TextureButton,
	$Window/P2/CollisionShape2D/TextureButton,
	$Window/P3/CollisionShape2D/TextureButton,
	$Window/P4/CollisionShape2D/TextureButton,
]

@onready var slot_labels = [
	$Window/P1/CollisionShape2D/Order,
	$Window/P2/CollisionShape2D/Order,
	$Window/P3/CollisionShape2D/Order,
	$Window/P4/CollisionShape2D/Order,
]

@onready var slot_sprites = [
	$Window/P1/CollisionShape2D/AnimatedSprite2D,
	$Window/P2/CollisionShape2D/AnimatedSprite2D,
	$Window/P3/CollisionShape2D/AnimatedSprite2D,
	$Window/P4/CollisionShape2D/AnimatedSprite2D,
]

func _ready():
	print("[AVATAR_SELECT] Ready. player_count=", GlobalData.player_count)
	selections.resize(4)
	selections.fill(-1)
	background_sprite.play("idle")
	preview_sprite.play("idle")
	continue_button.visible = false
	continue_button.disabled = true

	back_button.pressed.connect(_on_back_pressed)
	help_button.pressed.connect(_on_help_pressed)
	continue_button.pressed.connect(_on_continue_pressed)
	for i in range(slot_buttons.size()):
		slot_buttons[i].pressed.connect(_on_slot_pressed.bind(i))
	
	_update_slots_visibility()
	_hide_turn_labels()
	print("[AVATAR_SELECT] Avatar slots ready: 4 visible, order labels hidden until complete")

func _update_slots_visibility():
	for i in range(4):
		slot_nodes[i].visible = true
		print("[AVATAR_SELECT] Slot ", i + 1, " visible")


func _hide_turn_labels() -> void:
	for label in slot_labels:
		label.visible = false


func _on_slot_pressed(avatar_index: int) -> void:
	on_select_pressed(avatar_index)

func on_select_pressed(avatar_index: int):
	if selection_complete:
		print("[AVATAR_SELECT] Ignored avatar ", avatar_index, " because selection is complete")
		return
	# Ignore if already taken
	if selections[avatar_index] != -1:
		print("[AVATAR_SELECT] Ignored avatar ", avatar_index, " because it is already taken")
		return
	# Ignore if this player already selected
	if confirmed_count >= GlobalData.player_count:
		print("[AVATAR_SELECT] Ignored avatar ", avatar_index, " because confirmed_count=", confirmed_count, " reached player_count=", GlobalData.player_count)
		return

	print("[AVATAR_SELECT] Player ", confirmed_count + 1, " selected avatar ", avatar_index)
	selections[avatar_index] = confirmed_count
	confirmed_count += 1

	# Show preview of selected avatar
	preview_sprite.sprite_frames = avatar_frames[avatar_index]
	preview_sprite.play("idle")

	# Save to GlobalData
	GlobalData.selected_characters.append(avatar_index)
	print("[AVATAR_SELECT] GlobalData.selected_characters=", GlobalData.selected_characters)

	# Disable select button for this slot
	slot_buttons[avatar_index].disabled = true
	print("[AVATAR_SELECT] Disabled avatar button for slot ", avatar_index)

	# Check if all players have selected
	if confirmed_count >= GlobalData.player_count:
		_finalize_selection()

func _update_turn_labels() -> void:
	for label in slot_labels:
		label.visible = false

	for turn_pos in range(GlobalData.turn_order.size()):
		var selection_index = GlobalData.turn_order[turn_pos]
		var avatar_index = GlobalData.selected_characters[selection_index]
		slot_labels[avatar_index].text = "P%d" % (turn_pos + 1)
		slot_labels[avatar_index].visible = true

	print("[AVATAR_SELECT] Turn order labels shown")

func _finalize_selection():
	# Use RandomNumberGenerator to shuffle so we can support deterministic seeds for testing
	var order = range(GlobalData.player_count)
	var rng = RandomNumberGenerator.new()
	if deterministic_seed >= 0:
		rng.seed = int(deterministic_seed)
		print("[AVATAR_SELECT] Using deterministic seed:", deterministic_seed)
	else:
		rng.randomize()
		rng.seed = rng.seed
		print("[AVATAR_SELECT] Using non-deterministic RNG; seed=", rng.seed)

	# Fisher–Yates shuffle using rng so we can control the seed
	for i in range(order.size() - 1, 0, -1):
		var j = rng.randi_range(0, i)
		var tmp = order[i]
		order[i] = order[j]
		order[j] = tmp
	GlobalData.turn_order = order
	print("[SELECTION] Turn order: ", GlobalData.turn_order)
	print("[SELECTION] Characters: ", GlobalData.selected_characters)
	_update_turn_labels()
	selection_complete = true
	for button in slot_buttons:
		button.disabled = true
	print("[AVATAR_SELECT] All avatar buttons disabled")
	continue_button.visible = true
	continue_button.disabled = false
	print("[AVATAR_SELECT] Continue button enabled")


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Scene_UI/select_number.tscn")


func _on_help_pressed() -> void:
	pass


func _on_continue_pressed() -> void:
	if not selection_complete:
		print("[AVATAR_SELECT] Continue pressed before selection complete; ignored")
		return
	print("[AVATAR_SELECT] Continue pressed. Loading MapSelect")
	get_tree().change_scene_to_file("res://scenes/main/MapSelect.tscn")
