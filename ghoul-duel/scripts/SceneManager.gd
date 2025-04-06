extends Node

@export var PlayerScene : PackedScene

# to spawn player
func _ready() -> void:
	var index = 0 
	for i in global.Players:
		var currentPlayer = PlayerScene.instantiate()
		PlayerScene.instantiate()
		add_child(currentPlayer)
		for spawn in get_tree().get_nodes_in_group("SpawnPoint"):
			if spawn.name == str(1):
				currentPlayer.global_position = spawn.global_position
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
