extends RefCounted
## enums
## consts
## exports
## public vars
static var _moves:Array = []

# Special Moves Vars
static var _en_passant_flag:bool = false


static var knight_directions:Array = [Vector2i(1,2),Vector2i(-1,2), Vector2i(1,-2),Vector2i(-1,-2), Vector2i(2,1),Vector2i(2,-1), Vector2i(-2,1),Vector2i(-2,-1)]
static var rook_directions:Array = [Vector2i(0,1), Vector2i(0,-1), Vector2i(1,0), Vector2i(-1,0)]
static var bishop_directions:Array = [Vector2i(1,1), Vector2i(1,-1), Vector2i(-1,1), Vector2i(-1,-1)]

static var white_king_pos:Vector2i = Vector2i(0,0)
static var black_king_pos:Vector2i = Vector2i(0,0)
## private vars
## onready vars
# obj_ for node refrences
## built-in override methods
## public methods

static func get_moves(current_coords:Vector2i) -> Array:
	_moves = []
	match abs(Scripts.PIECE_MANAGER.get_piece_data(current_coords,Scripts.PIECE_CONSTS.PIECE_LIST.TYPE)):
		Scripts.PIECE_CONSTS.TYPE_LIST.PAWN:
			_moves = _get_pawn_moves(current_coords)
		Scripts.PIECE_CONSTS.TYPE_LIST.ROOK:
			_moves = _get_rook_moves(current_coords)
		Scripts.PIECE_CONSTS.TYPE_LIST.KNIGHT:
			_moves = _get_knight_moves(current_coords)
		Scripts.PIECE_CONSTS.TYPE_LIST.BISHOP:
			_moves = _get_bishop_moves(current_coords)
		Scripts.PIECE_CONSTS.TYPE_LIST.QUEEN:
			_moves = _get_rook_moves(current_coords) + _get_bishop_moves(current_coords)
		Scripts.PIECE_CONSTS.TYPE_LIST.KING:
			_moves = _get_king_moves(current_coords)
	#print("piece_move/get_moves- _moves: ",_moves)
	return _moves

static func calc_move(current_coords:Vector2i,asked_coords:Vector2i) -> void: # Calls all funcs used for movement # TODO: Finish En Passant
	if asked_coords in _moves:
		Scripts.fifty_move_rule += 1 # For each Turn Rule +=1
		
		# If Moved Piece is Pawn
		if Scripts.PIECE_MANAGER.get_piece_data(current_coords,Scripts.PIECE_CONSTS.PIECE_LIST.TYPE) == Scripts.PIECE_CONSTS.TYPE_LIST.PAWN:
			Scripts.fifty_move_rule = 0 # If Pawn is Moved Rule is Reset
			print("GET_MOVE- MOVED PIECE IS PAWN")
			# Get Direction
			var direction:int = 0
			if Scripts.PIECE_MANAGER.get_piece_data(current_coords,Scripts.PIECE_CONSTS.PIECE_LIST.PIECE_COLOR) == Scripts.PIECE_CONSTS.PIECE_COLOR.WHITE:
				direction = 1
			elif Scripts.PIECE_MANAGER.get_piece_data(current_coords,Scripts.PIECE_CONSTS.PIECE_LIST.PIECE_COLOR) == Scripts.PIECE_CONSTS.PIECE_COLOR.BLACK:
				direction = -1
			# Update PAWN_MOVED_TWO_TILES
			if asked_coords.x == current_coords.x +direction*2:
				print("GET_MOVE- MADE PAWN TWO TILE MOVE")
				Scripts.PIECE_MANAGER.set_piece_data(current_coords,Scripts.PIECE_CONSTS.PIECE_LIST.PAWN_MOVED_TWO_TILES,Scripts.PIECE_CONSTS.PAWN_MOVED_TWO_TILES.TRUE)
			# Apply En Passant Rules
			if asked_coords.y != current_coords.y:
				if Scripts.BOARD_DATABASE.TILE_DICTIONARY[asked_coords]["piece"] == 0:
					var en_passant_coords:Vector2i = Vector2i(current_coords.x,asked_coords.y)
					print("GET_MOVE- en_passant_coords: ",en_passant_coords)
					capture_piece(en_passant_coords)
					Scripts.BOARD_DATABASE.TILE_DICTIONARY[en_passant_coords]["piece"] = 0
		
		# If Moved Piece is King
		if Scripts.PIECE_MANAGER.get_piece_data(current_coords,Scripts.PIECE_CONSTS.PIECE_LIST.TYPE) == Scripts.PIECE_CONSTS.TYPE_LIST.KING:
			if Scripts.PIECE_MANAGER.get_piece_data(current_coords,Scripts.PIECE_CONSTS.PIECE_LIST.TIMES_MOVED) == 0:
				if asked_coords.y == current_coords.y +2:
					print("gay")
		
		move_piece(current_coords,asked_coords)
		
		# Modify color_turn, keeps track of whose turn it is
		if Scripts.color_turn == Scripts.PIECE_CONSTS.PIECE_COLOR.WHITE:
			Scripts.color_turn = Scripts.PIECE_CONSTS.PIECE_COLOR.BLACK
		else:
			Scripts.color_turn = Scripts.PIECE_CONSTS.PIECE_COLOR.WHITE
		Scripts.turn_amount += 1
		print("GET_MOVE- TURN AMOUNT: ",Scripts.turn_amount)
	
	else:
		print("GET_MOVE- COORDS NOT IN _MOVES!")
	
	return

