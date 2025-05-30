extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.name == "enemy":
		#print("collision detected between green base & enemy")
		body._on_home_base_body_entered(body)  # Push enemy out
	if body.name == "player":
		# Only score if game is active
		if not global.game_active:
			return
			
		#print("collision between green base & player")
		var chain_score = body.chain_size()
		if chain_score > 0:
			global.player_score += chain_score
			body.delete_chain()
			print("Green scored: ", chain_score, " points! Total: ", global.player_score)
			
			# Check for winner
			global.check_winner()
