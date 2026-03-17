extends Node
class_name  UIManager

var _clout_progress_bar : CloutProgressBar
var _susp_progress_bar : SuspProgressBar
var _ai_state : Label
var _look_at_mirror : Label
var _mini_game_1_timer : Label
var _inventory_ui:InventoryUI

func initialize_game() -> void:
	_ai_state = get_tree().current_scene.get_node("SubViewportContainer/SubViewport2D/TestingGroundsBIGJ/UI_Root/AI State")
	if _ai_state == null:
		print("AI STATE NULL!!")
	_look_at_mirror = get_tree().current_scene.get_node("SubViewportContainer/SubViewport2D/TestingGroundsBIGJ/UI_Root/LookAtMirror")
	_mini_game_1_timer = get_tree().current_scene.get_node("SubViewportContainer/SubViewport2D/TestingGroundsBIGJ/UI_Root/MiniGame1Timer")
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Game_Manager.register_ui(self)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func updateMiniGame(minigame:MiniGame):
	if minigame is MiniGame1:
		_mini_game_1_timer.set_text(str(int(minigame.game_timer.get_time_left())))
		
func register_progress_bar(progress_bar:ProgressBar):
	
	if progress_bar is CloutProgressBar:
		_clout_progress_bar = progress_bar
		_clout_progress_bar.max_value = 50  # set max when registered
		_clout_progress_bar.value = 0
	if progress_bar is SuspProgressBar:
		_susp_progress_bar = progress_bar
		_susp_progress_bar.max_value = 100  # set max when registered
		_susp_progress_bar.value = 0
	
func register_inventory_ui(ui: InventoryUI):
	_inventory_ui = ui

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
	if state == "pull_over":
		_ai_state.text = "Driver pulled over. The Game is Over!"
	if look_at_mirror:
		_look_at_mirror.text = "Bus Driver Looking At Mirror!"
	else:
		_look_at_mirror.text = ""
