extends Node2D
@onready var up_ray= $RayCast2DUp
@onready var down_ray = $RayCast2DDown


@onready var player =  $"../../Player"
@onready var progress = $"../TextureProgressBar"
@onready var loop_count = 0

signal entangled(target: Vector2)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	progress.visible = false	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	var up_collider = up_ray.get_collider()
	var down_collider = down_ray.get_collider()
		
	if up_collider == player:
		up_ray.add_exception(player)
		down_ray.remove_exception(player)
		count_loop()
	
	if down_collider == player:
		down_ray.add_exception(player)
		up_ray.remove_exception(player)
		count_loop()
		
	if loop_count >0 :
		progress.visible = true
		
func count_loop():
	progress.value += 20
	loop_count += 1
	print(loop_count)
	if loop_count == 5:
		player.converge_trail(global_position)
