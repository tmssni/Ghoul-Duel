#multiplayer.gd
extends Node

const SPAWN_RANDOM := 5.0

const PORT = 4433

func _ready():
	#if no player in server
	if not multiplayer.is_server():
		return
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(del_player)
	for id in multiplayer.get_peers():
		add_player(id)
	
func _exit_tree():
	if not multiplayer.is_server():
		return
	multiplayer.peer_connected.disconnect(add_player)
	multiplayer.peer_disconnected.disconnect(del_player)


func add_player(id: int):
	var character = load("res://player.tscn").instantiate()
	# Set player id. preload("res://player.tscn")
	character.player = str(id)
	# Randomize character position. (WILL REPLACE WITH SPAWN POINT EVENTUALLY)
	var pos := Vector2.from_angle(randf() * 2 * PI)
	character.position = Vector2(pos.x * SPAWN_RANDOM * randf(), pos.y * SPAWN_RANDOM * randf())
	character.name = str(id)
	$Players.add_child(character, true)


func del_player(id: int):
	if not $Players.has_node(str(id)):
		return
	$Players.get_node(str(id)).queue_free()
	#start paused.
	get_tree().paused = true
	#you can save bandwidth by disabling server relay and peer notifications.
	multiplayer.server_relay = false

	# optimization: automatically start the server in headless mode.
	if DisplayServer.get_name() == "headless":
		print("Automatically starting dedicated server.")
		_on_host_pressed.call_deferred()

func _on_host_pressed() -> void:
	#start as server
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(PORT)
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		OS.alert("Failed to start multiplayer server.")
		return
	multiplayer.multiplayer_peer = peer
	start_game()

func _on_connect_pressed() -> void:
	#start as client.
	var txt : String = $UI/Net/Options/Remote.text
	if txt == "":
		OS.alert("Need a remote to connect to.")
		return
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(txt, PORT)
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		OS.alert("Failed to start multiplayer client.")
		return
	multiplayer.multiplayer_peer = peer
	start_game()

func start_game():
	# Hide the UI and unpause to start the game.
	$UI.hide()
	get_tree().paused = false
