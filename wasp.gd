extends CharacterBody2D

const accel = 300
const speed = 300
@export var nav_agent: NavigationAgent2D
@onready var sprite = $AnimatedSprite2D
@onready var player = get_tree().get_first_node_in_group("player")
@onready var hud = get_tree().get_first_node_in_group("hud")

enum States {
	ALIVE,
	DEAD	
}


@onready var current_state = States.ALIVE

var target = null
var home_pos = Vector2.ZERO

func _ready() -> void:
	sprite.play("default")
	home_pos = self.global_position
	nav_agent.path_desired_distance = 4
	nav_agent.target_desired_distance = 4
	hud.enemies += 1

func _physics_process(delta: float) -> void:
	if current_state != States.DEAD:
		if nav_agent.is_navigation_finished():
			return
		var axis = to_local(nav_agent.get_next_path_position()).normalized()
		velocity = velocity.move_toward(axis*speed, delta * accel)
	else:
		velocity.x = 0
		velocity.y += 20
	
	move_and_slide()
	
func recalc_path():

	if target:
		nav_agent.target_position = target.global_position
	else:
		nav_agent.target_position = home_pos

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.owner == player:
		target = area.owner

func _on_timer_timeout() -> void:
	
	recalc_path()
	pass # Replace with function body.
	
func die():
	hud.enemies -= 1
	current_state = States.DEAD
	$TextureProgressBar.queue_free()
	$Entangle_Mechanic.queue_free()
	$Hitbox.queue_free()
	$DeathTimer.start()

func _on_death_timer_timeout() -> void:
	sprite.play("webbed")
