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
var tiles_obj: Node2D
var pieces_obj: Node2D
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

func get_coord(mouse_pos: Vector2) -> Vector2i:
	var local_mouse_pos: Vector2i = to_local(mouse_pos)
	var coord:Vector2i
	coord.x = local_mouse_pos.x >> 7
	coord.y = -(local_mouse_pos.y >> 7) # Minus here cuz Godot is stupid ass monkey shit and has y axis inverted for some reason
	return coord

func is_on_board(coord: Vector2i) -> bool:
	if coord.x in range(board_size) and coord.y in range(board_size):
		return true
	return false

func get_tile(coord: Vector2i) -> Tile:
	return tiles[coord.x * board_size + coord.y]

## private methods

func _create_tile(coord: Vector2i) -> void:
	tiles.resize(board_size * board_size)
	var is_tile_black:bool = _get_tile_color(coord)
	
	var tile: Tile = Tile.new()
	tiles_obj.add_child(tile)
	tile.setup(coord, tile_size, is_tile_black)
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

func _calc_piece(coords:Vector2i) -> int:
	if coords.y > 1 and coords.y < 6:
		return PIECE.NONE
	
	# White Pawns
	if coords.y == 1:
		return PIECE.PAWN
	# Black Pawns
	if coords.y == 6:
		return PIECE.PAWN + (PIECE.size() - 1)
	
	# White Pieces
	if coords.y == 0:
		return BACK_ROW[coords.x]
	# Black Pieces
	if coords.y == 7:
		return BACK_ROW[coords.x] + (PIECE.size() - 1)
	
	return PIECE.NONE # Emergency Stop

func _create_piece(coord:Vector2i, piece:int) -> void:
	var color_string: String = "WHITE"
	var piece_lookup: int = piece
	if piece > PIECE.size() - 1:
		color_string = "BLACK"
		piece_lookup += -PIECE.size() + 1
	
	var piece_string: String = PIECE.keys()[piece_lookup]
	var piece_texture: CompressedTexture2D = load("res://assets/images/pieces/%s/%s.png"%[color_string, piece_string])
	
	var piece_sprite:Sprite2D = Sprite2D.new()
	pieces_obj.add_child(piece_sprite)
	piece_sprite.texture = piece_texture
	var translated_coords:Vector2
	translated_coords.x = coord.x * tile_size
	translated_coords.y = -coord.y * tile_size
	
	piece_sprite.global_position = translated_coords
	piece_sprite.scale = Vector2i(8,8)
	piece_sprite.move_local_x(64)
	piece_sprite.move_local_y(-32)
	piece_sprite.z_index = -coord.y + 1
