extends CharacterBody2D

@export var speed = 400
@export var flames_stolen := 0
#@export var result : Dictionary
var collision 
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

func _physics_process(_delta):
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
		#collision = move_and_collide(velocity * delta)
		#if collision:
		var space_state = get_world_2d().direct_space_state
	# use global coordinates, not local to node
		var query = PhysicsRayQueryParameters2D.create(Vector2(0, 0), Vector2(50, 100))
		var result = space_state.intersect_ray(query)
		
		if result:
			#print("Hit at point: ", result.position)
			flames_stolen = flames_stolen + 1
			#print("Collider name: ", result.collider, "node")
		#else:
			#print("Not noted")
		
	
		
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
