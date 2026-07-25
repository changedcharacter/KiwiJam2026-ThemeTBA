extends CharacterBody2D


@onready var target = $"../Player"
@onready var sprite = $AnimatedSprite2D
@onready var ray_cast = $player_detector
@onready var timer = $Timer
@onready var hop_timer = $HopTimer
@onready var hop_duration = $HopTimer/HopDuration


var speed = 20
var chase_speed = 60
var acceleration = 300

@onready var hop_state = false
var jumpspeed_x = -15
var jumpspeed_y = -45
const max_fall_velocity: float = 200.0


#var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@export var can_move = true

@onready var right_bounds = $rightbound.position.x
@onready var left_bounds = $leftbnoound.position.x


@onready var direction = Vector2.RIGHT

enum States{
	WANDER,
	CHASE,
	DEAD
}
var current_state = States.WANDER

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print(target)
	hop_timer.start()
	sprite.play("default")
	pass # Replace with function body.


func _physics_process(delta: float) -> void:
	if can_move:
		handle_movement(delta)
		change_direction()
		look_for_player()


func handle_movement(delta):
	if current_state == States.WANDER:
		velocity = velocity.move_toward(direction*speed, acceleration * delta)
	elif current_state == States.CHASE:
		velocity = velocity.move_toward(direction*chase_speed, acceleration * delta)
	elif current_state == States.DEAD:
		hop_state = false
		hop_timer.stop()
		hop_duration.stop()
		timer.stop()
		velocity.x = 0
		velocity.y += 30
		
	if hop_state == true:
		velocity.y += jumpspeed_y
		if sprite.flip_h == false:
			velocity.x += jumpspeed_x
		else:
			velocity.x -= jumpspeed_x
	velocity += Vector2(0,20)
	velocity.y = min(velocity.y, max_fall_velocity)
	move_and_slide()
	
func look_for_player():
	if !current_state == States.DEAD:
		if ray_cast.is_colliding():
			var collider = ray_cast.get_collider()
			if collider == target:
				chase_player()
			elif current_state == States.CHASE:
				stop_chase()
				pass
		elif current_state == States.CHASE:
			stop_chase()

func chase_player():
	timer.start()
	current_state = States.CHASE
	
func stop_chase():

	if timer.time_left <= 0:
		timer.stop()	

func change_direction():
	if !current_state == States.DEAD: 
		if current_state == States.WANDER:
			if sprite.flip_h:
				#moving right
				if self.position.x <= right_bounds:
					direction = Vector2.RIGHT
				else:
					direction = Vector2.LEFT
					sprite.flip_h = false	
					ray_cast.target_position = Vector2(-125,0)
			else:
				#moving left
				if self.position.x >= left_bounds:
					direction = Vector2.LEFT
				else:
					sprite.flip_h = true
					ray_cast.target_position = Vector2(125,0)
		else:
			direction = (target.position - self.position).normalized()
			direction = sign(direction)
			print(direction)
			if direction.x == 1.0:
				#player is to the right
				sprite.flip_h = true	
				ray_cast.target_position = Vector2(125,0)
			elif direction.x == -1.0:
				#player is to the left
				sprite.flip_h = false	
				ray_cast.target_position = Vector2(-125,0)		

func die():
	print("died")
	sprite.play("webbed")
	current_state = States.DEAD
	$TextureProgressBar.queue_free()
	
	pass
			
func _on_timer_timeout() -> void:
	current_state = States.WANDER
	pass # Replace with function body.


func _on_hop_timer_timeout() -> void:
	hop()
	
	pass # Replace with function body.

func hop():
	hop_state = true
	hop_duration.start()

func get_Player():
	return target

func _on_hop_duration_timeout() -> void:
	hop_state = false
	hop_timer.start()
	pass # Replace with function body.
