extends CharacterBody2D

@onready var sprite := $AnimatedSprite2D
@onready var sprite_air := $Sprite2D
@onready var ray := $RayCast2D
@onready var line := $Grapple
@onready var hitbox := $Hitbox
@onready var hittimer := $HitTimer
@onready var trail := $Trail
@onready var hud = get_tree().get_first_node_in_group("hud")

const speed: float = 30.0
const max_speed: float = 300.0
const gravity = Vector2(0, 20.0)
const jump_velocity: float = -500.0
const max_fall_velocity: float = 400.0
const min_grapple_length: float = 2.0
const grapple_reel_in_rate: float = 1.0
const grapple_damping: float = 0.02
const anim_swing_threshold: float = 150.0
const kb_power: float = 800.0
const max_trail_points: int = 500
const converge_line = preload("res://scripts/converge.tscn")

var lives = 5
var jumped := false
var grapple_hooked = false
var grapple_target: Vector2
var grapple_length: float
var kb_force = Vector2.ZERO
var queue: Array = []
var queue_drift: Array = []

signal hit

func _ready() -> void:
	Global.current_player = self
	for i in range(200):
		var angle = i*2*PI/200
		queue_drift.push_back(0.1*Vector2(sin(2*angle), cos(angle)))

func _physics_process(_delta: float) -> void:
	SFX_Manager.update_position(self)
	ray.look_at(get_global_mouse_position())
	var direction = Input.get_axis("move_left", "move_right")
	if Input.is_action_just_pressed("grapple"):
		_launch_grapple()
	if Input.is_action_just_released("grapple"):
		_retract_grapple()
	_update_grapple()
	_do_trail()
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
	if kb_force.length() > 0:
		velocity = kb_force
		kb_force = Vector2.ZERO
	velocity += gravity
	velocity.y = min(velocity.y, max_fall_velocity)
	
	if Input.is_action_pressed("jump") and \
			not jumped and \
			(is_on_floor() or grapple_hooked):
		SFX_Manager.play_sound_effect_from_dictionary("foley_footstep_gravel_1")
		velocity.y += jump_velocity
		_retract_grapple()
		jumped = true
		#SFX_Manager.play_sound_effect_from_dictionary("foley_footstep_gravel_1")
	if Input.is_action_just_released("jump"):
		jumped = false
	
	move_and_slide()

func _launch_grapple():
	SFX_Manager.play_sound_effect_from_dictionary("whoosh_1")
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
	if Input.is_action_pressed("climb"):
		grapple_length = max(min_grapple_length, grapple_length - grapple_reel_in_rate*2)
	else:
		grapple_length = max(min_grapple_length, grapple_length - grapple_reel_in_rate)

func _do_animation(direction):
	if is_on_floor():
		sprite.show()
		sprite_air.hide()
		if direction:
			sprite.flip_h = direction < 0
			sprite.animation = "move"
		else:
			if Input.is_action_just_pressed("grapple"):
				sprite.animation = "shoot"
			if sprite.animation != "shoot" or not sprite.is_playing():
				sprite.animation = "idle"
				sprite.play()
	else:
		sprite.hide()
		sprite_air.show()
		if abs(velocity.x) < anim_swing_threshold:
			if velocity.y < -anim_swing_threshold:
				# Rising almost-straight up
				sprite_air.frame = 4
			elif velocity.y < anim_swing_threshold:
				# Almost unmoving
				if grapple_hooked:
					sprite.show()
					sprite_air.hide()
					sprite.animation = "dangle"
					sprite.flip_h = false
					sprite.play()
				else:
					sprite_air.frame = 5
			else:
				# Falling almost-straight down
				sprite_air.frame = 7
		else:
			sprite_air.flip_h = velocity.x < 0
			if velocity.y < -anim_swing_threshold:
				# Rising diagonally up
				sprite_air.frame = 3
			elif velocity.y < anim_swing_threshold:
				# Moving almost-straight horizontal
				sprite_air.frame = 5
			else:
				# Falling diagonally down
				sprite_air.frame = 6

func _do_trail():
	queue.push_front(global_position)
	if queue.size() > max_trail_points: queue.pop_back()
	trail.clear_points()
	for index in range(queue.size()):
		var drift_index = (index + queue.size()) % queue_drift.size()
		var point = queue[index] + queue_drift[drift_index]
		queue[index] = point
		trail.add_point(point)

func converge_trail(target: Vector2):
	var converge = converge_line.instantiate()
	converge.points = queue
	converge.target = target
	add_child(converge)
	queue = []

func _on_hitbox_area_entered(area: Area2D) -> void:
	if hittimer.is_stopped():
		hittimer.start()
		lives -= 1
		emit_signal("hit")
		SFX_Manager.play_sound_effect_from_dictionary("splat_quick")
		var tween = create_tween()
		for i in range(5):
			tween.tween_property(sprite, "modulate", Color.TRANSPARENT, 0.3)
			tween.tween_property(sprite, "modulate", Color.WHITE, 0.3)
	if lives <= 0:
		game_over()
	else:
		var direction = global_position.direction_to(area.global_position)
		kb_force = -kb_power * direction

func game_over():
	get_tree().paused = true
	hud.move_over_panel("Game Over")
