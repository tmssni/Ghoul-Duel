extends Node
#function: create clinet and server
#house callbacks when connections are established/disconnected

const SERVER_PORT = 8080
const SERVER_IP = "127.0.0.1"

#create server
func become_host():
	print("starting host!")
	
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
	
	multiplayer.multiplayer_peer = client_peer
	

func _add_player_to_game(id: int):
	print("player %s joined the game!" % id)
	
func _del_player(id: int):
	print("player %s left the game" % id)
