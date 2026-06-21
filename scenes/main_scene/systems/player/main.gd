extends Node
## enums
## consts
## exports
## public vars
var camera: Camera2D
var board: Board
var index_below_mouse: int = 0
var highlighted_tiles: Array = []
var highlighted_pieces: Array = []

var selected_tile: bool = false
var selected_piece: Piece
## private vars
## onready vars
## built-in override methods

func _ready() -> void:
	camera = get_viewport().get_camera_2d()
	board = Scripts.BOARD_MANAGER.board

func _process(_delta: float) -> void:
	index_below_mouse = board.get_tile_index()
	if selected_tile:
		return
	
	var index: int = index_below_mouse
	if board.is_valid_index(index) && !highlighted_tiles.has(index):
		
		board.highlight_tile(index, Consts.HIGHLIGHT.HOVER)
		highlighted_tiles.append(index)
		
		var piece_int: int = board.get_piece_int(index)
		if piece_int != -1:
			var piece: Piece = board.piece_objs[index]
			#if piece.color == board.turn_color:
			piece.highlight()
			highlighted_pieces.append(piece)
	
	for tile: int in highlighted_tiles:
		if tile == index:
			continue
		board.unhighlight_tile(tile)
		highlighted_tiles.erase(tile)
	
	for piece: Piece in highlighted_pieces:
		if board.piece_objs.has(index) and piece.coord == board.piece_objs[index].coord:
			continue
		piece.unhighlight()
		highlighted_pieces.erase(piece)
	


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		_mouse_buttons(event)

## public methods

## private methods

func _mouse_buttons(event:InputEventMouse) -> void:
	if event.is_action_pressed(&"_input_mouse_left"):
		var index: int = index_below_mouse
		if board.is_valid_index(index):
			if selected_tile == false:
				var piece_int: int = board.get_piece_int(index)
				board.get_piece_moves(index, piece_int)
				#if selected_piece.color == board.turn_color:
					#var piece_moves: PackedVector2Array = selected_piece.get_moves()
					#for move: Vector2i in piece_moves:
						#if board.pieces.has(move):
							#board.highlight_tile(move, Consts.HIGHLIGHT.CAPTURE)
							#continue
						#board.highlight_tile(move, Consts.HIGHLIGHT.MOVE)
						#
					#highlighted_tiles.append_array(piece_moves)
					#selected_tile = true
					#print("PLAYER- Piece Selected")
			#else:
				#selected_tile = false
				#selected_piece.move_to(coord)
				#selected_piece.reset_highlight()
				#highlighted_pieces.erase(selected_piece)
				#print("PLAYER- Piece Moved")
	
	if event.is_action_pressed(&"_input_mouse_right"):
		if board.is_valid_index(index_below_mouse):
			var piece_int: int = board.get_piece_int(index_below_mouse)
			print("PLAYER- Tile: ", index_below_mouse)
			if piece_int != -1:
				var piece_string :String = board.get_piece_string(piece_int)
				print("PLAYER- Piece Type: ", piece_string)
		else:
			print("PLAYER- Tile not in Board")
	
	if event.is_action_pressed(&"_input_mouse_middle"):
		print("PLAYER- Middle Mouse click detected")
