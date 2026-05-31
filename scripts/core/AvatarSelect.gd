extends Control

# Preload all 4 spritesheets for preview
var avatar_frames := [
	preload("res://assets/Players/Student_1.tres"),
	preload("res://assets/Players/Student_2.tres"),
	preload("res://assets/Players/Student_3.tres"),
	preload("res://assets/Players/Student_4.tres")
]

# Human-readable names for avatars (index matches the avatar resource order)
var avatar_names := ["Serena", "Calem", "Lucas", "Ethan"]

# Tracks which avatar each slot has selected (-1 = not yet selected)
var selections := []

# Tracks how many players have confirmed so far
var confirmed_count := 0
var selection_complete := false
@export var deterministic_seed: int = -1


var background_sprite: AnimatedSprite2D = null
var preview_sprite: AnimatedSprite2D = null
var back_button: TextureButton = null
var continue_button: TextureButton = null

# store path lists so we can resolve safely at runtime
var slot_node_paths := [
	"Window/P1",
	"Window/P2",
	"Window/P3",
	"Window/P4",
]
var slot_button_paths := [
	"Window/P1/CollisionShape2D/TextureButton",
	"Window/P2/CollisionShape2D/TextureButton",
	"Window/P3/CollisionShape2D/TextureButton",
	"Window/P4/CollisionShape2D/TextureButton",
]
var slot_label_paths := [
	"Window/P1/CollisionShape2D/Order",
	"Window/P2/CollisionShape2D/Order",
	"Window/P3/CollisionShape2D/Order",
	"Window/P4/CollisionShape2D/Order",
]
var slot_sprite_paths := [
	"Window/P1/CollisionShape2D/AnimatedSprite2D",
	"Window/P2/CollisionShape2D/AnimatedSprite2D",
	"Window/P3/CollisionShape2D/AnimatedSprite2D",
	"Window/P4/CollisionShape2D/AnimatedSprite2D",
]

# resolved node refs (may contain nulls if missing in scene)
var slot_nodes := []
var slot_buttons := []
var slot_labels := []
var slot_sprites := []

func _ready():
	print("[AVATAR_SELECT] Ready. player_count=", GlobalData.player_count)
	selections.resize(4)
	selections.fill(-1)
	# Resolve nodes safely (use get_node_or_null to survive scene edits/merges)
	background_sprite = get_node_or_null("BG")
	if background_sprite:
		background_sprite.play("idle")
	else:
		print("[AVATAR_SELECT] Warning: BG node missing")

	preview_sprite = get_node_or_null("Window/Mascot/TextureRect/AnimatedSprite2D")
	if preview_sprite:
		preview_sprite.play("idle")
	else:
		print("[AVATAR_SELECT] Warning: preview sprite node missing: Window/Mascot/TextureRect/AnimatedSprite2D")

	continue_button = get_node_or_null("Window/Continue")
	if continue_button:
		continue_button.visible = false
		continue_button.disabled = true
	else:
		print("[AVATAR_SELECT] Warning: Continue button node missing: Window/Continue")

	back_button = get_node_or_null("Window/Back")
	if back_button == null:
		print("[AVATAR_SELECT] Warning: Back button missing: Window/Back")

	# resolve slot nodes/buttons/labels/sprites
	for path in slot_node_paths:
		var n = get_node_or_null(path)
		slot_nodes.append(n)
		if n == null:
			print("[AVATAR_SELECT] Warning: missing slot node: ", path)

	for path in slot_button_paths:
		var b = get_node_or_null(path)
		slot_buttons.append(b)
		if b == null:
			print("[AVATAR_SELECT] Warning: missing slot button: ", path)

	for path in slot_label_paths:
		var l = get_node_or_null(path)
		slot_labels.append(l)
		if l == null:
			print("[AVATAR_SELECT] Warning: missing slot label: ", path)

	for path in slot_sprite_paths:
		var s = get_node_or_null(path)
		slot_sprites.append(s)
		if s == null:
			print("[AVATAR_SELECT] Warning: missing slot sprite: ", path)
		else:
			s.play("idle")

	# connect signals only for nodes that exist
	if back_button:
		back_button.pressed.connect(_on_back_pressed)
	if continue_button:
		continue_button.pressed.connect(_on_continue_pressed)

	for i in range(slot_buttons.size()):
		if slot_buttons[i]:
			slot_buttons[i].pressed.connect(_on_slot_pressed.bind(i))

	_update_slots_visibility()
	_restore_selection_state()
	print("[AVATAR_SELECT] Avatar slots ready: ", slot_nodes.size(), " checked; order labels hidden until complete")


