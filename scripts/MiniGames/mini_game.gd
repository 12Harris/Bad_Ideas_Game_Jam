extends Node
class_name MiniGame

signal succeeded(minigame)
signal failed(minigame)

var running : bool = false
var suspicion_gain: float = 0
var clout_gain: float = 0
var clout_levels_file : String = ""
var clout_levels: Array[CloutLevel] = []

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
		
	func increase_clout(multiplier = 1) -> void:
		var modified_clout_gain = _base_clout_gain * multiplier
		if _current_clout < _max_clout:
			if _current_clout + modified_clout_gain > _max_clout:
				modified_clout_gain = _max_clout-_current_clout
			_current_clout += modified_clout_gain
			#_minigame._total_clout += modified_clout_gain
			UI_Manager.increase_clout_meter(modified_clout_gain)
		elif _current_clout >= _max_clout and currentLevel < _minigame.clout_levels.size()-1:
			currentLevel += 1
			clout_level_increased.emit()	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_process_unhandled_input(true)
	read_clout_levels_from_file()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

#Triggered when the minigame(or a part of the minigame) succeded
func succeed()->void:
	succeeded.emit(self)

#Triggered when the minigame(or a part of the minigame) failed
func fail()->void:
	failed.emit(self)

func start():
	running = true
	
func calculate_suspicion(succeded: bool):
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
