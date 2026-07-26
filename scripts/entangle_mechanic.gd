extends Node2D
@onready var up_ray= $RayCast2DUp
@onready var down_ray = $RayCast2DDown
@onready var up_point = $PointLight2D
@onready var down_point = $PointLight2D2


@onready var player = get_tree().get_first_node_in_group("player")
@onready var progress = $"../TextureProgressBar"
@onready var loop_count = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	progress.visible = false	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	var up_collider = up_ray.get_collider()
	var down_collider = down_ray.get_collider()
	if up_collider == player:
		up_point.visible = false
		down_point.visible = true
		up_ray.add_exception(player)
		down_ray.remove_exception(player)
		count_loop()
	
	if down_collider == player:
		if player:
			up_point.visible = true
			down_point.visible = false
			down_ray.add_exception(player)
			up_ray.remove_exception(player)
			count_loop()
		
	if loop_count >0 && progress :
		progress.visible = true
		
func count_loop():
	if progress and player:
		SFX_Manager.play_sound_effect_from_dictionary("clothing_thud")
		progress.value += 20
		loop_count += 1
		if progress.value == 100:
			$"..".die()
			player.converge_trail(global_position)
