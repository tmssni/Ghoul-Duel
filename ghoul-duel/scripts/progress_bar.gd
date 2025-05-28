extends ProgressBar

var target_value = 50.0
var transition_speed = 3.0

# Define colors for different states
var green_color = Color(0.1, 0.8, 0.1, 1)  # Green
var purple_color = Color(0.8, 0.1, 0.8, 1) # Purple
var neutral_color = Color(0.7, 0.7, 0.7, 1) # Neutral Gray

var _custom_fill_stylebox: StyleBoxFlat = null

func _ready():
	add_to_group("progress_bar")
	value = 50.0  # Start at neutral position
	
	# Create a custom StyleBoxFlat for the fill
	_custom_fill_stylebox = StyleBoxFlat.new()
	_custom_fill_stylebox.bg_color = neutral_color
	_custom_fill_stylebox.border_width_left = 4
	_custom_fill_stylebox.border_width_top = 4
	_custom_fill_stylebox.border_width_right = 4
	_custom_fill_stylebox.border_width_bottom = 4
	_custom_fill_stylebox.border_color = Color(0.720468, 0.720467, 0.720467, 1)
	_custom_fill_stylebox.corner_radius_top_left = 10
	_custom_fill_stylebox.corner_radius_bottom_left = 10
	
	add_theme_stylebox_override("fill", _custom_fill_stylebox)

func _process(delta):
	# Smoothly animate to target value
	if abs(value - target_value) > 0.1:
		value = move_toward(value, target_value, transition_speed * delta * 60)
	
	# Update colors based on current target (not animated value to avoid flipping)
	update_colors()

func set_target_value(new_value: float):
	target_value = clamp(new_value, 0.0, 100.0)
	print("Progress bar target set to: ", target_value)

func update_colors():
	if not _custom_fill_stylebox:
		return
		
	var new_color = neutral_color
	var color_name = "NEUTRAL"
	
	# Use target_value for color decisions to avoid flipping during animation
	if target_value > 50:
		new_color = green_color
		color_name = "GREEN"
	elif target_value < 50:
		new_color = purple_color
		color_name = "PURPLE"
	
	# Only update if color actually needs to change
	if _custom_fill_stylebox.bg_color != new_color:
		_custom_fill_stylebox.bg_color = new_color
		print("Progress bar color: ", color_name, " (target: ", target_value, ", current: ", value, ")")
		queue_redraw()

func get_leading_player() -> String:
	if target_value > 55.0:
		return "Green"
	elif target_value < 45.0:
		return "Purple"
	else:
		return "Tie"
