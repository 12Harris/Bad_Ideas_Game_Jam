class_name PaperPlane
extends Throwable
signal on_entered_target_area(index)


func _ready() -> void:
	super._ready()
	t1 = 20
	t2 = 5
	t3 = -20
	pitch_start_angle = -0.9
	pitch_multiplier = 1
	
func _process(delta: float) -> void:
	super._process(delta)
	if !enabled or _is_flying:
		return
	
	if Input.is_action_pressed("Left Mouse"):
		if charge_force < 100:
			charge_force+=0.25
			UI_Manager.inc_throw_force_meter(0.25)
			#flight_distance = 50 + (charge_force/100)*150
			print ("FDP: ", flight_distance )
			print ("charge force: ", charge_force)
			
	print("huch")
	calculate_trajectory()
	
	
func _input(event):
	pass
	#if event is InputEventKey and event.pressed:
		#var keycode = event.as_text_physical_keycode()	
		#
		#if keycode == "F":
			#if flight_distance < max_flight_distance:
				#flight_distance+=2.5
			#if _speed < _max_speed:
				#_speed += 0.1
	#
			#calculate_plane_trajectory()
	
	#elif event is InputEventKey and event.is_released():
		#var keycode = event.as_text_physical_keycode()
		#if keycode == "F":
			#throw_plane()
			#on_thrown.emit()
			
func _physics_process(delta):
	super._physics_process(delta)
	
func reset():
	super.reset()
	UI_Manager.reset_throw_force_meter()
	
func _on_plane_target_area_entered(body: Node3D) -> void:
	on_entered_target_area.emit(0)
	print("entered target area!!!!")
