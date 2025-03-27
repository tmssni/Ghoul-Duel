extends Sprite2D

@export var value: int = 1  # How much the chain grows


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float):
	pass

func _on_area_2d_body_entered(body: Node2D):
	print("Collision with:", body.name)  # Debugging line
	if body.name == "player": #|| body.name == "enemy":
		body.flames_stolen += 1
		for i in range(value):
			body.add_chain_segment()  # Call function in player script
			self.hide()
			await get_tree().create_timer(5)

func _on_timer_timeout():
	self.show()
