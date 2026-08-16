class_name InteractionUI
extends CanvasLayer


@export var hover_panel: Control
@export var name_label: Label

@export var cursor_offset: Vector2 = Vector2(18.0, 18.0)


func _ready() -> void:
	if hover_panel != null:
		hover_panel.visible = false


func _process(_delta: float) -> void:
	if hover_panel.visible:
		hover_panel.position = (
			get_viewport().get_mouse_position()
			+ cursor_offset
		)


func show_npc_name(npc_name: String) -> void:
	name_label.text = npc_name
	hover_panel.visible = true


func hide_npc_name() -> void:
	hover_panel.visible = false
