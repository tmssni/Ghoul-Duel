extends Area2D

# Variable to store the chain segments in this area
var chain_segments = []

func _ready():
	# Connect the signal from each chain segment
	for segment in chain_segments:
		var collision_shape = segment.get_node("CollisionShape2D")  # Make sure this is the CollisionShape2D node in the segment
		collision_shape.connect("body_entered", self, "_on_chain_segment_hit")

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "enemy":  # Check if the colliding body is an enemy
		print("Enemy hit the chain segment!")
		# Call a function to remove the chain segment
		remove_tail_segment()

# Remove the tail segment from the chain
func remove_tail_segment():
	if chain_segments.size() > 0:
		var tail_segment = chain_segments.pop_back()  # Get the last segment
		tail_segment.queue_free()  # Remove it from the scene
		print("Tail segment removed")
