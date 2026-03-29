class_name MiniGame4
extends MiniGame

var _current_pose:int = 0
var _pressed: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	clout_levels_file = "mini_game_1.txt"
	super._ready()
	Game_Manager.register_minigame(self)
	set_process_input(true)
	id = 3
	
func _input(event):
	
	print("run minigame")
	
	if !running or item_required:
		return

	if !Game_Manager._player.in_action_zone():
		return

	if event is InputEventKey:
		var keycode = event.as_text_physical_keycode()
		if event.pressed and _pressed == false:
			_pressed = true
			
		elif event.is_released():
			_pressed = false
			#if  keycode in _alphabet and _current_letter_index < 26:
				#UI_Manager.update_minigame_1(_alphabet[_current_letter_index])

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if !running:
		return
		
	super._process(delta)
		
	UI_Manager.updateMiniGame(self)

func display_info():
	_information = ""
	
	_information = "Congratulations! You won the third minigame!\n\n"

	_information += "MINIGAME 4 - Strike the correct poses using the arrow keys.
	\nDon't get caught!\n"
		
	UI_Manager.showInfo(_information)
	UI_Manager.pause_game()
	
func start(show_info=true):
	print("start minigame")
	suspicion_gain = 0
	super.start()
	set_process_input(true)
	Game_Manager._music.play_psoe_music()
	if show_info:
		display_info()
	
	#UI_Manager.reset_susp_meter()
	#Game_Manager._busdriver.set_suspicion(0)
	
func evaluate(letter):
	pass
		
func calculate_suspicion():
	
	if chain_length > 0:
		suspicion_gain = 7.0 * float(chain_length)/5.0 #max chain length(26) <=> 35% suspicion gain maximum
	else:
		suspicion_gain = 7.0 
		
#only called if minigame succeded	
func calculate_clout():
	Game_Manager._player.increase_clout(1.5+ (chain_length-1))

func is_noisy()->bool:
	return true
	
func game_over():
	super.game_over()
	
func burp():
	var player = Game_Manager._player
	player.set_pose(2,0.7)

func on_item_selected(index):
	if running and index == 0 and item_required:
		#drink the soda
		var player = Game_Manager._player
		if !player.in_action_zone():
			return
		
		Game_Manager.hide_item_indicator()

		player.set_pose(1,4)
		Game_Manager.sounds.play_sound(self,0)
		await G_Utils.wait(3)
		item_required = false
		
		if _current_pose == 0:
			start(false)
