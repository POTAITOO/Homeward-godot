extends Label

@export var flicker_speed: float = 0.5

func _process(delta: float) -> void:
	modulate.a = (sin(Time.get_ticks_msec() * 0.001 * flicker_speed * TAU) + 1.0) / 2.0

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		get_tree().change_scene_to_file("res://scenes/main/player_select.tscn")
