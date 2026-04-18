extends Node
## enums
## consts
## exports
## public vars
static var mouse_pos:Vector2
## private vars
## onready vars
# obj_ for node refrences
## built-in override methods

func _ready() -> void:
	
	pass 

func _physics_process(delta: float) -> void:
	_mouse_buttons()
	_camera_movement(delta)
	_camera_zoom(delta)



## public methods

## private methods

static func _mouse_buttons() -> void:
	# Mouse Inputs
	if InputEventMouse:
		mouse_pos = Scripts.BOARD_MANAGER.get_tile_from_mouse()
		Scripts.SELECTION_MANAGER.reset_highlight()
		Scripts.PIECE_ANIMATE.reset_animation()
		
		if !Scripts.DATABASE.menu_is_open:
			Scripts.SELECTION_MANAGER.highlight_tile(mouse_pos)
			Scripts.PIECE_ANIMATE.hightlight_piece(mouse_pos)
			
			if Input.is_action_just_released(&"_input_mouse_left"):
				
				if Scripts.SELECTION_MANAGER.selected_tile:
					Scripts.SELECTION_MANAGER.select_destination_tile(mouse_pos)
					
				else:
					Scripts.SELECTION_MANAGER.select_tile(mouse_pos)
				
		if Input.is_action_just_released(&"_input_mouse_right"):
			print("Right Mouse click detected")
		if Input.is_action_just_released(&"_input_mouse_middle"):
			print("Middle Mouse click detected")

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
