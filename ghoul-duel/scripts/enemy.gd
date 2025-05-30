extends CharacterBody2D
var screen_size
@export var speed = 440  # Slightly faster than player
@export var flames_stolen := 0
@export var detection_radius = 400  # Increased to be more aggressive at chasing
@export var home_base_position = Vector2(348, 150) # This is the ENEMY'S home base

@export var gchain_scene: PackedScene = preload("res://scenes/chainsegments.tscn")
@export var chainsegments = []
var previous_positions = []
var max_positions = 10
var position_history_frequency = 1
var chain_update_timer = 0.0

enum AIState { CHASE_PLAYER, RUN_FROM_PLAYER, RETURN_TO_BASE, RANDOM_EVADE }
var current_state = AIState.CHASE_PLAYER
var player = null
var steal_cooldown = 0.0
const STEAL_COOLDOWN_TIME = 0.5
const RUN_AWAY_TIME = 0.75  # How long to run away before going to base
var run_away_timer = 0.0

var idle_monitor_timer = 0.0 # For animation-based idle
const MAX_IDLE_SECONDS = 1.0

var stuck_detection_timer = 0.0 # For position-based stuck detection
var last_known_position = Vector2.ZERO
const STUCK_CHECK_INTERVAL = 0.6 # Seconds
const MIN_STUCK_DISTANCE_SQUARED = 15.0 # (approx 4*4 pixels) If moves less than this, considered stuck
var random_evade_target = Vector2.ZERO
const RANDOM_EVADE_DISTANCE = 150.0

const PLAYER_BASE_CONTACT_PUSH_STRENGTH = 25.0 

func _ready():
	screen_size = get_viewport_rect().size
	add_to_group("enemy")
	randomize()
	last_known_position = global_position # Initialize for stuck detection

func _physics_process(delta):
	player = find_player()
	
	if steal_cooldown > 0:
		steal_cooldown -= delta

	# --- Animation-based Idle Monitoring (Quick Check) ---
	if $AnimatedSprite2D.animation == "idle":
		idle_monitor_timer += delta
	else:
		idle_monitor_timer = 0.0
	
	if idle_monitor_timer > MAX_IDLE_SECONDS:
		print("[AI RECOVERY - Idle Anim] AI idle too long. Forcing action.")
		force_ai_action_on_stuck("Idle Animation")

	# --- Position-based Stuck Detection (More Robust) ---
	stuck_detection_timer += delta
	if stuck_detection_timer >= STUCK_CHECK_INTERVAL:
		if global_position.distance_squared_to(last_known_position) < MIN_STUCK_DISTANCE_SQUARED:
			print("[AI RECOVERY - Position Stuck] AI physically stuck. Forcing action.")
			force_ai_action_on_stuck("Position Stuck")
		last_known_position = global_position
		stuck_detection_timer = 0.0

	# --- Main State Machine ---
	match current_state:
		AIState.CHASE_PLAYER:
			if player and is_instance_valid(player):
				if global_position.distance_to(player.global_position) < 30 and steal_cooldown <= 0:
					change_state(AIState.RUN_FROM_PLAYER, "Steal attempt! Running away!")
					steal_cooldown = STEAL_COOLDOWN_TIME
					run_away_timer = RUN_AWAY_TIME
				else:
					move_towards(player.global_position, delta)
			elif not (player and is_instance_valid(player)):
				change_state(AIState.RETURN_TO_BASE, "Player lost during chase. Returning to base.")
		
		AIState.RUN_FROM_PLAYER:
			if player and is_instance_valid(player):
				var away_dir = global_position - player.global_position
				if away_dir.length_squared() < 0.01: away_dir = Vector2.RIGHT.rotated(randf_range(0, TAU)) # Avoid zero if on top
				var run_target = global_position + away_dir.normalized() * 200
				run_target.x = clamp(run_target.x, 10, screen_size.x - 10)
				run_target.y = clamp(run_target.y, 10, screen_size.y - 10)
				move_towards(run_target, delta)
				
				run_away_timer -= delta
				if run_away_timer <= 0:
					change_state(AIState.RETURN_TO_BASE, "Done running! Returning to base.")
			else:
				change_state(AIState.RETURN_TO_BASE, "Player lost during run. Returning to base.")
			
		AIState.RETURN_TO_BASE:
			if global_position.distance_to(home_base_position) < 30:
				change_state(AIState.CHASE_PLAYER, "Reached own base! Chasing player.")
			else:
				move_towards(home_base_position, delta)
		
		AIState.RANDOM_EVADE:
			# Condition for completing evade: reached target OR stopped moving
			if global_position.distance_squared_to(random_evade_target) < (MIN_STUCK_DISTANCE_SQUARED * 2) or velocity.length_squared() < 0.1:
				print("[AI] Random evade complete or stopped. Re-evaluating.")
				if player and is_instance_valid(player):
					change_state(AIState.CHASE_PLAYER, "Evaded. Now chasing player.")
				else:
					change_state(AIState.RETURN_TO_BASE, "Evaded. Player not found. Returning to base.")
			else:
				# Still evading, continue moving towards the random_evade_target
				move_towards(random_evade_target, delta)

	update_chain_segments()

