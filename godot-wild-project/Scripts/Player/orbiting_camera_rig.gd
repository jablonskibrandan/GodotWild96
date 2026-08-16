class_name OrbitCameraRig
extends Node3D


@export_category("Target")

@export var target: Node3D
@export var pitch_pivot: Node3D
@export var camera: Camera3D


@export_category("Rotation")

## Horizontal rotation speed when pressing A/D.
@export var yaw_speed: float = 90.0

## Vertical rotation speed when pressing W/S.
@export var pitch_speed: float = 60.0

## Lowest angle the camera can reach.
@export_range(-89.0, 0.0, 1.0)
var minimum_pitch_degrees: float = -65.0

## Highest / most overhead angle.
@export_range(-89.0, 0.0, 1.0)
var maximum_pitch_degrees: float = -20.0


@export_category("Zoom")

@export var default_distance: float = 10.0

@export var minimum_distance: float = 4.0

@export var maximum_distance: float = 18.0

@export var zoom_step: float = 1.0

@export var zoom_smoothing: float = 10.0


@export_category("Height")

## Base point above the player's feet that the camera orbits around.
@export var target_height: float = 1.5

## Camera is never allowed below this world-space height
## relative to the player's position. This is done so we don't get any funky-ness
@export var minimum_camera_height: float = 2.0


@export_category("Following")

@export var follow_smoothing: float = 12.0


var current_distance: float
var desired_distance: float

var current_pitch: float


func _ready() -> void:
	current_distance = default_distance
	desired_distance = default_distance

	current_pitch = deg_to_rad(-40.0)

	if pitch_pivot != null:
		pitch_pivot.rotation.x = current_pitch

	if camera != null:
		camera.position = Vector3(
			0.0,
			0.0,
			current_distance
		)


func _physics_process(delta: float) -> void:
	if target == null:
		return

	_follow_target(delta)
	_handle_rotation(delta)
	_update_zoom(delta)
	_enforce_minimum_height()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				desired_distance -= zoom_step

			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				desired_distance += zoom_step

			desired_distance = clamp(
				desired_distance,
				minimum_distance,
				maximum_distance
			)


func _follow_target(delta: float) -> void:
	var desired_position := target.global_position
	desired_position.y += target_height

	global_position = global_position.lerp(
		desired_position,
		1.0 - exp(-follow_smoothing * delta)
	)


func _handle_rotation(delta: float) -> void:
	var yaw_input := Input.get_axis(
		"camera_left",
		"camera_right"
	)

	var pitch_input := Input.get_axis(
		"camera_up",
		"camera_down"
	)

	rotation.y -= deg_to_rad(yaw_speed) * yaw_input * delta

	current_pitch += (
		deg_to_rad(pitch_speed)
		* pitch_input
		* delta
	)

	current_pitch = clamp(
		current_pitch,
		deg_to_rad(minimum_pitch_degrees),
		deg_to_rad(maximum_pitch_degrees)
	)

	pitch_pivot.rotation.x = current_pitch


func _update_zoom(delta: float) -> void:
	current_distance = lerp(
		current_distance,
		desired_distance,
		1.0 - exp(-zoom_smoothing * delta)
	)

	camera.position.z = current_distance


func _enforce_minimum_height() -> void:
	if target == null or camera == null:
		return

	var minimum_y := (
		target.global_position.y
		+ minimum_camera_height
	)

	if camera.global_position.y < minimum_y:
		var height_difference := (
			minimum_y
			- camera.global_position.y
		)

		global_position.y += height_difference
