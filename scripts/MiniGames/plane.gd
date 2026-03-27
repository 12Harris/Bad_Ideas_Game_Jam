extends Node3D
class_name PaperPlane

@export var _trajectory: BezierCurve
@export var _max_speed : float
@export var _min_speed: float
var _speed:float
@export var _mesh:RigidBody3D
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
var update_collision = false
var enabled = false
var straight : Vector3

signal lerp_to_point_finished
signal on_entered_target_area(index)
signal on_landed
signal on_thrown

func _ready() -> void:
	print("plane ready")
	_speed = _max_speed
	_mesh.visible = false
	initial_pos = _mesh.global_position
	print("initial pos: ", initial_pos)
	
func _process(delta: float) -> void:
	
	if initial_pos == Vector3.ZERO:
		return
		
	_mesh.visible = enabled
	
	if !_is_flying:
		if Game_Manager.mouse_pos.y < 540:
			_pitch_angle =  -0.2+((540-Game_Manager.mouse_pos.y)/270)* 1
		elif  Game_Manager.mouse_pos.y > 540 and Game_Manager.mouse_pos.y < 1080:
			_pitch_angle =  -0.2+((540-Game_Manager.mouse_pos.y)/270)* 1	
			
		if Game_Manager.mouse_pos.x > 960:
			_yaw_angle = -1.1+((1440-Game_Manager.mouse_pos.x)/480)* 1
		elif  Game_Manager.mouse_pos.x < 960 and Game_Manager.mouse_pos.x > 480:
			_yaw_angle = -1.1+((1440-Game_Manager.mouse_pos.x)/480)* 1
		
		calculate_plane_trajectory()
	
	#if fall_velocity == -1 and _is_flying:
		#_mesh.look_at(straight)
	
func _input(event):
	
	if !enabled:
		return
	
	if event is InputEventKey and event.pressed:
		var keycode = event.as_text_physical_keycode()	
		
		if keycode == "F":
			if flight_distance < max_flight_distance:
				flight_distance+=2.5
			if _speed < _max_speed:
				_speed += 0.1
	
			calculate_plane_trajectory()
	
	elif event is InputEventKey and event.is_released():
		var keycode = event.as_text_physical_keycode()
		if keycode == "F":
			throw_plane()
			on_thrown.emit()
			
func _physics_process(delta):
	if !_is_flying:
		return
	
	var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
	
	if !_grounded:
		
		if fall_velocity > -1:
		
			if !_collided:
				fall_velocity += gravity * delta
			else:
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
			
func throw_plane():
	_is_flying = true
	#calculate_plane_trajectory()
	#var step = (destination_pos  - _mesh.global_position)/50.0
	var dir = (destination_pos  - _mesh.global_position).normalized()
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
	
	#_mesh.gravity_scale = 1.0
	#_mesh.freeze = false

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

func calculate_plane_trajectory():
	
	print("calc pt?")
	
	_trajectory.p0 = Game_Manager.camera.unproject_position(_mesh.global_position)
	var from = _mesh.global_position
	destination_pos = from  + (Vector3.FORWARD.rotated(Vector3.RIGHT,_pitch_angle) \
							+ Vector3.FORWARD.rotated(Vector3.UP,_yaw_angle))*flight_distance
		
	#print("Dest Pos: ", destination_pos)
	var p1 = Game_Manager.camera.unproject_position(from)
	#var p2 = Game_Manager.camera.unproject_position(result.position)
	var p2 = Game_Manager.camera.unproject_position(destination_pos)

	var dir3d = destination_pos - from
	var dir2d = p2-p1
	var t2 = 4000
	var t1 = t2 * 0.25
	_trajectory.p1 = _trajectory.p0 + Vector2.RIGHT * dir3d.length()*0.33-Vector2.UP*dir3d.length()*10
	_trajectory.p2 = _trajectory.p0 + Vector2.RIGHT * dir3d.length()*0.66-Vector2.UP*dir3d.length()*5
	#_trajectory.p3 = _trajectory.p0 + Vector2.RIGHT * dir3d.length() + ((220.0-(flight_distance-min_flight_distance))/180.0)*Vector2.UP * t2
	_trajectory.p3 = _trajectory.p0 + Vector2.RIGHT * dir3d.length()-Vector2.UP*dir3d.length()*-400
	_trajectory.calculate()
	
	var dir = (destination_pos  - _mesh.global_position).normalized()
	var straight = initial_pos
	var delta_y = _trajectory.positions[1].y - _trajectory.positions[0].y
	var delta_x =  _trajectory.positions[1].x - _trajectory.positions[0].x
	straight += dir * delta_x
	_mesh.look_at(straight+Vector3.UP*delta_y*0.02)
	#_mesh.look_at(_mesh.global_position + dir * delta_x*0.16 + Vector3.UP*delta_y*0.16)
	
#func initialize():
	#global_position = initial_pos

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

func _on_collision_occured(body: Node3D) -> void:
	
	if body == _mesh:
		_mesh.rotation.x = -1.2
		_collided = true

func _on_ground_collision_occured(body: Node3D) -> void:
	
	#if update_collision: return # Skip if already running
	
	#update_collision = true
	if body == _mesh:
		_grounded = true
		on_landed.emit()
		await G_Utils.wait(0.5)
		_mesh.visible = false
		print("ground collision!")
		#update_collision = false

func get_pos():
	return _mesh.global_position
	
func _on_plane_target_area_entered(body: Node3D) -> void:
	on_entered_target_area.emit(0)
	print("entered target area!!!!")

func _on_plane_target_area_2_entered(body: Node3D) -> void:
	#on_entered_target_area.emit(1)
	pass

func _on_plane_target_area_exited(body: Node3D) -> void:
	#on_entered_target_area.emit(-1)
	print("exited target area!!!!")

func _on_plane_target_area_2_exited(body: Node3D) -> void:
	#on_entered_target_area.emit(-2)
	pass
	
func show_plane_over_player():
	_mesh.get_node("Sprite3D").material_override.render_priority = 2

func show_plane_behind_player():
	_mesh.get_node("Sprite3D").material_override.render_priority = 0

func reset():
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
