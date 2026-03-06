extends Node
class_name MiniGame

signal succeeded(minigame)
signal failed(minigame)

var started : bool = false
var suspicion_gain: float = 0
var clout_gain: float = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_process_unhandled_input(true)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

#Triggered when the minigame(or a part of the minigame) succeded
func succeed()->void:
	succeeded.emit(self)

#Triggered when the minigame(or a part of the minigame) failed
func fail()->void:
	failed.emit(self)

func start():
	started = true
	
func calculate_suspicion(succeded: bool):
	pass

func is_noisy()->bool:
	return false
