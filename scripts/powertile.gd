# PowerTile.gd
class_name PowerTile
extends "res://scripts/Tile.gd"

enum PowerType {
	# Positive
	BUS_STOP,
	SHORTCUT_ALLEY,
	ENERGY_DRINK,
	FRIENDS_BIKE,
	GREEN_LIGHT,
	# Negative
	HEAVY_TRAFFIC,
	RAIN_SHOWER,
	FORGOT_HOMEWORK,
	CONSTRUCTION_AREA,
	LOST_PHONE_SIGNAL,
	# Neutral
	MYSTERY_TILE,
	RIDE_SHARE,
	# Optional
	SAFE_ZONE,
	STUDY_BREAK,
	GROUP_STUDY
}

@export var power_type: PowerType = PowerType.BUS_STOP

func on_land(player) -> void:
	match power_type:
		# --- POSITIVE ---
		PowerType.BUS_STOP:
			print("🚌 Bus Stop! Move forward 3.")
			_move_player(player, 3)
		PowerType.SHORTCUT_ALLEY:
			print("🛣️ Shortcut Alley! Moving to next waypoint.")
			player["pending_choice"] = "shortcut_alley"
		PowerType.ENERGY_DRINK:
			print("⚡ Energy Drink! Roll again.")
			player["roll_again"] = true
		PowerType.FRIENDS_BIKE:
			print("🚲 Friend's Bike! Move forward by last roll again.")
			_move_player(player, player["last_roll"])
		PowerType.GREEN_LIGHT:
			print("🚦 Green Light! Immune to obstacles for 1 turn.")
			player["obstacle_immune"] = true
		# --- NEGATIVE ---
		PowerType.HEAVY_TRAFFIC:
			print("🚗 Heavy Traffic! Move back 2.")
			_move_player(player, -2)
		PowerType.RAIN_SHOWER:
			print("🌧️ Rain Shower! Skip next turn.")
			player["skip_turn"] = true
		PowerType.FORGOT_HOMEWORK:
			print("📚 Forgot Homework! Move back to previous waypoint.")
			player["pending_choice"] = "forgot_homework"
		PowerType.CONSTRUCTION_AREA:
			print("🚧 Construction Area! Roll again but move half.")
			player["half_move"] = true
			player["roll_again"] = true
		PowerType.LOST_PHONE_SIGNAL:
			print("📵 Lost Phone Signal! Can't use waypoints for 1 turn.")
			player["waypoint_blocked"] = true
		# --- NEUTRAL ---
		PowerType.MYSTERY_TILE:
			_trigger_mystery(player)
		PowerType.RIDE_SHARE:
			print("🚕 Ride Share! Choose: +2 forward OR swap with player behind.")
			player["pending_choice"] = "ride_share"
		# --- OPTIONAL SPECIAL ---
		PowerType.SAFE_ZONE:
			print("🏠 Safe Zone! Protected from bad tiles for 1 turn.")
			player["safe_zone"] = true
		PowerType.STUDY_BREAK:
			print("☕ Study Break! Choose: Roll again OR move +2.")
			player["pending_choice"] = "study_break"
		PowerType.GROUP_STUDY:
			_trigger_group_study(player)

func _trigger_mystery(player) -> void:
	var effects = ["forward", "backward", "roll_again", "swap"]
	var chosen = effects[randi() % effects.size()]
	print("❓ Mystery Tile! Effect: %s" % chosen)
	match chosen:
		"forward":
			_move_player(player, 4)
		"backward":
			_move_player(player, -3)
		"roll_again":
			player["roll_again"] = true
		"swap":
			player["pending_choice"] = "mystery_swap"

func _trigger_group_study(player) -> void:
	print("👥 Group Study! Flagging for GameManager to check co-occupants.")
	player["pending_choice"] = "group_study"

func _move_player(player, amount: int) -> void:
	var total_tiles = 36
	player["position"] = clamp(player["position"] + amount, 0, total_tiles - 1)
	print("Player %s moved to position %d" % [player["name"], player["position"]])
