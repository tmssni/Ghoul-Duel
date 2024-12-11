extends Area2D

signal hit

@export var speed = 400
var screen_size 

func _ready():
	screen_size = get_viewport_rect().size
	#hide()
	
func _process(delta):
	var velocity = Vector2.ZERO
	if Input.is_action_pressed("move_right"):
		velocity.x += 1 
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1  
	if Input.is_action_pressed("move_down"):
		velocity.y += 1 
	
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()
	
	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)
	
	if velocity.x == 0 and velocity.y == 0:
		$AnimatedSprite2D.animation = "idle"
	elif velocity.x != 0:
		$AnimatedSprite2D.animation = "move"
		$AnimatedSprite2D.flip_v = false
		#$Trail.rotation = 0
		$AnimatedSprite2D.flip_h = velocity.x < 0
	elif velocity.y != 0:
		$AnimatedSprite2D.animation = "idle"
		#rotation = PI if velocity.y > 0 else 0 : flips image vertically

func start(pos):
	position = pos
	rotation = 0
	show()
	$CollisionShape2D.disabled = false

func _on_body_entered(body):
	hide() #player disappears after being hit
	hit.emit()
	$CollisionShape2D.set_deferred("disabled", true)
	
