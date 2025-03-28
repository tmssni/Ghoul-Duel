extends Sprite2D

@export var value: int = 1  # How much the chain grows
var game_manager

<<<<<<< HEAD
=======
# Called when the node enters the scene tree for the first time.
func _ready():
	#game_manager = get_node("/root/Main/GameManager")
	pass

>>>>>>> c959f7ffc211179170003b730897d47d5a4ae0ad
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float):
	pass

func _on_area_2d_body_entered(body: Node2D):
	if body.name == "player" || body.name == "enemy":
		GameManager.add_point()
		for i in range(value):
			body.add_chain_segment()  # Call function in player script
			queue_free()
