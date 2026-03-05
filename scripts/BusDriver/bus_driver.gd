class_name BusDriver
extends Node

class SuspicionLevel:
	var _id: int
	var _max_suspicion : float
	var _busdriver
	var _ai_state:String
	static var currentLevel : int = 0
	
	func _init(id,busdriver,max_suspicion, ai_state) -> void:
		_id = id
		_max_suspicion = max_suspicion
		_busdriver = busdriver
		_ai_state = ai_state
	
	#get the max anger
	func get_max_suspicion():
		return _max_suspicion
		
	func set_suspicion(amount) -> void:
		UI_Manager.set_susp_meter(amount)
		#if _busdriver.get_total_suspicion() >= _max_suspicion and currentLevel < 9:
			#currentLevel += 1# HIERE IST DER WURM		

var suspicion_levels: Array[SuspicionLevel] = []
var anger_levels_file : String
var total_suspicion: int = 0
var ai_state: String = "calm"
var _player:Player
	
signal suspicion_level_increased
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	initialize()
	await get_tree().process_frame
	_player = Game_Manager.get_player()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func initialize() -> void:
	read_suspicion_levels_from_file()
	for i in range(suspicion_levels.size()):
		print("suspicion level: ", suspicion_levels[i].get_max_suspicion())
	Game_Manager.register_busdriver(self)
		
#Reads the suspicion levels from a text file
func read_suspicion_levels_from_file() -> void:
	var file = FileAccess.open("res://data/suspicion_levels.txt", FileAccess.READ)
	var content = file.get_as_text()
	content = content.split("\n")
	var content_size = content.size()
	for i in range(1,content_size-1):
		var line = content[i].split("\t")
		suspicion_levels.append(SuspicionLevel.new(int(line[0]),self,float(line[1]),line[2]))

#Make the bus driver angry
func make_suspicious(total_player_clout) -> void:
	
	var max_clout_prev = _player.get_last_clout_level_by_suspicion_level_id(SuspicionLevel.currentLevel-1)
	var max_clout_cur = _player.get_last_clout_level_by_suspicion_level_id(SuspicionLevel.currentLevel)
	var clout_dif:float
	
	if max_clout_prev == null:
		clout_dif = max_clout_cur._max_clout
		#print("clout dif: " , clout_dif )
	else:	
		#print("max clout  prev: " , max_clout_prev._max_clout)
		clout_dif = max_clout_cur._max_clout - max_clout_prev._max_clout
	
	#print("susp level: ", SuspicionLevel.currentLevel)
	var max_susp_prev = get_suspicion_level(SuspicionLevel.currentLevel-1)
	var max_susp_cur = get_suspicion_level(SuspicionLevel.currentLevel)
	var susp_dif:float
	
	if max_susp_prev == null:
		susp_dif = max_susp_cur._max_suspicion
	else:
		#print("max susp prev: " , max_susp_prev._max_suspicion)
		susp_dif = max_susp_cur._max_suspicion - max_susp_prev._max_suspicion
		
	var suspicion_amount : float
	
	if max_susp_prev != null:
		suspicion_amount = max_susp_prev._max_suspicion + ((total_player_clout - max_clout_prev._max_clout)/clout_dif)*susp_dif
	else:
		suspicion_amount = ((total_player_clout)/clout_dif)*susp_dif
	
	#print("susp amount ", suspicion_amount, "total player clout", total_player_clout )
	suspicion_levels[SuspicionLevel.currentLevel].set_suspicion(suspicion_amount)
	total_suspicion += suspicion_amount
	
	#suspicion_levels[SuspicionLevel.currentLevel].increase_suspicion(suspicion_amount)
#Notify the ui manager that the anger level increased
func _on_suspicion_level_increased() -> void:
	pass
	
#get the total anger
func get_total_suspicion() -> int:
	return total_suspicion
	
func get_suspicion_level(id):
	if id < 0:
		return null
	return suspicion_levels[id]
	
func set_suspicion_level_id(id):
	#print("susp id: ", id)
	if id != SuspicionLevel.currentLevel:
		SuspicionLevel.currentLevel = id
		suspicion_level_increased.emit()
		ai_state = suspicion_levels[SuspicionLevel.currentLevel]._ai_state
		
