extends Control

@export var ip := "127.0.0.1"
@export var port := 8910
var peer

# Called when the node enters the scene tree for the first time
func _ready():
	print("[READY] Multiplayer Controller Initialized.")
	print("[READY] Is Server?: ", multiplayer.is_server())
	print("[READY] My Peer ID: ", multiplayer.get_unique_id())

	multiplayer.peer_connected.connect(player_connected)
	multiplayer.peer_disconnected.connect(player_disconnected)
	multiplayer.connected_to_server.connect(connected_to_server)
	multiplayer.connection_failed.connect(connection_failed)

# Spawns a character (player or enemy) at a named spawn point
func spawn_character(scene_path: String, name: String, id: int, spawn_point_name: String):
	var scene = load(scene_path).instantiate()
	scene.name = name
	scene.set_multiplayer_authority(id)
	add_child(scene)

	# Assign position from spawn point
	var spawn_points = get_tree().get_nodes_in_group("SpawnPoint")
	for spawn in spawn_points:
		if spawn.name == spawn_point_name:
			scene.global_position = spawn.global_position
			print("[SPAWN] Spawned ", name, " (ID ", id, ") at ", spawn_point_name)
			return
	print("[ERROR] Spawn point not found: ", spawn_point_name)

# Called when a player connects (server and client)
func player_connected(id):
	print("[CONNECT] Player connected: ", id)
	print("[CONNECT] I am server? ", multiplayer.is_server(), " | My ID: ", multiplayer.get_unique_id())

	if multiplayer.is_server():
		# Server spawns the new player's character
		if id == multiplayer.get_unique_id():
			spawn_character("res://scenes/player.tscn", "Player", id, "1")
		else:
			spawn_character("res://scenes/enemy.tscn", "Enemy", id, "0")

# Called when a player disconnects
func player_disconnected(id):
	print("[DISCONNECT] Player disconnected: ", id)

# Called only on clients
func connected_to_server():
	print("[NETWORK] Connected to server.")
	send_player_info.rpc_id(1, "player", multiplayer.get_unique_id())

# Called only on clients
func connection_failed():
	print("[NETWORK] Connection failed.")

# Send player metadata to server
@rpc("any_peer")
func send_player_info(name, id):
	print("[RPC] Received player info | ID: ", id, " | Name: ", name)
	if not global.Players.has(id):
		global.Players[id] = {
			"name": name,
			"id": id,
		}
	if multiplayer.is_server():
		for i in global.Players:
			send_player_info.rpc(global.Players[i].name, i)

@rpc("any_peer", "call_local")
func start_game():
	print("[GAME] Starting game scene...")
	var scene = load("res://scenes/multiplayer.tscn").instantiate()
	get_tree().root.add_child(scene)
	self.hide()

	# Wait one frame so scene loads first
	await get_tree().process_frame

	# Spawn host's own player
	if multiplayer.is_server():
		var id = multiplayer.get_unique_id()
		print("[SPAWN] Host is spawning their own player. ID: ", id)
		spawn_character("res://scenes/player.tscn", "Player", id, "1")


# UI Buttons

func _on_host_pressed():
	print("[UI] Host button pressed.")
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(port)
	if error != OK:
		print("[ERROR] Failed to host server: ", error)
		return

	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(peer)

	var id = multiplayer.get_unique_id()
	print("[HOST] My Peer ID: ", id)
	global.Players[id] = { "name": "host", "id": id }

	# Manually spawn host's player (since server doesn't "connect" to itself)
	spawn_character("res://scenes/player.tscn", "Player", id, "1")

	send_player_info("host", id)

func _on_join_pressed():
	print("[UI] Join button pressed.")
	peer = ENetMultiplayerPeer.new()
	peer.create_client(ip, port)
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(peer)

func _on_start_pressed():
	print("[UI] Start button pressed.")
	start_game.rpc()
