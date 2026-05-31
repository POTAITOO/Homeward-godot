extends CharacterBody2D

@onready var sprite: AnimatedSprite2D = $Sprite

const TILE_OFFSET := Vector2(0, 32)

var grid_position := 0
var last_position := 0
var target_position := Vector2.ZERO
var is_moving := false
var board = null
var max_tile := 0
var school_position := Vector2.ZERO
var move_queue: Array = []
var _step_direction: int = 0
var home_position := Vector2.ZERO  # set this from outside, like school_position

@export var character_id := 0

func _ready():
	call_deferred("_apply_character")

func _apply_character():
	match character_id:
		0: sprite.sprite_frames = preload("res://assets/Players/Student_1.tres")
		1: sprite.sprite_frames = preload("res://assets/Players/Student_2.tres")
		2: sprite.sprite_frames = preload("res://assets/Players/Student_3.tres")
		3: sprite.sprite_frames = preload("res://assets/Players/Student_4.tres")

func setup(p_board, p_school_pos: Vector2, p_home_pos: Vector2 = Vector2.ZERO) -> void:
	board = p_board
	school_position = p_school_pos
	home_position = p_home_pos
	global_position = school_position + TILE_OFFSET
	target_position = school_position + TILE_OFFSET
	_play_idle()

func take_turn(roll: int) -> void:
	if board == null:
		push_error("Board not assigned!")
		return

	last_position = grid_position

	move_queue.clear()
	_step_direction = 1

	var current = grid_position
	print("[PLAYER] starting take_turn. grid_position:", grid_position, "roll:", roll)
	for i in range(roll):
		current += 1
		current = min(current, max_tile)
		move_queue.append(current)

	print("[PLAYER] move_queue:", move_queue)

	is_moving = true
	_move_next()

func _move_next() -> void:
	if move_queue.is_empty():
		is_moving = false
		_step_direction = 0
		_play_idle()
		return

	var next_tile = move_queue.pop_front()
	grid_position = next_tile

	var new_pos = board.get_tile_world_position(grid_position) + TILE_OFFSET
	print("[PLAYER] moving to tile", grid_position, "world pos", new_pos)
	_update_walk_animation(new_pos)
	target_position = new_pos

func _update_walk_animation(new_target: Vector2) -> void:
	var dir = (new_target - global_position).normalized()
	if dir.length() == 0:
		return

	if abs(dir.x) > abs(dir.y):
		if dir.x > 0:
			sprite.play("right walk")
		else:
			sprite.play("left walk")
	elif dir.y < 0:
		sprite.play("back walk")
	else:
		sprite.play("forward walk")

func _play_idle() -> void:
	if sprite == null:
		push_error("Sprite is NULL!")
		return
	if sprite.animation != "idle":
		sprite.play("idle")

func _process(delta: float) -> void:
	if not is_moving:
		return

	global_position = global_position.move_toward(target_position, 200 * delta)

	if global_position.distance_to(target_position) < 2:
		global_position = target_position
		_move_next()

# ─── Tile-by-tile forward or backward movement ───────────────────────────────

func move_to_tile_stepwise(dest_tile: int) -> void:
	last_position = grid_position
	move_queue.clear()

	if dest_tile == grid_position:
		return

	_step_direction = 1 if dest_tile > grid_position else -1

	var current = grid_position
	while current != dest_tile:
		current += _step_direction
		move_queue.append(current)

	is_moving = true
	_move_next()

func move_backward_stepwise(dest_tile: int) -> void:
	move_to_tile_stepwise(dest_tile)

# ─── Reaction animations (safe: falls back to timer if animation loops) ───────

func play_jump_reaction() -> void:
	sprite.play("jump")
	# Wait for animation_finished but bail out after 2s max so game never freezes
	await _wait_for_animation_or_timeout("jump", 2.0)
	_play_idle()

func play_sleep_reaction() -> void:
	sprite.play("sleep")
	await _wait_for_animation_or_timeout("sleep", 2.0)
	_play_idle()

func _wait_for_animation_or_timeout(anim_name: String, timeout: float) -> void:
	var elapsed := 0.0
	# If the animation is looping or very short, we fall back to the timer
	while sprite.animation == anim_name and sprite.is_playing():
		elapsed += get_process_delta_time()
		if elapsed >= timeout:
			break
		await get_tree().process_frame

# ─── Helpers ─────────────────────────────────────────────────────────────────

func is_done_moving() -> bool:
	return not is_moving

func move_to_tile(tile_num: int) -> void:
	last_position = grid_position
	grid_position = tile_num
	_step_direction = 0
	move_queue.clear()
	if tile_num == 0:
		target_position = school_position + TILE_OFFSET
	else:
		target_position = board.get_tile_world_position(tile_num) + TILE_OFFSET
	is_moving = true

# Add this variable at the top with the others

func celebrate_win() -> void:
	is_moving = false
	move_queue.clear()
	_step_direction = 0

	# Loop jump forever
	if sprite.sprite_frames and sprite.sprite_frames.has_animation("jump"):
		sprite.set_frame_and_progress(0, 0.0)
		# Turn looping ON just for this animation
		sprite.sprite_frames.set_animation_loop("jump", true)
		sprite.play("jump")
	else:
		_play_idle()
