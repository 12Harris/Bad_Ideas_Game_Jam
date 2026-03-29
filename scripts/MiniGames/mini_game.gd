extends Node2D
class_name MiniGame

signal succeeded(minigame)
signal failed(minigame)
signal ended(minigame)
signal on_player_spotted
signal on_item_cooldown

var running : bool = false
var suspicion_gain: float = 0
var clout_gain: float = 0
var clout_levels_file : String = ""
var clout_levels: Array[CloutLevel] = []
var _busdriver: BusDriver
var _player:Player
var _look_at_diff:float
var _start_looking :float
var _information:String
var chain_length: int = 0
var item_required: bool = true
var _player_spotted:bool = false
var _num_tries :int = 0
var stop_game:bool = false
var id = 0

@export var _inventory_ui:InventoryUI

class CloutLevel:
	var _max_clout : float
	var _base_clout_gain : float
	var _current_clout : float
	var _minigame : MiniGame
	static var currentLevel : int = 0
	
	signal clout_level_increased()
	
	func _init(mini_game,max_clout,base_clout_gain) -> void:
		_max_clout = max_clout
		_base_clout_gain = base_clout_gain
		_current_clout = 0
		_minigame = mini_game
		clout_level_increased.connect(_minigame._on_clout_level_increased)
	
	#get the max clout for this level
	func get_max_clout():
		return _max_clout
		
	func increase_clout(override_clout = 0) -> void:
		var modified_clout_gain = _base_clout_gain
		
		if override_clout > 0:
			modified_clout_gain = override_clout
			
		if _current_clout < _max_clout:
			if _current_clout + modified_clout_gain > _max_clout:
				modified_clout_gain = _max_clout-_current_clout
			_current_clout += modified_clout_gain
			#_minigame._total_clout += modified_clout_gain
			UI_Manager.increase_clout_meter(modified_clout_gain)
			Game_Manager.get_player().increase_clout(modified_clout_gain)
		elif _current_clout >= _max_clout and currentLevel < _minigame.clout_levels.size()-1:
			currentLevel += 1
			clout_level_increased.emit()	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_process_unhandled_input(true)
	read_clout_levels_from_file()
	_busdriver = Game_Manager.get_bus_driver()
	_player = Game_Manager.get_player()
	_busdriver.on_stop_looking_back.connect(_on_busdriver_stop_looking_back)
	_inventory_ui.on_item_selected.connect(on_item_selected)
	_player.on_entered_action_zone.connect(on_player_entered_action_zone)
	_player.on_left_action_zone.connect(on_player_left_action_zone)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !running:
		return
		
	if !_player_spotted and _busdriver._looking_back and !_busdriver.distracted and !_player.is_safe():
		on_player_spotted.emit()
		_player_spotted = true
		
	if _busdriver.total_suspicion >= 100 and !stop_game:
		Game_Manager.game_over("The Bus Driver caught you. You lost the game!")
		stop_game = true
		
#Triggered when the minigame(or a part of the minigame) succeded
func succeed()->void:
	succeeded.emit(self)

#Triggered when the minigame(or a part of the minigame) failed
func fail()->void:
	failed.emit(self)

func start(show_info = true):
	_num_tries += 1
	running = true

func calculate_suspicion():
	pass

func calculate_clout():
	pass
	
func is_noisy()->bool:
	return false
	
#Reads minigame data from a text file
func read_clout_levels_from_file() -> void:
	var file = FileAccess.open("res://data/"+clout_levels_file, FileAccess.READ)
	var content = file.get_as_text()
	content = content.split("\n")
	var content_size = content.size()
	for i in range(1,content_size-1):
		var line = content[i].split("\t")
		clout_levels.append(CloutLevel.new(self,float(line[1]),float(line[2])))

func _on_clout_level_increased() -> void:
	UI_Manager.reset_clout_meter(clout_levels[CloutLevel.currentLevel].get_max_clout())
	Game_Manager._on_player_powerboost()

func game_over():
	ended.emit(self)
	running = false
	

func _on_busdriver_stop_looking_back():
	
	if !running:
		return
	_player_spotted = false
	
func on_item_selected(index):
	pass

func requires_arrow_keys():
	return false
	
func cancel_actions():
	pass

func display_info():
	pass

func on_player_entered_action_zone():
	pass

func on_player_left_action_zone():
	pass
	pass
