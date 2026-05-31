extends Control

# Preload all 4 spritesheets for preview
var avatar_frames := [
	preload("res://assets/Players/Student_1.tres"),
	preload("res://assets/Players/Student_2.tres"),
	preload("res://assets/Players/Student_3.tres"),
	preload("res://assets/Players/Student_4.tres")
]

# Tracks which avatar each slot has selected (-1 = not yet selected)
var selections := []  # index = avatar slot, value = player who picked it

# Tracks how many players have confirmed so far
var confirmed_count := 0

@onready var preview_sprite = $PreviewSprite  # the big preview top left
@onready var slots = [
	$Slots/Slot0,
	$Slots/Slot1,
	$Slots/Slot2,
	$Slots/Slot3,
]

func _ready():
	selections.resize(4)
	selections.fill(-1)
	_update_slots_visibility()

func _update_slots_visibility():
	# Only show slots up to player_count
	for i in range(4):
		slots[i].visible = i < GlobalData.player_count

func on_select_pressed(avatar_index: int):
	# Ignore if already taken
	if selections[avatar_index] != -1:
		return
	# Ignore if this player already selected
	if confirmed_count >= GlobalData.player_count:
		return

	selections[avatar_index] = confirmed_count
	confirmed_count += 1

	# Show preview of selected avatar
	preview_sprite.sprite_frames = avatar_frames[avatar_index]
	preview_sprite.play("idle")

	# Save to GlobalData
	GlobalData.selected_characters.append(avatar_index)

	# Update label above slot
	var label = slots[avatar_index].get_node("PlayerLabel")
	label.text = "P%d" % confirmed_count
	label.visible = true

	# Disable select button for this slot
	slots[avatar_index].get_node("SelectButton").disabled = true

	# Check if all players have selected
	if confirmed_count >= GlobalData.player_count:
		_finalize_selection()

func _finalize_selection():
	# Randomize turn order
	var order = range(GlobalData.player_count)
	order.shuffle()
	GlobalData.turn_order = order

	# Remap player labels based on randomized turn order
	var picked_avatars = []
	for i in range(4):
		if selections[i] != -1:
			picked_avatars.append(i)  # collect chosen avatar indices in selection order

	for turn_pos in range(GlobalData.player_count):
		var original_player = GlobalData.turn_order[turn_pos]
		var avatar_slot_index = picked_avatars[original_player]
		var label = slots[avatar_slot_index].get_node("PlayerLabel")
		label.text = "P%d" % (turn_pos + 1)

	print("[SELECTION] Turn order: ", GlobalData.turn_order)
	print("[SELECTION] Characters: ", GlobalData.selected_characters)

	# Wait a moment then go to game
	await get_tree().create_timer(1.5).timeout
	get_tree().change_scene_to_file("res://scenes/Game.tscn")
