extends Camera2D

var target: Node2D

func _ready():
	make_current()
	call_deferred("_auto_fit_scene")

func set_target(node: Node2D):
	target = node

func _process(delta):
	if target:
		global_position = global_position.lerp(target.global_position, 5 * delta)

# ----------------------------
# AUTO FIT WHOLE SCENE
# ----------------------------
func _auto_fit_scene():
	var screen_size = get_viewport_rect().size

	var nodes = get_tree().get_nodes_in_group("tiles")

	if nodes.is_empty():
		push_error("[CAMERA] No tiles found for auto-fit")
		return

	var min_x = INF
	var max_x = -INF
	var min_y = INF
	var max_y = -INF

	for n in nodes:
		var p = n.global_position

		min_x = min(min_x, p.x)
		max_x = max(max_x, p.x)
		min_y = min(min_y, p.y)
		max_y = max(max_y, p.y)

	var world_size = Vector2(
		max_x - min_x,
		max_y - min_y
	)

	var center = Vector2(
		(min_x + max_x) / 2,
		(min_y + max_y) / 2
	)

	global_position = center

	# Add padding so edges are not clipped
	var padding = 1.1
	world_size *= padding

	# FIT CAMERA
	zoom = screen_size / world_size

	print("[CAMERA] Auto-fit applied. Zoom:", zoom)
