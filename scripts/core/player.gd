extends CharacterBody2D

# --- PLAYER STATE ---
var grid_position := 1
var last_position := 1

var target_position := Vector2.ZERO   # Where the player should move (world position)
var is_moving := false           # Is the player currently moving?

# Reference to Board (assigned by GameManager)
var board = null
var max_tile := 0

# --- TURN ACTION ---
func take_turn(roll: int):

	if board == null:
		print("ERROR: Board not assigned!")
		return
		
	# SAVE LAST POSITION (for DOG tile)
	last_position = grid_position
	
	print("[PLAYER] ", name, " rolled ", roll)
	
	grid_position += roll

	# CLAMP ONLY TO LAST TILE
	grid_position = clamp(grid_position, 1, max_tile)

	target_position = board.get_tile_world_position(grid_position)

	is_moving = true

	print("[PLAYER] ", name, " rolled move to tile ", grid_position)

func _process(delta):

	if is_moving:

		global_position = global_position.move_toward(
			target_position,
			300 * delta
		)

		if global_position.distance_to(target_position) < 2:

			global_position = target_position
			is_moving = false

			print("[PLAYER] ", name, " arrived at tile ", grid_position)
