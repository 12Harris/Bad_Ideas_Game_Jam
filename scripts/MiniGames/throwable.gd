class_name Throwable
extends Node

@export var _mesh:RigidBody3D
@export var _trajectory: BezierCurve
@export var _max_speed : float
@export var _min_speed: float
var _speed:float
var initial_pos :Vector3 = Vector3.ZERO
var _is_flying:bool = false
var destination_pos:Vector3 = Vector3(0,-1,0)
var _visited_seats = 0
var fall_velocity: float = -1
var distance_fallen_this_frame:float = 0
var _grounded = false
var _collided = false
var _pitch_angle = 0
var _yaw_angle = 0
var min_flight_distance = 20
var max_flight_distance = 350
var flight_distance = min_flight_distance
var enabled = false
var straight : Vector3
var charge_force:float = 0

#trajectory curve modifiers:
var t1:float
var t2:float
var t3:float
var calculate_lookat:bool = true
var pitch_start_angle = -0.2
var yaw_start_angle = -1.1
var pitch_multiplier = 1
var yaw_multiplier = 1

signal lerp_to_point_finished
signal on_landed
signal on_thrown

func _ready() -> void:
	_speed = _max_speed
	_mesh.visible = false
	initial_pos = _mesh.global_position
	flight_distance = max_flight_distance

func _process(delta: float) -> void:
	
	if initial_pos == Vector3.ZERO:
		return
		
	_mesh.visible = enabled
	
	if !_is_flying:
		if Game_Manager.mouse_pos.y < 540:
			_pitch_angle =  pitch_start_angle +((540-Game_Manager.mouse_pos.y)/270)* pitch_multiplier
		elif  Game_Manager.mouse_pos.y > 540 and Game_Manager.mouse_pos.y < 1080:
			_pitch_angle =  pitch_start_angle +((540-Game_Manager.mouse_pos.y)/270)* pitch_multiplier	
			
		if Game_Manager.mouse_pos.x > 960:
			_yaw_angle = yaw_start_angle+((1440-Game_Manager.mouse_pos.x)/480)* yaw_multiplier
		elif  Game_Manager.mouse_pos.x < 960 and Game_Manager.mouse_pos.x > 480:
			_yaw_angle = yaw_start_angle+((1440-Game_Manager.mouse_pos.x)/480)* yaw_multiplier
		
		
func _physics_process(delta):
	if !_is_flying:
		return
	
	var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
	
	if !_grounded:
		
		if fall_velocity > -1:
		
			fall_velocity += gravity * delta * 0.5
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


func throw():
	on_thrown.emit()
	_is_flying = true
	#calculate_plane_trajectory()
	#var step = (destination_pos  - _mesh.global_position)/50.0
	var dir = (destination_pos  - _mesh.global_position).normalized()
	print("dest pos: ", destination_pos)
	var cross = (dir.cross(Vector3.RIGHT)).normalized()
	if cross.y < 0:
		cross *=-1
	
	print("cross y: ", cross.y)
			
	straight = initial_pos
	var i = 1
	while !_grounded and !_collided and i < _trajectory.positions.size():
		var delta_y = _trajectory.positions[i].y - _trajectory.positions[i-1].y
		var delta_x =  _trajectory.positions[i].x - _trajectory.positions[i-1].x
		straight += dir*delta_x+ cross*delta_y*0.01
		#print("lookat: ", straight+cross*delta_y*0.03)
		#_mesh.look_at(straight+Vector3.UP*delta_y*0.03)
		#await lerp_to_point(straight+cross*delta_y*0.03)
		print("cross: ", cross)
		await lerp_to_point(straight)
		i += 1
	if !_collided: 
		print("completed path")
	fall_velocity = 0
	
func lerp_to_point(end):
	var elapsed = 0
	var start_pos = _mesh.global_position
	#var duration = (1/_speed*10) * (destination_pos-initial_pos).length()*0.1
	var duration = (1/_speed*10) * (end-start_pos).length()*0.2
	while(elapsed < duration and !_grounded and !_collided):
		elapsed += get_process_delta_time()
		_mesh.global_position = start_pos.lerp(end,elapsed/duration)
		_mesh.look_at(straight)
		await get_tree().process_frame
		#await G_Utils.wait(0.1)

