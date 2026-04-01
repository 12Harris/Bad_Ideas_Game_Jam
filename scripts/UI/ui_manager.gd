extends Node
class_name  UIManager

var _clout_progress_bar : CloutProgressBar
var _susp_progress_bar : SuspProgressBar
var _throw_force_meter: ThrowForceMeter
var _ai_state : Label
var _look_at_mirror : Label
var  game_timer : Label
var _inventory_ui:InventoryUI
var _information_continue_btn:Button
var _quit_btn:Button
var _information:Node2D
var _background_image:TextureRect
var _mayhem_box:TextureRect
var _warning:Label
var _item_indicator : Sprite2D
var	_typed_letter_label:Label
var _sixty_seven_mode:Sprite2D
var minigame_4_hints:Node2D
var pose_counter: Label
var _sixty_seven_clickable = false

func initialize_game() -> void:
	_ai_state = get_tree().current_scene.get_node("SubViewportContainer/SubViewport2D/TestingGroundsBIGJ/UI_Root/AI State")
	if _ai_state == null:
		print("AI STATE NULL!!")
	_look_at_mirror = get_tree().current_scene.get_node("SubViewportContainer/SubViewport2D/TestingGroundsBIGJ/UI_Root/LookAtMirror")
	game_timer = get_tree().current_scene.get_node("SubViewportContainer/SubViewport2D/TestingGroundsBIGJ/UI_Root/GameTimer")
	_information = get_tree().current_scene.get_node("SubViewportContainer/SubViewport2D/TestingGroundsBIGJ/PauseMenu/Information")
	_information_continue_btn = _information.get_node("ContinueBtn")
	_quit_btn = _information.get_node("QuitBtn")
	_information_continue_btn.pressed.connect(continue_game)
	_quit_btn.pressed.connect(quit_game)
	_background_image = get_tree().current_scene.get_node("SubViewportContainer/SubViewport2D/TestingGroundsBIGJ/UI_Root/Background")
	_mayhem_box = get_tree().current_scene.get_node("SubViewportContainer/SubViewport2D/TestingGroundsBIGJ/UI_Root/MayhemBox")
	_warning = get_tree().current_scene.get_node("SubViewportContainer/SubViewport2D/TestingGroundsBIGJ/UI_Root/WarningLabel")
	_typed_letter_label = get_tree().current_scene.get_node("SubViewportContainer/SubViewport2D/TestingGroundsBIGJ/UI_Root/LetterLabel")
	_sixty_seven_mode = get_tree().current_scene.get_node("SubViewportContainer/SubViewport2D/TestingGroundsBIGJ/UI_Root/67Mode")
	minigame_4_hints = get_tree().current_scene.get_node("SubViewportContainer/SubViewport2D/TestingGroundsBIGJ/UI_Root/MiniGame4Hints")
	pose_counter =  get_tree().current_scene.get_node("SubViewportContainer/SubViewport2D/TestingGroundsBIGJ/UI_Root/PoseCounter")
	_sixty_seven_mode.get_node("TriggerArea").mouse_entered.connect(sixty_seven_clickable)
	_sixty_seven_mode.get_node("TriggerArea").mouse_exited.connect(sixty_seven_not_clickable)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Game_Manager.register_ui(self)
	process_mode = Node.PROCESS_MODE_PAUSABLE
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func updateMiniGame(minigame:MiniGame):
	pass
	
func register_progress_bar(progress_bar:TextureProgressBar):
	
	if progress_bar is CloutProgressBar:
		_clout_progress_bar = progress_bar
		_clout_progress_bar.max_value = 100  # set max when registered
		_clout_progress_bar.value = 0
	if progress_bar is SuspProgressBar:
		_susp_progress_bar = progress_bar
		_susp_progress_bar.max_value = 100  # set max when registered
		_susp_progress_bar.value = 0
	if progress_bar is ThrowForceMeter:
		_throw_force_meter = progress_bar
		_throw_force_meter.max_value = 100  # set max when registered
		_throw_force_meter.value = 0
	
func register_inventory_ui(ui: InventoryUI):
	_inventory_ui = ui

func reset_clout_meter(max_value):
	_clout_progress_bar.max_value = max_value
	_clout_progress_bar.value = 0
	
func reset_susp_meter():
	_susp_progress_bar.value = 0

func reset_throw_force_meter():
	_throw_force_meter.value = 0
	
func inc_throw_force_meter(amount):
	_throw_force_meter.increase_meter(amount)

func increase_clout_meter(amount):
	_clout_progress_bar.increase_meter(amount)
	
