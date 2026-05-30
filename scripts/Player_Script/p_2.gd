extends CharacterBody2D

var current_tile: int = 0
var previous_tile: int = 0
var target_position := Vector2.ZERO
var is_moving := false
var skip_next_turn: bool = false
var roll_again: bool = false

var board = null
var school_position := Vector2.ZERO

func setup(p_board, p_school_pos: Vector2) -> void:
	board = p_board
	school_position = p_school_pos
	global_position = school_position
	target_position = school_position

func move_to_tile(tile_num: int) -> void:
	previous_tile = current_tile
	current_tile = tile_num
	if tile_num == 0:
		target_position = school_position
	else:
		target_position = board.get_tile_world_position(tile_num)
	is_moving = true
	print(name + " moving to tile " + str(tile_num))

func _process(_delta: float) -> void:
	if is_moving:
		global_position = global_position.lerp(target_position, 0.15)
		if global_position.distance_to(target_position) < 2.0:
			global_position = target_position
			is_moving = false
			print(name + " reached tile " + str(current_tile))

func is_done_moving() -> bool:
	return not is_moving
