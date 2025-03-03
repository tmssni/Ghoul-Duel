extends CharacterBody2D

@export var speed = 400

var screen_size

# Set by the authority, synchronized on spawn.
@export var player := 1 :
	set(id):
		player = id
		# Give authority over the player input to the appropriate peer.
		$PlayerInput.set_multiplayer_authority(id)
# Player synchronized input

@onready var input = $PlayerInput

func _ready():
	# Set the camera as current if we are this player.
	#if player == multiplayer.get_unique_id():
		#$Camera2D.current = true
	#if player == multiplayer.get_unique_id():
		#$Camera2D.current = true
	pass
	#$MultiplayerSynchronizer.set_multiplayer_authority(str(name).to_int())

func _physics_process(delta):
		var input_velocity = Vector2.ZERO  # Reset velocity each frame
		
		if Input.is_action_pressed("ui_right"):
			input_velocity.x += 1 
		if Input.is_action_pressed("ui_left"):
			input_velocity.x -= 1
		if Input.is_action_pressed("ui_up"):
			input_velocity.y -= 1 
		if Input.is_action_pressed("ui_down"):
			input_velocity.y += 1
		
		if input_velocity.length() > 0:
			input_velocity = input_velocity.normalized() * speed
			$AnimatedSprite2D.play()
		else:
			$AnimatedSprite2D.stop()

		# Apply velocity using move_and_slide()
		velocity = input_velocity
		move_and_slide()
	
		
		# Handle animation
		if velocity.x != 0:
			$AnimatedSprite2D.animation = "idle"
			$AnimatedSprite2D.flip_v = false
			$AnimatedSprite2D.flip_h = velocity.x < 0
		elif velocity.y != 0:
			$AnimatedSprite2D.animation = "move"
			
	
func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false
