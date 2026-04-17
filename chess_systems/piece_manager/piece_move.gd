extends RefCounted
## enums
## consts
## exports
## public vars
static var knight_directions:Array = [Vector2i(1,2),Vector2i(-1,2), Vector2i(1,-2),Vector2i(-1,-2), Vector2i(2,1),Vector2i(2,-1), Vector2i(-2,1),Vector2i(-2,-1)]
static var rook_directions:Array = [Vector2i(0,1), Vector2i(0,-1), Vector2i(1,0), Vector2i(-1,0)]
static var bishop_directions:Array = [Vector2i(1,1), Vector2i(1,-1), Vector2i(-1,1), Vector2i(-1,-1)]

static var white_king_pos:Vector2i = Vector2i(0,0)
static var black_king_pos:Vector2i = Vector2i(0,0)

static var king_pos:Vector2i = white_king_pos
static var opponent_king_pos:Vector2i = black_king_pos
static var got_all_moves:bool = false
static var king_check:Array = []
static var opponent_king_check:Array = []
## private vars
## onready vars
# obj_ for node refrences
## built-in override methods
## public methods

static func get_all_moves() -> void:
	king_check.clear()
	opponent_king_check.clear()
	for coords:Vector2i in Scripts.DATABASE.TILE_DICTIONARY:
		if !is_empty(coords):
			var _moves:Array = get_moves(coords)
			if _moves.has(king_pos):
				king_check.append(coords)
			if _moves.has(opponent_king_pos):
				opponent_king_check.append(coords)
			Scripts.PIECE_MANAGER.set_piece_data(coords,Scripts.CONSTANTS.PIECE_LIST.MOVE_ARRAY,_moves)
	got_all_moves = true
	print("check pieces: ",king_check," opponent: ",opponent_king_check)

static func get_moves(current_coords:Vector2i) -> Array:
	var _moves:Array = []
	
	match abs(Scripts.PIECE_MANAGER.get_piece_data(current_coords,Scripts.CONSTANTS.PIECE_LIST.PIECE_TYPE)): # Checks which Piece, then gets Moves
		Scripts.CONSTANTS.PIECE_TYPE.PAWN:
			_moves = _get_pawn_moves(current_coords)
		Scripts.CONSTANTS.PIECE_TYPE.ROOK:
			_moves = _get_rook_moves(current_coords)
		Scripts.CONSTANTS.PIECE_TYPE.KNIGHT:
			_moves = _get_knight_moves(current_coords)
		Scripts.CONSTANTS.PIECE_TYPE.BISHOP:
			_moves = _get_bishop_moves(current_coords)
		Scripts.CONSTANTS.PIECE_TYPE.QUEEN:
			_moves = _get_rook_moves(current_coords) + _get_bishop_moves(current_coords)
		Scripts.CONSTANTS.PIECE_TYPE.KING:
			_moves = _get_king_moves(current_coords)
	
	return _moves

static func make_move(current_coords:Vector2i,asked_coords:Vector2i,_moves:Array) -> void: # Calls all funcs used for movement
	if asked_coords in _moves:
		Scripts.DATABASE.fifty_move_rule += 1 # For each Turn Rule +=1
		
		# If Moved Piece is Pawn
		if Scripts.PIECE_MANAGER.get_piece_data(current_coords,Scripts.CONSTANTS.PIECE_LIST.PIECE_TYPE) == Scripts.CONSTANTS.PIECE_TYPE.PAWN:
			Scripts.DATABASE.fifty_move_rule = 0 # If Pawn is Moved Rule is Reset
			print("MAKE_MOVE- MOVED PIECE IS PAWN")
			# Get Direction
			var direction:int = 0
			if Scripts.PIECE_MANAGER.get_piece_data(current_coords,Scripts.CONSTANTS.PIECE_LIST.PIECE_COLOR) == Scripts.CONSTANTS.PIECE_COLOR.WHITE:
				direction = 1
			elif Scripts.PIECE_MANAGER.get_piece_data(current_coords,Scripts.CONSTANTS.PIECE_LIST.PIECE_COLOR) == Scripts.CONSTANTS.PIECE_COLOR.BLACK:
				direction = -1
			# Update PAWN_MOVED_TWO_TILES
			if asked_coords.x == current_coords.x +direction*2:
				print("MAKE_MOVE- MADE PAWN TWO TILE MOVE")
				Scripts.PIECE_MANAGER.set_piece_data(current_coords,Scripts.CONSTANTS.PIECE_LIST.PAWN_MOVED_TWO_TILES,Scripts.CONSTANTS.PAWN_MOVED_TWO_TILES.TRUE)
			# Apply En Passant Rules
			if asked_coords.y != current_coords.y:
				if Scripts.DATABASE.TILE_DICTIONARY[asked_coords]["piece"] == 0:
					var en_passant_coords:Vector2i = Vector2i(current_coords.x,asked_coords.y)
					print("MAKE_MOVE- en_passant_coords: ",en_passant_coords)
					capture_piece(en_passant_coords)
					Scripts.DATABASE.TILE_DICTIONARY[en_passant_coords]["piece"] = 0
		
		# If Moved Piece is King
		if Scripts.PIECE_MANAGER.get_piece_data(current_coords,Scripts.CONSTANTS.PIECE_LIST.PIECE_TYPE) == Scripts.CONSTANTS.PIECE_TYPE.KING:
			if Scripts.PIECE_MANAGER.get_piece_data(current_coords,Scripts.CONSTANTS.PIECE_LIST.TIMES_MOVED) == 0:
				# Apply Castling
				if asked_coords.y == current_coords.y +2:
					var rook_coords:Vector2i = Vector2i(current_coords.x,current_coords.y +3)
					var rook_dest_coords:Vector2i = Vector2i(current_coords.x,current_coords.y +1)
					move_piece(rook_coords,rook_dest_coords)
		
		move_piece(current_coords,asked_coords)
		
		post_move()
	
	else:
		print("MAKE_MOVE- COORDS NOT IN _MOVES!")
	
	return