static func move_piece(current_coords:Vector2i,asked_coords:Vector2i) -> void: # Captures Pieces, Upates Dictionaries and moves Piece
	
	# Capture Enemy Piece
	if is_enemy(current_coords,asked_coords): # Add advanced logic for capturing here later if needed
		capture_piece(asked_coords)
	
	var piece:int = Scripts.BOARD_DATABASE.TILE_DICTIONARY[current_coords]["piece"]
	
	# Remove Old Data
	Scripts.BOARD_DATABASE.TILE_DICTIONARY[current_coords]["piece"] = 0
	
	# Write New Data
	Scripts.BOARD_DATABASE.TILE_DICTIONARY[asked_coords]["piece"] = piece
	var times_moved:int = Scripts.PIECE_MANAGER.get_piece_data(asked_coords,Scripts.PIECE_CONSTS.PIECE_LIST.TIMES_MOVED)
	times_moved += 1
	Scripts.PIECE_MANAGER.set_piece_data(asked_coords,Scripts.PIECE_CONSTS.PIECE_LIST.TIMES_MOVED,times_moved)
	print("MOVE_PIECE- TIMES_MOVED: ",times_moved)
	
	# Update King Position for Checkmate
	if current_coords == white_king_pos:
		white_king_pos = asked_coords
	elif current_coords == black_king_pos:
		black_king_pos = asked_coords
	
	# Move Piece
	var piece_object:Node2D = Scripts.PIECE_MANAGER.get_piece_data(asked_coords,Scripts.PIECE_CONSTS.PIECE_LIST.PIECE_OBJ)
	var translated_coords:Vector2 = Scripts.BOARD_MANAGER.get_mouse_from_tile(asked_coords)
	piece_object.global_position = translated_coords
	piece_object.move_local_y(-96)

static func capture_piece(asked_coords:Vector2i) -> void:
	var enemy_piece_object:Node2D = Scripts.PIECE_MANAGER.get_piece_data(asked_coords,Scripts.PIECE_CONSTS.PIECE_LIST.PIECE_OBJ)
	enemy_piece_object.hide()
	Scripts.fifty_move_rule = 0 # If Captured Piece Rule is Reset
	print("CAPTURE_PIECE- Enemy Piece Captured at: ",asked_coords)

static func is_empty(asked_coords:Vector2i) -> bool:
	if Scripts.PIECE_MANAGER.get_piece_data(asked_coords,Scripts.PIECE_CONSTS.PIECE_LIST.TYPE) == Scripts.PIECE_LIST.NONE:
		return true
	return false

static func is_enemy(coords:Vector2i,asked_coords:Vector2i) -> bool: # Checks if piece on coords is diffrent team than piece on asked_coords
	if Scripts.PIECE_MANAGER.get_piece_data(coords,Scripts.PIECE_CONSTS.PIECE_LIST.PIECE_COLOR) == Scripts.PIECE_CONSTS.PIECE_COLOR.WHITE:
		if Scripts.PIECE_MANAGER.get_piece_data(asked_coords,Scripts.PIECE_CONSTS.PIECE_LIST.PIECE_COLOR) == Scripts.PIECE_CONSTS.PIECE_COLOR.BLACK:
			return true
	elif Scripts.PIECE_MANAGER.get_piece_data(asked_coords,Scripts.PIECE_CONSTS.PIECE_LIST.PIECE_COLOR) == Scripts.PIECE_CONSTS.PIECE_COLOR.WHITE:
		return true
	return false

