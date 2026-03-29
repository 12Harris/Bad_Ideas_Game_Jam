class_name MiniGame4
extends MiniGame

var _old_pose:int = 0
var _current_pose:int = 0
var _pressed: bool = false
var pose_music_playing = false
var next_step:bool = true
var pose_index = 0

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
		if event.pressed:
			if keycode == "Up":
				_player.set_pose(9,0)
			elif keycode == "Right":
				_player.set_pose(10,0)	
			elif keycode == "Down":
				_player.set_pose(11,0)	
			elif keycode == "Left":
				_player.set_pose(12,0)	
				
			#if  keycode in _alphabet and _current_letter_index < 26:
				#UI_Manager.update_minigame_1(_alphabet[_current_letter_index])

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if !running:
		return
	
	if next_step:
		next_step = false
		UI_Manager.unhint_pose(_old_pose)
		var timeout = randf_range(1,2)
		_current_pose = randi_range(0,3)
		UI_Manager.hint_pose(_current_pose,timeout)
		await G_Utils.wait(timeout)
		_old_pose = _current_pose
		next_step = true

	super._process(delta)

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
	Game_Manager._music.stop_music(0)
	Game_Manager._music.play_pose_music()
	pose_music_playing = true
	UI_Manager.show_throw_force_meter(false)
	if _num_tries == 1:
		_player.set_pose(7,2)
		var timer = 0
		while timer < 2.0 and _player.in_action_zone():
			await get_tree().process_frame
		
		if _player.in_action_zone():
			_player.set_pose(8,0)
		else:
			_player.set_pose(0,0)
	else:
		_player.set_pose(8,0)
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
	
func on_item_selected(index):
	if running and index == 3 and item_required:
		#drink the soda
		var player = Game_Manager._player
		if !player.in_action_zone():
			return
		
		Game_Manager.hide_item_indicator()
		item_required = false
		Game_Manager._busdriver.make_suspicious(5)
		
		start(false)

func on_player_entered_action_zone():
	if !running:
		return

func on_player_left_action_zone():
	
	if !running:
		return
	_player.set_pose(0,0)
		
	item_required = true
	await G_Utils.wait(2)
	if pose_music_playing:
		Game_Manager._music.stop_music(1)
		Game_Manager._music.play_background_music()
		Game_Manager.show_item_indicator(3)
