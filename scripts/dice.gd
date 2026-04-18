# Dice.gd
extends Node2D

signal roll_completed(result: int)

var result: int = 0
var is_rolling: bool = false

func _ready() -> void:
	print("Dice ready!")

func roll() -> void:
	print("Dice.roll() called!")
	if is_rolling:
		return

	is_rolling = true
	result = randi_range(1, 6)
	is_rolling = false

	print("Emitting roll_completed with: %d" % result)
	emit_signal("roll_completed", result)
