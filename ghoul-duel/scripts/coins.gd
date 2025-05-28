extends Sprite2D

@export var value: int = 1  # How much the chain grows
var collected = false  # Flag to prevent multiple collections

func _on_area_2d_body_entered(body: Node2D):
	if collected:
		return  # Already collected, don't trigger again
	
	# Only allow collection if game is active
	if not global.game_active:
		return
		
	if body.name == "player" || body.name == "enemy":
		collected = true  # Mark as collected
		hide()  # Hide immediately
		for i in range(value):
			body.add_chain_segment()  # Call function in player script

func _ready():
	# Add to coins group for easy finding
	add_to_group("coins")
	# Reset collected flag when the coin becomes visible again
	visibility_changed.connect(_on_visibility_changed)
	# Connect to game reset
	if global:
		global.connect("winner_announced", _on_game_ended)

func _on_visibility_changed():
	if visible:
		collected = false  # Reset collection flag when coin respawns

func _on_game_ended(_winner_name: String):
	# Reset coin state when game ends
	collected = false
	show()

func reset_coin():
	# Public function to reset coin state
	collected = false
	show()
