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
	announce_winner("Time's Up!")

func check_winner() -> void:
	if not game_active:
		return
		
	if player_score >= max_score and player_score > enemy_score:
		if game_winner != "Green":
			game_winner = "Green"
			game_active = false
			announce_winner("Green Player Wins!")
	elif enemy_score >= max_score and enemy_score > player_score:
		if game_winner != "Purple":
			game_winner = "Purple"
			game_active = false
			announce_winner("Purple Player Wins!")
	elif player_score >= max_score and enemy_score >= max_score:
		# Tie case - whoever has more wins
		if player_score > enemy_score:
			if game_winner != "Green":
				game_winner = "Green"
				game_active = false
				announce_winner("Green Player Wins!")
		elif enemy_score > player_score:
			if game_winner != "Purple":
				game_winner = "Purple"
				game_active = false
				announce_winner("Purple Player Wins!")

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
