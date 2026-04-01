class_name MiniGame4
extends MiniGame

var _old_pose:int = 0
var _current_pose:int = 0
var _pressed: bool = false
var pose_music_playing = false
var next_step:bool = true
var pose_index = 0
var start_input_time:float = 0
var input_delay:float = 0
var timeout:float = 0
var press_duration = 0.0
var pressed_this_frame = false
var press_start_time = 0
var _saved_pose:int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	clout_levels_file = "mini_game_1.txt"
	super._ready()
	Game_Manager.register_minigame(self)
	set_process_input(true)
	id = 3
	randomize()
	
func _input(event):
	
	print("run minigame")
	
	if !running or item_required:
		return
		
	if !Game_Manager._player.in_action_zone():
		return

	if event is InputEventKey:
		var keycode = event.as_text_physical_keycode()
		if event.pressed and keycode in  ["Up","Right","Down","Left"]:
			
			if ! pressed_this_frame:
				press_start_time = get_time()
				input_delay = press_start_time - start_input_time
				_saved_pose = _current_pose
				pressed_this_frame = true
			
			if keycode == "Up":
				_player.set_pose(9,0)
				
			elif keycode == "Right":
				_player.set_pose(10,0)	

			elif keycode == "Down":
				_player.set_pose(11,0)	
				
			elif keycode == "Left":
				_player.set_pose(12,0)	
			
			#input_delay = press_start_time - start_input_time
			print("input delay: ", input_delay)
			
			press_duration =  get_time() - press_start_time
			
			#if _current_pose == _old_pose and press_duration >= timeout-0.5:
				# =  get_time()
				#start_input_time =  get_time()
		
		if event.is_released() and keycode in ["Up","Right","Down","Left"]:
			
			print("released")
			press_duration = get_time() - press_start_time

			print("press time: ", press_duration, ", timeout: ", timeout)

			if press_duration < timeout-0.5:
				print("press dur < timeout + 1: ",  press_duration, ": ", timeout)
				chain_length = 0
			else:
				if (keycode == "Up" and _saved_pose == 0 ) \
				or (keycode == "Right" and _saved_pose == 1) \
				or (keycode == "Down" and _saved_pose == 2) \
				or (keycode == "Left" and _saved_pose == 3):
					chain_length += 1
					print("success")
					succeed()	
			print("cur pose: ", _current_pose, "keycode: ", keycode)
			pressed_this_frame = false

func calculate_clout():
	Game_Manager._player.increase_clout(5+ ((chain_length-1)/5))
	if Game_Manager._sixty_seven_enabled:
		chain_length = 0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if !running:
		return
	
	if UI_Manager._throw_force_meter.visible:
		UI_Manager.show_throw_force_meter(false)
		
	super._process(delta)

func display_info(game_over = false):

	_information = "MINIGAME 4 - Strike the correct poses using the arrow keys.Hold the key for the length of the pose
	and release for the next pose. Press space key to hide.
	\nDon't get caught!\n"
	
	if game_over:
		_information = "Congratulations! You won this  minigame!\n\n"

	UI_Manager.showInfo(_information)
	UI_Manager.pause_game()
	
func start(show_info=true):
	print("start minigame")
	suspicion_gain = 0
	super.start()
	set_process_input(true)
	Game_Manager._music.stop_music(0)
	Game_Manager._music.play_pose_music()
	pose_music_playing = true
	UI_Manager.show_throw_force_meter(false)
	_busdriver.set_base_update_interval(7)
	UI_Manager.enable_letter_hint(false)
	
	timeout = 0
	next_step = true
	input_delay = 0
	start_input_time = 0
	
	if _num_tries == 1:
		_player.set_pose(7,2)
		var timer = 0
		while timer < 2.0 and _player.in_action_zone():
			await get_tree().process_frame
			timer+=get_process_delta_time()
			
		if _player.in_action_zone():
			_player.set_pose(8,0)
			dance()
		else:
			_player.set_pose(0,0)
	else:
		_player.set_pose(8,0)
		dance()
	#UI_Manager.reset_susp_meter()
	#Game_Manager._busdriver.set_suspicion(0)

func succeed()->void:
	if chain_length == 4:
		pose_index += chain_length
		UI_Manager.set_pose_counter(pose_index)
		
	super.succeed()
	
	if pose_index >= 15:
		game_over()
	
func dance():

	while !item_required:
	
		if next_step:
			#press_duration = 0.0
			#pressed_this_frame = false
			next_step = false
			_current_pose = randi_range(0,3)
			input_delay = 0
			UI_Manager.unhint_pose(_old_pose)
			
			var rand = randf_range(1.0,2)
			#if _current_pose != _old_pose:
	
			start_input_time = get_time()
			timeout =  rand

			UI_Manager.hint_pose(_current_pose,timeout)
			await G_Utils.wait(timeout)
			_old_pose = _current_pose
			next_step = true

func evaluate(letter):
	pass
		
func calculate_suspicion():
	
	if chain_length > 0:
		suspicion_gain = 7.0 * float(chain_length)/5.0 #max chain length(26) <=> 35% suspicion gain maximum
	else:
		suspicion_gain = 7.0 
		
func is_noisy()->bool:
	return true
	
func game_over():
	super.game_over()
	
func on_item_selected(index):
	
	super.on_item_selected(index)
	
	if running and index == 3 and item_required:
		#drink the soda
		var player = Game_Manager._player
		if !player.in_action_zone():
			return
		
		Game_Manager.hide_item_indicator()
		item_required = false
		Game_Manager._busdriver.make_suspicious(5)
		
		UI_Manager.enable_pose_counter()
		start(false)

func on_player_entered_action_zone():
	if !running:
		return
		
func on_player_left_action_zone():
	
	if !running:
		return
	_player.set_pose(0,0)
	
	item_required = true
	chain_length = 0
	
	await G_Utils.wait(2)
	if pose_music_playing:
		Game_Manager._music.stop_music(1)
		Game_Manager._music.play_background_music()
		Game_Manager.show_item_indicator(3)
		
func requires_arrow_keys():
	return true

func get_time():
	return Time.get_ticks_msec() / 1000.0
