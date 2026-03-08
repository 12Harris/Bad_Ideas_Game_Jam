extends TextureRect

var _can_press : bool = false

func _unhandled_input(event: InputEvent) -> void:
	if !_can_press:
		return
		
	if event is InputEventMouseButton and event.pressed:
		var btn = event.as_text()
		if btn == "Left Mouse Button":
			load_game()
		
func load_game():
	G_Utils.load_game_scene()
	
func _on_area_2d_mouse_entered() -> void:
	_can_press = true
	self_modulate = Color(0.5, 0.5, 0.5, 1.0) 

func _on_area_2d_mouse_exited() -> void:
	_can_press = false
	self_modulate = Color(1.0, 1.0, 1.0, 1.0) 
