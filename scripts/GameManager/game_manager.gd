class_name GameManager
extends Node

#The main player
var _player

#The bus driver
var _busdriver

#The UI
var _ui

#initialized flag
var _initialized

@export var interact_input_action = "interact"

#Register the UI
func register_ui(ui):
	_ui = ui

#Register the player
func register_player(p):
	_player = p
	_player.cause_anger.connect(on_player_cause_anger)
	
#Register the bus driver
func register_busdriver(b):
	_busdriver = b
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass	
#Initialize the game manager
func initialize() -> void:
	_initialized = true

func _unhandled_input(event: InputEvent) -> void:
	pass
		
func get_interact_action() -> String:
	return interact_input_action
	
func on_player_cause_anger(amount):
	_busdriver.make_angry(amount)
	G_Inventory.update()

func get_bus_driver() -> BusDriver:
	return _busdriver
	
func get_player() -> Player:
	return _player
