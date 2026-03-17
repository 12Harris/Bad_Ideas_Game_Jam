extends Area2D
class_name BusArea

enum Type {XZ, YZ, XY}

@export var type:Type

var distance_points :Array[DistancePoint] = []
var interpolation_steps = 1000

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	distance_points.append(get_node("DistancePoints/BL"))
	distance_points.append(get_node("DistancePoints/BR"))
	distance_points.append(get_node("DistancePoints/TR"))
	distance_points.append(get_node("DistancePoints/TL"))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func calculate_point(point_2d:Vector2):
	var x = 0.0
	var y = 0.0
	var z = 0.0
	var screen_dist_y:float = distance_points[0].screen_direction_to(distance_points[3].global_position).y
	var q = (distance_points[3].global_position.y - distance_points[0].global_position.y)/ distance_points[3].global_position.y
	var step = screen_dist_y/interpolation_steps
	var screen_dist_to_point_y = -distance_points[0].screen_direction_to(point_2d).y
	
	var start = distance_points[0].global_position
	var current = start
	while(current.y > point_2d.y):
		current
	
	if type == Type.XZ:
		z = distance_points[0].location
		
