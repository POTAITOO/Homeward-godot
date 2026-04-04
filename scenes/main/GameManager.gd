extends Node

#example data for test (Inspection)
@export var player_count: int = 3
@export var max_turns: int = 10
@export var turn_delay: float = 3.5

#@export var player_scene: PackedScene

var players = []
var current_player_index: int = 0
var current_turn: int = 0

func _ready():
	randomize()
	print("Game Started")
	setup_players()
	start_game()

#Create players Dynamically (player.tscn, player.gd)
func setup_players():
	for i in range(player_count):
		players.append({
			"name": "Player " + str(i + 1),
			"position": 0
		})
		print(players)

#Start the game Loop
func start_game():
	print("\nGame Started!!!\n")
	play_turn()
	
#Core Logic 
func play_turn():
	if current_turn >= max_turns:
		print("Game Over")
		return
	
	var player = players[current_player_index]
	
	var roll = roll_dice()
	player["position"] += roll
	
	print(player["name"] + " Rolled " + str(roll) + " -> position: " + str(player["position"]))
	
	current_turn += 1
	next_turn()
		
#Dice Rolled
func roll_dice():
	return randi() % 6 + 1
	
#Player Switch
func next_turn():
	current_player_index = (current_player_index + 1) % players.size()
	
	await get_tree().create_timer(turn_delay).timeout
	play_turn()
