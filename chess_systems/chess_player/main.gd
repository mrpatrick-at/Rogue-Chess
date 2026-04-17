extends Node
## enums
## consts
## exports
## public vars
## private vars
## onready vars
@onready var esc_menu: Control = $"../ChessCamera/Foreground/EscMenu"
# obj_ for node refrences
## built-in override methods

func _ready() -> void:
	
	pass 

func _physics_process(delta: float) -> void:
	_mouse_buttons(delta)
	_camera_movement(delta)
	_camera_zoom(delta)



## public methods

## private methods

func _mouse_buttons(_delta:float) -> void:
	# Mouse Inputs
	if InputEventMouse:
		Scripts.SELECTION_MANAGER.reset_highlight()
		if !esc_menu.is_visible_in_tree():
			Scripts.SELECTION_MANAGER.highlight_tile()
		var mouse_coords:Vector2 = get_viewport().get_mouse_position()
		if Input.is_action_just_released(&"_input_mouse_left"):
			if Scripts.SELECTION_MANAGER.selected_tile:
				Scripts.SELECTION_MANAGER.select_destination_tile()
			Scripts.SELECTION_MANAGER.select_tile()
			print("Left Mouse click detected at: ",mouse_coords)
		if Input.is_action_just_released(&"_input_mouse_right"):
			print("Right Mouse click detected at: ",mouse_coords)
		if Input.is_action_just_released(&"_input_mouse_middle"):
			print("Middle Mouse click detected at: ",mouse_coords)

static func _camera_movement(delta:float) -> void:
	# Camera Movement
	var direction:Vector2 = Vector2.ZERO
	if Input.is_action_pressed(&"_input_up") and !Input.is_action_pressed(&"_input_down"): direction.y = -1
	if Input.is_action_pressed(&"_input_down") and !Input.is_action_pressed(&"_input_up"): direction.y = +1 
	if Input.is_action_pressed(&"_input_left") and !Input.is_action_pressed(&"_input_right"): direction.x = -1 
	if Input.is_action_pressed(&"_input_right") and !Input.is_action_pressed(&"_input_left"): direction.x = +1
	if direction == Vector2.ZERO:return # No movement
	Scripts.CHESS_CAMERA2D.move_camera(direction,delta)

static func _camera_zoom(delta:float) -> void:
	# Camera Zoom
	var direction:float = 0
	if Input.is_action_just_released(&"_input_mouse_scroll_up"):
		direction = 1
	if Input.is_action_just_released(&"_input_mouse_scroll_down"):
		direction = -1
	if !direction:return
	Scripts.CHESS_CAMERA2D.zoom_camera(direction,delta)
