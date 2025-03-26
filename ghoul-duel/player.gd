class_name Player extends CharacterBody2D
@export var result : Dictionary
@export var speed = 400
@export var flames_stolen := 0

@export var chain_scene: PackedScene = preload("res://chain_segments.tscn")
@export var segment_spacing = 30 
var chain_segments = []  # Stores all chain segments
var previous_positions = []  # Stores past positions of the player
var max_positions = 100 # How many positions to store

# Update position history every frame, but pick positions further apart
var position_history_frequency = 1  # Save history every frame
var segment_follow_distance = 5    # Each segment follows a position further back in history
var timer = 0

var collision 

@export var player := 1 :
	set(id):
		player = id
		$PlayerInput.set_multiplayer_authority(id)

@onready var input = $PlayerInput

func _ready():
	pass

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
	timer += 1
	if timer >= position_history_frequency:
		timer = 0
		previous_positions.insert(0, global_position)
		
		# Keep the position history manageable
		if previous_positions.size() > max_positions:
			previous_positions.pop_back()

	# Update each chain segment to follow the player with snake-like effect
	for i in range(chain_segments.size()):
		var target_index = i * segment_follow_distance
		
		if target_index < previous_positions.size():
			chain_segments[i].global_position = Vector2(previous_positions[target_index].x - 225, previous_positions[target_index].y - 175) + Vector2(0, 30 * (i+1))
		else:
			# If we don't have enough position history yet
			var last_pos = previous_positions[previous_positions.size() - 1] if previous_positions.size() > 0 else global_position
			chain_segments[i].global_position = Vector2(last_pos.x - 225, last_pos.y - 175) + Vector2(0, 30 * (i+1))

func add_chain_segment():
	var new_segment = chain_scene.instantiate()
	get_parent().add_child(new_segment)  # Add to the scene
	if chain_segments.size() == 0:
		new_segment.global_position = global_position - Vector2(segment_spacing, 0)
	else:
		new_segment.global_position = chain_segments[-1].global_position - Vector2(segment_spacing, 0)
	chain_segments.append(new_segment)

func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false
