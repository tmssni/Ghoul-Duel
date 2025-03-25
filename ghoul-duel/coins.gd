extends Sprite2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_area_2d_body_entered(body: Node2D) -> void:
	print("Collision with:", body.name)  # Debugging line
	if body.name == "player":
		body.flames_stolen += 1
		queue_free()
