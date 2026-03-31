extends TextureRect

var _can_press : bool = false
var _items_guide:Node2D
var _next_button:Button
var _prev_button:Button
var _current_item = 0
var menu_active = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await G_Utils.wait(0.1)
	_items_guide = get_tree().current_scene.get_node("ItemsGuide")
	_next_button = get_tree().current_scene.get_node("NextBtn")
	_prev_button = get_tree().current_scene.get_node("PrevBtn")
	_next_button.visible = false
	_prev_button.visible = false
	
	_next_button.pressed.connect(next_item)
	_prev_button.pressed.connect(prev_item)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _unhandled_input(event: InputEvent) -> void:
	if !_can_press:
		return
		
	if event is InputEventMouseButton and event.pressed:
		var btn = event.as_text()
		if btn == "Left Mouse Button":
			_current_item = 0
			_next_button.visible = true
			_prev_button.visible = true
			menu_active = true
			get_tree().current_scene.get_node("Logo").visible = false
			show_item(_current_item)
			
func hide_item(index):
	_items_guide.get_child(index).visible = false
	
func show_item(index):
	
	if index == -1:
		_items_guide.get_child(0).visible = false
		_prev_button.visible = false
		_next_button.visible = false
		menu_active = false
		get_tree().current_scene.get_node("Logo").visible = true
	else:
		_items_guide.get_child(index).visible = true

		if index == 5:
			_next_button.visible = false
		else:
			_next_button.visible = true
	
func next_item():
	
	if !menu_active:
		return
		
	if !_next_button.visible:
		return
	_items_guide.get_child(_current_item).visible = false
	_current_item += 1
	show_item(_current_item)

func prev_item():
	
	if !menu_active:
		return
		
	if !_prev_button.visible:
		return
	_items_guide.get_child(_current_item).visible = false
	_current_item -= 1
	show_item(_current_item)

func _on_area_2d_mouse_entered() -> void:
	_can_press = true
	self_modulate = Color(0.5, 0.5, 0.5, 1.0) 

func _on_area_2d_mouse_exited() -> void:
	_can_press = false
	self_modulate = Color(1.0, 1.0, 1.0, 1.0) 
