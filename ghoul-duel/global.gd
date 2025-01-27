extends Node

func instance_node_at_location(node: Object, parent: Object, location: Vector2) -> Object:
	var node_instance = instance_node(node, parent)
	node_instance.global_position = location
	return node_instance
	
func instance_node(node: Object, parent: Object) -> Object:
	var node_instance = node.instance()
	parent.add_child(node_instance)
	return node_instance
	
func _ready() -> void:
	if get_tree().is_network_server():
		setup_players_positions()
		randomize()
		var seedToUse = randi()
		self.rpc("applySeed", seedToUse)
func applySeed(seedToUse):
		seed(seedToUse)
		
