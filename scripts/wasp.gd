extends CharacterBody2D


@export var speed = 50
@export var nav_agent: NavigationAgent2D

var target = null
var home_pos = Vector2.ZERO

func _ready() -> void:
	home_pos = self.global_position
	nav_agent.path_desired_distance = 4000
	nav_agent.target_desired_distance = 4000
	
func _physics_process(_delta: float) -> void:
	if nav_agent.is_navigation_finished():
		return
	var axis = to_local(nav_agent.get_next_path_position()).normalized()
	#print(axis)
	velocity = axis *speed
	move_and_slide()
	
func recalc_path():
	print(nav_agent.target_position)
	if target:
		nav_agent.target_position = target.global_position
	else:
		nav_agent.target_position = home_pos




func _on_area_2d_area_entered(area: Area2D) -> void:
	target = area.owner
	#print(target)
	pass # Replace with function body.


func _on_timer_timeout() -> void:
	recalc_path()
	pass # Replace with function body.
