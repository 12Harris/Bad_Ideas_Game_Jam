extends Node
class_name Utils

func wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout

func load_game_scene():
	await change_scene("res://scenes/TestingGrounds_BIGJ.tscn")
	Game_Manager.initialize_game()
	
func change_scene(scene_path: String):
	get_tree().change_scene_to_file(scene_path)
	# Wait until the current scene is replaced
	await get_tree().tree_changed
	# Get the new root node of the scene
	var new_scene = get_tree().current_scene
	# Wait until the new scene's _ready() finishes
	await new_scene.ready
