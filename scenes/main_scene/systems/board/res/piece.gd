extends Sprite2D
class_name Piece
## enums
## consts
const path: String = "res://assets/images/pieces/%s/%s.png"
## exports
## public vars
var type: int = 0
var color: int = 0
var move_amount: int = 0
var coord: Vector2i = Vector2i.ZERO
var moves: PackedVector2Array = []
var board: Board
## private vars
## onready vars
## built-in override methods

func _init(piece_coord: Vector2i, piece_type: int, piece_color: int, piece_info: Array) -> void:
	type = piece_type
	color = piece_color
	coord = piece_coord
	board = Scripts.BOARD_MANAGER.board
	
	self.name = "%s, %s"%piece_info
	
	var piece_texture: CompressedTexture2D = load(path%piece_info)
	
	self.texture = piece_texture
	move_to(coord, true)
	moves = get_moves()
	
	self.scale = Vector2i(8,8)

## public methods

func get_moves() -> PackedVector2Array:
	var piece_moves: PackedVector2Array = []
	
	piece_moves = _get_pawn_moves(coord, color)
	return piece_moves

func move_to(target_coord: Vector2i, is_init:bool) -> void:
	if moves.has(target_coord) or is_init:
		var translated_coords: Vector2
		translated_coords.x = target_coord.x * Consts.tile_size + 64
		translated_coords.y = -target_coord.y * Consts.tile_size - 32
		self.global_position = translated_coords
		board.pieces.erase(coord)
		board.pieces[target_coord] = self
		
		coord = target_coord
		self.z_index = -target_coord.y + 1
		
		moves = get_moves()

## private methods

func _get_pawn_moves(asked_coords:Vector2i, color:int) -> PackedVector2Array:
	var piece_moves: PackedVector2Array = []
	var move_range: int = 1
	#var capture_squares: Array = [Vector2i(1,1),Vector2i(1,-1)]
	#if color == Consts.COLOR.BLACK:
		#capture_squares = [Vector2i(-1,-1),Vector2i(-1,1)]
	
	var direction_int: int = 1
	if color == Consts.COLOR.BLACK:
		direction_int = -1
	
	if move_amount == 0:
		move_range = 2
	
	# Main Movement
	for i:int in move_range:
		var pos:Vector2i = asked_coords
		pos.y += (i + 1) * direction_int
		if !board.is_valid_coord(pos):
			break
		if !board.is_empty(pos):
			break
		
		print("is empty appending: ", pos)
		piece_moves.append(pos)
	
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
	
	return piece_moves

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
