extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.name == "enemy":
		#print("collision detected between green base & enemy")
		body._on_home_base_body_entered(body)  # Push enemy out
	if body.name == "player":
		#print("collision between green base & player")
		global.player_score += body.chain_size()
		body.delete_chain()
	global._progress_bar(global.player_score, global.enemy_score)
