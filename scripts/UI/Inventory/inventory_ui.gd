# InventoryUI.gd
class_name InventoryUI
extends CanvasLayer
 
@onready var grid_container = $GridContainer
@export var item_data : Array[ItemData] = []
@export var _item_indicator:Sprite2D
var slots = []
var inventory_items : Array[Inventory_Item]
var inventory_item_detection_area : Array[Area2D] = []
var selectedSlot = null

signal on_item_selected(index)

func _ready():
	# Connect to the inventory's signal.
	# Now, whenever an item is added or removed, update_ui() is called.
	G_Inventory.inventory_changed.connect(update_ui)
	G_Inventory.inventory_removed.connect(update_ui_2)
	await get_tree().process_frame
	slots = grid_container.get_children()
	
	inventory_items = G_Inventory._items
	
	inventory_item_detection_area.append(get_node("GridContainer/InventorySlot/Area2D"))
	inventory_item_detection_area.append(get_node("GridContainer/InventorySlot2/Area2D"))
	inventory_item_detection_area.append(get_node("GridContainer/InventorySlot3/Area2D"))
	inventory_item_detection_area.append(get_node("GridContainer/InventorySlot4/Area2D"))

	await get_tree().process_frame
	
	inventory_item_detection_area[0].mouse_entered.connect(inventory_item1_selected)
	inventory_item_detection_area[1].mouse_entered.connect(inventory_item2_selected)
	inventory_item_detection_area[2].mouse_entered.connect(inventory_item3_selected)
	inventory_item_detection_area[3].mouse_entered.connect(inventory_item4_selected)

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
		else:
			# Otherwise, clear the slot.
			slot.get_node("TextureRect").texture = null

func update_ui_2(index):
 	
	var slot = slots[index]
	slot.get_node("TextureRect").texture = null
			
func inventory_item1_selected():
	selectedSlot = slots[0]
	
func inventory_item2_selected():
	selectedSlot = slots[1]

func inventory_item3_selected():
	selectedSlot = slots[2]
	
func inventory_item4_selected():
	selectedSlot = slots[3]
	
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		#if event.pressed:
		var btn = event.as_text()
		if btn == "Left Mouse Button":
			if selectedSlot != null and selectedSlot.get_node("TextureRect").texture != null:
				print("sel slot is valid")
				var index = slots.find(selectedSlot)
				if index < inventory_items.size():
					#if Inventory_Item.selected != inventory_items[index]:
					Inventory_Item.selected = inventory_items[index]
					on_item_selected.emit(index)
					print("item selected")

func show_item_indicator(index):
	print("slotindex: ", index)
	var offset = slots[index].global_position + Vector2.RIGHT*50 + Vector2.UP * 50
	_item_indicator.global_position = offset
	_item_indicator.visible = true
	
func hide_item_indicator():
	_item_indicator.visible = false
