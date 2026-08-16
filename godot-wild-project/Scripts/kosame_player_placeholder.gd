extends CharacterBody3D


@onready var inventory_ui: CanvasLayer = $InventoryUI
@onready var inventory_item: Node3D = $InventoryItem


func _ready() -> void:
	pass


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Inventory"):
		inventory_ui.visible = !inventory_ui.visible
		#get_tree().paused = !get_tree().paused 
