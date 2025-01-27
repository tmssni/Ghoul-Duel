extends CharacterBody2D


@export var speed = 400
var screen_size
var velocity = Vector2.ZERO

@onready var tween := $Tween
@onready var camera := $Camera2D

puppet var puppet_position = Vector2(0, 0) : set = puppet_position_set, get = puppet_position_set
puppet var puppet_velocity = Vector2() : set = puppet_position_set, get = puppet_position_set

func puppet_velocity_set(new_value) -> void:
	puppet_position = new_value

func puppet_position_set(new_value) -> void:
	puppet_position = new_value
	tween.interpolate_property(self, "global_position", global_position, puppet_position, 0.1)
	tween.start()

func _ready():
	screen_size = get_viewport_rect().size
	await get_tree("idle_frame")
	if get_tree().has_network_peer():
		if is_network_master():
			camera.make_current()


func _process(delta):
	if get_tree().has_network_peer():
		if is_network_master():
			velocity = Vector2()
			
			if Input.is_action_pressed("ui_right"):
				velocity.x += 1 
			if Input.is_action_pressed("ui_left"):
				velocity.x -= 1
			if Input.is_action_pressed("ui_up"):
				velocity.y -= 1  
			if Input.is_action_pressed("ui_down"):
				velocity.y += 1 
			
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
		else:
			if not tween.is_active():
				move_and_slide(puppet_velocity * speed)

func update_position(pos):
	# function for updating player position outside this script
	global_position = pos
	puppet_position = pos

func _on_Network_tick_rate_timeout():
	if get_tree().has_network_peer():
		if is_network_master():
			self.rset_unreliable("puppet_position", global_position)
			self.rset_unreliable("puppet_velocity", velocity)

func start(pos):
	position = pos
	rotation = 0
	show()
	$CollisionShape2D.disabled = false
