#multiplayer.gd
extends Node

const SPAWN_RANDOM := 5.0
@export var map_scene: PackedScene

const PORT = 4433
var ip = "127.0.0.1"

var player_scene = load("res://player.tscn")
var ememy_scene = load("res://enemy.tscn")
var player_to_add

func _ready():
	#if no player in server
	pass
	#get ip address
	#if OS.get_name() == "Windows":
		#ip = IP.get_local_addresses()[3]
	#else:
		#ip = IP.get_local_addresses()[3]
		
	#check if valid ip address	
	#for address in IP.get_local_addresses():
		#if address.begins_with("192.168") and not address.ends_with(".1"):
			#ip = address  # This correctly updates the outer instance variable

func _exit_tree():
	if not multiplayer.is_server():
		return
	multiplayer.peer_connected.disconnect(add_player)
	multiplayer.peer_disconnected.disconnect(del_player)

func _on_host_pressed() -> void:
	#start as server
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(PORT)
	print("host game!")
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		OS.alert("Failed to start multiplayer server.")
		return
	multiplayer.multiplayer_peer = peer
	start_game()
	
	#add and delete players from game
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(del_player)
	
	#for id in multiplayer.get_peers():
		#add_player(id)
	
func _on_connect_pressed() -> void:
	#start as client.
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(ip, PORT)
	print("join game!")
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		OS.alert("Failed to start multiplayer client.")
		return
	multiplayer.multiplayer_peer = peer
	start_game()

func add_player(id: int):
	print("player %s joined" % id)
	if not multiplayer.is_server():
		player_to_add = player_scene.instantiate()
	else:
		player_to_add = ememy_scene.instantiate()
	# Set player id. preload("res://player.tscn")
	#player_to_add.player_id = id
	#player_to_add.name = str(id)
	
	#$Players.add_child(character, true)


func del_player(id: int):
	#if not $Players.has_node(str(id)):
		#return
	#$Players.get_node(str(id)).queue_free()
	#start paused.
	#get_tree().paused = true
	#you can save bandwidth by disabling server relay and peer notifications.
	#multiplayer.server_relay = false

	# optimization: automatically start the server in headless mode.
	#if DisplayServer.get_name() == "headless":
		#print("Automatically starting dedicated server.")
		#_on_host_pressed.call_deferred()
	pass



func start_game():
	# Hide the UI and unpause to start the game.
	$UI.hide()
	get_tree().paused = false