static func move_piece(current_coords:Vector2i,asked_coords:Vector2i) -> void: # Captures Pieces, Upates Dictionaries and moves Piece
	
	# Capture Enemy Piece
	if is_enemy(current_coords,asked_coords): # Add advanced logic for capturing here later if needed
		capture_piece(asked_coords)
	
	var piece:int = Scripts.DATABASE.TILE_DICTIONARY[current_coords]["piece"]
	
	# Remove Old Data
	Scripts.DATABASE.TILE_DICTIONARY[current_coords]["piece"] = 0
	
	# Write New Data
	Scripts.DATABASE.TILE_DICTIONARY[asked_coords]["piece"] = piece
	var times_moved:int = Scripts.PIECE_MANAGER.get_piece_data(asked_coords,Scripts.CONSTANTS.PIECE_LIST.TIMES_MOVED)
	times_moved += 1
	Scripts.PIECE_MANAGER.set_piece_data(asked_coords,Scripts.CONSTANTS.PIECE_LIST.TIMES_MOVED,times_moved)
	print("MOVE_PIECE- TIMES_MOVED: ",times_moved)
	
	# Update King Position for Checkmate
	if current_coords == white_king_pos:
		white_king_pos = asked_coords
	elif current_coords == black_king_pos:
		black_king_pos = asked_coords
	
	# Move Piece
	var piece_object:Node2D = Scripts.PIECE_MANAGER.get_piece_data(asked_coords,Scripts.CONSTANTS.PIECE_LIST.PIECE_OBJ)
	var translated_coords:Vector2 = Scripts.BOARD_MANAGER.get_mouse_from_tile(asked_coords)
	piece_object.global_position = translated_coords
	piece_object.move_local_y(-96)
	
	Scripts.SELECTION_MANAGER._moved.erase(piece_object) # TEMP FIX. CHANGE LATER !!!!!!!

static func post_move() -> void: # Stuff to Do After Move was Called
	# Modify color_turn, keeps track of whose turn it is
	if Scripts.DATABASE.color_turn == Scripts.CONSTANTS.PIECE_COLOR.WHITE:
		Scripts.DATABASE.color_turn = Scripts.CONSTANTS.PIECE_COLOR.BLACK
	else:
		Scripts.DATABASE.color_turn = Scripts.CONSTANTS.PIECE_COLOR.WHITE
		
	# Increment Turn Amount
	Scripts.DATABASE.turn_amount += 1
	print("MAKE_MOVE- TURN AMOUNT: ",Scripts.DATABASE.turn_amount)
	
	# Update king_pos depending on whose turn it is
	if Scripts.DATABASE.color_turn == Scripts.CONSTANTS.PIECE_COLOR.WHITE:
		king_pos = white_king_pos
		opponent_king_pos = black_king_pos
	else:
		king_pos = black_king_pos
		opponent_king_pos = white_king_pos
	
	get_all_moves() # Set New Data

static func is_in_check() -> bool: # Returns True if Piece on check_pos is in check
	if king_check.size() > 0:
		return true
	return false

