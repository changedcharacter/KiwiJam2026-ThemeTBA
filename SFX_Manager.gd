extends AudioStreamPlayer2D

@export var audio_library = Audio_library.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	stream =AudioStreamPolyphonic.new()
	stream.polyphony = 64
	volume_db = -20
	pass # Replace with function body.

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("sfx_volume_up"):
		volume_db += 2
	if Input.is_action_just_pressed("sfx_volume_down"):
		volume_db -= 2


func play_sound_effect_from_dictionary(_tag: String)->void:
	if _tag:
		var audio_stream = audio_library.get_audio_stream(_tag)
		## print(audio_stream)
		if !playing:
			self.play()
		var  audio_stream_playback := self.get_stream_playback()
		audio_stream_playback.play_stream(audio_stream)
	else:
			printerr("no tag provided")


func update_position(node: Node2D):
	position = node.position
