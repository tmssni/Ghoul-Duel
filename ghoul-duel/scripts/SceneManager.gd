extends Node

@export var GreenPlayerScene : PackedScene
@export var PurplePlayerScene : PackedScene

# to spawn player
func _ready() -> void:
	var index = 0 
	for i in global.GreenPlayers:
		var currentPlayer = GreenPlayerScene.instantiate()
		PurplePlayerScene.instantiate()
		add_child(currentPlayer)
		print(currentPlayer.get_unique_id())
		for spawn in get_tree().get_nodes_in_group("GreenSpawnPoint"):
			if spawn.name == str(1):
				currentPlayer.global_position = spawn.global_position
				
		
	for i in global.PurplePlayers:
		var currentPlayer = PurplePlayerScene.instantiate()
		GreenPlayerScene.instantiate()
		add_child(currentPlayer)
		print(currentPlayer.get_unique_id())
		for spawn in get_tree().get_nodes_in_group("PurpleSpawnPoint"):
			if spawn.name == str(0):
				currentPlayer.global_position = spawn.global_position
				
		
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
