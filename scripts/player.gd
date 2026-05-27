extends CharacterBody2D

# --- PLAYER STATE ---
var grid_position := 0            # Which tile the player is on (0–35)
var target_position := Vector2.ZERO   # Where the player should move (world position)
var is_moving := false           # Is the player currently moving?

# Reference to Board (assigned by GameManager)
var board

# --- TURN ACTION ---
func take_turn(roll: int):
	if board == null:
		print("ERROR: Board not assigned!")
		return
	
	# Update tile position
	grid_position += roll
	
	# Prevent going outside the board
	grid_position = clamp(grid_position, 0, 35)
	
	# Ask board where this tile is in the world
	target_position = board.get_tile_position(grid_position)
	
	# Start movement
	is_moving = true
	
	print(name, " moving to tile ", grid_position)

# --- MOVEMENT LOOP ---
func _process(_delta):
	if is_moving:
		# Smooth movement toward target
		global_position = global_position.lerp(target_position, 0.2)
		
		# Stop when close enough
		if global_position.distance_to(target_position) < 2:
			global_position = target_position
			is_moving = false
			
			print(name, " reached tile ", grid_position)
