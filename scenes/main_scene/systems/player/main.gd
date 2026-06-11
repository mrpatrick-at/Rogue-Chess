extends Node
## enums
## consts
## exports
## public vars
var camera: Camera2D
var board: Board
var tile_below_mouse: Vector2i
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

	tile_below_mouse = board.get_coord()
	if selected_tile:
		return
	
	var coord:Vector2i = tile_below_mouse
	if board.is_valid_coord(coord):
		
		if !highlighted_tiles.has(coord):
			
			board.highlight_tile(coord, Consts.HIGHLIGHT.HOVER)
			highlighted_tiles.append(coord)
			
			if board.pieces.has(coord):
				var piece: Piece = board.pieces[coord]
				piece.highlight()
				highlighted_pieces.append(piece)
	
	for tile: Vector2i in highlighted_tiles:
		if tile == coord:
			continue
		board.unhighlight_tile(tile)
		highlighted_tiles.erase(tile)
	
	for piece: Piece in highlighted_pieces:
		if piece.coord == coord:
			continue
		piece.unhighlight()
		highlighted_pieces.erase(piece)
	


func _input(event: InputEvent) -> void:
	if event is InputEventMouse:
		_mouse_buttons(event)

## public methods

## private methods

func _mouse_buttons(event:InputEventMouse) -> void:
	if event is InputEventMouseButton:
		if event.is_action_pressed(&"_input_mouse_left"):
			var coord: Vector2i = tile_below_mouse
			if board.is_valid_coord(coord):
				if selected_tile == false:
					if board.pieces.has(coord):
						selected_piece = board.pieces[coord]
						var piece_moves: PackedVector2Array = selected_piece.get_moves()
						for move: Vector2i in piece_moves:
							if board.pieces.has(move):
								board.highlight_tile(move, Consts.HIGHLIGHT.CAPTURE)
								continue
							board.highlight_tile(move, Consts.HIGHLIGHT.MOVE)
							
						highlighted_tiles.append_array(piece_moves)
						selected_tile = true
						print("PLAYER- Piece Selected")
				else:
					selected_tile = false
					selected_piece.move_to(coord)
					print("PLAYER- Piece Moved")
		
		if event.is_action_pressed(&"_input_mouse_right"):
			if board.is_valid_coord(tile_below_mouse):
				print("PLAYER- Tile: ",tile_below_mouse)
			else:
				print("PLAYER- Tile not in Board")
	
		if event.is_action_pressed(&"_input_mouse_middle"):
			print("PLAYER- Middle Mouse click detected")
