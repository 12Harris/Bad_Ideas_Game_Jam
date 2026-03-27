extends Node2D
class_name BezierCurve

var p0:Vector2 = Vector2.ZERO
var p1:Vector2
var p2:Vector2
var p3:Vector2
var _angle:float = 0

var positions = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in range(50):
		positions.append(Vector2.ZERO)
		print("Init bezier ", positions.size())
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_angle(angle:float):
	_angle = angle
	
func calculate():
	if p0 == Vector2.ZERO:
		return
	
	positions[0] = p0
	var old_pos = p0
	var old_pos_shifted = old_pos
	for i in range(1, 50):
		var pos = G_Utils._cubic_bezier(p0,p1,p2,p3,float(i*2)/100.0)
		var line = pos - old_pos
		line = line.rotated(-_angle)
		old_pos = pos
		old_pos_shifted = old_pos_shifted+line
		positions[i] = old_pos_shifted
		#print("positions i: ", positions[i])
