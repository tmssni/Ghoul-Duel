class_name Player extends CharacterBody2D
@export var result : Dictionary
@export var speed = 200
@export var flames_stolen := 0

@export var chain_scene: PackedScene = preload("res://chain_segments.tscn")  # Drag & drop ChainSegment.tscn into this in the editor
@export var chain_segments = []  # Stores all chain segments
var previous_positions = []  # Stores past positions of the player
var max_positions = 10  # How many positions to store (adjust as needed)

# Update position history every frame, but pick positions further apart
var position_history_frequency = 1  # Save history every frame
var segment_follow_distance = 5    # Each segment follows a position further back in history
var timer = 0
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
	
	#$MultiplayerSynchronizer.set_multiplayer_authority(str(name).to_int())
	add_to_group("player")

func _physics_process(_delta):
		var input_velocity = Vector2.ZERO  # Reset velocity each frame
		z_index = 1
		if Input.is_action_pressed("ui_right"):
			input_velocity.x += 0.1 
		if Input.is_action_pressed("ui_left"):
			input_velocity.x -= 0.1
		if Input.is_action_pressed("ui_up"):
			input_velocity.y -= 0.1
		if Input.is_action_pressed("ui_down"):
			input_velocity.y += 0.1
		
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

		# Store player's position history every frame
		timer += 2
		if timer >= position_history_frequency:
			timer = 0
			previous_positions.insert(0, global_position)
		
		move_and_slide()
		# Store player's position history
		previous_positions.insert(0, global_position)
		if previous_positions.size() > max_positions * chain_segments.size():
			previous_positions.pop_back()  

			# Update each chain segment to follow the player with snake-like effect
		for i in range(chain_segments.size()):
			var target_index = i * segment_follow_distance
			var index = (i + 1) * max_positions
			if index < previous_positions.size():
				chain_segments[i].global_position = previous_positions[index] - Vector2(0.03,0.03)
	
func add_chain_segment():
	var new_segment = chain_scene.instantiate()
	get_parent().add_child(new_segment)  # Add to the scene
	new_segment.global_position = global_position  # Spawn at player location
	chain_segments.append(new_segment)

func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false

func remove_segment(segment: Node):
	if segment in chain_segments:
		chain_segments.erase(segment)  # Remove from array
		segment.queue_free()  # Remove it from the scene
		print("Tail segment removed")
