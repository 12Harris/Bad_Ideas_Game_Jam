extends Node
class_name MiniGame

signal succeeded
signal failed

var started : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_process_unhandled_input(true)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

#Triggered when the minigame(or a part of the minigame) succeded
func succeed()->void:
	succeeded.emit()

#Triggered when the minigame(or a part of the minigame) failed
func fail()->void:
	failed.emit()

func start():
	started = true
