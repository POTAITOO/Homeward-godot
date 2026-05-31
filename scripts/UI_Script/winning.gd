extends Control

@onready var bg_sprite: AnimatedSprite2D = get_node_or_null("Camera2D/BG")
@onready var player_sprite: AnimatedSprite2D = get_node_or_null("AnimatedSprite2D")
@onready var play_button: TextureButton = get_node_or_null("Play")

func _ready() -> void:
	var fade_overlay := ColorRect.new()
	fade_overlay.color = Color(0, 0, 0, 1)
	fade_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	fade_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(fade_overlay)
	move_child(fade_overlay, 0)

	# Play background loop if available
	if bg_sprite and bg_sprite.sprite_frames:
		if bg_sprite.sprite_frames.has_animation("default"):
			bg_sprite.play("default")
	# Set player animation based on the winner's display name.
	var anim: String = String(GlobalData.winner_name).strip_edges()
	if player_sprite and player_sprite.sprite_frames and anim != "":
		if player_sprite.sprite_frames.has_animation(anim):
			player_sprite.animation = anim
			player_sprite.play()
	# Connect play button to restart
	if play_button:
		play_button.pressed.connect(_on_play_pressed)

	# Fade the winning scene in after it has loaded so the transition feels continuous.
	await get_tree().process_frame
	var tw := get_tree().create_tween()
	tw.tween_property(fade_overlay, "color", Color(0, 0, 0, 0), 0.8)
	await tw.finished
	fade_overlay.queue_free()

func _on_play_pressed() -> void:
	# Reset global state and go back to player select
	GlobalData.reset()
	get_tree().change_scene_to_file("res://scenes/Scene_UI/select_number.tscn")
