extends Resource
class_name  Audio_library

@export var sound_effects: Dictionary = {}

func _init() -> void:
	var base_dir = "res://audio/400 Sounds Pack/"
	search_for_dir(base_dir)

func search_for_dir(base_dir: String):
	var array_of_dir = DirAccess.get_directories_at(base_dir)
	# need to search all sub dir inside the current dir for dir and files
	for folders in array_of_dir:
		var path := base_dir.path_join(folders)
		search_for_dir(path) 
	
	var array_of_files = DirAccess.get_files_at(base_dir)
	
	# add all files in the dir to the dictionary
	for file in array_of_files:
		if file.ends_with(".import"):
			if OS.has_feature("template"):
				file = file.left(len(file) - len('.import'))
			else: 
				continue
		var path := base_dir.path_join(file)
		var stream := load(path)
		if stream is AudioStream:
			# Key however you like; basename() gives "click" from "click.ogg"
			sound_effects[file.get_basename()] = stream
		else:
			push_warning("Not an AudioStream (or failed to load): %s" % path)
		
	
func get_audio_stream(_tag: String):
	if _tag:
		if sound_effects.has(_tag):
			return sound_effects[_tag]
		else:
			printerr("tag not found")	
	else:
		printerr("No tag provided, cannot return audio stream")
	return null
		
