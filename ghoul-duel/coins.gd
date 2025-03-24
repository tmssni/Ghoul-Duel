extends Area2D

var collider_name
var collider_obj
#class_name coins
@export var value: int = 1
@onready var timer: Timer = $Timer
@onready var area: Area2D #$Area2D

func _ready():
	timer.timeout.connect(_on_timeout)

func _on_body_entered(body: Node2D) -> void:
	#if body.name == "purple" or body.name == "green":
	body.flames_stolen += 1
	

	if body is CharacterBody2D:
		#GameController.coin_collected(value)
		collider_obj = $player/RayCast2D.get_collider()
		print(collider_obj)
		print(body.flames_stolen)
		#if collider_obj:
			#collider_name = collider_obj.collider
			#timer.start()
			#collider_name.visible = false
			
			#print("collided with: ", collider_obj.position)
		#	area.set_deferred("monitoring", false)
			#body.visible = false
		

func _on_timeout() -> void:
	#$Coins.set_deferred("monitoring", true) #"monitoring"
	collider_name.visible = true
	#collider_name.visible = true
	
