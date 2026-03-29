class_name FartBomb
extends Throwable

signal on_entered_target_area(index)

var inflated = false

func _ready() -> void:
	super._ready()
	t1 = 10
	t2 = 5
	t3 = -10
	flight_distance = min_flight_distance
	pitch_start_angle = 0.2
	yaw_start_angle = 0
	yaw_multiplier = 0.5
	
func _process(delta: float) -> void:
	super._process(delta)
	if _is_flying or !enabled:
		return
		
	print("enabled:: ", enabled)

	calculate_trajectory(true)
	
func _input(event):
	pass

func evaluate()->bool:
	return charge_force < 75
	
func charge():
	if charge_force < 100:
		charge_force += 1
		UI_Manager.inc_throw_force_meter(1)
		print("charge force: ", charge_force)
		#t1 = 40 - 25*(flight_distance/max_flight_distance)
		_speed = _min_speed + (_max_speed-_min_speed)*(charge_force/100)
		#flight_distance = min_flight_distance + (max_flight_distance-min_flight_distance)*(charge_force/100)
		if charge_force > 75 and !inflated:
			inflate()
			inflated = true
		
func explode():
	pass

func inflate():
	
	var mat = _mesh.get_node("Sprite3D").material_override
	mat.albedo_texture  = preload("res://assets/FartBomb/inflated-fart-bomb.png")
		
func _physics_process(delta):
	super._physics_process(delta)

func _on_fartbomb_target_area_entered(body: Node3D) -> void:
	on_entered_target_area.emit(0)

func reset():
	super.reset()
	inflated = false
	
	var mat = _mesh.get_node("Sprite3D").material_override
	mat.albedo_texture  = preload("res://assets/Inventory/Fart-bomb.png")
	UI_Manager.reset_throw_force_meter()
