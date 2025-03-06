extends Area2D

var collider_name

@export var value: int = 1
@onready var timer: Timer = $Timer
@onready var area: Area2D #$Area2D

func _ready():
	timer.timeout.connect(_on_timeout)

func _on_body_entered(body: Node2D) -> void:
	#if body.name == "purple" or body.name == "green":
	body.flames_stolen += 1
	print(body.flames_stolen)

	if body is CharacterBody2D:
		#GameController.coin_collected(value)
		collider_name = body.collision.collider.name
		timer.start()
		collider_name.visible = false
		#area.set_deferred("monitoring", false)

func _on_timeout() -> void:
	#$Coins.set_deferred("monitoring", true) #"monitoring"
	collider_name.visible = true
