class_name Player
extends Node

var _total_clout : int

var bus_driver : BusDriver

signal powerboost
signal on_entered_action_zone
signal on_left_action_zone

var poses: Node2D
var _current_pose: TextureRect
var _is_moving:bool = false

@export var _move_speed:float
@export var _paper_plane:Node3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("player ready")
	Game_Manager.register_player(self)
	set_process_unhandled_input(true)
	bus_driver = Game_Manager.get_bus_driver()
	_total_clout = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func increase_clout(clout_gain) -> void:
	#clout_levels[CloutLevel.currentLevel].increase_clout(clout_gain)
	_total_clout += clout_gain
	UI_Manager.increase_clout_meter(clout_gain)
	G_Inventory.update()
	if _total_clout >= 100:
		_total_clout = 100
		Game_Manager.enable_67_mode(13)
		await G_Utils.wait(1)
		_total_clout = 0
		UI_Manager.reset_clout_meter(100)
		
		

func _physics_process(delta):
   	
	if Game_Manager.game_timer == null:
		return
		
	if Game_Manager.current_mini_game == -1 or !Game_Manager.get_current_minigame().requires_arrow_keys():
		
		print("moiving")
		_move_speed = 440 #470 original
		if Input.is_action_pressed("Left"):
			try_move(-Vector2.RIGHT)
		elif Input.is_action_pressed("Right") :
			try_move(Vector2.RIGHT)
		else:
			_is_moving = false
		
		Game_Manager.get_current_minigame().cancel_actions()
	else:
		#470 original
		if Input.is_action_pressed("Right") and !in_action_zone():
			_move_speed = 440
			try_move(Vector2.RIGHT)
		
		elif Input.is_action_pressed("Left") and !in_action_zone():
			_move_speed = 440
			try_move(-Vector2.RIGHT)
			
		elif Input.is_action_just_pressed("Cancel") and !in_safety_zone():
			hide()
	Game_Manager.get_current_minigame().cancel_actions()
	#move_and_slide()		

func _input(event: InputEvent) -> void:
	pass
				
func get_total_clout() -> int:
	return _total_clout
	
func power_boost():
	powerboost.emit()

func hide():
	print("hide!")
	_move_speed = 200
	while !in_safety_zone():
		try_move(-Vector2.RIGHT)
		await get_tree().process_frame
	
func try_move(direction:Vector2):
	if _current_pose == null:
		return
	
	var first_pose = poses.get_child(0)
	var screen_pos  =Game_Manager._sub_viewport_2.get_canvas_transform() * first_pose.global_position
	var initial_screen_pos = screen_pos
	print(screen_pos)
	if direction == -Vector2.RIGHT:
		if screen_pos.x > 0:
			screen_pos.x -= _move_speed * get_process_delta_time()
			#_paper_plane.global_position.x -= 0.1
			_is_moving = true
		else:
			screen_pos.x = 0
			_is_moving = false
		
		if screen_pos.x < 375.0 and in_action_zone():
			on_left_action_zone.emit()

	elif direction == Vector2.RIGHT:
		if screen_pos.x < 380:
			screen_pos.x += _move_speed * get_process_delta_time()
			#_paper_plane.global_position.x += 0.1
			_is_moving = true
		else:
			screen_pos.x = 380
			_is_moving = false
		if screen_pos.x >= 375.0 and !in_action_zone():
			on_entered_action_zone.emit()

	var world_pos = Game_Manager._sub_viewport_2.get_canvas_transform().affine_inverse() * screen_pos
	first_pose.global_position = world_pos
	
	for child in poses.get_children():
		child.global_position = first_pose.global_position

func in_safety_zone() ->bool:
	return (Game_Manager._sub_viewport_2.get_canvas_transform() * _current_pose.global_position).x <= 20

func in_action_zone() ->bool:
	
	if(!Game_Manager.game_lost()):
		return (Game_Manager._sub_viewport_2.get_canvas_transform() * _current_pose.global_position).x >= 375
	else:
		return false
		
func is_safe() ->bool:
	return in_safety_zone()
	
func set_pose(index, duration, override:bool= false):
	
	print("setting new pose")
	_current_pose.visible = false
	
	_current_pose = poses.get_child(index)
	
	#if !override:
		#_current_pose = poses.get_child(index)
	#else:
		#_current_pose = Game_Manager._sub_viewport.get_node("TestingGroundsBIGJ/BimmyPoses").get_child(index)

	_current_pose.visible = true
	
	if duration > 0:
		await G_Utils.wait(duration)
		_current_pose.visible = false
		_current_pose = poses.get_child(0)
		_current_pose.visible = true
