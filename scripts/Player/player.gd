class_name Player
extends Node

signal cause_suspicion()

var _clout_gained : int = 20

var _total_clout : int

var bus_driver : BusDriver

#nested class for the player clout
class CloutLevel:
	var _min_clout:float
	var _max_clout : float
	var _current_clout : float
	var _player : Player
	var suspicion_level_id : int
	static var currentLevel : int = 0
	
	signal clout_level_increased()
	
	func _init(player,max_clout,min_clout) -> void:
		_max_clout = max_clout
		_min_clout = min_clout
		_current_clout = _min_clout
		_player = player
		clout_level_increased.connect(_player._on_clout_level_increased)
	
	#get the max anger
	func get_max_clout():
		return _max_clout
		
	func increase_clout(clout) -> void:
		if _current_clout < _max_clout:
			if _current_clout + clout > _max_clout:
				clout = _max_clout-_current_clout
			_current_clout += clout
			_player._total_clout += clout
			UI_Manager.increase_clout_meter(clout)
		elif _current_clout >= _max_clout and currentLevel < 9:
			currentLevel += 1
			UI_Manager.set_min_clout(_max_clout)
			clout_level_increased.emit()	

var clout_levels: Array[CloutLevel] = []
var clout_levels_file : String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Game_Manager.register_player(self)
	set_process_unhandled_input(true)
	bus_driver = Game_Manager.get_bus_driver()
	read_clout_levels_from_file()
	_total_clout = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(Game_Manager.get_interact_action()):
		handle_interaction()
	elif event.is_action_pressed(Game_Manager.get_interact_action_2()):
		handle_interaction()
		cause_suspicion.emit()
	get_viewport().set_input_as_handled()

#called when F or G key is pressed
func handle_interaction() -> void:
	clout_levels[CloutLevel.currentLevel].increase_clout(_clout_gained)
	#_total_clout += _clout_gained
	#Update the clout caused for the next calculation
	_clout_gained *=  (1.2- (CloutLevel.currentLevel/10.0)*0.2)
	G_Inventory.update()
	
#Reads the anger levels from a text file
func read_clout_levels_from_file() -> void:
	var file = FileAccess.open("res://data/clout_levels.txt", FileAccess.READ)
	var content = file.get_as_text()
	content = content.split("\n")
	var content_size = content.size()
	var old_clout_level:CloutLevel
	for i in range(1,content_size-1):
		var line = content[i].split("\t")
		if(clout_levels.size() > 0):
			old_clout_level = clout_levels[clout_levels.size()-1]
			clout_levels.append(CloutLevel.new(self,float(line[1]),old_clout_level._max_clout))
		else:
			clout_levels.append(CloutLevel.new(self,float(line[1]),0))
			
#Notify the ui manager that the anger level increased
func _on_clout_level_increased() -> void:
	UI_Manager.reset_clout_meter(clout_levels[CloutLevel.currentLevel].get_max_clout())
	
func get_total_clout() -> int:
	return _total_clout
	
