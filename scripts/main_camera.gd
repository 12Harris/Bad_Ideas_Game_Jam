extends Camera3D
class_name MainCamera
@export var secondary_camera : Camera3D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	Game_Manager.register_camera(self)
	#DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	#get_window().size = Vector2(959,539)
	#get_window().content_scale_size = get_window().size*2
	#get_window().size = Vector2(1919,1079)
	#get_window().content_scale_size = get_window().size
	#get_tree().root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	#get_tree().root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_KEEP
	#print("viewport size: "get_viewport().size)

func init():
	pass
	
func set_ortho():
	# Set to Orthogonal
	self.projection = Camera3D.PROJECTION_ORTHOGONAL
	# Adjust the size (vertical screen size)
	self.size = 10.0 
	
func set_persp():
	# Set to Orthogonal
	self.projection = Camera3D.PROJECTION_PERSPECTIVE
	# Adjust the size (vertical screen size)
	#self.size = 1.0 
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_dimensions(width:float, height:float):
	var new_size = Vector2i(width, height)
	#get_window().size = new_size
	#get_window().content_scale_size = new_size

	
#func set_size(width:float, height:float):
	#var new_size = Vector2i(width, height)
	#get_window().size = new_size
	#get_window().content_scale_size = new_size

func set_limits(left, right, top, bottom):
	pass
	#limit_left = left
	#limit_right = right
	#limit_top = top
	#limit_bottom = bottom
	
