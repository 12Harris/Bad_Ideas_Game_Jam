class_name MiniGame3
extends MiniGame

var stage: int = 0
var retries = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	Game_Manager.register_minigame(self)
	_inventory_ui.on_item_selected.connect(on_item_selected)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		var btn = event.as_text()
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !running:
		return
		
func on_item_selected(index):
	if running and index == 2:
		start()
		
