extends Label

@export var sway_amount: float = 10.0
@export var sway_speed: float = 2.0
@export var bob_amount: float = 5.0
@export var bob_speed: float = 1.5

var origin: Vector2

func _ready() -> void:
	origin = position

func _process(delta: float) -> void:
	var t = Time.get_ticks_msec() * 0.001
	position.x = origin.x + sin(t * sway_speed) * sway_amount
	position.y = origin.y + sin(t * bob_speed) * bob_amount
