extends CharacterBody2D
var screen_size
@export var speed = 400
@export var flames_stolen := 0

@export var gchain_scene: PackedScene = preload("res://scenes/chainsegments.tscn")  # Drag & drop ChainSegment.tscn into this in the editor
@export var chainsegments = []  # Stores all chain segments
var previous_positions = []  # Stores past positions of the player
var max_positions = 10  # How many positions to store (adjust as needed)

# Update position history every frame, but pick positions further apart
var position_history_frequency = 1  # Save history every frame
var segment_follow_distance = 5    # Each segment follows a position further back in history
var timer = 0


func _ready():
	screen_size = get_viewport_rect().size
	add_to_group("enemy")

func _process(delta):
	velocity = Vector2.ZERO
	z_index = 2
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
		# Store player's position history every frame
	timer += 5
	if timer >= position_history_frequency:
		timer = 0
		previous_positions.insert(0, global_position)
	
	move_and_slide()
	# Store player's position history
	previous_positions.insert(0, global_position)
	if previous_positions.size() > max_positions * chainsegments.size():
		previous_positions.pop_back()  
		
		# Update each chain segment to follow the player with snake-like effect
	for i in range(chainsegments.size()):
		var target_index = i * segment_follow_distance
		var index = (i + 1) * max_positions
		if index < previous_positions.size():
			chainsegments[i].global_position = previous_positions[index] - Vector2(0.03,0.03)

func add_chain_segment():
	var new_segment = gchain_scene.instantiate()
	get_parent().add_child(new_segment)  # Add to the scene
	new_segment.global_position = global_position  # Spawn at player location
	chainsegments.append(new_segment)

func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false


func remove_segment(segment: Node):
	if segment in chainsegments:
		chainsegments.erase(segment)  # Remove from array
		segment.queue_free()  # Remove it from the scene
		print("Tail segment removed")
		
func delete_chain():
	# Iterate through all chain segments and queue them for deletion
	for segment in chainsegments:
		segment.queue_free()
	chainsegments.clear()

func chain_size():
	var num = chainsegments.size()
	return num


func _on_home_base_body_entered(body):
	if body == self:
		print("Enemy entered home base! Pushing out...")
		if body.position.y < 950:
			body.position.y -= 50  # Move up
			print("up")
		elif body.position.x < 350:
			body.position.x -= 50  # Move left
			print("left")
		#elif body.position.x < 410:
		else:
			body.position.x += 50  # Move right
			print("right")
