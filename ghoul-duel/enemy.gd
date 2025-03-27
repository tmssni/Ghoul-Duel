extends CharacterBody2D
var screen_size
@export var speed = 400
@export var flames_stolen := 0

var is_being_pushed = false
var push_direction = Vector2.ZERO
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
	print(global_position)

func start(pos):
	position = pos
	rotation = 0
	show()
	$CollisionShape2D.disabled = false

func _green_base_on_body_exited(body):
	is_being_pushed = false

func _on_home_base_body_entered(body):
	if body == self:
		print("Enemy entered home base! Pushing out...")
		if body.position.y < 950:
			body.position.y -= 100  # Move up
			print("up")
		elif body.position.x < 405:
			body.position.x -= 150  # Move left
			print("left")
		#elif body.position.x < 410:
		else:
			body.position.x += 100  # Move right
			print("right")
