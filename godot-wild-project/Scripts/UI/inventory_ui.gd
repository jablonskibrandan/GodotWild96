### Inventory_UI.gd

extends Control

# Scene-Tree Node references
@onready var inventory_grid: GridContainer = $InventoryGrid
const INVENTORY_SLOT = preload("uid://dwqw4wvqp21fq")


func _ready():
	var slot = INVENTORY_SLOT.instantiate()
	inventory_grid.add_child(slot)
	# Connect function to signal to update inventory UI
	Globals.inventory_updated.connect(_on_inventory_updated)
	_on_inventory_updated()

# Update inventory UI
func _on_inventory_updated():
	# Clear existing slots
	clear_grid_container()
	# Add slots for each inventory position
	for item in Globals.inventory:
		var slot = INVENTORY_SLOT.instantiate()
		inventory_grid.add_child(slot)
		if item != null:
			slot.set_item(item)
		else:
			slot.set_empty() 
				
# Clear inventory UI grid	
func clear_grid_container():
	while inventory_grid.get_child_count() > 0:
		var child = inventory_grid.get_child(0)
		inventory_grid.remove_child(child)
		child.queue_free()
