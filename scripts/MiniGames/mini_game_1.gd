class_name MiniGame1
extends MiniGame

var _alphabet = ['A','B','C','D','E','F','G','H','I','J',
				'K','L','M','N','O','P','Q','R','S','T',
				'U','V','W','X','Y','Z']
				
var _busdriver: BusDriver
var _current_letter_index : int = 0
var _suspicion_multiplier : float = 0
var _clout_multiplier : float = 0
var _update_timer : float = -1
var game_timer : Timer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	clout_levels_file = "mini_game_1.txt"
	super._ready()
	Game_Manager.register_minigame(self)
	await get_tree().process_frame
	_busdriver = Game_Manager.get_bus_driver()
	suspicion_gain = 2
	game_timer = get_node("Timer")
	await game_timer.ready
	game_timer.timeout.connect(_on_timeout)
	
func _input(event):
	
	if !running:
		return
		
	if event is InputEventKey and event.pressed:
		var keycode = event.as_text_physical_keycode()
		if _current_letter_index < _alphabet.size() \
			and keycode >= 'A' and keycode <= 'Z':
			
			if _update_timer < 0 or _update_timer >= 0.75:	
				if _update_timer < 0:
					game_timer.start()
				Game_Manager.sounds.play_random_burp_sound()
				evaluate(keycode)
				_current_letter_index += 1
				running = _current_letter_index < _alphabet.size() and _busdriver.get_total_suspicion() < 100
				_update_timer = 0.0	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !running:
		return
	if _update_timer >= 0.0:
		_update_timer+=delta
		
	UI_Manager.updateMiniGame(self)

func start():
	super.start()
	
func evaluate(letter):
	
	if letter != _alphabet[_current_letter_index]:
		if _busdriver._looking_at_mirror:
			_suspicion_multiplier= 1.5
		else:
			_suspicion_multiplier =1.2
		fail()
	else:
		if _busdriver._looking_at_mirror:
			_suspicion_multiplier = 1.35
			fail()
		else:
			_suspicion_multiplier = 1.05
			succeed()

func calculate_suspicion(succeeded:bool):
	if !succeeded:
		if(suspicion_gain < 5):
			suspicion_gain += 5	
		else:
			suspicion_gain *= _suspicion_multiplier
	else:
		suspicion_gain *= _suspicion_multiplier
	
#only called if minigame succeded	
func calculate_clout():
	if _busdriver._looking_at_mirror:
		clout_levels[CloutLevel.currentLevel].increase_clout(1.5)
	else:
		clout_levels[CloutLevel.currentLevel].increase_clout()

func is_noisy()->bool:
	return true

func _on_timeout():
	running = false
