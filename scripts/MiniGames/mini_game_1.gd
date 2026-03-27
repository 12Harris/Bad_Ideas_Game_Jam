class_name MiniGame1
extends MiniGame

var _alphabet = ['A','B','C','D','E','F','G','H','I','J',
				'K','L','M','N','O','P','Q','R','S','T',
				'U','V','W','X','Y','Z']

				
var _current_letter_index : int = 0
var _suspicion_multiplier : float = 0
var _clout_multiplier : float = 0
var _update_timer : float = -1
var burp_start_time :float
var is_burping:bool = false
var num_burps = 0
var item_cooldown : float = 2.5
var _pressed:bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	clout_levels_file = "mini_game_1.txt"
	super._ready()
	Game_Manager.register_minigame(self)
	await get_tree().process_frame
	suspicion_gain = 2.5

	set_process_input(true)
	
func _input(event):
	
	print("run minigame")
	
	if !running or item_required:
		return
		
	if _current_letter_index >= _alphabet.size():
		return
		
	if !Game_Manager._player.in_action_zone():
		return

	if event is InputEventKey:
		var keycode = event.as_text_physical_keycode()
		if event.pressed and _pressed == false:
			_pressed = true
			if _current_letter_index < _alphabet.size() \
				and keycode in _alphabet:
				
				UI_Manager.update_minigame_1(_alphabet[_current_letter_index])
				
				if _update_timer < 0 or _update_timer >= 0.7:	
					
					UI_Manager.update_minigame_1(_alphabet[_current_letter_index])
					Game_Manager.sounds.play_random_burp_sound()
					burp_start_time = 300-Game_Manager.game_timer.get_time_left()
					_look_at_diff = _start_looking - burp_start_time
					burp()
					evaluate(keycode)
					
					if _current_letter_index == 25 || _busdriver.total_suspicion >= 100:
						game_over()
					elif keycode == _alphabet[_current_letter_index]:
						_current_letter_index += 1
					
					_update_timer = 0.0	
					await G_Utils.wait(0.5)
					UI_Manager.update_minigame_1(_alphabet[_current_letter_index])

					
		elif event.is_released():
			_pressed = false
			#if  keycode in _alphabet and _current_letter_index < 26:
				#UI_Manager.update_minigame_1(_alphabet[_current_letter_index])

		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if !running:
		return
	
	super._process(delta)
	if _update_timer >= 0.0:
		_update_timer+=delta
		
	UI_Manager.updateMiniGame(self)

func display_info():
	_information = "MINIGAME 1\n\nDrink some Fizzy Pop and burp the alphabet in the correct order using the keyboard
					\nBe careful, the driver may be looking into the mirror!"


func start(show_info=true):
	print("start minigame")
	num_burps = 0
	_current_letter_index = 0
	suspicion_gain = 0
	super.start()
	set_process_input(true)
	if show_info:
		display_info()
	#UI_Manager.reset_susp_meter()
	#Game_Manager._busdriver.set_suspicion(0)
	
func evaluate(letter):
	
	print("cur letter: ", _current_letter_index)
	if letter != _alphabet[_current_letter_index]:
		chain_length = 0
		fail()
	else:
		
		chain_length += 1
		succeed()
	num_burps += 1
	
	if num_burps >= 6:
		item_required = true
		num_burps = 0
		on_item_cooldown.emit(self)
		Game_Manager.show_item_indicator(0)
		#chain_length = 0
		
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

		player.set_pose(1,3)
		Game_Manager.sounds.play_sound(self,0)
		await G_Utils.wait(3)
		item_required = false
		
		if _current_letter_index == 0:
			start(false)
