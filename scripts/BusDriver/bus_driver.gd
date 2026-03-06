class_name BusDriver
extends Node

class SuspicionLevel:
	var _id: int
	var _max_suspicion : float
	var _busdriver:BusDriver
	var _ai_state:String
	static var timer : float = 0
	static var currentLevel : int = 0
	static var targetLevel: int = 0
	
	func _init(id,busdriver,max_suspicion, ai_state) -> void:
		_id = id
		_max_suspicion = max_suspicion
		_busdriver = busdriver
		_ai_state = ai_state
	
	#get the max anger
	func get_max_suspicion():
		return _max_suspicion
		
	static func update(busdriver:BusDriver,delta, drain:bool) -> void:
		
		if drain == false:
			timer = 0.0
			return
	
		timer += delta
		if timer > 0.25:
			UI_Manager.set_susp_meter(busdriver.get_total_suspicion())
			timer = 0.0
			
	func decrease_suspicion(amount) -> void:
		
		if _busdriver.get_total_suspicion() > _busdriver.get_suspicion_level(targetLevel)._max_suspicion and currentLevel > targetLevel:
			_busdriver.total_suspicion -=amount
			if _busdriver.get_total_suspicion() <= _busdriver.get_suspicion_level(currentLevel-1)._max_suspicion:
					currentLevel -= 1
		else:
			currentLevel = targetLevel
			set_suspicion(_busdriver.get_suspicion_level(currentLevel)._max_suspicion)
			_busdriver._drain_suspicion = false
		
		_busdriver.ai_state = _busdriver.get_suspicion_level(currentLevel)._ai_state
		UI_Manager.update_ai_state(_busdriver.ai_state,_busdriver._looking_at_mirror)

	func increase_suspicion(amount) -> void:
		
		_busdriver.total_suspicion += amount
		UI_Manager.inc_susp_meter(amount)
		if _busdriver.get_total_suspicion() >= _max_suspicion and currentLevel < 9:
			currentLevel += 1
		
		_busdriver.ai_state = _busdriver.get_suspicion_level(currentLevel)._ai_state
		UI_Manager.update_ai_state(_busdriver.ai_state,_busdriver._looking_at_mirror)

	func set_suspicion(amount) -> void:
		UI_Manager.set_susp_meter(amount)

var suspicion_levels: Array[SuspicionLevel] = []
var anger_levels_file : String
var total_suspicion: float = 0
var base_suspicion_multiplier : float = 1.0
var ai_state: String = "calm"
var _player:Player
var suspicion_drain : float = 0.01
var _drain_suspicion = false
var _looking_at_mirror = false
var _timer : float = 0.0
var _update_interval :float = 4.0

signal suspicion_level_increased
signal on_look_at_mirror
signal on_stop_look_at_mirror

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	initialize()
	await get_tree().process_frame
	_player = Game_Manager.get_player()
	randomize()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	#drain suspicion logic
	if _drain_suspicion and SuspicionLevel.currentLevel > SuspicionLevel.targetLevel:
		suspicion_levels[SuspicionLevel.currentLevel].decrease_suspicion(suspicion_drain)
	SuspicionLevel.update(self,delta,_drain_suspicion)
	
	# do look at mirror logic
	if _timer >= 0:
		_timer += delta
		_update_interval = 3.0 - 2* (SuspicionLevel.currentLevel/10)
		
		if _timer > _update_interval:
			var probability = calculate_look_at_mirror_probability()
			#print("probability: ", probability)
			if probability <= randi() % 100:
				look_at_mirror()
			
		
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

#Make the bus driver suspicious
func make_suspicious(suspicion_amount) -> void:
	suspicion_levels[SuspicionLevel.currentLevel].increase_suspicion(suspicion_amount*base_suspicion_multiplier)
	_drain_suspicion = false
	await G_Utils.wait(2)
	SuspicionLevel.targetLevel = SuspicionLevel.currentLevel - 2
	if SuspicionLevel.targetLevel < 0:
		SuspicionLevel.targetLevel = 0
	_drain_suspicion = true
	
	#suspicion_levels[SuspicionLevel.currentLevel].increase_suspicion(suspicion_amount)
#Notify the ui manager that the anger level increased
func _on_suspicion_level_increased() -> void:
	pass
	
#get the total anger
func get_total_suspicion() -> int:
	return total_suspicion
	
func get_suspicion_level(id):
	if id < 0:
		return suspicion_levels[0]
	return suspicion_levels[id]
	
func look_at_mirror():
	var min_duration = 0.5
	var max_duration = 3.0
	
	_looking_at_mirror = true
	UI_Manager.update_ai_state(ai_state,true)
	on_look_at_mirror.emit()
	_timer = -1
	var duration = min_duration

	if ai_state == "suspicious":
		#duration = 0.5 - 1.0
		duration = min_duration + randf()
	
	elif ai_state == "angry":
		#duration = 1.0 - 3.0
		min_duration = 1.0
		var temp = randi() % 10
		var additional:float = 0
		if temp < SuspicionLevel.currentLevel:
			additional = SuspicionLevel.currentLevel/10.0
		
		duration = min_duration + additional *(max_duration-min_duration)

	await G_Utils.wait(duration)
	_looking_at_mirror = false
	UI_Manager.update_ai_state(ai_state,false)
	on_stop_look_at_mirror.emit()
	_timer = 0

#in fixed upate intervals the probability is calculated
#currently just returns the total suspicion
func calculate_look_at_mirror_probability() -> float:	
	var probability = get_total_suspicion()
	return probability
