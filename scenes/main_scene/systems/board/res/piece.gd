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
static var _knight_directions:Array = [Vector2i(1,2),Vector2i(-1,2), Vector2i(1,-2),Vector2i(-1,-2), Vector2i(2,1),Vector2i(2,-1), Vector2i(-2,1),Vector2i(-2,-1)]
static var _rook_directions:Array = [Vector2i(0,1), Vector2i(0,-1), Vector2i(1,0), Vector2i(-1,0)]
static var _bishop_directions:Array = [Vector2i(1,1), Vector2i(1,-1), Vector2i(-1,1), Vector2i(-1,-1)]
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
	
	match abs(type): # Checks which Piece, then gets Moves
		Consts.PIECE.PAWN:
			piece_moves = _get_pawn_moves()
		Consts.PIECE.ROOK:
			piece_moves = _get_rook_moves()
		Consts.PIECE.KNIGHT:
			piece_moves = _get_knight_moves()
		Consts.PIECE.BISHOP:
			piece_moves = _get_bishop_moves()
		Consts.PIECE.QUEEN:
			piece_moves = _get_rook_moves() + _get_bishop_moves()
		Consts.PIECE.KING:
			piece_moves = _get_king_moves()
	
	return piece_moves

func move_to(target_coord: Vector2i, is_init:bool) -> void:
	moves = get_moves()
	if moves.has(target_coord) or is_init:
		if board.pieces.has(target_coord):
			var target_piece: Piece = board.pieces[target_coord]
			board.pieces_obj.remove_child(target_piece)
			target_piece.queue_free()
			board.pieces.erase(target_coord)
			
		var translated_coords: Vector2
		translated_coords.x = target_coord.x * Consts.tile_size + 64
		translated_coords.y = -target_coord.y * Consts.tile_size - 32
		self.global_position = translated_coords
		board.pieces.erase(coord)
		board.pieces[target_coord] = self
		
		coord = target_coord
		self.z_index = -target_coord.y + 1

## private methods

func _get_pawn_moves() -> PackedVector2Array:
	var piece_moves: PackedVector2Array = []
	var move_range: int = 1
	
	var direction_int: int = 1
	if color == Consts.COLOR.BLACK:
		direction_int = -1
	
	if move_amount == 0:
		move_range = 2
	
	# Main Movement
	for i:int in move_range:
		var pos:Vector2i = coord
		pos.y += (i + 1) * direction_int
		if !board.is_valid_coord(pos):
			break
		if !board.is_empty(pos):
			break
		
		print("is empty appending: ", pos)
		piece_moves.append(pos)
	
	# Piece Capturing
	var capture_squares: PackedVector2Array = [Vector2i(-1,direction_int),Vector2i(1,direction_int)]
	for vec2i:Vector2i in capture_squares:
		var pos:Vector2i = coord + vec2i
		if !board.is_valid_coord(pos):
			continue
		if board.is_empty(pos):
			continue
		if !board.is_enemy(pos, color):
			continue
		piece_moves.append(pos)
		# En Passant Rules
		#var pos_passant:Vector2i = Vector2i(current_coords.x,pos.y)
		#if board.is_valid_position(pos_passant):
			#if board.is_enemy(pos_passant, 0):
				#var passant_piece: Piece = board.pieces[pos_passant]
				#if passant_piece.type == Scripts.CONSTANTS.PIECE_TYPE.PAWN:
					#if passant_piece.move_amount == 1:
						#if Scripts.PIECE_MANAGER.get_piece_data(pos_passant,Scripts.CONSTANTS.PIECE_LIST.PAWN_MOVED_TWO_TILES) == Scripts.CONSTANTS.PAWN_MOVED_TWO_TILES.TRUE:
							#_moves.append(pos)
	print(piece_moves)
	return piece_moves

func _get_rook_moves() -> Array:
	var piece_moves:Array = []
	
	for direction: Vector2i in _rook_directions:
		var pos: Vector2i = coord + direction
		
		while board.is_valid_coord(pos):
			
			if board.is_empty(pos):
				piece_moves.append(pos)
				pos += direction
				continue
			
			if board.is_enemy(pos, color):
				piece_moves.append(pos)
			
			break
	
	return piece_moves

func _get_knight_moves() -> PackedVector2Array: # TODO: Prob can Make this a little bit better !!!
	var piece_moves: PackedVector2Array = []
	
	for direction: Vector2i in _knight_directions:
		var pos:Vector2i = coord + direction
		
		if board.is_valid_coord(pos):
			
			if board.is_empty(pos) or board.is_enemy(pos, color):
				piece_moves.append(pos)
	
	return piece_moves

func _get_bishop_moves() -> Array:
	var piece_moves:Array = []
	
	for direction: Vector2i in _bishop_directions:
		var pos: Vector2i = coord + direction
		
		while board.is_valid_coord(pos):
			
			if board.is_empty(pos):
				piece_moves.append(pos)
				pos += direction
				continue
			
			if board.is_enemy(pos, color):
				piece_moves.append(pos)
			
			break
	
	return piece_moves

func _get_king_moves() -> Array: # TODO: Wow I just discovered how absolutely shit the Castling Code is. FIX IN FUTURE!!!!
	var piece_moves:Array = []
	
	for x in 3:
		for y in 3:
			var pos:Vector2i = coord
			pos.x += x - 1
			pos.y += y - 1
			
			if board.is_valid_coord(pos):
				if board.is_empty(pos):
					piece_moves.append(pos)
					continue
				
				if board.is_enemy(pos, color):
					piece_moves.append(pos)
	
	
	# Castling
	#if Scripts.PIECE_MANAGER.get_piece_data(current_coords,Scripts.CONSTANTS.PIECE_LIST.TIMES_MOVED) == 0:
		#if Scripts.PIECE_MANAGER.get_piece_data(Vector2i(current_coords.x,current_coords.y + 3),Scripts.CONSTANTS.PIECE_LIST.PIECE_TYPE) == Scripts.CONSTANTS.PIECE_TYPE.ROOK:
			#if Scripts.PIECE_MANAGER.get_piece_data(Vector2i(current_coords.x,current_coords.y + 3),Scripts.CONSTANTS.PIECE_LIST.TIMES_MOVED) == 0:
				#if Scripts.PIECE_MANAGER.is_empty(Vector2i(current_coords.x,current_coords.y + 1)):
					#if Scripts.PIECE_MANAGER.is_empty(Vector2i(current_coords.x,current_coords.y + 2)):
						#piece_moves.append(Vector2i(current_coords.x,current_coords.y + 2))
	
	return piece_moves
