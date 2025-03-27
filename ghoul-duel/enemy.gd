extends CharacterBody2D
var screen_size
@export var speed = 400
@export var flames_stolen := 0
#var target_player = null
#var enemy = enemy.instance()
#countEnemy += 1
#enemy.set_name("enemy_" + str(countEnemy))


func _ready():
	screen_size = get_viewport_rect().size
	
func _process(delta):
	velocity = Vector2.ZERO
	if Input.is_action_pressed("d"):
		velocity.x += 0.1 
	if Input.is_action_pressed("a"):
		velocity.x -= 0.1
	if Input.is_action_pressed("w"):
		velocity.y -= 0.1  
	if Input.is_action_pressed("s"):
		velocity.y += 0.1 
	
	velocity = velocity.normalized() * speed
	move_and_slide()
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

func _on_home_base_body_entered(body):
	if body == self:
		print("Enemy entered home base! Pushing out...")
		if body.position.x < 410:
			body.position.x += 50  # Move right
		elif body.position.x > 285:
			body.position.x -= 50  # Move left
		elif body.position.y > 920:
			body.position.y -= 50  # Move up
