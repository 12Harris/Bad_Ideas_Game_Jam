class_name MiniGame2
extends MiniGame

@export var _plane:PaperPlane
@export var _bus_driver:Node3D
		
var stage: int = 0
var retries = 0
var target_area_index = -2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	clout_levels_file = "mini_game_1.txt"
	super._ready()
	Game_Manager.register_minigame(self)
	_plane.on_entered_target_area.connect(on_plane_entered_target_area)
	_plane.on_landed.connect(on_plane_landed)
	_plane.on_thrown.connect(on_plane_thrown)

func _input(event: InputEvent) -> void:
	pass
			
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !running:
		return
	
	super._process(delta)
	
func _physics_process(delta):
	pass
	
func on_plane_landed():
	await G_Utils.wait(1)
	evaluate()
	await G_Utils.wait(2)
	Game_Manager.show_item_indicator(1)

func on_plane_entered_target_area(index):
	target_area_index = index
	print("target area index: ", target_area_index)


func evaluate():
	
	if target_area_index == 0:
		succeed()
		game_over()
	else:
		item_required = true
		fail()

func game_over():
	super.game_over()
	
#only called if minigame succeded	
func calculate_clout():
	Game_Manager._player.increase_clout(7)
	if _busdriver._looking_back:
		Game_Manager._player.increase_clout(7)
		
func calculate_suspicion():
	suspicion_gain = 4.0 
	if _busdriver._looking_back:
		suspicion_gain = 8.0
		
func display_info():
	_information = ""
	
	_information = "Congratulations! You won the first minigame!\n\n"

	_information += "MINIGAME 2 - Hit the bus driver with a paper plane. Use the mouse to aim the paper plane.\n
		Press and hold \"F\" to charge the paper plane then release
		to throw it.\nDon't get caught!\n"
		
	UI_Manager.showInfo(_information)
	UI_Manager.pause_game()
		
func start(show_info = true):
	super.start()
	print("start minigame 2")
	
	_busdriver.set_base_update_interval(5)
	UI_Manager.reset_susp_meter()
	
	if _busdriver.total_suspicion > 50:
		Game_Manager._busdriver.set_suspicion(20)
		
	Game_Manager._busdriver.set_suspicion(20)#comment this out later
		
	#_plane.initial_pos = Vector3(13,-3,-21)
	_plane.reset()
	if show_info:
		display_info()

func on_item_selected(index):
	if running and index == 1 and item_required:
		#drink the soda
		if !_player.in_action_zone():
			return
		
		Game_Manager.hide_item_indicator()
		_player.set_pose(3,0,true)
		item_required = false
		_plane.enabled = true
		start(false)
			
func on_plane_thrown():
	_player.set_pose(4,1)
	_look_at_diff = _start_looking - (300-Game_Manager.game_timer.get_time_left())
	
func on_player_entered_action_zone():
	_player.set_pose(3,0)
	
func on_player_left_action_zone():
	_player.set_pose(0,0)
	if !_plane._is_flying:
		_plane.enabled = false
