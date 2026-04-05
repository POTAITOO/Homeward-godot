extends Node2D
class_name Tile

# Tile types
enum TILE_TYPE {
	NORMAL,
	POWER,
	WAYPOINT,
	HOME
}

# Power tile effects
enum POWER_EFFECT {
	MOVE_FORWARD,
	MOVE_BACKWARD,
	SKIP_TURN,
	ROLL_AGAIN
}

# Properties
var tile_type: int = TILE_TYPE.NORMAL
var position_index: int = 0 # Position on the board (0 to board_size-1)
var power_effect: int = POWER_EFFECT.MOVE_FORWARD # For power tiles
var waypoint_target: int = -1 # Target tile index for waypoints
var is_occupied: bool = false
var occupying_player: int = -1 # Player ID currently on this tile

# Visual properties
var tile_color: Color = Color.WHITE
var tile_size: Vector2 = Vector2(32, 32)

func _ready() -> void:
	# Set up visual appearance based on tile type
	_update_tile_appearance()

# Get tile type as string for debugging
func get_tile_type_name() -> String:
	match tile_type:
		TILE_TYPE.NORMAL:
			return "Normal"
		TILE_TYPE.POWER:
			return "Power"
		TILE_TYPE.WAYPOINT:
			return "Waypoint"
		TILE_TYPE.HOME:
			return "Home"
		_:
			return "Unknown"

# Get power effect as string
func get_power_effect_name() -> String:
	match power_effect:
		POWER_EFFECT.MOVE_FORWARD:
			return "Move Forward"
		POWER_EFFECT.MOVE_BACKWARD:
			return "Move Backward"
		POWER_EFFECT.SKIP_TURN:
			return "Skip Turn"
		POWER_EFFECT.ROLL_AGAIN:
			return "Roll Again"
		_:
			return "Unknown"

# Set tile as a normal tile
func set_normal_tile() -> void:
	tile_type = TILE_TYPE.NORMAL
	tile_color = Color.WHITE
	_update_tile_appearance()

# Set tile as a power tile with a specific effect
func set_power_tile(effect: int) -> void:
	tile_type = TILE_TYPE.POWER
	power_effect = effect
	
	match effect:
		POWER_EFFECT.MOVE_FORWARD:
			tile_color = Color.GREEN
		POWER_EFFECT.MOVE_BACKWARD:
			tile_color = Color.RED
		POWER_EFFECT.SKIP_TURN:
			tile_color = Color.ORANGE
		POWER_EFFECT.ROLL_AGAIN:
			tile_color = Color.BLUE
	
	_update_tile_appearance()

# Set tile as a waypoint with a target
func set_waypoint_tile(target_index: int) -> void:
	tile_type = TILE_TYPE.WAYPOINT
	waypoint_target = target_index
	tile_color = Color.PURPLE
	_update_tile_appearance()

# Set tile as the home/finish tile
func set_home_tile() -> void:
	tile_type = TILE_TYPE.HOME
	tile_color = Color.GOLD
	_update_tile_appearance()

# Place a player on this tile
func place_player(player_id: int) -> void:
	is_occupied = true
	occupying_player = player_id

# Remove a player from this tile
func remove_player() -> void:
	is_occupied = false
	occupying_player = -1

# Check if tile is occupied
func has_player() -> bool:
	return is_occupied and occupying_player >= 0

# Get the occupying player ID
func get_occupying_player() -> int:
	return occupying_player

# Apply power tile effect - returns the effect type
func apply_power_effect() -> int:
	if tile_type == TILE_TYPE.POWER:
		return power_effect
	return -1

# Get waypoint target
func get_waypoint_target() -> int:
	if tile_type == TILE_TYPE.WAYPOINT:
		return waypoint_target
	return -1

# Update visual appearance
func _update_tile_appearance() -> void:
	# This will be used for visual updates
	# You can extend this to add sprites, modulate color, etc.
	if has_node("ColorRect"):
		var color_rect = $ColorRect
		color_rect.color = tile_color
	else:
		# Create a simple visual representation if it doesn't exist
		var color_rect = ColorRect.new()
		color_rect.size = tile_size
		color_rect.color = tile_color
		add_child(color_rect)

# Debug function to print tile info
func print_tile_info() -> void:
	print("Tile #%d - Type: %s | Color: %s" % [position_index, get_tile_type_name(), tile_color])
	if tile_type == TILE_TYPE.POWER:
		print("  Power Effect: %s" % get_power_effect_name())
	if tile_type == TILE_TYPE.WAYPOINT:
		print("  Waypoint Target: Tile #%d" % waypoint_target)
	if is_occupied:
		print("  Occupied by Player #%d" % occupying_player)
