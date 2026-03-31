class_name OutDoorTree
extends Sprite3D

var is_moving:bool
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	is_moving = true

func stop_moving():
	is_moving = false
	
func move():
	print("moving tree")
	while is_moving:
		global_position -= Vector3.FORWARD*get_process_delta_time() * 500
		if !Game_Manager.game_lost():
			await get_tree().process_frame
		else:
			is_moving = false
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
