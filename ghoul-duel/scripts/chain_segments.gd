extends Sprite2D

# Variable to store the chain segments in this area
var chain_segments = []
var collision_active = true  # Flag to prevent multiple collisions

func _ready():
	pass

func _on_area_2d_body_entered(body: Node2D) -> void:
	if not collision_active:
		return  # Collision already processed
		
	if body.name == "enemy":
		collision_active = false  # Disable collision temporarily
		print("Enemy hit the chain!")

		# Find the player dynamically
		var player = get_tree().get_nodes_in_group("player")  # Make sure the player is in this group

		if player.is_empty():
			print("ERROR: No player found in the scene!")
			collision_active = true  # Re-enable collision
			return
		
		player = player[0]  # Get the first player in the group

		if not player.has_method("remove_segment"):  # Check if it's really the correct node
			print("ERROR: Found node is not the player!")
			collision_active = true  # Re-enable collision
			return
		
		if player.chain_segments.size() > 0:
			print("Chain segments before removal:", player.chain_segments.size())

			var segment_to_remove = player.chain_segments.pop_back()
			print("Segment to remove:", segment_to_remove)

			if segment_to_remove == null:
				print("ERROR: segment_to_remove is null!")
			elif not is_instance_valid(segment_to_remove):
				print("ERROR: segment_to_remove is not valid!")
			else:
				body.add_chain_segment()
				player.chain_segments.erase(segment_to_remove)
				segment_to_remove.queue_free()
				print("Removed segment successfully.")

			print("Chain segments after removal:", player.chain_segments.size())
		
		# Re-enable collision after a short delay
		call_deferred("_reset_collision")

func _reset_collision():
	collision_active = true
