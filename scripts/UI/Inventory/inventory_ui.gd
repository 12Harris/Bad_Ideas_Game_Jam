# InventoryUI.gd
class_name InventoryUI
extends CanvasLayer
 
@onready var grid_container = $Panel/GridContainer
@export var item_data : Array[ItemData] = []
var slots = []
var inventory_items : Array[Inventory_Item]
var inventory_item_detection_area : Array[Area2D] = []
var selectedSlot = null

func _ready():
	# Connect to the inventory's signal.
	# Now, whenever an item is added or removed, update_ui() is called.
	G_Inventory.inventory_changed.connect(update_ui)
	
	await get_tree().process_frame
	slots = grid_container.get_children()
	inventory_items = G_Inventory._items
	
	inventory_item_detection_area.append(get_node("Panel/GridContainer/InventorySlot/Area2D"))
	inventory_item_detection_area.append(get_node("Panel/GridContainer/InventorySlot2/Area2D"))
	inventory_item_detection_area.append(get_node("Panel/GridContainer/InventorySlot3/Area2D"))
	inventory_item_detection_area.append(get_node("Panel/GridContainer/InventorySlot4/Area2D"))
	inventory_item_detection_area.append(get_node("Panel/GridContainer/InventorySlot5/Area2D"))
	inventory_item_detection_area.append(get_node("Panel/GridContainer/InventorySlot6/Area2D"))
	
	await get_tree().process_frame
	
	inventory_item_detection_area[0].mouse_entered.connect(inventory_item1_selected)
	inventory_item_detection_area[1].mouse_entered.connect(inventory_item2_selected)
	inventory_item_detection_area[2].mouse_entered.connect(inventory_item3_selected)
	inventory_item_detection_area[3].mouse_entered.connect(inventory_item4_selected)
	inventory_item_detection_area[4].mouse_entered.connect(inventory_item5_selected)
	inventory_item_detection_area[5].mouse_entered.connect(inventory_item6_selected)

	print("AREA: ", inventory_item_detection_area[0].name)
	# Initial UI update.
	update_ui()
	
func update_ui():
 
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

func inventory_item1_selected():
	selectedSlot = slots[0]
	
func inventory_item2_selected():
	selectedSlot = slots[1]

func inventory_item3_selected():
	selectedSlot = slots[2]
	
func inventory_item4_selected():
	selectedSlot = slots[3]
	
func inventory_item5_selected():
	selectedSlot = slots[4]
	
func inventory_item6_selected():
	selectedSlot = slots[5]

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_released():
		#if event.pressed:
		var btn = event.as_text()
		if btn == "Left Mouse Button":
			if selectedSlot != null:
				var index = slots.find(selectedSlot)
				if index < inventory_items.size():
					Inventory_Item.selected = inventory_items[index]
