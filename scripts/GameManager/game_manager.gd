class_name GameManager
extends Node

#The main player
var _player : Player

#The bus driver
var _busdriver : BusDriver

#The UI
var _ui

#initialized flag
var _initialized

#array of minigames
var mini_games: Array[MiniGame] = []

#game sounds
var sounds: Sounds

#camera
var camera: MainCamera

#global timer
var game_timer:Timer

#Collision Areas
var collisions: Node2D

var mouse_pos:Vector2 = Vector2.ZERO
var old_mouse_pos:Vector2 = Vector2.ZERO

var _sub_viewport:SubViewport

var _sub_viewport_2:SubViewport


var interact_input_action = "interact"
var interact_input_action_2 = "interact2"

var bus_seats_left:Array[StaticBody3D]= []
var bus_seats_right:Array[StaticBody3D]= []

var current_mini_game : int = 0

var _minigame_warnings : int = 0

var _inventory_ui:InventoryUI

var _sixty_seven_enabled:bool = false

#Register the UI
func register_ui(ui):
	_ui = ui

#Register the player
func register_player(p):
	_player = p
	_player.powerboost.connect(_on_player_powerboost)
	
#Register the bus driver
func register_busdriver(b):
	_busdriver = b

func register_minigame(minigame:MiniGame):
	mini_games.append(minigame)
	minigame.succeeded.connect(_on_minigame_succeeded)
	minigame.failed.connect(_on_minigame_failed)
	minigame.ended.connect(_on_minigame_ended)
	minigame.on_player_spotted.connect(on_player_spotted)
	minigame.on_item_cooldown.connect(_on_item_cooldown)

func register_sounds(sounds:Sounds):
	self.sounds = sounds

func register_camera(camera:Camera3D):
	self.camera = camera

#Initialize the game scene once it is loaded
func initialize_game() -> void:
	print("scene name: ", get_tree().current_scene.name)
	UI_Manager.initialize_game()
	G_Inventory.initialize()
	#Main_Camera.set_persp()
	get_tree().root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	get_tree().root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_KEEP
	await get_tree().process_frame
	_sub_viewport =  get_tree().current_scene.get_node("SubViewportContainer/SubViewport2D")
	_sub_viewport.physics_object_picking = true
	_inventory_ui = _sub_viewport.get_node("TestingGroundsBIGJ/UI_Root/InventoryUi/")
	UI_Manager.fade_in_background()
	_sub_viewport_2 = get_tree().current_scene.get_node("ViewportContainer/SubViewport")
	bus_seats_left.assign(_sub_viewport_2.get_node("Collision/Seats/Left").get_children())
	bus_seats_right.assign(_sub_viewport_2.get_node("Collision/Seats/Right").get_children())
	game_timer = _sub_viewport.get_node("TestingGroundsBIGJ/GameTimer")
	#await game_timer.ready
	_busdriver.poses =_sub_viewport.get_node("TestingGroundsBIGJ/UI_Root/BusDriverPoses")
	_busdriver._current_pose = _busdriver.poses.get_child(0)
	_player.poses =_sub_viewport_2.get_node("BimmyPoses")
	_player._current_pose = _player.poses.get_child(0)
	game_timer.timeout.connect(_on_timeout)
	await G_Utils.wait(2)
	mini_games[1].running = true
	mini_games[1].display_info()
	
	_inventory_ui.show_item_indicator(1)
	
	#get_tree().root.content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	#Main_Camera.set_limits(0,500,0,0)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	UI_Manager.update()
	
func _input(event):
		# Mouse in viewport coordinates.
	if event is InputEventMouseMotion:
		old_mouse_pos = mouse_pos
		mouse_pos = event.position
	if _sub_viewport:
		_sub_viewport.push_input(event)
	if _sub_viewport_2:
		_sub_viewport_2.push_input(event)
	
	if event is InputEventKey and event.pressed:
		var keycode = event.as_text_physical_keycode()
		if keycode == "Tab":
			UI_Manager.pause_game()
			
#Initialize the game manager
func initialize() -> void:
	_initialized = true

func _unhandled_input(event: InputEvent) -> void:
	pass
		
func get_interact_action() -> String:
	return interact_input_action
	
func get_interact_action_2() -> String:
	return interact_input_action_2
	
func get_bus_driver() -> BusDriver:
	return _busdriver
	
func get_player() -> Player:
	return _player

func _on_item_cooldown(minigame:MiniGame):
	print("item cooldown")
	minigame.calculate_suspicion()
	_busdriver.make_suspicious(minigame.suspicion_gain)

#called when a minigame or a part of a minigame suceeded
func _on_minigame_succeeded(minigame:MiniGame):
	minigame.calculate_clout()
	_player.increase_clout(minigame.clout_gain)
	
	if minigame is MiniGame2:
		minigame.calculate_suspicion()
		_busdriver.make_suspicious(minigame.suspicion_gain)

#called when a minigame or a part of a minigame failed
func _on_minigame_failed(minigame:MiniGame):
	pass
	#minigame.calculate_suspicion(false)+
	#_busdriver.make_suspicious(minigame.suspicion_gain)
	#print("bus driver susp: ", _busdriver.total_suspicion )

func _on_player_powerboost():
	_busdriver.base_suspicion_multiplier-=0.3

func game_lost():
	return _busdriver.total_suspicion >= 100

func _on_minigame_ended(minigame):
	print("mini game index: ",current_mini_game )
	if !game_lost():
		#start next minigame
		await G_Utils.wait(2)
		print("mini game index: ",current_mini_game )
		if current_mini_game < 1:
			current_mini_game = current_mini_game+1
			mini_games[current_mini_game].running = true
			mini_games[current_mini_game].display_info()
			_inventory_ui.show_item_indicator(current_mini_game)
	else:
		game_over("The Bus Driver caught you. You lost the game!")

func game_over(message):
	UI_Manager.showInfo(message)
	UI_Manager.pause_game()
	
func _on_timeout():
	game_over("The time has run out!\n You lost the game")

func get_current_minigame():
	return mini_games[current_mini_game]
	
func on_player_spotted():
	_minigame_warnings += 1
	
	_busdriver.set_suspicion(_busdriver.get_total_suspicion() + 5 + 33)
	print("player spotted, bus driver has suspicion: ", _busdriver.get_total_suspicion())
	if _minigame_warnings == 3:
		_busdriver.set_suspicion(100)
		
	UI_Manager.display_warning()	
	
func show_item_indicator(index):
	_inventory_ui.show_item_indicator(index)
	
func hide_item_indicator():
	_inventory_ui.hide_item_indicator()

func enable_67_mode(duration):
	_sixty_seven_enabled = true
	_busdriver.ignore_suspicion(true)
	UI_Manager.display_67_mode(duration)
	await G_Utils.wait(duration)
	_busdriver.ignore_suspicion(false)
	_sixty_seven_enabled = false
