extends CanvasLayer

@onready var winner_overlay = $WinnerOverlay
@onready var winner_label = $WinnerOverlay/WinnerLabel
@onready var restart_button = $WinnerOverlay/RestartButton
@onready var timer_label = $TimerLabel
@onready var score_bar = $ScoreBar
@onready var winner_background = $WinnerOverlay/Background

func _ready():
	add_to_group("hud")
	# Connect to global's winner announcement
	global.winner_announced.connect(_on_winner_announced)
	# Connect to timer updates
	global.timer_updated.connect(_on_timer_updated)
	# Debug print to check if button exists
	print("Restart button node: ", restart_button)

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
		winner_background.texture = load("res://assets/lobby + results/results green.png")
	elif winner_name == "Purple":
		winner_label.text = "TIME'S UP!\nPURPLE WINS!"
		winner_label.add_theme_color_override("font_color", Color(0.8, 0.1, 0.8, 1))
		winner_background.texture = load("res://assets/lobby + results/results purple.png")
	else:
		winner_label.text = "TIME'S UP!\nIT'S A TIE!"
		winner_label.add_theme_color_override("font_color", Color(1, 1, 1, 1))
		winner_background.visible = false # Or set a default tie image
	
	winner_overlay.visible = true
	# Pause the game
	get_tree().paused = true

func _on_timer_updated(time_left: float):
	var minutes = int(time_left / 60)
	var seconds = int(time_left) % 60
	# Ensure timer format has consistent width to prevent overlap
	timer_label.text = "%01d : %01d" % [minutes, seconds]
	
	# Change color when time is running low
	if time_left <= 10:
		timer_label.add_theme_color_override("font_color", Color(1, 0.2, 0.2, 1))  # Red
	elif time_left <= 30:
		timer_label.add_theme_color_override("font_color", Color(1, 1, 0.2, 1))  # Yellow
	else:
		timer_label.add_theme_color_override("font_color", Color(1, 1, 1, 1))  # White 
