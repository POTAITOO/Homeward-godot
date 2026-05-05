extends Node2D

@export var tile_number: int = 0
@export var tile_type: String = "normal"

@onready var bg: ColorRect = $BG
@onready var num_label: Label = $NumLabel
@onready var icon_label: Label = $IconLabel

const TILE_COLORS = {
	"normal":     Color("#f0ede8"),
	"bus_green":  Color("#c8f5d8"),
	"bus_violet": Color("#e8d8f8"),
	"vending":    Color("#d0f0ff"),
	"bicycle":    Color("#d8f5d0"),
	"puddle":     Color("#cce4f8"),
	"traffic":    Color("#ffd0d0"),
	"stray_dog":  Color("#f8e8c8"),
}

const TILE_ICONS = {
	"bus_green":  "🚌",
	"bus_violet": "🚌",
	"vending":    "🥤",
	"bicycle":    "🚲",
	"puddle":     "💧",
	"traffic":    "🚦",
	"stray_dog":  "🐕",
}

func setup(number: int, type: String) -> void:
	tile_number = number
	tile_type = type
	num_label.text = str(number)
	bg.color = TILE_COLORS.get(type, Color("#f0ede8"))
	icon_label.text = TILE_ICONS.get(type, "")
