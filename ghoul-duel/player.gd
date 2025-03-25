class_name Player extends CharacterBody2D
@export var result : Dictionary
@export var speed = 400
@export var flames_stolen := 0

@export var chain_scene: PackedScene = preload("res://chain_segments.tscn")  # Drag & drop ChainSegment.tscn into this in the editor
var chain_segments = []  # Stores all chain segments
var previous_positions = []  # Stores past positions of the player
var max_positions = 10  # How many positions to store (adjust as needed)


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
			#print(collision.collider.name)
		
	
		
		# Handle animation
		if velocity.x != 0:
			$AnimatedSprite2D.animation = "idle"
			$AnimatedSprite2D.flip_v = false
			$AnimatedSprite2D.flip_h = velocity.x < 0
		elif velocity.y != 0:
			$AnimatedSprite2D.animation = "move"
		
		move_and_slide()
	# Store player's position history
		previous_positions.insert(0, global_position)
		if previous_positions.size() > max_positions * chain_segments.size():
			previous_positions.pop_back()  
			# Move each chain segment to follow the previous one
		for i in range(chain_segments.size()):
			var index = (i + 1) * max_positions
			if index < previous_positions.size():
				chain_segments[i].global_position = previous_positions[index]
	
func add_chain_segment():
	var new_segment = chain_scene.instantiate()
	get_parent().add_child(new_segment)  # Add to the scene
	new_segment.global_position = global_position  # Spawn at player location
	chain_segments.append(new_segment)

func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false
