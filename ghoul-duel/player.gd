extends CharacterBody2D


@export var speed = 400
var screen_size

func _ready():
	screen_size = get_viewport_rect().size
	#hide()

func _process(delta):
	var velocity = Vector2.ZERO
	if Input.is_action_pressed("ui_right"):
		velocity.x += 1 
	if Input.is_action_pressed("ui_left"):
		velocity.x -= 1
	if Input.is_action_pressed("ui_up"):
		velocity.y -= 1  
	if Input.is_action_pressed("ui_down"):
		velocity.y += 1 
	
	velocity = velocity.normalized() * speed
	$AnimatedSprite2D.play()
	
	position += velocity * delta
	position = position.clamp(Vector2(), screen_size)
	
	if (velocity.x == 0 and velocity.y == 0) or velocity.y != 0:
		$AnimatedSprite2D.animation = "idle"
	elif velocity.x != 0:
		$AnimatedSprite2D.animation = "move"
		$AnimatedSprite2D.flip_v = false
		#$Trail.rotation = 0
		$AnimatedSprite2D.flip_h = velocity.x < 0
	

func start(pos):
	position = pos
	rotation = 0
	show()
	$CollisionShape2D.disabled = false
