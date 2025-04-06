extends Control
#multiplayer_controller.gd

@export var ip = "127.0.0.1"
@export var port = 8910
var peer

#called when the node enters the scene tree for the first time
func _ready():
	multiplayer.peer_connected.connect(player_connected)
	multiplayer.peer_connected.disconnect(player_disconnected)
	multiplayer.connected_to_server.connect(connected_to_server)
	multiplayer.connection_failed.connect(connection_failed)
	
func _process(delta):
	pass

func player_connected(id):
	print("player %s connected" % id)
	
func player_disconnected(id):
	print("player %s disconnected" % id)

#used to send any customer name or icon to server
func connected_to_server():
	print("connected to server")
	send_player_info.rpc_id(1, "", multiplayer.get_unique_id())

func connection_failed():
	print("connection failed")

@rpc("any_peer")
func send_player_info(name, id):
	#print(name)
		if !global.Players.has(id):
			global.Players[id] ={
				"name" : name,
				"id" : id,
			}
		if multiplayer.is_server():
			for i in global.Players:
				send_player_info.rpc(global.Players[i].name, i)


@rpc("any_peer", "call_local")
func start_game():
	var scene = load("res://scenes/multiplayer.tscn").instantiate()
	get_tree().root.add_child(scene)
	self.hide()

func _on_host_pressed():
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(port)
	if error != OK:
		print("cannot host")
		return
	
	#omptimization
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	
	multiplayer.set_multiplayer_peer(peer)
	send_player_info("player", multiplayer.get_unique_id())
	
func _on_join_pressed():
	peer = ENetMultiplayerPeer.new()
	peer.create_client(ip, port)
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	send_player_info("player", multiplayer.get_unique_id())

func _on_start_pressed():
	start_game.rpc()
# Called every frame. 'delta' is the elapsed time since the previous frame.
