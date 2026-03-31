class_name StreetStrip
extends Node3D

var is_moving:bool
var reset_pos:Vector3
var _timer = 0
var _dist_traveled = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	is_moving = true

func stop_moving():
	is_moving = false

func set_reset_position(pos):
	reset_pos = pos
	
func move(delta):
	print("moving street strip")
	#while is_moving:
	global_position -= Vector3.FORWARD*get_process_delta_time() * 400
		#await get_tree().process_frame
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_timer += delta
	if global_position.z > reset_pos.z + 1600:
		global_position = reset_pos
