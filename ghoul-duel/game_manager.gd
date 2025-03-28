extends Node

var flames = 0

func add_point():
	flames += 1
	print(flames)

func host_game():
	print("become host")
	%UI.hide()
	MultiplayerManager.host_game()
	

func join_game():
	print("join game as player two")
	%UI.hide()
	MultiplayerManager.join_game()
