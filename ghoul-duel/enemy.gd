extends CharacterBody2D

var velocity := Vector2.ZERO
var screen_size
@export var speed = 400
@export var flames_stolen := 1
var target_player = null
var enemy = enemy.instance()
countEnemy += 1
enemy.set_name("enemy_" + str(countEnemy))

puppet var puppet_position = Vector2(0, 0) : set = puppet_position_set, get = puppet_position_set
puppet var puppet_velocity = Vector2() : set = puppet_position_set, get = puppet_position_set

func puppet_position_set(new_value):
	puppet_position = new_value
	$Tween.interpolate_property(self, "global_position", global_position, puppet_position, 0.1)
	$Tween.start()

func puppet_direction_set(new_value):
	puppet_direction = new_value


func _physics_process(delta):
	velocity = Vector2.ZERO
	if target_player:
		# normalized, bc we dont want get float vector
		velocity = global_position.direction_to(target_player.global_position).normalized()
	var _move = move_and_collide(direction * speed)


func _on_PlayerDetect_body_entered(player):
	if player.is_in_group("Player"):
		target_player = player


func _on_StealDistance_body_entered(player):
	# we will call function on player "damage" with value "weapon_damage"
	if player.is_in_group("Player"):
		player.damage(weapon_damage)


func _on_Network_tick_rate_timeout():
	if get_tree().has_network_peer():
		if is_network_master():
			self.rset_unreliable("puppet_position", global_position)
			self.rset_unreliable("puppet_direction", velocity

func _ready():
	screen_size = get_viewport_rect().size
	for player in persistent_nodes.get_children():
		#this iwll focus first valid player
		if is_instance_valid(player):
			target_player = player
			break

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
