extends Node

var map_name: String = "6x6"
var total_tiles: int = 36
var home_tile: int = 37

var tile_index: Dictionary = {
	1:  "plain",
	2:  "plain",
	3:  "vending",
	4:  "plain",
	5:  "puddle",
	6:  "plain",
	7:  "plain",
	8:  "bus_stop_green",
	9:  "plain",
	10: "plain",
	11: "dog",
	12: "plain",
	13: "bus_stop_orange",
	14: "plain",
	15: "traffic",
	16: "bike",
	17: "plain",
	18: "plain",
	19: "vending",
	20: "plain",
	21: "plain",
	22: "bus_stop_green",
	23: "plain",
	24: "plain",
	25: "plain",
	26: "bike",
	27: "plain",
	28: "dog",
	29: "bus_stop_orange",
	30: "plain",
	31: "traffic",
	32: "plain",
	33: "plain",
	34: "puddle",
	35: "plain",
	36: "plain",
}

# tile_num → destination tile_num
var bus_pairs: Dictionary = {
	8:  22,
	22: 8,
	13: 29,
	29: 13,
}
