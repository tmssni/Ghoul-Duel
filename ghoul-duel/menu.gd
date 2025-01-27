extends Control

@export var Address = "127.0.0.1"
@export var port = 8910
var peer

func _ready():
	multiplayer.peer_connected.connect(peer_connected)
	multiplayer.peer_disconnected.disconnect(peer_disconnected)
	multiplayer.connected_to_server.connect(connected_to_server)
	multiplayer.connection_failed.connect(connection_failed)
	if "--server" in OS.get_cmdline_args():
		hostGame()
	$ServerBrowser.joinGame.connect(joinbyIp)
	
func _process(_delta):
	pass

func peer_connected(id):
	print ("Player Connected " + str(id))
func peer_disconnected(id):
	print ("Player Disconnected " + str(id))
	Manager.Players.erase(id)
	var players = get_tree().get_nodes_in_group("Player")
	for i in players:
		if i.name == str(id):
			i.queue_free()
func connected_to_server():
	print ("Connected to server")
	SendPlayerInformation.rpc_id(1, $LineEdit.text, multiplayer.get_unique_id())
func connection_failed():
	print ("Connection Fail")

@rpc("any_peer")
func SendPlayerInformation(name, id):
	print(name + str(id))
	if !Manager.Players.has(id):
		Manager.Players[id] ={
			"name" : name,
			"id" : id,
			"flames" : 0
	}
	
	if multiplayer.is_server():
		for i in Manager.Players:
			SendPlayerInformation.rpc(Manager.Players[i].name, i)

@rpc("any_peer", "call_local")
func StartGame():
	var scene = load("res://map.tscn").instantiate()
	get_tree().root.add_child(scene)
	self.hide()

func hostGame():
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(port, 2)
	if error != OK:
		print("Cannot host: " + str(error))
		return
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(peer)
	
	print("Waiting for players")
	SendPlayerInformation($LineEdit.text, multiplayer.get_unique_id())

func _on_host_pressed() -> void:
	hostGame()
	SendPlayerInformation($LineEdit.text, multiplayer.get_unique_id())
	$ServerBrowser.setUpBroadcast($LineEdit.text + "'s server")

func _on_join_pressed():
	joinbyIp(Address)

func joinbyIp(ip):
	peer = ENetMultiplayerPeer.new()
	peer.create_client(ip, port)
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(peer)

func _on_start_pressed() -> void:
	StartGame.rpc()
