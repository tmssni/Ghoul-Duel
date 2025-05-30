extends ProgressBar

# Colors for the teams
const GREEN_COLOR = Color(0.1, 0.8, 0.1, 1.0)  # Bright green
const PURPLE_COLOR = Color(0.8, 0.1, 0.8, 1.0)  # Bright purple

# Style boxes for the progress bar
var fill_style: StyleBoxFlat
var background_style: StyleBoxFlat

func _ready():
	# Basic progress bar setup
	min_value = 0
	max_value = 100
	value = 50  # Start at neutral position
	show_percentage = false
	
	# Create fill style (green side)
	fill_style = StyleBoxFlat.new()
	fill_style.bg_color = GREEN_COLOR
	fill_style.corner_radius_top_left = 8
	fill_style.corner_radius_bottom_left = 8
	
	# Create background style (purple side)
	background_style = StyleBoxFlat.new()
	background_style.bg_color = PURPLE_COLOR
	background_style.corner_radius_top_right = 8
	background_style.corner_radius_bottom_right = 8
	
	# Apply styles
	add_theme_stylebox_override("fill", fill_style)
	add_theme_stylebox_override("background", background_style)
	
	# Add to progress_bar group for global script to find
	add_to_group("progress_bar")
	
	print("[PROGRESS BAR] Initialized")

func set_score_ratio(green_score: int, purple_score: int):
	var total = green_score + purple_score
	if total > 0:
		# Calculate green's percentage of total score
		var green_percent = (float(green_score) / float(total)) * 100.0
		value = green_percent
		print("[PROGRESS BAR] Updated - Green: ", green_score, " Purple: ", purple_score, " Ratio: ", green_percent, "%")
	else:
		# If no scores, show 50-50
		value = 50
		print("[PROGRESS BAR] Reset to neutral (50-50)")
