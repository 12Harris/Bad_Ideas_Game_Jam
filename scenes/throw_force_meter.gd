class_name ThrowForceMeter
extends TextureProgressBar


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	UI_Manager.register_progress_bar(self)
	
func increase_meter(amount) -> void:
	if self.value < self.max_value:
		self.value += amount

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
