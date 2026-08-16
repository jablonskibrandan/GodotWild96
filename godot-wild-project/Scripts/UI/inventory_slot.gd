extends Control

# Scene-Tree Node references
@onready var icon: Sprite2D = $InnerBorder/ItemIcon
@onready var name_label: Label = $DetailsPanel/Name_Label
@onready var type_label: Label = $DetailsPanel/Type_Label
@onready var item_effect: Label = $DetailsPanel/Item_Effect
@onready var quantity_label: Label = $InnerBorder/Quantity_Label
@onready var usage_panel: ColorRect = $UsagePanel
@onready var details_panel: ColorRect = $DetailsPanel


# Slot item
var item = null


# Show usage panel for player to use/remove item
func _on_item_button_pressed():
	if item != null:
		usage_panel.visible = !usage_panel.visible


# Show item details on hover enter
func _on_item_button_mouse_entered():
	if item != null:
		usage_panel.visible = false
		details_panel.visible = true
	print("a")

# Hide item details on hover exit
func _on_item_button_mouse_exited():
	details_panel.visible = false

# Default empty slot
func set_empty():
	icon.texture = null
	quantity_label.text = ""

# Set slot item with its values from the dictionary
func set_item(new_item):
	item = new_item
	icon.texture = item["texture"] 
	quantity_label.text = str(item["quantity"])
	name_label.text = str(item["name"])
	type_label.text = str(item["type"])
	if item["effect"] != "":
		item_effect.text = str("+ ", item["effect"])
	else: 
		item_effect.text = ""
