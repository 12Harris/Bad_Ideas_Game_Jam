extends Node
class_name Sounds

var _burp_sounds: Array[AudioStreamPlayer] = []
@export var _burp_sound_files: Array[String] = []

var _index_of_last_burp_sound = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for file:String in _burp_sound_files:
		print("SOUNDS INIT")
		var child = AudioStreamPlayer.new()
		child.stream = load(file)
		get_node("MiniGame1/Burping/").add_child(child)
		_burp_sounds.append(child)
	Game_Manager.register_sounds(self)
	randomize()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func play_random_burp_sound():
	print("playing burp")
	var index = randi() % _burp_sounds.size()
	while(index == _index_of_last_burp_sound):
		index = randi() % _burp_sounds.size()
	_index_of_last_burp_sound = index
	_burp_sounds[index].play()
