class_name MiniGame1
extends MiniGame

var _alphabet = ['A','B','C','D','E','F','G','H','I','J',
				'K','L','M','N','O','P','Q','R','S','T',
				'U','V','W','X','Y','Z']

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	Game_Manager.register_minigame(self)
	
func _input(event):
	if Input.is_action_pressed("A"):
		print("A key pressed")
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if started == false:
		return

func start():
	super.start()
