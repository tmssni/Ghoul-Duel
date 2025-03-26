extends Sprite2D

# Variable to store the chain segments in this area
var chain_segments = []

func _ready():
	# Connect the signal from each chain segment
	for segment in chain_segments:
		var collision_shape = segment.get_node("CollisionShape2D")  # Ensure this is correct
		collision_shape.connect("body_entered", self, "_on_chain_segment_hit", [segment])  # Pass the segment as an argument

# Remove the tail segment from the chain
func remove_segment(segment: Node):
	if segment in chain_segments:
		chain_segments.erase(segment)  # Remove from array
		segment.queue_free()  # Remove it from the scene
		print("Tail segment removed")


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "enemy":
		print("Enemy hit the chain!")
