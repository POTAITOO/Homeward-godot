extends CharacterBody2D

var grid_position := 0
var last_position := 0
var target_position := Vector2.ZERO
var is_moving := false

var board = null
var max_tile := 0
var school_position := Vector2.ZERO

# Queue of tiles to walk through one by one
var move_queue: Array = []

func setup(p_board, p_school_pos: Vector2) -> void:
	board = p_board
	school_position = p_school_pos
	global_position = school_position
	target_position = school_position

func take_turn(roll: int) -> void:
	if board == null:
		print("ERROR: Board not assigned!")
		return

	last_position = grid_position
	print("[PLAYER] ", name, " rolled ", roll)

	# Build a queue of every tile to step through
	move_queue.clear()
	for i in range(1, roll + 1):
		var next_tile = grid_position + i
		if next_tile > max_tile:
			next_tile = max_tile
		move_queue.append(next_tile)

	# Start walking
	is_moving = true
	_move_next()

func _move_next() -> void:
	if move_queue.is_empty():
		is_moving = false
		print("[PLAYER] ", name, " arrived at tile ", grid_position)
		return

	# Pop the next tile from the queue
	var next_tile = move_queue.pop_front()
	grid_position = next_tile
	target_position = board.get_tile_world_position(grid_position)
	print("[PLAYER] ", name, " stepping to tile ", grid_position)

func _process(delta: float) -> void:
	if is_moving:
		global_position = global_position.move_toward(target_position, 200 * delta)
		if global_position.distance_to(target_position) < 2:
			global_position = target_position
			# Move to next tile in queue
			_move_next()

func is_done_moving() -> bool:
	return not is_moving

# Called by GameManager for teleport effects (bus, dog, puddle, bike)
func move_to_tile(tile_num: int) -> void:
	last_position = grid_position
	grid_position = tile_num
	if tile_num == 0:
		target_position = school_position
	else:
		target_position = board.get_tile_world_position(tile_num)
	is_moving = true
	move_queue.clear()   # no stepping for teleports, go directly
