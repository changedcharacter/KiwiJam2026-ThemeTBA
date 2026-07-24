extends CharacterBody2D

var max_speed: float = 600.0
var run_power: float = 2000.0
var halt_acceleration: float = 1000.0
var gravity: Vector2 = Vector2(0, 1000.0)
var jump_power: float = -800.0

func _physics_process(delta: float) -> void:
	velocity += gravity * delta
	
	if Input.is_action_pressed("jump") and is_on_floor():
		velocity.y = jump_power
	
	var direction = Input.get_axis("move_left", "move_right")
	velocity.x = Vector2(velocity.x, 0).move_toward(Vector2(max_speed*direction, 0), run_power*delta).x
	
	move_and_slide()
