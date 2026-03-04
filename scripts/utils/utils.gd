extends Node
class_name Utils

func wait(seconds: float) -> void:
  await get_tree().create_timer(seconds).timeout
