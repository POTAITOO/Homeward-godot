extends Node2D

# School is the start point — players spawn here

func _ready() -> void:
	add_to_group("tiles")
	# Register as school (starting point) if named School, or if named Home but placed in Layer1 (for 8x8 and 10x10 maps)
	if name == "School" or (name == "Home" and get_parent() != null and get_parent().name == "Layer1"):
		add_to_group("school")
	else:
		add_to_group("home")

func get_spawn_position() -> Vector2:
	return global_position
