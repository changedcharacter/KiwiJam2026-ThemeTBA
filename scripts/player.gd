extends CharacterBody2D

@onready var sprite := $Sprite2D
@onready var ray := $RayCast2D
@onready var line := $Line2D

const speed: float = 30.0
const max_speed: float = 300.0
const gravity = Vector2(0, 20.0)
const jump_velocity: float = -400.0
const max_fall_velocity: float = 400.0
const min_grapple_length: float = 2.0
const grapple_reel_in_rate: float = 1.0
const grapple_damping: float = 0.02

var jumped := false
var grapple_hooked = false
var grapple_target: Vector2
var grapple_length: float

func _physics_process(_delta: float) -> void:
	ray.look_at(get_global_mouse_position())
	var direction = Input.get_axis("move_left", "move_right")
	if Input.is_action_just_pressed("grapple"):
		_launch_grapple()
	if Input.is_action_just_released("grapple"):
		_retract_grapple()
	_update_grapple()
	_do_movement(direction)
	_do_animation(direction)

func _do_movement(direction):
	if grapple_hooked:
		var distance_to_target = global_position.distance_to(grapple_target)
		var direction_to_target = global_position.direction_to(grapple_target)
		velocity.x += speed * direction * abs(direction_to_target.y)
		if distance_to_target < grapple_length:
			grapple_length = distance_to_target
		else:
			velocity += direction_to_target * (distance_to_target - grapple_length)
		velocity *= 1 - grapple_damping
	else:
		velocity.x = move_toward(velocity.x, max_speed * direction, speed)
	velocity += gravity
	velocity.y = min(velocity.y, max_fall_velocity)
	
	if Input.is_action_pressed("jump") and \
			not jumped and \
			(is_on_floor() or grapple_hooked):
		velocity.y += jump_velocity
		_retract_grapple()
		jumped = true
	if Input.is_action_just_released("jump"):
		jumped = false
	
	move_and_slide()

func _launch_grapple():
	if not ray.is_colliding(): return
	grapple_hooked = true
	grapple_target = ray.get_collision_point()
	grapple_length = global_position.distance_to(grapple_target)
	line.visible = true

func _retract_grapple():
	grapple_hooked = false
	line.visible = false

func _update_grapple():
	if not grapple_hooked: return
	line.set_point_position(1, to_local(grapple_target))
	grapple_length = max(min_grapple_length, grapple_length - grapple_reel_in_rate)

func _do_animation(direction):
	if direction > 0: sprite.flip_h = false
	elif direction < 0: sprite.flip_h = true
	if $Sprite2D/Timer.is_stopped():
		sprite.frame = (sprite.frame + 1) % sprite.hframes
		$Sprite2D/Timer.start()
