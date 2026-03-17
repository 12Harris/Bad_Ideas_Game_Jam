class_name MiniGame2
extends MiniGame

@export var _plane:PaperPlane

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	clout_levels_file = "mini_game_1.txt"
	super._ready()
	Game_Manager.register_minigame(self)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		var btn = event.as_text()
		#if btn == "Left Mouse Button" and Inventory_Item.selected is C:
		if btn == "Left Mouse Button":
			_plane.throw_plane()
			
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _physics_process(delta):
	pass

func start():
	super.start()
	print("start minigame 2")
	
