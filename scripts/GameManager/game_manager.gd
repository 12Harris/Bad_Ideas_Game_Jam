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
var global_timer: float = 0

#Collision Areas
var collisions: Node2D

var mouse_pos:Vector2 = Vector2.ZERO

var _sub_viewport:SubViewport

var _sub_viewport_2:SubViewport


var interact_input_action = "interact"
var interact_input_action_2 = "interact2"

var bus_seats_left:Array[StaticBody3D]= []
var bus_seats_right:Array[StaticBody3D]= []

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
	collisions = get_tree().current_scene.get_node("Collisions")
	_sub_viewport =  get_tree().current_scene.get_node("SubViewportContainer/SubViewport2D")
	_sub_viewport.physics_object_picking = true
	_sub_viewport_2 = get_tree().current_scene.get_node("ViewportContainer/SubViewport")
	bus_seats_left.assign(_sub_viewport_2.get_node("Collision/Seats/Left").get_children())
	bus_seats_right.assign(_sub_viewport_2.get_node("Collision/Seats/Right").get_children())
	mini_games[1].start()
	#get_tree().root.content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	#Main_Camera.set_limits(0,500,0,0)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	global_timer += delta

func _input(event):
		# Mouse in viewport coordinates.
	if event is InputEventMouseMotion:
		mouse_pos = event.position
	if _sub_viewport:
		_sub_viewport.push_input(event)
	if _sub_viewport_2:
		_sub_viewport_2.push_input(event)
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

#called when a minigame or a part of a minigame suceeded
func _on_minigame_succeeded(minigame:MiniGame):
	
	minigame.calculate_clout()
	if minigame.is_noisy():
		minigame.calculate_suspicion(true)
		_busdriver.make_suspicious(minigame.suspicion_gain)

	_player.increase_clout(minigame.clout_gain)

#called when a minigame or a part of a minigame failed
func _on_minigame_failed(minigame:MiniGame):
	minigame.calculate_suspicion(false)
	_busdriver.make_suspicious(minigame.suspicion_gain)
	
func _on_player_powerboost():
	_busdriver.base_suspicion_multiplier-=0.2
	
func _on_minigame_ended(minigame):
	await G_Utils.wait(2)
	mini_games[1].start()
