extends Node
## enums
## consts
## exports
## public vars
var mouse_position: Vector2 = Vector2.ZERO
var camera: Camera2D
var board: Board
var tile_buffer: Array = []
## private vars
## onready vars
# obj_ for node refrences
## built-in override methods

func _ready() -> void:
	camera = get_viewport().get_camera_2d()
	board = Scripts.BOARD_MANAGER.board
	pass 

#func _physics_process(delta: float) -> void:
	#
	#_camera_movement(delta)
	#_camera_zoom(delta)
	#_mouse_buttons()

func _process(_delta: float) -> void:
	var tile_info: Array = get_mouse_collision_pos()
	if tile_info[1] is Tile:
		var tile: Tile = tile_info[1]
		tile_buffer.append(tile)
		tile.hightlight()
		#print(tile)
	
	for tile: Tile in tile_buffer:
		if tile == tile_info[1]:
			continue
		tile.unhighlight()
		tile_buffer.erase(tile)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouse:
		_mouse_buttons(event)

## public methods

## private methods

func get_mouse_collision_pos() -> Array: # Query Cam and Return Result
	var tile_info: Array = []
	tile_info.resize(2)
	var coord: Vector2i = board.get_coord(mouse_position)
	var tile: Tile
	if board.is_on_board(coord):
		tile = board.get_tile(coord)
	tile_info[0] = coord
	tile_info[1] = tile
	return tile_info

func _mouse_buttons(event:InputEventMouse) -> void:
	mouse_position = camera.get_global_mouse_position()
	
	if event is InputEventMouseButton:
		if event.is_action_pressed(&"_input_mouse_left"):
			print("Left Mouse click detected")
		if event.is_action_pressed(&"_input_mouse_right"):
			print("Right Mouse click detected")
		if event.is_action_pressed(&"_input_mouse_middle"):
			print("Middle Mouse click detected")

#static func _camera_movement(delta:float) -> void:
	## Camera Movement
	#var direction:Vector2 = Vector2.ZERO
	#if Input.is_action_pressed(&"_input_up") and !Input.is_action_pressed(&"_input_down"): direction.y = -1
	#if Input.is_action_pressed(&"_input_down") and !Input.is_action_pressed(&"_input_up"): direction.y = +1 
	#if Input.is_action_pressed(&"_input_left") and !Input.is_action_pressed(&"_input_right"): direction.x = -1 
	#if Input.is_action_pressed(&"_input_right") and !Input.is_action_pressed(&"_input_left"): direction.x = +1
	#if direction == Vector2.ZERO:return # No movement
	#Scripts.CHESS_CAMERA2D.move_camera(direction,delta)
#
#static func _camera_zoom(delta:float) -> void:
	## Camera Zoom
	#var direction:float = 0
	#if Input.is_action_just_released(&"_input_mouse_scroll_up"):
		#direction = 1
	#if Input.is_action_just_released(&"_input_mouse_scroll_down"):
		#direction = -1
	#if !direction:return
	#Scripts.CHESS_CAMERA2D.zoom_camera(direction,delta)
