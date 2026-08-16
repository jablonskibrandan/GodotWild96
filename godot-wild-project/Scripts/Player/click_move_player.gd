class_name ClickMovePlayer
extends CharacterBody3D


@export_category("Movement")

@export var move_speed: float = 5.0
@export var acceleration: float = 20.0
@export var stopping_distance: float = 0.15
@export var rotation_speed: float = 10.0

@export_category("Click Movement")

## Maximum distance that the mouse ray can travel. is this overkill? Maybe?
@export var ray_length: float = 2000.0


@export_category("Interaction")

@export var interaction_ui: InteractionUI

## Ground + NPC interaction layers.
@export_flags_3d_physics var mouse_collision_mask: int = 5


var hovered_npc: NPCInteractable

var click_requested: bool = false
var requested_click_position: Vector2

## Collision mask used for clickable colliders 
@export_flags_3d_physics var ground_collision_mask: int = 1

@export var camera: Camera3D
@export var move_marker: Node3D


var target_position: Vector3
var has_target: bool = false


func _ready() -> void:
	target_position = global_position

	if move_marker != null:
		move_marker.visible = false


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("move_to"):
		requested_click_position = (
			get_viewport().get_mouse_position()
		)

		click_requested = true


func _physics_process(delta: float) -> void:
	_update_hover()

	if click_requested:
		_handle_world_click(requested_click_position)
		click_requested = false

	_apply_gravity(delta)

	if has_target:
		_move_toward_target(delta)
	else:
		_slow_down(delta)

	move_and_slide()
	
func _raycast_mouse(
	screen_position: Vector2
) -> Dictionary:
	if camera == null:
		return {}

	var ray_origin := camera.project_ray_origin(
		screen_position
	)

	var ray_direction := camera.project_ray_normal(
		screen_position
	)

	var ray_end := (
		ray_origin
		+ ray_direction * ray_length
	)

	var query := PhysicsRayQueryParameters3D.create(
		ray_origin,
		ray_end,
		mouse_collision_mask
	)

	query.exclude = [get_rid()]

	query.collide_with_bodies = true
	query.collide_with_areas = true

	var space_state := (
		get_world_3d().direct_space_state
	)

	return space_state.intersect_ray(query)
	
	
func _update_hover() -> void:
	var mouse_position := get_viewport().get_mouse_position()
	var result := _raycast_mouse(mouse_position)

	var new_hovered_npc: NPCInteractable = null

	if not result.is_empty():
		new_hovered_npc = _get_npc_from_collider(result["collider"])

	if new_hovered_npc == hovered_npc:
		return

	hovered_npc = new_hovered_npc

	if interaction_ui == null:
		return

	if hovered_npc != null:
		interaction_ui.show_npc_name(hovered_npc.display_name)
	else:
		interaction_ui.hide_npc_name()
		
func _handle_world_click(
	screen_position: Vector2
) -> void:
	var result := _raycast_mouse(screen_position)

	if result.is_empty():
		return

	var npc := _get_npc_from_collider(result["collider"])

	if npc != null:
		npc.interact()
		return

	target_position = result["position"]
	has_target = true

	if move_marker != null:
		move_marker.global_position = target_position
		move_marker.visible = true


func _get_npc_from_collider(collider: Object) -> NPCInteractable:
	if collider is NPCInteractable:
		return collider

	if collider is Node:
		var current_node := collider as Node

		while current_node != null:
			if current_node is NPCInteractable:
				return current_node

			current_node = current_node.get_parent()

	return null


func _move_toward_target(delta: float) -> void:
	var flattened_target := Vector3(
		target_position.x,
		global_position.y,
		target_position.z
	)

	var offset := flattened_target - global_position
	var distance := offset.length()

	if distance <= stopping_distance:
		has_target = false

		velocity.x = move_toward(
			velocity.x,
			0.0,
			acceleration * delta
		)

		velocity.z = move_toward(
			velocity.z,
			0.0,
			acceleration * delta
		)

		if move_marker != null:
			move_marker.visible = false

		return

	var direction := offset.normalized()

	velocity.x = move_toward(
		velocity.x,
		direction.x * move_speed,
		acceleration * delta
	)

	velocity.z = move_toward(
		velocity.z,
		direction.z * move_speed,
		acceleration * delta
	)

	_rotate_toward_direction(direction, delta)


func _rotate_toward_direction(
	direction: Vector3,
	delta: float
) -> void:
	if direction.length_squared() <= 0.001:
		return

	var desired_yaw := atan2(direction.x, direction.z)

	rotation.y = lerp_angle(
		rotation.y,
		desired_yaw,
		rotation_speed * delta
	)


func _slow_down(delta: float) -> void:
	velocity.x = move_toward(
		velocity.x,
		0.0,
		acceleration * delta
	)

	velocity.z = move_toward(
		velocity.z,
		0.0,
		acceleration * delta
	)

func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= get_gravity().y * -1.0 * delta
	else:
		velocity.y = 0.0
