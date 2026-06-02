extends Node
## enums
## consts
## exports
## public vars
static var mouse_pos:Vector2
static var grid_info: Array
static var camera: Camera2D
var board: Board
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
		print(tile_info[1])
	#if !collision_ray.is_empty():
		#if collision_ray.collider == MeshInstance2D:
			#grid_info = get_grid_info(collision_ray)
			#return
	
	grid_info = []

## public methods

## private methods

func get_mouse_collision_pos(mouse_position:Vector2 = camera.get_global_mouse_position()) -> Array: # Query Cam and Return Result
	var tile_info: Array = []
	tile_info.resize(2)
	var coord: Vector2i = board.get_coord(mouse_position)
	var tile: Tile
	if board.is_on_board(coord):
		tile = board.get_tile(coord)
	tile_info[0] = coord
	tile_info[1] = tile
	return tile_info

#static func _mouse_buttons() -> void:
	## Reset Stuff
	#Scripts.SELECTION_MANAGER.reset_highlight()
	#Scripts.PIECE_ANIMATE.reset_animation()
		#
	#if !Scripts.DATABASE.menu_is_open:
		#if InputEventMouse:
			## Highlight Tiles and Pieces on Hover
			#mouse_pos = Scripts.BOARD_MANAGER.get_tile_from_mouse()
			#Scripts.SELECTION_MANAGER.highlight_tile(mouse_pos)
			#Scripts.PIECE_ANIMATE.hightlight_piece(mouse_pos)
		#
		#if Input.is_action_just_released(&"_input_mouse_left"):
			## Allow Piece Movement
			#if Scripts.SELECTION_MANAGER.selected_tile:
				#Scripts.SELECTION_MANAGER.select_destination_tile(mouse_pos)
				#
			#else:
				#Scripts.SELECTION_MANAGER.select_tile(mouse_pos)
		#
		#if Input.is_action_just_released(&"_input_mouse_right"):
			#print("Right Mouse click detected")
		#if Input.is_action_just_released(&"_input_mouse_middle"):
			#print("Middle Mouse click detected")
#
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
