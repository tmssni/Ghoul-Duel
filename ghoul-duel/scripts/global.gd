extends Node

signal winner_announced(winner_name: String)
signal timer_updated(time_left: float)

var player_score = 0
var enemy_score = 0
var Players = {}
var game_winner = ""
var max_score = 50  # Higher score for longer games
var progress_bar_node = null
var game_timer = 90.0  # 90 seconds
var game_active = true
var timer_node = null

func _ready():
	# Try to find the progress bar in the scene
	call_deferred("find_progress_bar")
	# Start the game timer
	start_game_timer()

func _process(delta):
	if game_active and game_timer > 0:
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

func find_progress_bar():
	progress_bar_node = get_tree().get_first_node_in_group("progress_bar")
	if not progress_bar_node:
		# Alternative method to find progress bar
		var hud = get_tree().get_first_node_in_group("hud")
		if hud:
			progress_bar_node = hud.get_node("ProgressBar")
	
	# Only initialize progress bar once when first found
	if progress_bar_node:
		print("Progress bar found, initializing...")
		# Don't call update_progress_bar here as it will conflict with actual game scores

func update_progress_bar(p_score: int, e_score: int) -> void:
	if not progress_bar_node:
		find_progress_bar()
	
	print("Updating progress bar - Player score: ", p_score, ", Enemy score: ", e_score)
	
	if progress_bar_node:
		var total_score = p_score + e_score
		if total_score > 0:
			# Progress bar shows ratio: 0% = all Purple, 100% = all Green
			var progress_value = (float(p_score) / float(total_score)) * 100.0
			progress_bar_node.set_target_value(progress_value)
			print("Progress value calculated: ", progress_value)
		else:
			# Equal when no scores
			progress_bar_node.set_target_value(50.0)
			print("No scores yet, setting to neutral (50)")
	else:
		print("ERROR: Progress bar node not found!")

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
	print("GAME OVER: ", message)
	var winner_name = ""
	if message.contains("Green"):
		winner_name = "Green"
	elif message.contains("Purple"):
		winner_name = "Purple"
	elif message.contains("Time"):
		winner_name = "Time"
	
	winner_announced.emit(winner_name)
	# You can add more winner announcement logic here
	# For example, play sound effects, etc.

func reset_game() -> void:
	print("RESET: Resetting game state...")
	player_score = 0
	enemy_score = 0
	game_winner = ""
	game_timer = 90.0
	game_active = true
	print("RESET: Calling update_progress_bar with (0, 0)")
	update_progress_bar(0, 0)
