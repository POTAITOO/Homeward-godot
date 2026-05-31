extends Control

const EMOTE_ACTIVE: Texture2D = preload("res://assets/UI/Emotes1.png")
const EMOTE_SKIP: Texture2D = preload("res://assets/UI/Emotes3.png")

@onready var tile_preview_sprite: AnimatedSprite2D = get_node_or_null("Tile Preview/AnimatedSprite2D")
@onready var tile_title: Label = get_node_or_null("Tile Preview/Title")
@onready var tile_subtitle: Label = get_node_or_null("Tile Preview/Subtitle")

var game_manager: Node = null
var exit_button: TextureButton = null
var _last_player_index := -1
var _last_tile_number := -999
var _turn_rows: Array = []

const TILE_INFO := {
	"plain": {
		"animation": "plain",
		"title": "Plain",
		"subtitle": "A normal tile. Nothing special happens here."
	},
	"puddle": {
		"animation": "puddle",
		"title": "Puddle",
		"subtitle": "Slip back 3 tiles."
	},
	"bike": {
		"animation": "bike",
		"title": "Bike",
		"subtitle": "Catch up by moving behind the player in front."
	},
	"dog": {
		"animation": "dog",
		"title": "Dog",
		"subtitle": "Go back to your last position."
	},
	"vending": {
		"animation": "vending",
		"title": "Vending",
		"subtitle": "Roll again and keep moving."
	},
	"traffic": {
		"animation": "stoplight",
		"title": "Traffic Light",
		"subtitle": "Sleep and skip your next turn."
	},
	"bus_stop_green": {
		"animation": "bus-stop",
		"title": "Bus Stop",
		"subtitle": "Ride to the matching bus stop."
	},
	"bus_stop_orange": {
		"animation": "bus-stop",
		"title": "Bus Stop",
		"subtitle": "Ride to the matching bus stop."
	},
	"bus_stop_violet": {
		"animation": "bus-stop",
		"title": "Bus Stop",
		"subtitle": "Ride to the matching bus stop."
	}
}

func _ready() -> void:
	_resolve_game_manager()
	_resolve_turn_rows()
	_refresh_turn_list()
	_show_default_preview()
	set_process(true)

	exit_button = get_node_or_null("Buttons/Exit")
	if exit_button == null:
		print("[SIDEBAR] Warning: Back button missing: Sidebar/Buttons/Exit")

	if exit_button:
		exit_button.pressed.connect(_on_exit_pressed)
func _process(_delta: float) -> void:
	if game_manager == null or not is_instance_valid(game_manager):
		_resolve_game_manager()
		if game_manager == null:
			return

	var players: Array = game_manager.get("players")
	var player_index := int(game_manager.get("current_player_index"))
	if players.is_empty() or player_index < 0 or player_index >= players.size():
		return

	if player_index != _last_player_index:
		_last_player_index = player_index

	var current_player = players[player_index]
	if current_player == null or not is_instance_valid(current_player):
		return

	_refresh_turn_list()

	var tile_number := int(current_player.get("grid_position"))
	if tile_number != _last_tile_number:
		_last_tile_number = tile_number
		_update_preview_for_current_tile(tile_number)


func _resolve_game_manager() -> void:
	if game_manager != null and is_instance_valid(game_manager):
		return
	var current_scene = get_tree().current_scene
	if current_scene:
		game_manager = current_scene.get_node_or_null("GameManager")


func _resolve_turn_rows() -> void:
	_turn_rows.clear()
	for i in range(4):
		var row = get_node_or_null("Stack/Player Turn List/Turn %d" % (i + 1))
		var label = get_node_or_null("Stack/Player Turn List/Turn %d/Player %d" % [i + 1, i + 1])
		var icon = get_node_or_null("Stack/Player Turn List/Turn %d/TextureRect" % (i + 1))
		_turn_rows.append({
			"row": row,
			"label": label,
			"icon": icon,
		})


func _refresh_turn_list() -> void:
	if game_manager == null or not is_instance_valid(game_manager):
		return

	var players: Array = game_manager.get("players")
	var current_player_index := int(game_manager.get("current_player_index"))
	var skip_turn_players: Array = game_manager.get("skip_turn_players")
	var player_count := int(GlobalData.player_count)
	var total_players: int = min(player_count, players.size())

	for i in range(_turn_rows.size()):
		var entry: Dictionary = _turn_rows[i]
		var row: Control = entry["row"] as Control
		var label: Label = entry["label"] as Label
		var icon: TextureRect = entry["icon"] as TextureRect
		var visible_row: bool = i < total_players
		var player_node: Node = null
		if visible_row:
			var player_index: int = (current_player_index + i) % players.size()
			player_node = players[player_index]

		if row:
			row.visible = visible_row
			row.self_modulate = Color(1, 1, 1, 1) if i == 0 else Color(0.86, 0.86, 0.86, 1)

		if label and visible_row:
			var player_name := "Player %d" % (i + 1)
			if player_node != null and is_instance_valid(player_node) and String(player_node.name) != "":
				player_name = String(player_node.name)
			label.text = player_name

		if icon:
			icon.visible = false
			icon.texture = null
			if visible_row and player_node != null and is_instance_valid(player_node):
				if i == 0:
					icon.texture = EMOTE_SKIP if skip_turn_players.has(player_node) else EMOTE_ACTIVE
					icon.visible = true
				elif skip_turn_players.has(player_node):
					icon.texture = EMOTE_SKIP
					icon.visible = true


func _show_default_preview() -> void:
	_apply_tile_info("plain")


func _update_preview_for_current_tile(tile_number: int) -> void:
	var tile_type := _get_tile_type_for_current_player(tile_number)
	_apply_tile_info(tile_type)


func _get_tile_type_for_current_player(tile_number: int) -> String:
	if game_manager == null or not is_instance_valid(game_manager):
		return "plain"

	var current_map_data = game_manager.get("current_map_data")
	if current_map_data == null:
		return "plain"

	var tile_index: Dictionary = current_map_data.get("tile_index")
	if tile_index == null:
		return "plain"

	var tile_type = tile_index.get(tile_number, "plain")
	if tile_type == null:
		return "plain"
	return String(tile_type)


func _apply_tile_info(tile_type: String) -> void:
	var info = TILE_INFO.get(tile_type, TILE_INFO["plain"])
	var animation_name := String(info["animation"])
	var title_text := String(info["title"])
	var subtitle_text := String(info["subtitle"])

	if tile_preview_sprite:
		if tile_preview_sprite.sprite_frames and tile_preview_sprite.sprite_frames.has_animation(animation_name):
			tile_preview_sprite.play(animation_name)
		elif tile_preview_sprite.sprite_frames and tile_preview_sprite.sprite_frames.has_animation("plain"):
			tile_preview_sprite.play("plain")

	if tile_title:
		tile_title.text = title_text

	if tile_subtitle:
		tile_subtitle.text = subtitle_text

func _on_exit_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Scene_UI/select_map.tscn")
