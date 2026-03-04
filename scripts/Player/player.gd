class_name Player
extends Node

signal cause_anger(amount)

var _anger_caused : int = 20

var _exp : int = 0

var bus_driver : BusDriver
		
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Game_Manager.register_player(self)
	set_process_unhandled_input(true)
	bus_driver = Game_Manager.get_bus_driver()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(Game_Manager.get_interact_action()):
		cause_anger.emit(_anger_caused)
		#Simplified experience calculation: simply set it to the total_anger of the bus driver
		_exp = bus_driver.get_total_anger()
		#Update the anger caused for the next calculation
		_anger_caused *=  (1.2- (bus_driver.AngerLevel.currentLevel/10.0)*0.2)
		get_viewport().set_input_as_handled()
		
func get_exp() -> int:
	return _exp
