extends CharacterBody2D


@export var speed = 400
var screen_size
var syncPos = Vector2(0,0)

func _ready():
	screen_size = get_viewport_rect().size
	$MultiplayerSynchronizer.set_multiplayer_authority(str(name).to_int())

func _process(delta):
	if $MultiplayerSynchronizer.get_multiplayer_authority() == multiplayer.get_unique_id():
		var velocity = Vector2.ZERO
		
		if Input.is_action_pressed("ui_right"):
			velocity.x += 1 
		if Input.is_action_pressed("ui_left"):
			velocity.x -= 1
		if Input.is_action_pressed("ui_up"):
			velocity.y -= 1  
		if Input.is_action_pressed("ui_down"):
			velocity.y += 1 
		
		syncPos = global_position
		
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
			
		move_and_slide()
	else:
		global_position = global_position.lerp(syncPos, .5)
		
func start(pos):
	position = pos
	rotation = 0
	show()
	$CollisionShape2D.disabled = false
