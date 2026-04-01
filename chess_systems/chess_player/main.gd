extends Node
## enums
## consts
## exports
## public vars
var tilemap_scene = preload("res://chess_objects/board/main.gd")
var cam_movement_velocity:Vector2 = Vector2.ZERO
var cam_zoom_velocity:float = 0.0
## private vars
## onready vars
# obj_ for node refrences
## built-in override methods

func _ready() -> void:
	
	pass 

func _physics_process(delta: float) -> void:
	_mouse_buttons(delta)
	_camera_movement(delta)
	_camera_zoom(delta)

func _mouse_buttons(delta) -> void:
	# Mouse Inputs
	if InputEventMouse:
		var mouse_coords:Vector2 = get_viewport().get_mouse_position()
		if Input.is_action_just_released(&"_input_mouse_left"):
			print("Left Mouse click detected at: ",mouse_coords)
		if Input.is_action_just_released(&"_input_mouse_right"):
			print("Right Mouse click detected at: ",mouse_coords)
		if Input.is_action_just_released(&"_input_mouse_middle"):
			print("Middle Mouse click detected at: ",mouse_coords)

func _camera_movement(delta) -> void:
	# Camera Movement
	var direction:Vector2 = Vector2.ZERO
	if Input.is_action_pressed(&"_input_up") and !Input.is_action_pressed(&"_input_down"): direction.y = -1
	if Input.is_action_pressed(&"_input_down") and !Input.is_action_pressed(&"_input_up"): direction.y = +1 
	if Input.is_action_pressed(&"_input_left") and !Input.is_action_pressed(&"_input_right"): direction.x = -1 
	if Input.is_action_pressed(&"_input_right") and !Input.is_action_pressed(&"_input_left"): direction.x = +1
	if direction == Vector2.ZERO:return # No movement
	Scripts.CHESS_CAMERA2D.move_camera(direction,delta)

func _camera_zoom(delta) -> void:
	# Camera Zoom
	var direction:float = 0
	if Input.is_action_just_released(&"_input_mouse_scroll_up"):
		direction = 1
	if Input.is_action_just_released(&"_input_mouse_scroll_down"):
		direction = -1
	if !direction:return
	Scripts.CHESS_CAMERA2D.zoom_camera(direction,delta)

## public methods

## private methods
