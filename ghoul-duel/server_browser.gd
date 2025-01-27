#ServerBrowser
extends Control

signal found_server
signal server_remove
signal joinGame(ip)

var broadcastTimer : Timer
var RoomInfo = {
	"name" : "name", 
	"playerCount" : 0
}
var broadcaster : PacketPeerUDP
var listener : PacketPeerUDP

@export var listenPort : int = 8911
@export var broadcastPort : int = 8912
@export var broadcastAddress : String = '192.168.1.255'
@export var serverInfo : PackedScene

func _ready():
	broadcastTimer = $BroadcastTimer
	setUp()
	
func setUp():
	listener = PacketPeerUDP.new()
	listener.set_broadcast_enabled(true)
	var ok = listener.bind(listenPort)
	if ok == OK:
		print("Bound to listen Port " + str(listenPort) + " sucessful")
		$Label2.text="Bound to listen Port: True"
	else:
		print("Failed to bind to listen Port")
		$Label2.text="Bound to listen Port: False"
	
func setUpBroadcast(name):
	RoomInfo.name = name
	RoomInfo.playerCount = Manager.Players.size()
	broadcaster = PacketPeerUDP.new()
	broadcaster.set_broadcast_enabled(true)
	broadcaster.set_dest_address(broadcastAddress, listenPort)
	
	var ok = broadcaster.bind(broadcastPort)
	if ok == OK:
		print("Bound to Broadcast Port " + str(broadcastPort) + " sucessful")
	else:
		print("Failed to bind to broadcast port")
	
	$BroadcastTimer.start()

func _process(delta):
	if listener.get_available_packet_count() > 0:
		var serverip = listener.get_packet_ip()
		var serverport = listener.get_packet_port()
		var bytes = listener.get_packet()
		var data = bytes.get_string_from_ascii()
		var roomInfo = JSON.parse_string(data)
		
		print("server ip: " + str(serverip) + "server port: " + str(serverport) + "room info: " + str(roomInfo))
		
		var child = $Panel/VBoxContainer.find_child(RoomInfo.name)
		if child != null:
			child.get_node("PlayerCount").text = str(data.playerCount)
		
		#for i in child:
			#if i.name == RoomInfo.name:
				#i.get_node("Ip").text = serverip
				#i.get_node("PlayerCount").text = str(RoomInfo.playerCount)
				#return

		var currentInfo = serverInfo.instantiate()
		currentInfo.name = RoomInfo.name
		currentInfo.get_node("Name").text = RoomInfo.name
		currentInfo.get_node("Ip").text = serverip
		currentInfo.get_node("PlayerCount").text = str(RoomInfo.playerCount)
		$Panel/vBoxContainer.find_child(currentInfo)
		$ServerBrowser.join.connect(joinbyIp)
		currentInfo.join.connect(joinbyIp)

func _on_broadcast_timer_timeout():
	print("Broadcasting Game!")
	RoomInfo.playerCount = Manager.Players.size()
	var data = JSON.stringify(RoomInfo)
	var packet = data.to_ascii_buffer()
	broadcaster.put_packet(packet)

func cleanUp():
	listener.close()
	$BroadcastTimer.stop()
	if broadcaster != null:
		broadcaster.close()

func _exit_tree():
	cleanUp()

func joinbyIp(ip):
	joinGame.emit(ip)