static func capture_piece(asked_coords:Vector2i) -> void: # Captures The Piece on the Given Tile
	var enemy_piece_object:Node2D = Scripts.PIECE_MANAGER.get_piece_data(asked_coords,Scripts.CONSTANTS.PIECE_LIST.PIECE_OBJ)
	enemy_piece_object.hide()
	Scripts.DATABASE.fifty_move_rule = 0 # If Captured Piece Rule is Reset
	print("CAPTURE_PIECE- Enemy Piece Captured at: ",asked_coords)

static func is_empty(asked_coords:Vector2i) -> bool: # Checks if Tile is Empty, duh
	if Scripts.PIECE_MANAGER.get_piece_data(asked_coords,Scripts.CONSTANTS.PIECE_LIST.PIECE_TYPE) == Scripts.CONSTANTS.PIECE_TYPE.NONE:
		return true
	return false

static func is_enemy(coords:Vector2i,asked_coords:Vector2i) -> bool: # Checks if piece on coords is diffrent team than piece on asked_coords
	if Scripts.PIECE_MANAGER.get_piece_data(coords,Scripts.CONSTANTS.PIECE_LIST.PIECE_COLOR) == Scripts.CONSTANTS.PIECE_COLOR.WHITE:
		if Scripts.PIECE_MANAGER.get_piece_data(asked_coords,Scripts.CONSTANTS.PIECE_LIST.PIECE_COLOR) == Scripts.CONSTANTS.PIECE_COLOR.BLACK:
			return true
	elif Scripts.PIECE_MANAGER.get_piece_data(asked_coords,Scripts.CONSTANTS.PIECE_LIST.PIECE_COLOR) == Scripts.CONSTANTS.PIECE_COLOR.WHITE:
		return true
	return false

## private methods

static func _get_pawn_moves(current_coords:Vector2i) -> Array:
	var _moves:Array = []
	var move_range:Array
	var capture_squares:Array
	if Scripts.PIECE_MANAGER.get_piece_data(current_coords,Scripts.CONSTANTS.PIECE_LIST.PIECE_COLOR) == Scripts.CONSTANTS.PIECE_COLOR.WHITE:
		capture_squares = [Vector2i(1,1),Vector2i(1,-1)]
		if Scripts.PIECE_MANAGER.get_piece_data(current_coords,Scripts.CONSTANTS.PIECE_LIST.TIMES_MOVED) == 0:
			move_range = range(1,3)
		else:
			move_range = range(1,2)
	else:
		capture_squares = [Vector2i(-1,-1),Vector2i(-1,1)]
		if Scripts.PIECE_MANAGER.get_piece_data(current_coords,Scripts.CONSTANTS.PIECE_LIST.TIMES_MOVED) == 0:
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
				if Scripts.PIECE_MANAGER.get_piece_data(pos_passant,Scripts.CONSTANTS.PIECE_LIST.PIECE_TYPE) == Scripts.CONSTANTS.PIECE_TYPE.PAWN:
					if Scripts.PIECE_MANAGER.get_piece_data(pos_passant,Scripts.CONSTANTS.PIECE_LIST.TIMES_MOVED) == 1: # Bug if 1 En Passant is possible both appear
						if Scripts.PIECE_MANAGER.get_piece_data(pos_passant,Scripts.CONSTANTS.PIECE_LIST.PAWN_MOVED_TWO_TILES) == Scripts.CONSTANTS.PAWN_MOVED_TWO_TILES.TRUE:
							_moves.append(pos)
	
	return _moves

static func _get_knight_moves(current_coords:Vector2i) -> Array: # TODO: Prob can Make this a little bit better !!!
	var _moves:Array = []
	
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
	var _moves:Array = []
	
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
	var _moves:Array = []
	
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

static func _get_king_moves(current_coords:Vector2i) -> Array: # TODO: Wow I just discovered how absolutely shit the Castling Code is. FIX IN FUTURE!!!!
	var _moves:Array = []
	
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
	if Scripts.PIECE_MANAGER.get_piece_data(current_coords,Scripts.CONSTANTS.PIECE_LIST.TIMES_MOVED) == 0:
		if Scripts.PIECE_MANAGER.get_piece_data(Vector2i(current_coords.x,current_coords.y + 3),Scripts.CONSTANTS.PIECE_LIST.PIECE_TYPE) == Scripts.CONSTANTS.PIECE_TYPE.ROOK:
			if Scripts.PIECE_MANAGER.get_piece_data(Vector2i(current_coords.x,current_coords.y + 3),Scripts.CONSTANTS.PIECE_LIST.TIMES_MOVED) == 0:
				if is_empty(Vector2i(current_coords.x,current_coords.y + 1)):
					if is_empty(Vector2i(current_coords.x,current_coords.y + 2)):
						_moves.append(Vector2i(current_coords.x,current_coords.y + 2))
	
	return _moves