static func is_in_check() -> bool: # Checks if King is in check
	var king_pos:Vector2i
	var _is_in_check:bool = false
	if Scripts.color_turn == Scripts.PIECE_CONSTS.PIECE_COLOR.WHITE:
		king_pos = white_king_pos
	else:
		king_pos = black_king_pos
	
	var pawn_direction:int
	if Scripts.color_turn == Scripts.PIECE_CONSTS.PIECE_COLOR.WHITE:
		pawn_direction = 1
	else:
		pawn_direction = -1
	
	var pawn_attacks:Array = [king_pos + Vector2i(pawn_direction,-1),king_pos + Vector2i(pawn_direction,1)]
	
	for pos:Vector2i in pawn_attacks:
		if Scripts.BOARD_MANAGER.is_valid_position(pos):
			if is_enemy(king_pos,pos):
				var piece:int = Scripts.PIECE_MANAGER.get_piece_data(pos,Scripts.PIECE_CONSTS.PIECE_LIST.TYPE)
				if piece == Scripts.PIECE_CONSTS.TYPE_LIST.PAWN:
					print("PIECE_MOVE- pawn_check")
					_is_in_check = true
	
	for pos:Vector2i in _get_knight_moves(king_pos):
		var piece:int = Scripts.PIECE_MANAGER.get_piece_data(pos,Scripts.PIECE_CONSTS.PIECE_LIST.TYPE)
		if piece == Scripts.PIECE_CONSTS.TYPE_LIST.KNIGHT:
			print("PIECE_MOVE- knight_check")
			_is_in_check = true
	
	for pos:Vector2i in _get_rook_moves(king_pos):
		var piece:int = Scripts.PIECE_MANAGER.get_piece_data(pos,Scripts.PIECE_CONSTS.PIECE_LIST.TYPE)
		if piece == Scripts.PIECE_CONSTS.TYPE_LIST.ROOK:
			print("PIECE_MOVE- rook_check")
			_is_in_check = true
		elif piece == Scripts.PIECE_CONSTS.TYPE_LIST.QUEEN:
			print("PIECE_MOVE- queen_check")
			_is_in_check = true
	
	for pos:Vector2i in _get_bishop_moves(king_pos):
		var piece:int = Scripts.PIECE_MANAGER.get_piece_data(pos,Scripts.PIECE_CONSTS.PIECE_LIST.TYPE)
		if piece == Scripts.PIECE_CONSTS.TYPE_LIST.BISHOP:
			print("PIECE_MOVE- bishop_check")
			_is_in_check = true
		elif piece == Scripts.PIECE_CONSTS.TYPE_LIST.QUEEN:
			print("PIECE_MOVE- queen_check")
			_is_in_check = true
	
	for x in range(-1,2):
		for y in range(-1,2):
			var pos:Vector2i = king_pos
			pos.x += x
			pos.y += y
			
			if Scripts.BOARD_MANAGER.is_valid_position(pos):
				if is_enemy(king_pos,pos):
					print("PIECE_MOVE- king_check????????????????")
					_is_in_check = true
	
	return _is_in_check

## private methods

