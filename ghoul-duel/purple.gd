extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.name == "player":
		print("collision detected between purple base & player")
		body._on_home_base_body_entered(body)  # Push enemy out
	if body.name == "enemy":
		print("collision between purple base & enemy")
		global.enemy_score += body.chain_size()
		body.delete_chain()
	global._progress_bar(global.player_score, global.enemy_score)
