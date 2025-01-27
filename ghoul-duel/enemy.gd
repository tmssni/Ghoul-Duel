extends CharacterBody2D

var direction := Vector2.ZERO
var screen_size
@export var speed = 400
@export var flames_stolen := 1
var target_player = null
#var enemy = enemy.instance()
#countEnemy += 1
#enemy.set_name("enemy_" + str(countEnemy))


func _ready():
	screen_size = get_viewport_rect().size
	

func _physics_process(delta):
	direction = Vector2.ZERO
	if is_instance_valid(target_player):
		# normalized, bc we dont want get float vector
		direction = global_position.direction_to(target_player.global_position).normalized()
	var _move = move_and_collide(direction * speed)

func _on_player_detect_body_entered(player):
	if player.is_in_group("Player"):
		target_player = player


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
	#velocity = move_and_slide()
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
	
