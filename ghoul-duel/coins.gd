extends Area2D
@export var value: int = 1

@onready var timer: Timer = $Timer
@onready var area: Area2D = $Area2D

func _ready():
	timer.timeout.connect(_on_timeout)

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		#GameController.coin_collected(value)
		timer.start()
		self.visible = false
		area.set_deferred("monitoring", false)

func _on_timeout() -> void:
	area.set_deferred("monitoring", true)
	self.visible = true
