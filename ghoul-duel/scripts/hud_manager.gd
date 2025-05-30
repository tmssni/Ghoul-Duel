extends CanvasLayer

@onready var winner_overlay = $WinnerOverlay
@onready var winner_label = $WinnerOverlay/WinnerLabel
@onready var restart_button = $WinnerOverlay/RestartButton
@onready var timer_label = $TimerLabel
@onready var score_bar = $ScoreBar

func _ready():
	add_to_group("hud")
	# Connect to global's winner announcement
	global.winner_announced.connect(_on_winner_announced)
	# Connect to timer updates
	global.timer_updated.connect(_on_timer_updated)
	# Make sure the restart button is connected properly
	if restart_button:
		restart_button.pressed.connect(_on_restart_pressed)

func _on_update_timer_timeout():
	if score_bar:
		var total = global.player_score + global.enemy_score
		if total > 0:
			var green_percent = (float(global.player_score) / float(total)) * 100.0
			score_bar.value = green_percent
		else:
			score_bar.value = 50.0

func _on_winner_announced(winner_name: String):
	show_winner(winner_name)

func show_winner(winner_name: String):
	if winner_name == "Green":
		winner_label.text = "TIME'S UP!\nGREEN WINS!"
		winner_label.add_theme_color_override("font_color", Color(0.1, 0.8, 0.1, 1))
	elif winner_name == "Purple":
		winner_label.text = "TIME'S UP!\nPURPLE WINS!"
		winner_label.add_theme_color_override("font_color", Color(0.8, 0.1, 0.8, 1))
	else:
		winner_label.text = "TIME'S UP!\nIT'S A TIE!"
		winner_label.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	
	winner_overlay.visible = true
	# Pause the game
	get_tree().paused = true

func _on_restart_pressed():
	print("Restart button pressed!")  # Debug
	# Hide winner overlay
	winner_overlay.visible = false
	# Resume the game
	get_tree().paused = false
	# Reset the game state
	global.reset_game()
	
	# Reset timer display
	timer_label.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	timer_label.text = "1:30"
	
	# Reset all coins
	var coins = get_tree().get_nodes_in_group("coins")
	for coin in coins:
		if coin.has_method("reset_coin"):
			coin.reset_coin()
	
	# Reset player positions and chains
	var players = get_tree().get_nodes_in_group("player")
	var enemies = get_tree().get_nodes_in_group("enemy")
	
	for player in players:
		if player.has_method("delete_chain"):
			player.delete_chain()
		# Reset player position to spawn point
		player.global_position = Vector2(348, 900)  # Adjust as needed
	
	for enemy in enemies:
		if enemy.has_method("delete_chain"):
			enemy.delete_chain()
		# Reset enemy position to spawn point  
		enemy.global_position = Vector2(348, 150)  # Adjust as needed 

func _on_timer_updated(time_left: float):
	var minutes = int(time_left / 60)
	var seconds = int(time_left) % 60
	# Ensure timer format has consistent width to prevent overlap
	timer_label.text = "%01d:%02d" % [minutes, seconds]
	
	# Change color when time is running low
	if time_left <= 10:
		timer_label.add_theme_color_override("font_color", Color(1, 0.2, 0.2, 1))  # Red
	elif time_left <= 30:
		timer_label.add_theme_color_override("font_color", Color(1, 1, 0.2, 1))  # Yellow
	else:
		timer_label.add_theme_color_override("font_color", Color(1, 1, 1, 1))  # White 
