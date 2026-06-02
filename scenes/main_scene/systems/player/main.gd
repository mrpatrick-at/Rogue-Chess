extends Node
## enums
## consts
## exports
## public vars
var mouse_position: Vector2 = Vector2.ZERO
var camera: Camera2D
var board: Board
var piece_manager: PieceManager
var tile_info: Array = []
var tile_buffer: Array = []

var selected_tile: bool = false
var selected_piece: Piece
## private vars
## onready vars
## built-in override methods

func _ready() -> void:
	camera = get_viewport().get_camera_2d()
	board = Scripts.BOARD_MANAGER.board
	piece_manager = Scripts.BOARD_MANAGER.piece_manager

func _process(_delta: float) -> void:
	tile_info = get_mouse_collision_pos()
	
	if selected_tile:
		return
	
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
	var tile_data: Array = []
	tile_data.resize(2)
	var coord: Vector2i = board.get_coord(mouse_position)
	var tile: Tile
	if board.is_valid_coord(coord):
		tile = board.get_tile(coord)
	tile_data[0] = coord
	tile_data[1] = tile
	return tile_data

func _mouse_buttons(event:InputEventMouse) -> void:
	mouse_position = camera.get_global_mouse_position()
	
	if event is InputEventMouseButton:
		if event.is_action_pressed(&"_input_mouse_left"):
			if tile_info[1] is Tile:
				var coord:Vector2i = tile_info[0]
				if selected_tile == false:
					if board.pieces.has(coord):
						selected_piece = board.pieces[coord]
						board.highlight_tiles(piece_manager.get_piece_moves(tile_info[0]))
						selected_tile = true
						print("Tile selected")
				else:
					selected_tile = false
					selected_piece.move_to(coord, false)
					board.unhighlight_tiles()
					print("Tile unselected")
	
		if event.is_action_pressed(&"_input_mouse_right"):
			if tile_info[1] is Tile:
				print(tile_info[1])
	
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
