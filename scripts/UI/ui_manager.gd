extends Node
class_name  UIManager

var _clout_progress_bar : CloutProgressBar
var _susp_progress_bar : SuspProgressBar
var _ai_state : Label
var _look_at_mirror : Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Game_Manager.register_ui(self)
	await get_tree().process_frame
	_ai_state = get_tree().current_scene.get_node("UI_Root/AI State")
	_look_at_mirror = get_tree().current_scene.get_node("UI_Root/LookAtMirror")
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func register_progress_bar(progress_bar:ProgressBar):
	
	if progress_bar is CloutProgressBar:
		_clout_progress_bar = progress_bar
		_clout_progress_bar.max_value = 50  # set max when registered
		_clout_progress_bar.value = 0
	if progress_bar is SuspProgressBar:
		_susp_progress_bar = progress_bar
		_susp_progress_bar.max_value = 100  # set max when registered
		_susp_progress_bar.value = 0
	
func reset_clout_meter(max_value):
	_clout_progress_bar.max_value = max_value
	_clout_progress_bar.value = 0

func increase_clout_meter(amount):
	_clout_progress_bar.increase_meter(amount)
	
func set_min_clout(min_clout):
	_clout_progress_bar.min_value = min_clout
	
func set_susp_meter(amount):
	_susp_progress_bar.set_meter(amount)
	
func inc_susp_meter(amount):
	_susp_progress_bar.increase_meter(amount)
	
func update_ai_state(state:String,look_at_mirror:bool):
	_ai_state.text = "AI State: " + state
	
	if look_at_mirror:
		_look_at_mirror.text = "Bus Driver Looking At Mirror!"
	else:
		_look_at_mirror.text = ""
