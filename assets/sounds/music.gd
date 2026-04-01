class_name Music
extends Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Game_Manager.register_music(self)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func initialize():
	pass

func play_background_music():
	(get_child(0) as AudioStreamPlayer).stream.loop = true
	get_child(0).play()

func stop_music(index):
	get_child(index).stop()

func play_pose_music():
	(get_child(1) as AudioStreamPlayer).stream.loop = true
	get_child(1).play()
