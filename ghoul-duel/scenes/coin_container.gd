extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_coin_respawn_timer_timeout() -> void:
	print("[DEBUG] Coin respawn timer triggered.")
	for coin in get_children():
		if coin.name == "CoinRespawnTimer":
			continue
		if coin is Node2D:
			if not coin.visible:
				print("[DEBUG] ->", coin.name, " is hidden. Showing it now.")
				coin.show()
			else:
				print("[DEBUG] ->", coin.name, " is already visible.")
