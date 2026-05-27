extends Node

@export var player_scene: PackedScene
#example data for test (Inspection)
@export var player_count: int = 3
@export var max_turns: int = 10
@export var turn_delay: float = 2.5

var players = []
var current_player_index: int = 0
var current_turn: int = 0

@onready var players_node = get_parent().get_node("Players")

func _ready():
	randomize()
	print("Game Started")
	setup_players()
	start_game()

#Create real players 
func setup_players():
	for i in range(player_count):
		var player = player_scene.instantiate()
		
		player.name = "Player" + str(i+1)
		
		players_node.add_child(player) #add to players node
		players.append(player)
	
	print("Players spawned: ", players.size())

#Start the game Loop
func start_game():
	print("\nGame Started!!!\n")
	play_turn()
	
#Turn Logic 
func play_turn():
	if current_turn >= max_turns:
		print("Game Over")
		return
	
	var player = players[current_player_index]
	
	var roll = roll_dice()
	
	# 👉 CALL PLAYER FUNCTION (you will create this)
	player.take_turn(roll)
	
	print(player.name + " rolled " + str(roll))
	
	current_turn += 1
	next_turn()
		
#Dice Rolled
func roll_dice():
	return randi() % 6 + 1
	
#Player Switch
func next_turn():
	current_player_index = (current_player_index + 1) % players.size()
	
	#later to Button input (Roll Dice)
	await get_tree().create_timer(turn_delay).timeout
	play_turn()