func calculate_trajectory(use_mouse:bool = false):
	
	print("use mouse: ", use_mouse)
	
	_trajectory.p0 = Game_Manager.camera.unproject_position(_mesh.global_position)
	var from = _mesh.global_position
	destination_pos = Vector3.ZERO
	var mouse_pos = Game_Manager._sub_viewport_2.get_mouse_position()
	if !use_mouse:
		destination_pos = from  + (Vector3.FORWARD.rotated(Vector3.RIGHT,_pitch_angle) \
							+ Vector3.FORWARD.rotated(Vector3.UP,_yaw_angle))*100

	else:
		print("MP: ", mouse_pos)
		var camera = Game_Manager._sub_viewport_2.get_node("Camera3D")
		var ray_start = camera.project_ray_origin(mouse_pos)
		var ray_end = ray_start + camera.project_ray_normal(mouse_pos)*2000 # 2000 is distance
		print("RE: ", ray_end) 
			
		var space_state = camera.get_world_3d().direct_space_state
		var query = PhysicsRayQueryParameters3D.create(ray_start, ray_end)
		query.collide_with_areas = true
		query.collide_with_bodies = true
		query.collision_mask = 0xFFFFFFFF
		var result = space_state.intersect_ray(query)

		if result:
			destination_pos = result.position
		else:
			print("no hit!")

	var p1 = Game_Manager.camera.unproject_position(from)
	#var p2 = Game_Manager.camera.unproject_position(result.position)
	var p2 = Game_Manager.camera.unproject_position(destination_pos)
	
	var dir3d = destination_pos - from
	max_flight_distance = dir3d.length()
	flight_distance = min_flight_distance + (max_flight_distance-min_flight_distance)*(charge_force/100)
	print("min flight distance: ", flight_distance, " max: ", max_flight_distance )

	#_trajectory.p1 = _trajectory.p0 + Vector2.RIGHT * flight_distance*0.33-Vector2.UP*flight_distance*t1
	#_trajectory.p2 = _trajectory.p0 + Vector2.RIGHT * flight_distance *0.66-Vector2.UP*flight_distance*t1
	#_trajectory.p3 = _trajectory.p0 + Vector2.RIGHT * flight_distance -Vector2.UP*flight_distance *t3

	_trajectory.p1 = _trajectory.p0 + Vector2.RIGHT * max_flight_distance*0.33-Vector2.UP*max_flight_distance*t1
	_trajectory.p2 = _trajectory.p0 + Vector2.RIGHT * max_flight_distance *0.66-Vector2.UP*max_flight_distance*t1
	_trajectory.p3 = _trajectory.p0 + Vector2.RIGHT * max_flight_distance + 5*Vector2.RIGHT+Vector2.UP*max_flight_distance * (max_flight_distance/flight_distance)
	
	_trajectory.calculate()
	
	var dir = (destination_pos  - _mesh.global_position).normalized()
	var straight = initial_pos
	var delta_y = _trajectory.positions[1].y - _trajectory.positions[0].y
	var delta_x =  _trajectory.positions[1].x - _trajectory.positions[0].x
	straight += dir * delta_x
	
	if calculate_lookat:
		_mesh.look_at(straight+Vector3.UP*delta_y*0.02)

func _on_collision_occured(body: Node3D) -> void:
	
	if !enabled:
		print("not enabled...")
	if !enabled:
		return
		
	if body == _mesh:
		_mesh.rotation.x = -1.2
		_collided = true

func _on_ground_collision_occured(body: Node3D) -> void:
	
	if !enabled:
		return
		
	if body == _mesh:
		_grounded = true
		on_landed.emit()
		await G_Utils.wait(0.5)
		_mesh.visible = false
		print("ground collision!")
	
func get_pos():
	return _mesh.global_position
	
func reset():
	charge_force = 0
	enabled = true
	_mesh.global_position = initial_pos
	_mesh.visible = true
	_grounded = false
	_collided = false
	_visited_seats = 0
	_is_flying = false
	_mesh.rotation.x = 0
	flight_distance = min_flight_distance
	_speed = _min_speed
	for i in range(4):
		Game_Manager.bus_seats_left[i].get_node("Mesh").visible = false
		Game_Manager.bus_seats_right[i].get_node("Mesh").visible = false
	
	fall_velocity = -1
