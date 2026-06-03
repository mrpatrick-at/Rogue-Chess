@tool
extends Node2D
class_name Board
## enums
## consts
const tile_size:int = 128
const board_size:int = 8

const BACK_ROW = [
	Consts.PIECE.ROOK, Consts.PIECE.KNIGHT, Consts.PIECE.BISHOP, Consts.PIECE.QUEEN, 
	Consts.PIECE.KING, Consts.PIECE.BISHOP, Consts.PIECE.KNIGHT, Consts.PIECE.ROOK
]
## exports
## public vars
var tiles: Array = []
var pieces: Dictionary = {}
var tiles_obj: Node2D
var pieces_obj: Node2D
var highlighted_tiles: PackedVector2Array = []
## private vars
## onready vars

# obj_ for node refrences
## built-in override methods

func _ready() -> void: # Runs on Startup
	build_board()

func _physics_process(_delta:float) -> void: # Runs Every Tick
	pass
## public methods

func build_board() -> void: # Remember y_range needs to be +1 bc it stops 1 before
	var starting_time: float = Time.get_ticks_usec()
	print_rich("[color=Springgreen]BUILD_BOARD-[/color] Started Building Board")
	self.name = "Board"
	tiles_obj = Node2D.new()
	pieces_obj = Node2D.new()
	tiles_obj.name = "Tiles"
	pieces_obj.name = "Pieces"
	add_child(tiles_obj)
	add_child(pieces_obj)
	
	tiles.resize(board_size * board_size)
	
	for x in board_size:
		for y in board_size:
			var coord: Vector2i = Vector2i(x, y)
			_create_tile(coord)
			var piece_int: int = _calc_piece(coord)
			if piece_int != Consts.PIECE.NONE:
				var piece: Piece = _create_piece(coord, piece_int)
				pieces[coord] = piece
	
	var ending_time:float = (Time.get_ticks_usec() - starting_time) / 1000
	print_rich("[color=Springgreen]BUILD_BOARD-[/color] Created Board of size: [color=gold]%s[/color] in: [color=gold]%sms[/color]" %[board_size, ending_time])

func get_coord(mouse_pos: Vector2) -> Vector2i:
	var local_mouse_pos: Vector2i = to_local(mouse_pos)
	var coord: Vector2i
	coord.x = local_mouse_pos.x >> 7
	coord.y = -(local_mouse_pos.y >> 7) # Minus here cuz Godot is stupid ass monkey shit and has y axis inverted for some reason
	return coord

func is_valid_coord(coord: Vector2i) -> bool:
	if coord.x in range(board_size) and coord.y in range(board_size):
		return true
	return false

func get_tile(coord: Vector2i) -> Tile:
	return tiles[coord.x * board_size + coord.y]

func is_empty(asked_coords: Vector2i) -> bool:
	if pieces.has(asked_coords):
		return false
	return true

func is_enemy(asked_coords: Vector2i, piece_color: int) -> bool:
	if !is_empty(asked_coords):
		var piece: Piece = pieces[asked_coords]
		if piece.color == piece_color:
			return false
	return true

func highlight_tiles(tiles_to_highlight: PackedVector2Array) -> void:
	for tile_coord: Vector2i in tiles_to_highlight:
		#print("BOARD- Highlighting Tile: ",tile_coord)
		var tile: Tile = get_tile(tile_coord)
		tile.hightlight()
	
	highlighted_tiles.append_array(tiles_to_highlight)

func unhighlight_tiles(tiles_to_unhighlight: PackedVector2Array) -> void:
	for tile_coord: Vector2i in tiles_to_unhighlight:
		#print("BOARD- Unhighlighting Tile: ",tile_coord)
		var tile: Tile = get_tile(tile_coord)
		tile.unhighlight()
	
	for tile_coord: Vector2i in tiles_to_unhighlight:
		highlighted_tiles.erase(tile_coord)

func unhighlight_all_tiles() -> void:
	#print("BOARD- Unhighligting all Tiles")
	unhighlight_tiles(highlighted_tiles)

## private methods

func _create_tile(coord: Vector2i) -> void:
	tiles.resize(board_size * board_size)
	var is_tile_black: bool = _get_tile_color(coord)
	
	var tile: Tile = Tile.new(coord, tile_size, is_tile_black)
	tiles_obj.add_child(tile)
	tile.z_index = -board_size
	tiles[coord.x * board_size + coord.y] = tile

func _get_tile_color(coord: Vector2i) -> bool: # Returns false if White and True if Black
	var is_x_even: bool = false
	var is_y_even: bool = false
	var is_tile_black: bool = false
	
	if coord.x & 1 == 0:
		is_x_even = true
	
	if coord.y & 1 == 0:
		is_y_even = true
	
	if is_x_even == is_y_even: # tile is black
		is_tile_black = true
	return is_tile_black

func _calc_piece(coords: Vector2i) -> int:
	if coords.y > 1 and coords.y < 6:
		return Consts.PIECE.NONE
	
	# White Pawns
	if coords.y == 1:
		return Consts.PIECE.PAWN
	# Black Pawns
	if coords.y == 6:
		return Consts.PIECE.PAWN + (Consts.PIECE.size() - 1)
	
	# White Pieces
	if coords.y == 0:
		return BACK_ROW[coords.x]
	# Black Pieces
	if coords.y == 7:
		return BACK_ROW[coords.x] + (Consts.PIECE.size() - 1)
	
	return Consts.PIECE.NONE # Emergency Stop

func _create_piece(coord: Vector2i, piece_int: int) -> Piece:
	var piece_color:int = Consts.COLOR.WHITE
	var color_string: String = "WHITE"
	var piece_lookup: int = piece_int
	if piece_int > Consts.PIECE.size() - 1:
		piece_color = Consts.COLOR.BLACK
		color_string = "BLACK"
		piece_lookup += -Consts.PIECE.size() + 1
	
	var piece_string: String = Consts.PIECE.keys()[piece_lookup]
	
	var piece: Piece = Piece.new(coord, piece_lookup, piece_color, [color_string, piece_string])
	pieces_obj.add_child(piece)
	
	return piece
