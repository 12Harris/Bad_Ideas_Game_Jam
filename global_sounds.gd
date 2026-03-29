class_name GSounds
extends Node

var win_game_sound: AudioStreamPlayer
var loose_game_sound: AudioStreamPlayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("ready g sound")

func initialize():
	
	print("initialize gsounds")
	win_game_sound = get_tree().current_scene.get_node("GlobalSounds").get_child(0)
	loose_game_sound = get_tree().current_scene.get_node("GlobalSounds").get_child(1)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func play_win_game_sound():
	win_game_sound.play()
	
func play_loose_game_sound():
	loose_game_sound.play()
	print("play loose game sound")