func set_min_clout(min_clout):
	_clout_progress_bar.min_value = min_clout
	
func set_susp_meter(amount):
	_susp_progress_bar.set_meter(amount)
	
func inc_susp_meter(amount):
	_susp_progress_bar.increase_meter(amount)

func show_throw_force_meter(hide:bool):
	_throw_force_meter.visible = hide

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		var btn = event.as_text()
		if btn == "Left Mouse Button" and _sixty_seven_clickable:
			Game_Manager.enable_67_mode(13)
			_sixty_seven_clickable = false
			show_sixty_seven_mode(false)
			Game_Manager.sounds.play_67()
			Game_Manager._player.pose_67_mode()


func enable_67_mode_label(show):
	get_tree().current_scene.get_node("SubViewportContainer/SubViewport2D/TestingGroundsBIGJ/UI_Root/67 Mode Label").visible = show	

func show_sixty_seven_mode(show):
	_sixty_seven_mode.visible = show
	print("67 mode enabled")
		
func update():
	
	if game_timer == null:
		return
		
	game_timer.set_text("Time left: " + str(int(Game_Manager.game_timer.get_time_left())))
		
func update_ai_state(state:String,look_at_mirror:bool):
	_ai_state.text = "AI State: " + state
	if state == "pull_over":
		_ai_state.text = "Driver pulled over. The Game is Over!"
	if look_at_mirror:
		_look_at_mirror.text = "Bus Driver Looking At Mirror!"
	else:
		_look_at_mirror.text = ""
		
func showInfo(text:String):
	
	
	_information.get_node("InfoText").text \
	= "CONTROLS: \n\nLeft and Right Arrow Keys --- Left To Center(Left is Safe, Center to start and complete minigames).\n"
	
	if Game_Manager.current_mini_game == 3:
		
		_information.get_node("InfoText").text \
		+= "Up,Right,Down.Left Arrow Keys(Action zone) --- Perform poses while in action zone.\n"
		
		_information.get_node("InfoText").text \
		+= "Space(Action Zone)--- Move to safe zone while in action zone\n"

	_information.get_node("InfoText").text += "Tab --- Pause Game\n\n"
	
	
	_information.get_node("InfoText").text += "INSTRUCTIONS: \n\n"
	
	_information.get_node("InfoText").text \
	+= "Try to complete as many minigames before the time runs out.\n" \
		+ "Avoid getting caught by the driver!\n\n" + text + "\n"
	
func continue_game():
	
	if _mayhem_box.visible:
		_mayhem_box.visible = false
		
	get_tree().paused = false
	_information.visible = false
	print("CONTINUE GAME")
	
func pause_game():
	get_tree().paused = true
	print("game paused!")
	_information.visible = true

func quit_game():
	get_tree().quit()
	
func fade_in_background():
	var tween = get_tree().create_tween()
	tween.tween_property(_background_image, "modulate:a", 1, 2)
	tween.play()
	await tween.finished
	tween.kill()

func display_67_mode(duration):
	_sixty_seven_mode.visible = true
	await G_Utils.wait(duration)
	_sixty_seven_mode.visible = false

	
func display_warning():
	_warning.visible = true
	await G_Utils.wait(2.0)
	
	if _warning:
		_warning.visible = false
	
func update_minigame_1(letter):
	_typed_letter_label.text = "Current Letter: " + letter

func enable_letter_hint(value):
	_typed_letter_label.visible = value
	
func unhint_pose(index):
	minigame_4_hints.get_child(index).visible = false

func enable_pose_counter():
	pose_counter.visible = true
	
func set_pose_counter(value):
	pose_counter.text = "Completed Poses: " + str(value) + "/" + str(16)

func display_lost_game_label():
	await G_Utils.wait(0.5)
	get_tree().current_scene.get_node("LostGameLabel").visible = true

func show_credits():
	get_tree().current_scene.get_node("LooseScreen").visible = false
	get_tree().current_scene.get_node("LostGameLabel").visible = false
	get_tree().current_scene.get_node("CreditsScreen").visible = true
	
func hint_pose(index,duration):
	
	if(Game_Manager.game_lost()):
		return
	minigame_4_hints.get_child(index).visible = true
	await G_Utils.wait(duration)
	minigame_4_hints.get_child(index).visible = false
	
func sixty_seven_clickable():
	if !_sixty_seven_mode.visible:
		return
	_sixty_seven_clickable = true

func sixty_seven_not_clickable():
	if !_sixty_seven_mode.visible:
		return
	_sixty_seven_clickable = false
