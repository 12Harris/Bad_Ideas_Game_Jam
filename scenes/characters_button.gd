extends TextureRect

var _can_press : bool = false
var _character_bios:Node2D
var _next_button:Button
var _prev_button:Button
var _current_bio = 0
var menu_active = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await G_Utils.wait(0.1)
	_character_bios = get_tree().current_scene.get_node("CharacterBios")
	_next_button = get_tree().current_scene.get_node("NextBtn")
	_prev_button = get_tree().current_scene.get_node("PrevBtn")
	
	_next_button.visible = false
	_prev_button.visible = false
	
	_next_button.pressed.connect(next_bio)
	_prev_button.pressed.connect(prev_bio)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _unhandled_input(event: InputEvent) -> void:
	if !_can_press:
		return
		
	if event is InputEventMouseButton and event.pressed:
		var btn = event.as_text()
		if btn == "Left Mouse Button":
			_current_bio = 0
			_next_button.visible = true
			_prev_button.visible = true
			menu_active = true
			get_tree().current_scene.get_node("Logo").visible = false
			show_bio(_current_bio)
			
func hide_bio(index):
	_character_bios.get_child(index).visible = false
	
func show_bio(index):
	
	if !menu_active:
		return 
		
	if index == -1:
		_character_bios.get_child(0).visible = false
		_prev_button.visible = false
		_next_button.visible = false
		menu_active = false
		get_tree().current_scene.get_node("Logo").visible = true
	else:
		_character_bios.get_child(index).visible = true

		if index == 2:
			_next_button.visible = false
		else:
			_next_button.visible = true
	
func next_bio():

	if !menu_active:
		return 
		
	if !_next_button.visible:
		return
	_character_bios.get_child(_current_bio).visible = false
	_current_bio += 1
	show_bio(_current_bio)

func prev_bio():
	
	if !menu_active:
		return 
		
	if !_prev_button.visible:
		return
		
	_character_bios.get_child(_current_bio).visible = false
	_current_bio -= 1
	show_bio(_current_bio)

func _on_area_2d_mouse_entered() -> void:
	_can_press = true
	self_modulate = Color(0.5, 0.5, 0.5, 1.0) 

func _on_area_2d_mouse_exited() -> void:
	_can_press = false
	self_modulate = Color(1.0, 1.0, 1.0, 1.0) 
