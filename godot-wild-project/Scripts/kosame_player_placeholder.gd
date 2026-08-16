extends CharacterBody3D


@onready var inventory_ui: CanvasLayer = $InventoryUI


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Inventory"):
		inventory_ui.visible = !inventory_ui.visible
		#get_tree().paused = !get_tree().paused 
