class_name MiniGame3
extends MiniGame

@export var _fartbomb:FartBomb
@export var _bus_driver:Node3D
		
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	clout_levels_file = "mini_game_1.txt"
	super._ready()
	Game_Manager.register_minigame(self)
	_fartbomb.on_landed.connect(on_fartbomb_landed)
	_fartbomb.on_thrown.connect(on_fartbomb_thrown)
	_fartbomb.calculate_lookat = false
	id = 2

func _input(event: InputEvent) -> void:
	if !_fartbomb.enabled:
		return
		
	if item_required:
		return
		
	if event is InputEventKey and event.pressed:
		var keycode = event.as_text_physical_keycode()	
		if keycode == "F":
			_fartbomb.charge()
			if _fartbomb.charge_force >= 100:
				_fartbomb.enabled = false
				_player.set_pose(6,0)
				_player.poses.get_child(6).get_node("Explosion").visible = true
				await G_Utils.wait(0.5)
				_player.poses.get_child(6).get_node("Explosion").visible = false
				fail()
	
	elif event is InputEventKey and event.is_released():
		var keycode = event.as_text_physical_keycode()
		if keycode == "F":
			if !_fartbomb._is_flying:
				_fartbomb.throw()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !running:
		return
	
	super._process(delta)
	
func _physics_process(delta):
	pass
	
func on_fartbomb_landed():
	if !running:
		return
		
	Game_Manager.sounds.play_sound(self,0)
	await G_Utils.wait(1)
	evaluate()
	item_required = true
	await G_Utils.wait(2)
	calculate_suspicion()
	Game_Manager._busdriver.make_suspicious(suspicion_gain)


func evaluate():
	var dist = (_fartbomb.get_pos() - _bus_driver.global_position).length()
	var x_dist = _fartbomb.get_pos().x - _bus_driver.global_position.x
	
	print("dist1: ", dist)
	if dist < 30 and _fartbomb.get_pos().z > _bus_driver.global_position.z \
	or (_fartbomb.get_pos().z < _bus_driver.global_position.z \
	and x_dist < 50):
		succeed()
	else:
		Game_Manager.show_item_indicator(2)
	

func succeed()->void:
	_busdriver.set_pose(4,4.5)
	Game_Manager.sounds.play_sound(self,1)
	await G_Utils.wait(4.5)
	super.succeed()
	game_over()

func fail():
	super.fail()
	Game_Manager.warn_player()
	item_required = true
	Game_Manager.sounds.play_sound(self,0)
	_player.increase_clout(-clout_gain)
	await G_Utils.wait(2)
	Game_Manager.show_item_indicator(2)
	#decerase clout points
	
func game_over():
	_fartbomb.enabled = false
	UI_Manager.show_throw_force_meter(false)
	super.game_over()
	
#only called if minigame succeded	
func calculate_clout():
	
	var dist = (_fartbomb.get_pos() - _bus_driver.global_position).length()
	var score = dist-(_fartbomb.get_pos() - _bus_driver.global_position).length()
	Game_Manager._player.increase_clout(20)
	if score > 0:
		Game_Manager._player.increase_clout(20*score/dist)  

func calculate_suspicion():
	
	suspicion_gain = 15
	if _busdriver._looking_back:
		pass
		
func display_info(game_over = false):
	_information = ""
	
	_information = "Congratulations! You won the second minigame!\n\n"

	_information += "MINIGAME 3 - Hit the bus driver with a fart bomb. Use the mouse to aim.
		Hold \"F\" to charge and release to throw.\nDon't get caught!\n"
	
	if game_over:
		_information = "Congratulations! You won this minigame!\n\n"


	UI_Manager.showInfo(_information)
	UI_Manager.pause_game()
		
func start(show_info = true):
	super.start()
	print("start minigame 2")
	
	if _num_tries == 1:
		Game_Manager.sounds.play_sound(self,2)
	
	UI_Manager.show_throw_force_meter(true)
	_busdriver.set_base_update_interval(6)
	UI_Manager.enable_letter_hint(false)

	#if _busdriver.total_suspicion > 50 and _busdriver.total_suspicion < 100:
		#Game_Manager._busdriver.set_suspicion(30)
		
	#Game_Manager._busdriver.set_suspicion(30)#comment this out later
		
	#_plane.initial_pos = Vector3(13,-3,-21)
	_fartbomb.reset()
	if show_info:
		display_info()

func on_item_selected(index):
	
	super.on_item_selected(index)
	
	if running and index == 2 and item_required:

		if !_player.in_action_zone():
			return
		
		_fartbomb.reset()
		UI_Manager.reset_throw_force_meter()
		Game_Manager.hide_item_indicator()
		_player.set_pose(5,0,true)
		await G_Utils.wait(0.1)
		item_required = false
		start(false)
	
	elif !running:
		_fartbomb.enabled = false
		print("not running")
			
func on_fartbomb_thrown():
	if !running:
		return
		
	_player.set_pose(4,1)
	_look_at_diff = _start_looking - (300-Game_Manager.game_timer.get_time_left())
	
func on_player_entered_action_zone():
	if !running:
		return
		
	if !item_required:
		_player.set_pose(5,0)
	
func on_player_left_action_zone():
	
	if!running:
		return
	_player.set_pose(0,0)
	if !_fartbomb._is_flying:
		_fartbomb.reset()
		item_required = true	
		_fartbomb.enabled = false
		Game_Manager.show_item_indicator(2)