func change_state(new_state: AIState, reason: String):
	if current_state != new_state:
		print("[AI STATE CHANGE] ", AIState.keys()[current_state], " -> ", AIState.keys()[new_state], " (", reason, ")")
		current_state = new_state
		idle_monitor_timer = 0.0
		stuck_detection_timer = 0.0 # Reset stuck timer on any intentional state change
		# Reset specific state timers
		if new_state != AIState.RUN_FROM_PLAYER: run_away_timer = 0.0

func force_ai_action_on_stuck(reason_stuck: String):
	print("[AI RECOVERY TRIGGERED] Reason: ", reason_stuck)
	# Priority for recovery actions:
	if current_state == AIState.RETURN_TO_BASE and global_position.distance_squared_to(home_base_position) < MIN_STUCK_DISTANCE_SQUARED * 4:
		# If stuck very close to its own base, it might be an edge case. Try RANDOM_EVADE.
		print("[AI RECOVERY] Stuck near own base. Trying RANDOM_EVADE.")
		var random_dir = Vector2(randf_range(-1,1), randf_range(-1,1)).normalized()
		random_evade_target = global_position + random_dir * RANDOM_EVADE_DISTANCE
		random_evade_target.x = clamp(random_evade_target.x, 10, screen_size.x - 10)
		random_evade_target.y = clamp(random_evade_target.y, 10, screen_size.y - 10)
		change_state(AIState.RANDOM_EVADE, "Stuck recovery: Random Evade from base")
	elif player and is_instance_valid(player) and current_state != AIState.RUN_FROM_PLAYER:
		# If player is valid and we are not already trying to run from them, try running.
		print("[AI RECOVERY] Player valid. Forcing RUN_FROM_PLAYER state.")
		change_state(AIState.RUN_FROM_PLAYER, "Stuck recovery: Run from Player")
		run_away_timer = RUN_AWAY_TIME # Give it time to run
	elif current_state != AIState.RETURN_TO_BASE:
		# If can't run from player (or player invalid), try returning to own base.
		print("[AI RECOVERY] Forcing RETURN_TO_BASE state.")
		change_state(AIState.RETURN_TO_BASE, "Stuck recovery: Return to Base")
	else: # If already trying to return to base (and not close enough to trigger above), or other states failed, do RANDOM_EVADE
		print("[AI RECOVERY] Defaulting to RANDOM_EVADE.")
		var random_dir = Vector2(randf_range(-1,1), randf_range(-1,1)).normalized()
		random_evade_target = global_position + random_dir * RANDOM_EVADE_DISTANCE
		random_evade_target.x = clamp(random_evade_target.x, 10, screen_size.x - 10)
		random_evade_target.y = clamp(random_evade_target.y, 10, screen_size.y - 10)
		change_state(AIState.RANDOM_EVADE, "Stuck recovery: Random Evade General")
	
	# Ensure all timers are reset after forcing an action
	idle_monitor_timer = 0.0
	stuck_detection_timer = 0.0
	last_known_position = global_position # Important: update last_known_position after a forced move attempt

