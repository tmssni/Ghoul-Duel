extends Node

signal winner_announced(winner_name: String)
signal timer_updated(time_left: float)

var player_score = 0
var enemy_score = 0
var Players = {}
var game_winner = ""
var max_score = 50  # Higher score for longer games
var game_timer = 90.0  # 90 seconds
var game_active = true
var timer_node = null

func _ready():
	# Start the game timer
	start_game_timer()

func _process(delta):
	if game_active:
		if game_timer > 0:
			game_timer -= delta
			timer_updated.emit(game_timer)
			if game_timer <= 0:
				game_timer = 0
				end_game_by_time()

func start_game_timer():
	game_timer = 90.0
	game_active = true

func end_game_by_time():
	game_active = false
	# Determine winner based on score
	if player_score > enemy_score:
		announce_winner("Green Player Wins!")
	elif enemy_score > player_score:
		announce_winner("Purple Player Wins!")
	else:
		announce_winner("Tie!")

func check_winner() -> void:
	# Do nothing - winners are only determined when time runs out
	pass

func announce_winner(message: String) -> void:
	print("[GLOBAL] GAME OVER: ", message)
	var winner_name = ""
	if message.contains("Green"):
		winner_name = "Green"
	elif message.contains("Purple"):
		winner_name = "Purple"
	elif message.contains("Time"):
		winner_name = "Time"
	
	winner_announced.emit(winner_name)

func reset_game() -> void:
	print("[GLOBAL] Resetting game state...")
	player_score = 0
	enemy_score = 0
	game_winner = ""
	game_timer = 90.0
	game_active = true
