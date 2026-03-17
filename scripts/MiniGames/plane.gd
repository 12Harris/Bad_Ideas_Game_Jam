extends Node3D
class_name PaperPlane

@export var _trajectory: BezierCurve
@export var _speed:float = 10
@export var _mesh:RigidBody3D
var initial_pos :Vector3
var _max_speed : float
var _is_flying:bool = false
var destination_pos:Vector3 = Vector3(0,-1,0)
var _visited_seats = 0
var fall_velocity: float = -1
var distance_fallen_this_frame:float = 0
var _grounded = false
signal lerp_to_point_finished


func _ready() -> void:
	print("plane ready")
	
func _process(delta: float) -> void:
	pass
	
func _input(event):
	pass

func _physics_process(delta):
	if !_is_flying:
		return
	
	var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
	
	if !_grounded and fall_velocity > -1:
		fall_velocity += gravity * delta
		distance_fallen_this_frame = fall_velocity*delta
		_mesh.global_position -= Vector3.UP*distance_fallen_this_frame
		var nearest_seat = get_nearest_seat()
		if nearest_seat > -1:
			Game_Manager.bus_seats_left[get_nearest_seat()].get_node("Mesh").visible = true
			Game_Manager.bus_seats_right[get_nearest_seat()].get_node("Mesh").visible = true
		else:
			print("nearest seat < 0")
			
	elif _visited_seats < 4 and _mesh.global_position.z < Game_Manager.bus_seats_left[_visited_seats].global_position.z-1 \
		and _mesh.global_position.x < 0:
		Game_Manager.bus_seats_left[_visited_seats].get_node("Mesh").visible = true
		_visited_seats = _visited_seats+1

	elif _visited_seats < 4 and _mesh.global_position.z < Game_Manager.bus_seats_right[_visited_seats].global_position.z-1 \
		and _mesh.global_position.x > 0:	
		Game_Manager.bus_seats_right[_visited_seats].get_node("Mesh").visible = true
		_visited_seats = _visited_seats+1

		
func throw_plane():
	_is_flying = true
	initial_pos = _mesh.global_position
	calculate_plane_trajectory()
	print("ts ",_trajectory.positions.size() )
	var step = (destination_pos  - _mesh.global_position)/50.0
	var straight = initial_pos
	print("step ", step)
	for i in range(1,_trajectory.positions.size()):
		var delta_y =_trajectory.positions[i].y - _trajectory.positions[0].y
		print("delta y: ", delta_y)
		straight += step 
		_mesh.look_at(straight+Vector3.UP*delta_y*0.01)
		await lerp_to_point(straight+Vector3.UP*delta_y*0.01,_trajectory.positions[i-1], _trajectory.positions[i])
	fall_velocity = 0
	
	#_mesh.gravity_scale = 1.0
	#_mesh.freeze = false

func lerp_to_point(end, start_2d, end_2d):
	var elapsed = 0
	var duration = (1/_speed) * (destination_pos-initial_pos).length()*0.05
	var start_pos = _mesh.global_position
	while(elapsed < duration):
		elapsed += get_process_delta_time()
		_mesh.global_position = start_pos.lerp(end,elapsed/duration)
		await get_tree().process_frame
	
func calculate_plane_trajectory():
	#_debug_line.clear_points()
	_trajectory.p0 = Game_Manager.camera.unproject_position(_mesh.global_position)
	var mouse_pos = get_viewport().get_mouse_position()
	var ray_from = Game_Manager.camera.project_ray_origin(mouse_pos)
	#var ray_from = _mesh.global_position
	var ray_to = ray_from + Game_Manager.camera.project_ray_normal(mouse_pos) *  1000 # 1000 is max range
	#var ray_to = ray_from + Game_Manager.camera.project_ray_normal(mouse_pos) * 1000 # 1000 is max range
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(ray_from, ray_to)
	var result = space_state.intersect_ray(query)
	
	if result:
		print("Intersected: ", result.collider.name)
		destination_pos = result.position
		#print("Dest Pos: ", destination_pos)
		var p1 = Game_Manager.camera.unproject_position(ray_from)
		var p2 = Game_Manager.camera.unproject_position(result.position)

		var dir3d = result.position - ray_from
		var dir2d = p2-p1
		_trajectory.p1 = _trajectory.p0 + Vector2.RIGHT * dir3d.length()*0.2-Vector2.UP*dir3d.length()*6
		_trajectory.p2 = _trajectory.p0 + Vector2.RIGHT * dir3d.length()*0.4-Vector2.UP*dir3d.length()*2
		_trajectory.p3 = _trajectory.p0 + Vector2.RIGHT * dir3d.length()
		
		_trajectory.calculate()
		
	else:
		print("No Intersection!")
	
func initialize():
	initial_pos = Vector3(2.061,-1.964,-1.874)
	global_position = initial_pos


func _on_floor_3d_body_entered(body: Node3D) -> void:
	if body == _mesh:
		_grounded = true
		_mesh.freeze = true

func _on_front_platform_body_entered(body: Node3D) -> void:
	if body == _mesh:
		_grounded = true
		_mesh.freeze = true

func _on_front_platform_2_area_body_entered(body: Node3D) -> void:
	if body == _mesh:
		_grounded = true
		_mesh.freeze = true

func _on_front_seat_area_body_entered(body: Node3D) -> void:
	if body == _mesh:
		_grounded = true
		_mesh.freeze = true
		print("LANDED")


func get_nearest_seat() -> int:

	var foundIndex = -1
	if _mesh.global_position.x < 0:
		for i in range(4):
			if _mesh.global_position.z < Game_Manager.bus_seats_left[i].global_position.z-1:
				foundIndex = i
	
	elif _mesh.global_position.x > 0:
		for i in range(4):
			if _mesh.global_position.z < Game_Manager.bus_seats_right[i].global_position.z-1:
				foundIndex = i
	
	return foundIndex


func _on_front_floor_area_body_entered(body: Node3D) -> void:
	if body == _mesh:
		_grounded = true
		_mesh.freeze = true