func _restore_selection_state() -> void:
	# Rebuild local selection cache from GlobalData so returning from map select keeps state.
	selections.fill(-1)
	confirmed_count = 0
	selection_complete = false
	_hide_turn_labels()

	for button in slot_buttons:
		if button:
			button.disabled = false

	if continue_button:
		continue_button.visible = false
		continue_button.disabled = true

	for selection_index in range(GlobalData.selected_characters.size()):
		var avatar_index = GlobalData.selected_characters[selection_index]
		if avatar_index >= 0 and avatar_index < selections.size():
			selections[avatar_index] = selection_index
			if avatar_index < slot_buttons.size() and slot_buttons[avatar_index]:
				slot_buttons[avatar_index].disabled = true

	confirmed_count = GlobalData.selected_characters.size()

	if confirmed_count >= GlobalData.player_count and GlobalData.turn_order.size() == GlobalData.player_count:
		selection_complete = true
		_update_turn_labels()
		for button in slot_buttons:
			if button:
				button.disabled = true
		if continue_button:
			continue_button.visible = true
			continue_button.disabled = false
		print("[AVATAR_SELECT] Restored completed selection state")
	else:
		print("[AVATAR_SELECT] Restored partial selection state")

func _update_slots_visibility():
	for i in range(4):
		var node = null
		if i < slot_nodes.size():
			node = slot_nodes[i]
		if node:
			node.visible = true
			print("[AVATAR_SELECT] Slot ", i + 1, " visible")
		else:
			print("[AVATAR_SELECT] Slot node missing for index ", i)


func _hide_turn_labels() -> void:
	for label in slot_labels:
		if label:
			label.visible = false
		else:
			# silently skip missing labels
			pass


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

	# Keep mascot preview static in this scene (do not switch on selection)

	# Save to GlobalData
	GlobalData.selected_characters.append(avatar_index)
	# Save the human display name for this avatar selection (keeps order consistent with selected_characters)
	var display_name = "Player %d" % (confirmed_count)
	if avatar_index >= 0 and avatar_index < avatar_names.size():
		display_name = avatar_names[avatar_index]
	GlobalData.selected_names.append(display_name)
	print("[AVATAR_SELECT] GlobalData.selected_characters=", GlobalData.selected_characters, " names=", GlobalData.selected_names)

	# Disable select button for this slot
	if avatar_index < slot_buttons.size() and slot_buttons[avatar_index]:
		slot_buttons[avatar_index].disabled = true
	print("[AVATAR_SELECT] Disabled avatar button for slot ", avatar_index)

	# Check if all players have selected
	if confirmed_count >= GlobalData.player_count:
		_finalize_selection()

func _update_turn_labels() -> void:
	for label in slot_labels:
		if label:
			label.visible = false

	for turn_pos in range(GlobalData.turn_order.size()):
		var selection_index = GlobalData.turn_order[turn_pos]
		var avatar_index = GlobalData.selected_characters[selection_index]
		if avatar_index < slot_labels.size() and slot_labels[avatar_index]:
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

	# Debug mapping: show explicit mapping turn -> selection_index -> avatar_index -> name
	for t in range(GlobalData.turn_order.size()):
		var sel_idx: int = GlobalData.turn_order[t]
		var avatar_idx: int = -1
		var avatar_name := "<unknown>"
		if sel_idx >= 0 and sel_idx < GlobalData.selected_characters.size():
			avatar_idx = GlobalData.selected_characters[sel_idx]
			if sel_idx < GlobalData.selected_names.size():
				avatar_name = GlobalData.selected_names[sel_idx]
		print("[SELECTION_MAP] Turn %d -> selection_index %d -> avatar_index %d -> name %s" % [t, sel_idx, avatar_idx, avatar_name])
	_update_turn_labels()
	selection_complete = true
	for button in slot_buttons:
		if button:
			button.disabled = true
	print("[AVATAR_SELECT] All avatar buttons disabled")
	if continue_button:
		continue_button.visible = true
		continue_button.disabled = false
	print("[AVATAR_SELECT] Continue button enabled")


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Scene_UI/select_number.tscn")

func _on_continue_pressed() -> void:
	if not selection_complete:
		print("[AVATAR_SELECT] Continue pressed before selection complete; ignored")
		return
	print("[AVATAR_SELECT] Continue pressed. Loading MapSelect")
	get_tree().change_scene_to_file("res://scenes/Scene_UI/select_map.tscn")
