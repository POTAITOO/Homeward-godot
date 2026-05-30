extends Area2D

@onready var animated_sprite = $AnimatedSprite2D
var is_rolling = false

func _ready():
	animated_sprite.animation_finished.connect(_on_animation_finished)
	animated_sprite.play("idle")

func _input(event):
	if event.is_action_pressed("roll_dice") and not is_rolling:
		roll()

func roll():
	is_rolling = true
	animated_sprite.play("rolling")

func _on_animation_finished():
	if animated_sprite.animation == "rolling":
		var result = randi_range(1, 6)
		animated_sprite.play("result_" + str(result))
		is_rolling = false
