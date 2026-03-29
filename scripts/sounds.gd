extends Node
class_name Sounds

var _minigame_1_sounds: Array[AudioStreamPlayer] = []
var _minigame_3_sounds: Array[AudioStreamPlayer] = []
@export var _minigame_1_sound_files: Array[String] = []
@export var _minigame_3_sound_files: Array[String] = []

var _index_of_last_burp_sound = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for file:String in _minigame_1_sound_files:
		var child = AudioStreamPlayer.new()
		child.stream = load(file)
		get_node("MiniGame1/Burping/").add_child(child)
		_minigame_1_sounds.append(child)
	
	for file:String in _minigame_3_sound_files:
		var child = AudioStreamPlayer.new()
		child.stream = load(file)
		get_node("MiniGame3").add_child(child)
		_minigame_3_sounds.append(child)

	Game_Manager.register_sounds(self)
	randomize()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func play_sound(minigame, index):
	if minigame is MiniGame1:
		_minigame_1_sounds[index].stream.loop = false
		_minigame_1_sounds[index].play()
	
	elif minigame is MiniGame3:
		_minigame_3_sounds[index].stream.loop = false
		_minigame_3_sounds[index].play()
		
func play_sound_looping(minigame, index):
	if minigame is MiniGame1:
		_minigame_1_sounds[index].stream.loop = true
		_minigame_1_sounds[index].play()
		
func play_random_burp_sound():
	print("playing burp")
	var index = 1
	index += randi() % (_minigame_1_sounds.size()-1)
	while(index == _index_of_last_burp_sound):
		index = 1
		index += randi() % (_minigame_1_sounds.size()-1)
	_index_of_last_burp_sound = index
	print("burp sound index: ", _index_of_last_burp_sound )
	_minigame_1_sounds[index].play()
