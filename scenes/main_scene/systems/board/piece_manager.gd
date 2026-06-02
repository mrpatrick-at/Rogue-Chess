extends Node2D
class_name  PieceManager
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
## exports
## public vars
## private vars
var board: Board
static var _knight_directions:Array = [Vector2i(1,2),Vector2i(-1,2), Vector2i(1,-2),Vector2i(-1,-2), Vector2i(2,1),Vector2i(2,-1), Vector2i(-2,1),Vector2i(-2,-1)]
static var _rook_directions:Array = [Vector2i(0,1), Vector2i(0,-1), Vector2i(1,0), Vector2i(-1,0)]
static var _bishop_directions:Array = [Vector2i(1,1), Vector2i(1,-1), Vector2i(-1,1), Vector2i(-1,-1)]
## onready vars
## built-in override methods

func _ready() -> void:
	board = Scripts.BOARD_MANAGER.board

## public methods

func get_piece_moves(coords: Vector2i) -> PackedVector2Array:
	var moves: PackedVector2Array = []
	if board.pieces.has(coords):
		if board.pieces[coords].type == PIECE.PAWN:
			moves = _get_pawn_moves(coords)
	
	return moves

func calc_moves() -> Dictionary:
	
	return {}

## private methods
func _get_pawn_moves(asked_coords:Vector2i) -> PackedVector2Array:
	var piece: Piece = board.pieces[asked_coords]
	var moves: Array = []
	var move_range: int = 0
	var is_black: bool = false
	var capture_squares: Array = [Vector2i(1,1),Vector2i(1,-1)]
	if piece.color == 1:
		capture_squares = [Vector2i(-1,-1),Vector2i(-1,1)]
	
	if piece.move_amount == 0:
		move_range = 2
	else:
		move_range = 1
	
	# Main Movement
	for i:int in move_range:
		var pos:Vector2i = asked_coords
		pos.x += i
		if board.is_valid_coord(pos):
			if board.is_empty(pos):
				moves.append(pos)
	
	# Piece Capturing
	#for i:Vector2i in capture_squares:
		#var pos:Vector2i = asked_coords + i
		#if board.is_valid_coord(pos):
			#if board.is_enemy(pos, 0):
				#moves.append(pos)
		# En Passant Rules
		#var pos_passant:Vector2i = Vector2i(current_coords.x,pos.y)
		#if board.is_valid_position(pos_passant):
			#if board.is_enemy(pos_passant, 0):
				#var passant_piece: Piece = board.pieces[pos_passant]
				#if passant_piece.type == Scripts.CONSTANTS.PIECE_TYPE.PAWN:
					#if passant_piece.move_amount == 1:
						#if Scripts.PIECE_MANAGER.get_piece_data(pos_passant,Scripts.CONSTANTS.PIECE_LIST.PAWN_MOVED_TWO_TILES) == Scripts.CONSTANTS.PAWN_MOVED_TWO_TILES.TRUE:
							#_moves.append(pos)
	
	return moves

#static func _get_knight_moves(current_coords:Vector2i) -> Array: # TODO: Prob can Make this a little bit better !!!
	#var _moves:Array = []
	#
	#for i:Vector2i in _knight_directions:
		#var pos:Vector2i = current_coords
		#pos += i
		#if Scripts.BOARD_MANAGER.is_valid_position(pos):
			#if Scripts.PIECE_MANAGER.is_empty(pos):
				#_moves.append(pos)
			#elif Scripts.PIECE_MANAGER.is_enemy(pos):
				#_moves.append(pos)
	#
	#return _moves
#
#static func _get_rook_moves(current_coords:Vector2i,getting_moves:bool) -> Array:
	#var _moves:Array = []
	#
	#for i:Vector2i in rook_directions:
		#var pos:Vector2i = current_coords
		#pos += i
		#
		#while Scripts.BOARD_MANAGER.is_valid_position(pos):
			#if Scripts.PIECE_MANAGER.is_empty(pos):
				#_moves.append(pos)
			#elif Scripts.PIECE_MANAGER.is_enemy(pos):
				#_moves.append(pos)
				#break
			#elif getting_moves:
				#break
			#
			#pos +=i
	#
	#return _moves
#
#static func _get_bishop_moves(current_coords:Vector2i,getting_moves:bool) -> Array:
	#var _moves:Array = []
	#
	#for i:Vector2i in bishop_directions:
		#var pos:Vector2i = current_coords
		#pos += i
		#
		#while Scripts.BOARD_MANAGER.is_valid_position(pos):
			#if Scripts.PIECE_MANAGER.is_empty(pos):
				#_moves.append(pos)
			#elif Scripts.PIECE_MANAGER.is_enemy(pos):
				#_moves.append(pos)
				#break
			#elif getting_moves:
				#break
			#
			#pos +=i
	#
	#return _moves
#
#static func _get_king_moves(current_coords:Vector2i) -> Array: # TODO: Wow I just discovered how absolutely shit the Castling Code is. FIX IN FUTURE!!!!
	#var _moves:Array = []
	#
	#for x in range(-1,2):
		#for y in range(-1,2):
			#var pos:Vector2i = current_coords
			#pos.x += x
			#pos.y += y
			#
			#if Scripts.BOARD_MANAGER.is_valid_position(pos):
				#if Scripts.PIECE_MANAGER.is_empty(pos):
					#_moves.append(pos)
				#elif Scripts.PIECE_MANAGER.is_enemy(pos):
					#_moves.append(pos)
	#
	#
	## Castling
	#if Scripts.PIECE_MANAGER.get_piece_data(current_coords,Scripts.CONSTANTS.PIECE_LIST.TIMES_MOVED) == 0:
		#if Scripts.PIECE_MANAGER.get_piece_data(Vector2i(current_coords.x,current_coords.y + 3),Scripts.CONSTANTS.PIECE_LIST.PIECE_TYPE) == Scripts.CONSTANTS.PIECE_TYPE.ROOK:
			#if Scripts.PIECE_MANAGER.get_piece_data(Vector2i(current_coords.x,current_coords.y + 3),Scripts.CONSTANTS.PIECE_LIST.TIMES_MOVED) == 0:
				#if Scripts.PIECE_MANAGER.is_empty(Vector2i(current_coords.x,current_coords.y + 1)):
					#if Scripts.PIECE_MANAGER.is_empty(Vector2i(current_coords.x,current_coords.y + 2)):
						#_moves.append(Vector2i(current_coords.x,current_coords.y + 2))
	#
	#return _moves
