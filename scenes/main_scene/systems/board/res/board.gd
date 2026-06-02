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
var pieces: int = 0
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
	for x in board_size:
		for y in board_size:
			var coord: Vector2i = Vector2i(x, y)
			_create_tile(coord)
			var piece: int = _calc_piece(coord)
			print(piece)
	
	var ending_time:float = (Time.get_ticks_usec() - starting_time) / 1000
	print_rich("[color=Springgreen]BUILD_BOARD-[/color] Created Board of size: [color=gold]%s[/color] in: [color=gold]%sms[/color]" %[board_size, ending_time])

#static func is_valid_position(_asked_coords:Vector2i) -> bool:
	#if _asked_coords.x >= 1 and _asked_coords.x < 9 and _asked_coords.y >= 1 and _asked_coords.y < 9:
		#return true
	#return false
#
#static func get_tile_from_mouse() -> Vector2i: # Translates Mouse coords into Board coords
	#var tilemap_selection_local_mouse_coords:Vector2 = tilemap_selection.get_local_mouse_position()
	#var tilemap_selection_coords:Vector2i
	#
	#if tilemap_board == null: # Error if tilemap_board cant be found
		#print("Tilemap is null")
	#
	#tilemap_selection_coords = tilemap_board.local_to_map(tilemap_selection_local_mouse_coords)
	#
	##print("Updated highlighted Tile: ",tilemap_selection_local_mouse_coords," ; Tilemap Coords: ",tilemap_selection_coords,"!")
	#return tilemap_selection_coords
#
#static func get_mouse_from_tile(coords:Vector2i) -> Vector2: # Translates Coords from map to global
	#var translated_coords:Vector2 = tilemap_board.to_global(tilemap_board.map_to_local(coords))
	#return translated_coords
#
#static func get_tiles_between_points(starting_pos:Vector2i,target_pos:Vector2i) -> Array: # Returns starting_pos + Array of all Positions between the two Points
	#var value_x:int
	#var value_y:int
	#
	#if starting_pos.x < target_pos.x:
		#value_x = 1
	#elif starting_pos.x == target_pos.x:
		#value_x = 0
	#else:
		#value_x = -1
		#
	#if starting_pos.y < target_pos.y:
		#value_y = 1
	#elif starting_pos.y == target_pos.y:
		#value_y = 0
	#else:
		#value_y = -1
	#
	##print("GET_TILES_BETWEEN_POINTS- step values: ",Vector2i(value_x,value_y))
	#var step:Vector2i = Vector2i(starting_pos)
	#var _steps:Array = []
	#var pieces_between:Array = []
	#
	#while step != target_pos:
		#_steps.append(step)
		#
		#if step.x != target_pos.x:
			#step.x += value_x
		#if step.y != target_pos.y:
			#step.y += value_y
		#
		#if !Scripts.PIECE_MANAGER.is_empty(step) and step != target_pos:
			#pieces_between.append(step)
			#print("GET_TILES_BETWEEN_POINTS- Piece Found at",step)
	#
	##print("GET_TILES_BETWEEN_POINTS- Amount of Pieces Between King and Checking Piece: %s"
	##%piece_amount)
	#
	#return [_steps,pieces_between] # [0] = between tiles; [1] = between pieces

## private methods

func _create_tile(coord: Vector2i) -> void:
	tiles.resize(board_size * board_size)
	var is_tile_black:bool = _get_tile_color(coord)
	
	var tile: Tile = Tile.new()
	add_child(tile)
	tile.setup(coord, tile_size, is_tile_black)
	tiles[coord.x + coord.y * board_size] = tile

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
