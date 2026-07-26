extends Node2D

@onready var rand_index = randi()%get_child_count()
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_child(rand_index).playing = true	
	for audio_stream in get_children():
			audio_stream.volume_db = -30

func _process(_delta: float) -> void:
	position = Global.current_player.position
	if Input.is_action_just_pressed("sfx_volume_up"):
		for audio_stream in get_children():
			audio_stream.volume_db += 2
	if Input.is_action_just_pressed("sfx_volume_down"):
		for audio_stream in get_children():
			audio_stream.volume_db -= 2
	

func _on_audio_stream_player_2d_finished() -> void:
	var new_rand_index = randi()%get_child_count()
	while new_rand_index == rand_index:
		if new_rand_index == rand_index:
			new_rand_index = randi()%get_child_count()
	get_child(new_rand_index).playing = true
	rand_index = new_rand_index
	pass # Replace with function body.
