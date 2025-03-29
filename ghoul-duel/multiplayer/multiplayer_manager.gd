extends Node
#function: create clinet and server
#house callbacks when connections are established/disconnected

const SERVER_PORT = 8080
const SERVER_IP = "127.0.0.1"

var multiplayer_scene = load("res://multiplayer_player.tscn")

var _GreenPlayers_spawn_node
var _PurplePlayers_spawn_node

#create server
func become_host():
	print("starting host!")
	
	_GreenPlayers_spawn_node = get_tree().get_current_scene().get_node("GreenPlayers")
	
	var server_peer = ENetMultiplayerPeer.new()
	server_peer.create_server(SERVER_PORT)
	
	#establish this instance is server
	multiplayer.multiplayer_peer = server_peer
	multiplayer.peer_connected.connect(_add_player_to_game)
	multiplayer.peer_disconnected.disconnect(_del_player)
	
func join_as_player():
	print("player two joining!")
	
	var client_peer = ENetMultiplayerPeer.new()
	client_peer.create_client(SERVER_IP, SERVER_PORT)
	
	#scene is going to represent every new player the joins the game
	multiplayer.multiplayer_peer = client_peer
	

func _add_player_to_game(id: int):
	print("player %s joined the game!" % id)

	var player_to_add = multiplayer_scene.instantiate()
	_PurplePlayers_spawn_node.add_child(player_to_add, true)
	
	
func _del_player(id: int):
	print("player %s left the game" % id)
