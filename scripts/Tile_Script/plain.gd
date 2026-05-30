extends Area2D

@export var tile_number: int = 0
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	anim.play("default")
	add_to_group("tiles")

func on_player_landed(player: Dictionary) -> void:
	pass