static func _get_pawn_moves(current_coords:Vector2i) -> Array:
	_moves = []
	var move_range:Array
	var capture_squares:Array
	if Scripts.PIECE_MANAGER.get_piece_data(current_coords,Scripts.PIECE_CONSTS.PIECE_LIST.PIECE_COLOR) == Scripts.PIECE_CONSTS.PIECE_COLOR.WHITE:
		capture_squares = [Vector2i(1,1),Vector2i(1,-1)]
		if Scripts.PIECE_MANAGER.get_piece_data(current_coords,Scripts.PIECE_CONSTS.PIECE_LIST.TIMES_MOVED) == 0:
			move_range = range(1,3)
		else:
			move_range = range(1,2)
	else:
		capture_squares = [Vector2i(-1,-1),Vector2i(-1,1)]
		if Scripts.PIECE_MANAGER.get_piece_data(current_coords,Scripts.PIECE_CONSTS.PIECE_LIST.TIMES_MOVED) == 0:
			move_range = range(-2,1)
		else:
			move_range = range(-1,1)
	
	# Main Movement
	for i:int in move_range:
		var pos:Vector2i = current_coords
		pos.x += i
		if Scripts.BOARD_MANAGER.is_valid_position(pos):
			if is_empty(pos):
				_moves.append(pos)
	
	# Piece Capturing
	for i:Vector2i in capture_squares:
		var pos:Vector2i = current_coords + i
		if Scripts.BOARD_MANAGER.is_valid_position(pos):
			if is_enemy(current_coords,pos):
				_moves.append(pos)
		# En Passant Rules
		var pos_passant:Vector2i = Vector2i(current_coords.x,pos.y)
		if Scripts.BOARD_MANAGER.is_valid_position(pos_passant):
			if is_enemy(current_coords,pos_passant):
				if Scripts.PIECE_MANAGER.get_piece_data(pos_passant,Scripts.PIECE_CONSTS.PIECE_LIST.TIMES_MOVED) == 1: # Bug if 1 En Passant is possible both appear
					print("pos: ",pos,"pos_passant: ",pos_passant)
					if Scripts.PIECE_MANAGER.get_piece_data(pos_passant,Scripts.PIECE_CONSTS.PIECE_LIST.PAWN_MOVED_TWO_TILES) == Scripts.PIECE_CONSTS.PAWN_MOVED_TWO_TILES.TRUE:
						_moves.append(pos)
	
	return _moves

static func _get_knight_moves(current_coords:Vector2i) -> Array: # Idk if this is the best it can be, but maybe it is
	_moves = []
	
	for i:Vector2i in knight_directions:
		var pos:Vector2i = current_coords
		pos += i
		if Scripts.BOARD_MANAGER.is_valid_position(pos):
			if is_empty(pos):
				_moves.append(pos)
			elif is_enemy(current_coords,pos):
				_moves.append(pos)
	
	return _moves

static func _get_rook_moves(current_coords:Vector2i) -> Array:
	_moves = []
	
	for i:Vector2i in rook_directions:
		var pos:Vector2i = current_coords
		pos += i
		
		while Scripts.BOARD_MANAGER.is_valid_position(pos):
			if is_empty(pos):
				_moves.append(pos)
			elif is_enemy(current_coords,pos):
				_moves.append(pos)
				break
			else: break
			
			pos +=i
	
	return _moves

static func _get_bishop_moves(current_coords:Vector2i) -> Array:
	_moves = []
	
	for i:Vector2i in bishop_directions:
		var pos:Vector2i = current_coords
		pos += i
		
		while Scripts.BOARD_MANAGER.is_valid_position(pos):
			if is_empty(pos):
				_moves.append(pos)
			elif is_enemy(current_coords,pos):
				_moves.append(pos)
				break
			else: break
			
			pos +=i
	
	return _moves

static func _get_king_moves(current_coords:Vector2i) -> Array:
	_moves = []
	
	for x in range(-1,2):
		for y in range(-1,2):
			var pos:Vector2i = current_coords
			pos.x += x
			pos.y += y
			
			if Scripts.BOARD_MANAGER.is_valid_position(pos):
				if is_empty(pos):
					_moves.append(pos)
				elif is_enemy(current_coords,pos):
					_moves.append(pos)
	
	
	# Castling
	if Scripts.PIECE_MANAGER.get_piece_data(current_coords,Scripts.PIECE_CONSTS.PIECE_LIST.TIMES_MOVED) == 0:
		if Scripts.PIECE_MANAGER.get_piece_data(Vector2i(current_coords.x,current_coords.y + 3),Scripts.PIECE_CONSTS.PIECE_LIST.TYPE) == Scripts.PIECE_CONSTS.TYPE_LIST.ROOK:
			if Scripts.PIECE_MANAGER.get_piece_data(Vector2i(current_coords.x,current_coords.y + 3),Scripts.PIECE_CONSTS.PIECE_LIST.TIMES_MOVED) == 0:
				if is_empty(Vector2i(current_coords.x,current_coords.y + 1)):
					if is_empty(Vector2i(current_coords.x,current_coords.y + 2)):
						_moves.append(Vector2i(current_coords.x,current_coords.y + 2))
	
	return _moves
