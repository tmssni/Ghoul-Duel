extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.name == "player":
		print("collision detected between purple base & player")
		body._on_home_base_body_entered(body)  # Push enemy out
	if body.name == "enemy":
		# Only score if game is active
		if not global.game_active:
			return
			
		print("collision between purple base & enemy")
		var chain_score = body.chain_size()
		if chain_score > 0:
			global.enemy_score += chain_score
			body.delete_chain()
			print("Purple scored: ", chain_score, " points! Total: ", global.enemy_score)
			
			# Update progress bar and check for winner
			global.update_progress_bar(global.player_score, global.enemy_score)
			global.check_winner()
