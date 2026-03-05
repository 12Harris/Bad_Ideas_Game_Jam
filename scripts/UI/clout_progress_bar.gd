extends ProgressBar
class_name CloutProgressBar

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	UI_Manager.register_progress_bar(self)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func increase_meter(amount) -> void:
	if self.value < self.max_value:
		self.value += amount
