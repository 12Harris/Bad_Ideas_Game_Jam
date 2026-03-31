extends TextureRect

var _can_press : bool = false
var _start_click_sound:AudioStreamPlayer
@export var _main_menu_music:AudioStreamPlayer

func _ready() -> void:
	_start_click_sound = AudioStreamPlayer.new()
	_start_click_sound.stream = load("res://assets/sounds/main menu/click_start.mp3")
	add_child(_start_click_sound)
	await(G_Utils.wait(0.1))
	_main_menu_music.play()
	
func _unhandled_input(event: InputEvent) -> void:
	if !_can_press:
		return
		
	if event is InputEventMouseButton and event.pressed:
		var btn = event.as_text()
		if btn == "Left Mouse Button":
			_start_click_sound.play()
			await G_Utils.wait(1)
			load_game()

func load_game():
	_main_menu_music.stop()
	G_Utils.load_intro_scene()
	#G_Utils.load_game_scene()
	
func _on_area_2d_mouse_entered() -> void:
	_can_press = true
	self_modulate = Color(0.5, 0.5, 0.5, 1.0) 

func _on_area_2d_mouse_exited() -> void:
	_can_press = false
	self_modulate = Color(1.0, 1.0, 1.0, 1.0) 
