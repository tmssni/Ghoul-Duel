extends Sprite2D

# Variable to store the chain segments in this area
var chainsegments = []

func _ready():
	pass

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "player":
		print("Player hit the chain!")

		# Find the player dynamically
		var enemy = get_tree().get_nodes_in_group("enemy")  

		if enemy.is_empty():
			print("PURPLE ERROR: No player found in the scene!")
			return
		
		enemy = enemy[0]  # Get the first player in the group

		if not enemy.has_method("remove_segment"):  # Check if it's really the correct node
			print("PURPLE ERROR: Found node is not the enemy!")
			return
		
		if enemy.chainsegments.size() > 0:
			print("PURPLE Chain segments before removal:", enemy.chainsegments.size())

			var segment_to_remove = enemy.chainsegments.pop_back()
			print("PURPLE Segment to remove:", segment_to_remove)

			if segment_to_remove == null:
				print("ERROR: PURPLE segment_to_remove is null!")
			elif not is_instance_valid(segment_to_remove):
				print("ERROR: PURPLE segment_to_remove is not valid!")
			else:
				enemy.chainsegments.erase(segment_to_remove)
				segment_to_remove.queue_free()
				print("Removed PURPLE segment successfully.")

			print("Chain segments after removal:", enemy.chainsegments.size())
