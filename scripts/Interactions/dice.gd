extends Area2D

@onready var animated_sprite = $AnimatedSprite2D
var is_rolling = false
var _orig_global_pos: Vector2
var _orig_scale: Vector2
var _last_result: int = 0
var _roll_session_id: int = -1
var _result_shown: bool = false

func _ready():
	animated_sprite.animation_finished.connect(_on_animation_finished)
	# Start from idle by default. Store last numeric result separately.
	_last_result = 0
	animated_sprite.play("idle")

	# Cache original transform so we can move/scale the dice during roll.
	_orig_global_pos = global_position
	_orig_scale = scale

func _input(event):
	if not event.is_action_pressed("roll_dice"):
		return

	if is_rolling:
		return

	# Only allow rolling when the GameManager is waiting for a roll (player's turn)
	var gm = get_tree().get_current_scene().get_node_or_null("GameManager")
	if gm == null:
		return
	if not gm.waiting_for_roll:
		return

	roll()

func roll():
	is_rolling = true
	_result_shown = false
	print("[DICE] roll started")
	# Capture the current GameManager roll session so we can submit back with a token
	var gm = get_tree().get_current_scene().get_node_or_null("GameManager")
	if gm:
		_roll_session_id = gm.current_roll_session

	# Move to screen center and scale up, then start rolling animation
	var viewport_size = get_viewport().get_visible_rect().size
	var center = viewport_size * 0.5

	var t = create_tween()
	t.tween_property(self, "global_position", center, 0.22).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	t.tween_property(self, "scale", _orig_scale * 1.2, 0.22)
	# After the move+scale completes, start the rolling animation
	t.connect("finished", Callable(self, "_start_rolling_anim"))

func _start_rolling_anim() -> void:
	animated_sprite.play("rolling")
	print("[DICE] rolling animation started")

func _on_animation_finished():
	var anim = animated_sprite.animation
	if anim == "rolling":
		_last_result = randi_range(1, 6)
		animated_sprite.play("result_" + str(_last_result))
		# keep is_rolling true until we've returned to origin and submitted
		return

	if anim.begins_with("result_"):
		# Prevent re-handling the same result animation multiple times
		if _result_shown:
			return
		# After showing the result, tween back to original position/scale, then submit the roll
		var t_back = create_tween()
		t_back.tween_property(self, "global_position", _orig_global_pos, 0.22).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		t_back.tween_property(self, "scale", _orig_scale, 0.22)
		await t_back.finished

		# Submit the roll to GameManager (it will ignore if not waiting)
		var gm = get_tree().get_current_scene().get_node_or_null("GameManager")
		if gm:
			print("[DICE] submitting roll", _last_result, "to GameManager (session", _roll_session_id, ")")
			gm.submit_roll(_last_result, _roll_session_id)
		else:
			push_warning("Dice: GameManager not found to submit roll")

		# Reset state and show the last result face at origin so it's visible to players.
		is_rolling = false
		var face_name = "result_" + str(max(1, _last_result))
		# Show the result frame but mark as shown so we don't re-enter this handler
		animated_sprite.play(face_name)
		# Stop further playback so the single-frame result doesn't immediately trigger animation_finished again
		animated_sprite.stop()
		_result_shown = true
		print("[DICE] returned to origin, showing", face_name)
