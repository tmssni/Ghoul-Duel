#multiplayer.gd
extends Node

const SPAWN_RANDOM := 5.0

const PORT = 4433
var ip

func _ready():
	#if no player in server
	if not multiplayer.is_server():
		return
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(del_player)
	for id in multiplayer.get_peers():
		add_player(id)
	
	if OS.get_name() == "Windows":
		ip = IP.get_local_addresses()[3]
	else:
		ip = IP.get_local_addresses()[3]
		
	#get ip address
	for address in IP.get_local_addresses():
		if address.begins_with("192.168") and not address.ends_with(".1"):
			ip = address  # This correctly updates the outer instance variable

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
	multiplayer.set_multiplayer_server(peer)
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		OS.alert("Failed to start multiplayer server.")
		return
	#multiplayer.multiplayer_peer = peer
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

#LAVANYA's POSSIBLY INCORRECTLY PLACED CODE

#grid variable
var cells : int = 20
var cell_size : int = 40

#G snake variables
var old_gdata : Array
var snake_gdata : Array
var snake_g : Array

#movement variables
var start_pos 
var move_direction : Vector2
var can_move : bool

func generate_chain():
	old_gdata.clear()
	snake_gdata.clear()
	snake_g.clear()
	for i in range (3):
		add_segment(start_pos + Vector2(0, i))

func add_segment(pos):
	snake_gdata.append(pos)
	var GreenChain = map_scene.instantiate()
	GreenChain.position = (pos * cell_size) * Vector2(0, cell_size)
	add_child(GreenChain)
	snake_g.append(GreenChain)

func _on_timer_timeout() -> void:
	can_move = true
	old_gdata = [] + snake_gdata
	snake_gdata[0] += move_direction
	for i in range(len(snake_gdata)):
		if i > 0:
			snake_gdata[i] = old_gdata[i-1]
		snake[i].position = (snake_gdata[i] * cell_size) + Vector2(0, cell_size)
