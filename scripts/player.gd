extends CharacterBody2D

const max_speed: float = 600.0
const accel: float = 2000.0
const gravity: float = 1000.0
const jump_velocity: float = -800.0
const max_fall_velocity: float = 800.0

func _physics_process(delta: float) -> void:
	if velocity.y < max_fall_velocity:
		velocity.y += gravity * delta
	
	if Input.is_action_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
	
	var direction = Input.get_axis("move_left", "move_right")
	velocity.x = Vector2(velocity.x, 0).move_toward(Vector2(max_speed*direction, 0), accel*delta).x
	
	move_and_slide()