# This function is called if the enemy enters an Area2D named "HomeBase" (presumably the Player's Base)
func _on_HomeBase_body_entered(body_that_entered_area):
	if body_that_entered_area == self: 
		print("[AI] Enemy has entered Player's Base Area.")
		var push_back_direction = Vector2.ZERO
		if player and is_instance_valid(player) and current_state == AIState.CHASE_PLAYER:
			push_back_direction = (global_position - player.global_position).normalized()
			if push_back_direction.length_squared() < 0.001: 
				push_back_direction = Vector2.UP.rotated(randf_range(0, TAU)) 
		else:
			push_back_direction = (home_base_position - global_position).normalized()
			if push_back_direction.length_squared() < 0.001: 
				push_back_direction = Vector2.UP.rotated(randf_range(0, TAU))
		
		self.global_position += push_back_direction * PLAYER_BASE_CONTACT_PUSH_STRENGTH
		print("[AI] Pushed from Player's Base by: ", push_back_direction * PLAYER_BASE_CONTACT_PUSH_STRENGTH)

		if current_state != AIState.RETURN_TO_BASE:
			change_state(AIState.RETURN_TO_BASE, "Contacted Player Base: Forcing RETURN_TO_BASE")
		else:
			print("[AI] Contacted Player Base while already returning to own base. Push applied.")

		idle_monitor_timer = 0.0
		stuck_detection_timer = 0.0
		last_known_position = global_position

func move_towards(target: Vector2, delta):
	var dir = (target - global_position)
	if dir.length_squared() > 1: # Use squared length for minor optimization
		velocity = dir.normalized() * speed
		
		# Basic wall avoidance (simple stop)
		var next_pos = global_position + velocity * delta
		if next_pos.x < 10 or next_pos.x > screen_size.x - 10:
			velocity.x = 0
		if next_pos.y < 10 or next_pos.y > screen_size.y - 10:
			velocity.y = 0
			
		if velocity.length_squared() > 0.01: # Check squared length
			move_and_slide()
			if $AnimatedSprite2D.animation != "move": $AnimatedSprite2D.animation = "move"
			if velocity.x != 0: $AnimatedSprite2D.flip_h = velocity.x < 0
		else:
			if $AnimatedSprite2D.animation != "idle": $AnimatedSprite2D.animation = "idle"
	else:
		velocity = Vector2.ZERO
		if $AnimatedSprite2D.animation != "idle": $AnimatedSprite2D.animation = "idle"

func find_player():
	var players = get_tree().get_nodes_in_group("player")
	return players[0] if not players.is_empty() else null

func update_chain_segments():
	chain_update_timer += 1
	if chain_update_timer >= position_history_frequency:
		chain_update_timer = 0
		previous_positions.insert(0, global_position)
		if previous_positions.size() > max_positions * chainsegments.size() + max_positions:
			previous_positions.pop_back()
			
	for i in range(chainsegments.size()):
		var index = (i + 1) * max_positions
		if index < previous_positions.size():
			chainsegments[i].global_position = previous_positions[index] - Vector2(0.03,0.03)

func add_chain_segment():
	var new_segment = gchain_scene.instantiate()
	get_parent().add_child(new_segment)
	new_segment.global_position = global_position
	chainsegments.append(new_segment)

func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false

func remove_segment(segment: Node):
	if segment in chainsegments:
		chainsegments.erase(segment)
		segment.queue_free()
		
func delete_chain():
	for segment in chainsegments:
		segment.queue_free()
	chainsegments.clear()

func chain_size():
	return chainsegments.size()
