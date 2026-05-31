extends Control

@onready var background_sprite: AnimatedSprite2D = $BG
@onready var duo_sprite_a: AnimatedSprite2D = $Window/Duo/CollisionShape2D/AnimatedSprite2D
@onready var duo_sprite_b: AnimatedSprite2D = $Window/Duo/CollisionShape2D/AnimatedSprite2D2
@onready var trio_sprite_a: AnimatedSprite2D = $Window/Trio/CollisionShape2D/AnimatedSprite2D3
@onready var trio_sprite_b: AnimatedSprite2D = $Window/Trio/CollisionShape2D/AnimatedSprite2D4
@onready var trio_sprite_c: AnimatedSprite2D = $Window/Trio/CollisionShape2D/AnimatedSprite2D
@onready var quad_sprite_a: AnimatedSprite2D = $Window/Quad/CollisionShape2D/AnimatedSprite2D3
@onready var quad_sprite_b: AnimatedSprite2D = $Window/Quad/CollisionShape2D/AnimatedSprite2D4
@onready var quad_sprite_c: AnimatedSprite2D = $Window/Quad/CollisionShape2D/AnimatedSprite2D2
@onready var quad_sprite_d: AnimatedSprite2D = $Window/Quad/CollisionShape2D/AnimatedSprite2D
@onready var duo_button: TextureButton = $Window/Duo/CollisionShape2D/TextureButton
@onready var trio_button: TextureButton = $Window/Trio/CollisionShape2D/TextureButton
@onready var quad_button: TextureButton = $Window/Quad/CollisionShape2D/TextureButton
@onready var back_button: TextureButton = $Window/Back


func _ready() -> void:
	print("[SELECT_NUMBER] Ready. Default player_count=", GlobalData.player_count)
	background_sprite.play("idle")
	duo_sprite_a.play("idle")
	duo_sprite_b.play("idle")
	trio_sprite_a.play("idle")
	trio_sprite_b.play("idle")
	trio_sprite_c.play("idle")
	quad_sprite_a.play("idle")
	quad_sprite_b.play("idle")
	quad_sprite_c.play("idle")
	quad_sprite_d.play("idle")

	duo_button.pressed.connect(_on_player_count_pressed.bind(2))
	trio_button.pressed.connect(_on_player_count_pressed.bind(3))
	quad_button.pressed.connect(_on_player_count_pressed.bind(4))
	back_button.pressed.connect(_on_back_pressed)


func _set_player_count(count: int) -> void:
	print("[SELECT_NUMBER] Button pressed for player count: ", count)
	GlobalData.player_count = count
	GlobalData.selected_characters.clear()
	GlobalData.selected_names.clear()
	GlobalData.turn_order.clear()
	print("[SELECT_NUMBER] Saved to GlobalData -> player_count=", GlobalData.player_count, ", selected_characters cleared, turn_order cleared")
	get_tree().change_scene_to_file("res://scenes/Scene_UI/select_avatar.tscn")


func _on_player_count_pressed(count: int) -> void:
	_set_player_count(count)


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Scene_UI/Title.tscn")
