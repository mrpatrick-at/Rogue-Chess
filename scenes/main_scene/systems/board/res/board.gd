@tool
extends Node2D
class_name Board
## enums
enum PIECE {
	NONE,
	PAWN,
	ROOK,
	KNIGHT,
	BISHOP,
	QUEEN,
	KING,
}
## consts
const tile_size:int = 128
const board_size:int = 8

const BACK_ROW = [
	PIECE.ROOK, PIECE.KNIGHT, PIECE.BISHOP, PIECE.QUEEN, 
	PIECE.KING, PIECE.BISHOP, PIECE.KNIGHT, PIECE.ROOK
]
## exports
## public vars
var tiles: Array = []
var pieces: PackedByteArray = []
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
	tiles.resize(board_size * board_size)
	pieces.resize(board_size * board_size)
	for x in board_size:
		for y in board_size:
			var coord: Vector2i = Vector2i(x, y)
			_create_tile(coord)
			var piece: int = _calc_piece(coord)
			if piece != PIECE.NONE:
				_create_piece(coord, piece)
				pieces[coord.x * board_size + coord.y] = piece
			
	print(pieces)
	var ending_time:float = (Time.get_ticks_usec() - starting_time) / 1000
	print_rich("[color=Springgreen]BUILD_BOARD-[/color] Created Board of size: [color=gold]%s[/color] in: [color=gold]%sms[/color]" %[board_size, ending_time])

## private methods

func _create_tile(coord: Vector2i) -> void:
	tiles.resize(board_size * board_size)
	var is_tile_black:bool = _get_tile_color(coord)
	
	var tile: Tile = Tile.new()
	add_child(tile)
	tile.setup(coord, tile_size, is_tile_black)
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

func _calc_piece(coords:Vector2i) -> int:
	if coords.x > 1 and coords.x < 6:
		return PIECE.NONE
	
	# White Pawns
	if coords.x == 1:
		return PIECE.PAWN
	# Black Pawns
	if coords.x == 6:
		return PIECE.PAWN + (PIECE.size() - 1)
	
	# White Pieces
	if coords.x == 0:
		return BACK_ROW[coords.y]
	# Black Pieces
	if coords.x == 7:
		return BACK_ROW[coords.y] + (PIECE.size() - 1)
	
	return PIECE.NONE # Emergency Stop

func _create_piece(coord:Vector2i, piece:int) -> void:
	var color_string: String = "WHITE"
	var piece_lookup: int = piece
	if piece > PIECE.size() - 1:
		color_string = "BLACK"
		piece_lookup -= PIECE.size() - 1
	
	var piece_string: String = PIECE.keys()[piece_lookup]
	var piece_texture: CompressedTexture2D = load("res://assets/images/pieces/%s/%s.png"%[color_string, piece_string])
