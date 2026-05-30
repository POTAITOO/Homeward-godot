extends CharacterBody2D

@onready var sprite: AnimatedSprite2D = $Sheet

const TILE_OFFSET := Vector2(0, 32)

var grid_position := 0
var last_position := 0
var target_position := Vector2.ZERO
var is_moving := false
var board = null
var max_tile := 0
var school_position := Vector2.ZERO
var move_queue: Array = []

func setup(p_board, p_school_pos: Vector2) -> void:
	board = p_board
	school_position = p_school_pos
	global_position = school_position + TILE_OFFSET
	target_position = school_position + TILE_OFFSET
	_play_idle()

func take_turn(roll: int) -> void:
	if board == null:
		print("ERROR: Board not assigned!")
		return
	last_position = grid_position
	print("[PLAYER] ", name, " rolled ", roll)
	move_queue.clear()
	for i in range(1, roll + 1):
		var next_tile = grid_position + i
		if next_tile > max_tile:
			next_tile = max_tile
		move_queue.append(next_tile)
	is_moving = true
	_move_next()

func _move_next() -> void:
	if move_queue.is_empty():
		is_moving = false
		_play_idle()
		print("[PLAYER] ", name, " arrived at tile ", grid_position)
		return

	var next_tile = move_queue.pop_front()
	grid_position = next_tile
	var new_pos = board.get_tile_world_position(grid_position) + TILE_OFFSET
	_update_walk_animation(new_pos)
	target_position = new_pos
	print("[PLAYER] ", name, " stepping to tile ", grid_position)

func _update_walk_animation(new_target: Vector2) -> void:
	var dir = (new_target - global_position).normalized()

	if abs(dir.x) > abs(dir.y):
		if dir.x > 0:
			sprite.play("walk_right")
		else:
			sprite.play("walk_left")
	elif dir.y < 0:
		sprite.play("walk_up")
	else:
		sprite.play("walk_down")

func _play_idle() -> void:
	sprite.play("idle")

func _process(delta: float) -> void:
	if is_moving:
		global_position = global_position.move_toward(target_position, 200 * delta)
		if global_position.distance_to(target_position) < 2:
			global_position = target_position
			_move_next()

func is_done_moving() -> bool:
	return not is_moving

func move_to_tile(tile_num: int) -> void:
	last_position = grid_position
	grid_position = tile_num
	if tile_num == 0:
		target_position = school_position + TILE_OFFSET
	else:
		target_position = board.get_tile_world_position(tile_num) + TILE_OFFSET
	is_moving = true
	move_queue.clear()
