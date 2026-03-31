class_name OutDoorEnvironment
extends Node3D

var _trees: Array[OutDoorTree] = []

@export var _startpos:Node3D
var _spawnInterval = 1.5
var _timer = 0.0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_timer+= delta
	if _timer > _spawnInterval:
		var xmin = randf_range(-150, -50)
		var xmax = randf_range(50, 150)
		
		var randx = randi()%2
		
		if randx == 0:
			randx = xmin
		else:
			randx = xmax
			
		var randz = randf_range(0,-300)
		_spawn_tree(_startpos.global_position + Vector3(randx,0,randz))
		_timer = 0

func _spawn_tree(location:Vector3):
	var tree = preload("res://scenes/Tree.tscn")
	var instance = tree.instantiate()
	add_child(instance)
	instance.global_position = location
	_trees.append(instance)
	(instance as OutDoorTree).move()

func _on_bus_area_body_entered(body: Node3D) -> void:
	pass

func _on_bus_area_body_exited(body: Node3D) -> void:
	if body is OutDoorTree:
		(body as OutDoorTree).stop_moving()
		_trees.erase(body)
