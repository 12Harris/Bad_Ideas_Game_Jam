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

#global timer
var global_timer: float = 0

@export var interact_input_action = "interact"
@export var interact_input_action_2 = "interact2"

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

func register_sounds(sounds:Sounds):
	self.sounds = sounds
		
#Initialize the game scene once it is loaded
func initialize_game() -> void:
	print("scene name: ", get_tree().current_scene.name)
	UI_Manager.initialize_game()
	G_Inventory.initialize()
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	global_timer += delta
		
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
	
