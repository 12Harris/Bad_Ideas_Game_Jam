# InventoryUI.gd
extends CanvasLayer
 
@onready var grid_container = $Panel/GridContainer
@export var item_data : Array[ItemData] = []
 
func _ready():
	# Connect to the inventory's signal.
	# Now, whenever an item is added or removed, update_ui() is called.
	G_Inventory.inventory_changed.connect(update_ui)
	
	# Initial UI update.
	update_ui()
 
func update_ui():
	var slots = grid_container.get_children()
	var inventory_items : Array[Inventory_Item] = G_Inventory._items
 
	for i in range(slots.size()):
		var slot = slots[i]
		if i < inventory_items.size():
			# If there's an item for this slot, display it.
			var item = inventory_items[i]
			slot.get_node("TextureRect").texture = item_data[i].texture
			slot.get_node("Label").text = "1"
		else:
			# Otherwise, clear the slot.
			slot.get_node("TextureRect").texture = null
			slot.get_node("Label").text = "0"
