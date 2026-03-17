class_name Inventory_Item

var id : int
var clout_req : int
var name : String
static var selected : Inventory_Item = null

func _init(id, clout, name) -> void:
	id = id
	clout_req = clout
	name = name
