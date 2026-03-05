class_name Inventory
extends Node

#the unlockd inventory items
var _items: Array[Inventory_Item] = []
#the locked inventory items
var _lockedItems:Array[Inventory_Item] = []
var _player: Player
var _totalItems: int = 0

# A signal to notify the UI when the inventory changes.
signal inventory_changed

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	read_inventory_from_file()
	await get_tree().process_frame
	_player = Game_Manager.get_player()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func update() -> void:
	if _items.size() < _totalItems && _player.get_total_clout() > _lockedItems[0].clout_req:
		add_item(_lockedItems[0])
		_lockedItems.remove_at(0)
	
#Add Item to Inventory
func add_item(item : Inventory_Item):
	_items.append(item)
	print("item unlocked: " , item.name)
	inventory_changed.emit()

#Add inventory items from file
func read_inventory_from_file() -> void:
	var file = FileAccess.open("res://data/inventory.txt", FileAccess.READ)
	var content = file.get_as_text()
	content = content.split("\n")
	var content_size = content.size()
	for i in range(1,content_size-1):
		_totalItems += 1
		var line = content[i].split("\t")
		var id = int(line[0])
		var inventory_class = line[1]
		var exp_req = int(line[2])
		var item_name = line[3]
		inventory_class = "res://scripts/inventory/items/"+inventory_class+".gd"
		var inventory_script = load(inventory_class)
		
		var instance = inventory_script.new(id, exp_req, item_name)
		if exp_req == 0:
			_items.append(instance)
		else:
			_lockedItems.append(instance)
