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

func _input(event:InputEvent) -> void:
	# Mouse Inputs
	if InputEventMouse:
		var mouse_coords:Vector2 = get_viewport().get_mouse_position()
		#if Input.is_action_just_released(&"_input_mouse_left"):
			#print("Left Mouse click detected at: ",mouse_coords)
		if Input.is_action_just_released(&"_input_mouse_right"):
			print("Right Mouse click detected at: ",mouse_coords)
		if Input.is_action_just_released(&"_input_mouse_middle"):
			print("Middle Mouse click detected at: ",mouse_coords)

## public methods

## private methods
