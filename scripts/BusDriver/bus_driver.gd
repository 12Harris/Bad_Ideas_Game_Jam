class_name BusDriver
extends Node

class AngerLevel:
	var _max_anger : float
	var _current_anger : float
	var _busdriver
	static var currentLevel : int = 0
	
	signal anger_level_increased()
	
	func _init(busdriver,max_anger) -> void:
		_current_anger = 0
		_max_anger = max_anger
		_busdriver = busdriver
		anger_level_increased.connect(_busdriver._on_anger_level_increased)
	
	#get the max anger
	func get_max_anger():
		return _max_anger
		
	func increase_anger(anger) -> void:
		if _current_anger < _max_anger:
			_current_anger += anger
			_busdriver.total_anger  += _current_anger
			print("current anger: " , _current_anger)
			UI_Manager.increase_anger_meter(anger)
		elif _current_anger >= _max_anger and currentLevel < 9:
			currentLevel += 1
			anger_level_increased.emit()

var anger_levels: Array[AngerLevel] = []
var anger_levels_file : String
var total_anger: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	initialize()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func initialize() -> void:
	read_anger_levels_from_file()
	for i in range(anger_levels.size()):
		print("anger level: ", anger_levels[i].get_max_anger())
	Game_Manager.register_busdriver(self)
		
#Reads the anger levels from a text file
func read_anger_levels_from_file() -> void:
	var file = FileAccess.open("res://data/anger_levels.txt", FileAccess.READ)
	var content = file.get_as_text()
	content = content.split("\n")
	var content_size = content.size()
	for i in range(content_size-1):
		var line = content[i].split(" ")
		print(line[0])
		anger_levels.append(AngerLevel.new(self,float(line[1])))

#Make the bus driver angry
func make_angry(anger_amount) -> void:
	anger_levels[AngerLevel.currentLevel].increase_anger(anger_amount)
	
#Notify the ui manager that the anger level increased
func _on_anger_level_increased() -> void:
	UI_Manager.reset_anger_meter(anger_levels[AngerLevel.currentLevel].get_max_anger())

#get the total anger
func get_total_anger() -> int:
	return total_anger
	
