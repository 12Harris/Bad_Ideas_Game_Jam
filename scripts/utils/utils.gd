extends Node
class_name Utils

func wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout

func load_game_scene():
	await change_scene("res://scenes/Main_3D.tscn")
	Game_Manager.initialize_game()
	
func change_scene(scene_path: String):
	get_tree().change_scene_to_file(scene_path)
	# Wait until the current scene is replaced
	await get_tree().tree_changed
	# Get the new root node of the scene
	var new_scene = get_tree().current_scene
	# Wait until the new scene's _ready() finishes
	await new_scene.ready

#returns a point on on a bezier curve
func _cubic_bezier(p0: Vector2, p1: Vector2, p2: Vector2, p3: Vector2, t: float):
	var q0 = p0.lerp(p1, t)
	var q1 = p1.lerp(p2, t)
	var q2 = p2.lerp(p3, t)

	var r0 = q0.lerp(q1, t)
	var r1 = q1.lerp(q2, t)

	var s = r0.lerp(r1, t)
	return s

		
