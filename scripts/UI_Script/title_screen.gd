extends Control

@onready var play_button: TextureButton = $TextureButton
@onready var background_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var button_sprite: AnimatedSprite2D = $TextureButton/AnimatedSprite2D
@onready var title_sprite: AnimatedSprite2D = $TextureRect/AnimatedSprite2D


func _ready() -> void:
	background_sprite.play("idle")
	button_sprite.play("idle")
	title_sprite.play("idle")


func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Scene_UI/select_number.tscn")
