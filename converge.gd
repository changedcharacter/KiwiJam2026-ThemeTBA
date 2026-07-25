extends Line2D

var points_copy: Array
var target: Vector2
var weight: float = 0.0
var weight_vel: float = -0.1
var weight_accel: float = 0.01

func _ready() -> void:
	points_copy = points.duplicate()

func _physics_process(_delta: float) -> void:
	weight += weight_vel
	weight_vel += weight_accel
	if weight >= 1.0: queue_free()
	for index in range(points.size()):
		points[index] = points_copy[index].lerp(target, weight)
