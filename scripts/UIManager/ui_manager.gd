extends Node
class_name  UIManager

var _anger_progress_bar : AngerProgressBar

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Game_Manager.register_ui(self)
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func register_progress_bar(progress_bar):
	_anger_progress_bar = progress_bar
	_anger_progress_bar.max_value = 50  # set max when registered
	_anger_progress_bar.value = 0
	
func reset_anger_meter(max_value):
	_anger_progress_bar.max_value = max_value
	_anger_progress_bar.value = 0

func increase_anger_meter(amount):
	_anger_progress_bar.increase_anger_meter(amount)
