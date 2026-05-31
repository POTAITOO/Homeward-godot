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
@export var character_id := 0

func _ready():
	call_deferred("_apply_character")

func _apply_character():
	match character_id:
		0: sprite.sprite_frames = preload("res://assets/Players/Student_1.tres")
		1: sprite.sprite_frames = preload("res://assets/Players/Student_2.tres")
		2: sprite.sprite_frames = preload("res://assets/Players/Student_3.tres")
		3: sprite.sprite_frames = preload("res://assets/Players/Student_4.tres")

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
	
	var current = grid_position
	for i in range(roll):
		current += 1
		current = min(current, max_tile)
		move_queue.append(current)
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
		push_error("Sprite is NULL! Check node path.")
		return

	if sprite.animation != "idle":
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
	
func celebrate_win() -> void:
	is_moving = false
	move_queue.clear()
	
	_play_idle()
	
	# Optional animation if you have it
	if sprite.sprite_frames and sprite.sprite_frames.has_animation("win"):
		sprite.play("jump")
	
	print("[PLAYER] ", name, " is celebrating WIN!")
