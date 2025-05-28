extends Label

var last_score = 0
var flash_timer = 0.0
var normal_color = Color(1, 1, 1, 1)
var flash_color = Color(0.1, 1, 0.1, 1)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var current_score = global.player_score
	text = str(current_score)
	
	# Flash effect when score changes
	if current_score != last_score:
		flash_timer = 0.5  # Flash for half a second
		last_score = current_score
	
	# Handle flash animation
	if flash_timer > 0:
		flash_timer -= delta
		# Alternate between normal and flash color
		var flash_intensity = sin(flash_timer * 20) * 0.5 + 0.5
		add_theme_color_override("font_color", normal_color.lerp(flash_color, flash_intensity))
	else:
		add_theme_color_override("font_color", normal_color)
