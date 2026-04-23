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

static var king_pos:Vector2i = Vector2i(0,0)
static var king_checked_from:Array = []

static var between_moves:Array = []
static var all_valid_moves:Dictionary = {}
## private vars
## onready vars
# obj_ for node refrences
## built-in override methods
## public methods

static func get_all_moves() -> void: # Ran After A Move is Made. TODO: Make Pieces not Move if Moving will put King under Check. Use: get_tiles_between_points
	var _all_moves:Dictionary = {}
	# Clear Old Data
	king_checked_from.clear()
	
	
	
	
	king_checked_from = Scripts.PIECE_CHECK.get_check_coords(king_pos)
	if Scripts.PIECE_MANAGER.is_in_check():
		print("GET_ALL_MOVES- Pieces Checking King: ",king_checked_from)
		between_moves.clear()
		# Get Moves that will stop check
		for checking_piece:Vector2i in king_checked_from:
			between_moves.append_array(get_tiles_between_points(checking_piece,king_pos))
	
	# Get Moves of all Pieces
	for piece_coords:Vector2i in Scripts.DATABASE.TILE_DICTIONARY:
		if !Scripts.PIECE_MANAGER.is_empty(piece_coords):
			if !Scripts.PIECE_MANAGER.is_enemy(piece_coords):
				var _moves:Array = get_moves(piece_coords)
				_all_moves[piece_coords] = _moves
	
	# If no Moves Available, Lose
	if _all_moves.is_empty():
		Scripts.DATABASE.is_lost = true
		return
	
	# Put Moves into The Database
	for piece_coords:Vector2i in _all_moves:
		var valid_moves:Array = _all_moves[piece_coords]
		Scripts.PIECE_MANAGER.clear_piece_data(piece_coords,Scripts.CONSTANTS.PIECE_LIST.MOVE_ARRAY)
		Scripts.PIECE_MANAGER.set_piece_data(piece_coords,Scripts.CONSTANTS.PIECE_LIST.MOVE_ARRAY,valid_moves)

static func get_moves(current_coords:Vector2i) -> Array: # Gets All Valid Moves for the Requested Piece
	var _moves:Array = []
	var piece_type:int = Scripts.PIECE_MANAGER.get_piece_data(current_coords,Scripts.CONSTANTS.PIECE_LIST.PIECE_TYPE)
	
	match abs(piece_type): # Checks which Piece, then gets Moves
		Scripts.CONSTANTS.PIECE_TYPE.PAWN:
			_moves = _get_pawn_moves(current_coords)
		Scripts.CONSTANTS.PIECE_TYPE.ROOK:
			_moves = _get_rook_moves(current_coords,true)
		Scripts.CONSTANTS.PIECE_TYPE.KNIGHT:
			_moves = _get_knight_moves(current_coords)
		Scripts.CONSTANTS.PIECE_TYPE.BISHOP:
			_moves = _get_bishop_moves(current_coords,true)
		Scripts.CONSTANTS.PIECE_TYPE.QUEEN:
			_moves = _get_rook_moves(current_coords,true) + _get_bishop_moves(current_coords,true)
		Scripts.CONSTANTS.PIECE_TYPE.KING:
			_moves = _get_king_moves(current_coords)
	
	# Only Write Valid Moves that will Stop Check
	var _valid_moves:Array = []
	for move_coords:Vector2i in _moves:
		if piece_type == Scripts.CONSTANTS.PIECE_TYPE.KING:
			if Scripts.PIECE_CHECK.get_check_coords(move_coords).is_empty():
				_valid_moves.append(move_coords)
			continue
		
		if Scripts.PIECE_MANAGER.is_in_check():
			if move_coords in between_moves:
				_valid_moves.append(move_coords)
		else:
			_valid_moves = _moves
	
	print("GET_MOVES- these da piece: ",current_coords," these da movez: ",_valid_moves)
	return _valid_moves

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
					_capture_piece(en_passant_coords)
					Scripts.DATABASE.TILE_DICTIONARY[en_passant_coords]["piece"] = 0
		
		# If Moved Piece is King
		if Scripts.PIECE_MANAGER.get_piece_data(current_coords,Scripts.CONSTANTS.PIECE_LIST.PIECE_TYPE) == Scripts.CONSTANTS.PIECE_TYPE.KING:
			if Scripts.PIECE_MANAGER.get_piece_data(current_coords,Scripts.CONSTANTS.PIECE_LIST.TIMES_MOVED) == 0:
				# Apply Castling
				if asked_coords.y == current_coords.y +2:
					var rook_coords:Vector2i = Vector2i(current_coords.x,current_coords.y +3)
					var rook_dest_coords:Vector2i = Vector2i(current_coords.x,current_coords.y +1)
					_move_piece(rook_coords,rook_dest_coords)
		
		_move_piece(current_coords,asked_coords)
		
		_post_move()
	
	else:
		print("MAKE_MOVE- COORDS NOT IN _MOVES!")
	
	return

static func get_tiles_between_points(starting_pos:Vector2i,target_pos:Vector2i) -> Array: # Returns starting_pos + Array of all Positions between the two Points
	var value_x:int
	var value_y:int
	
	if starting_pos.x < target_pos.x:
		value_x = 1
	elif starting_pos.x == target_pos.x:
		value_x = 0
	else:
		value_x = -1
		
	if starting_pos.y < target_pos.y:
		value_y = 1
	elif starting_pos.y == target_pos.y:
		value_y = 0
	else:
		value_y = -1
	
	#print("GET_TILES_BETWEEN_POINTS- step values: ",Vector2i(value_x,value_y))
	var step:Vector2i = Vector2i(starting_pos)
	var _steps:Array = []
	
	while step != target_pos:
		_steps.append(step)
		if step.x != target_pos.x:
			step.x += value_x
		if step.y != target_pos.y:
			step.y += value_y
		#print("GET_TILES_BETWEEN_POINTS- steps +1")
		
	#print("GET_TILES_BETWEEN_POINTS- steps: ",_steps)
	
	return _steps

## private methods

static func _move_piece(current_coords:Vector2i,asked_coords:Vector2i) -> void: # Captures Pieces, Upates Dictionaries and moves Piece
	
	# Capture Enemy Piece
	if Scripts.PIECE_MANAGER.is_enemy(asked_coords): # Add advanced logic for capturing here later if needed
		_capture_piece(asked_coords)
	
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
	
	Scripts.PIECE_ANIMATE.moved.erase(piece_object) # TEMP FIX. CHANGE LATER !!!!!!!

static func _post_move() -> void: # Stuff to Do After Move was Called
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
	else:
		king_pos = black_king_pos
	
	get_all_moves()

static func _capture_piece(asked_coords:Vector2i) -> void: # Captures The Piece on the Given Tile
	var enemy_piece_object:Node2D = Scripts.PIECE_MANAGER.get_piece_data(asked_coords,Scripts.CONSTANTS.PIECE_LIST.PIECE_OBJ)
	enemy_piece_object.hide()
	Scripts.DATABASE.fifty_move_rule = 0 # If Captured Piece Rule is Reset
	print("CAPTURE_PIECE- Enemy Piece Captured at: ",asked_coords)

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
			if Scripts.PIECE_MANAGER.is_empty(pos):
				_moves.append(pos)
	
	# Piece Capturing
	for i:Vector2i in capture_squares:
		var pos:Vector2i = current_coords + i
		if Scripts.BOARD_MANAGER.is_valid_position(pos):
			if Scripts.PIECE_MANAGER.is_enemy(pos):
				_moves.append(pos)
		# En Passant Rules
		var pos_passant:Vector2i = Vector2i(current_coords.x,pos.y)
		if Scripts.BOARD_MANAGER.is_valid_position(pos_passant):
			if Scripts.PIECE_MANAGER.is_enemy(pos_passant):
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
			if Scripts.PIECE_MANAGER.is_empty(pos):
				_moves.append(pos)
			elif Scripts.PIECE_MANAGER.is_enemy(pos):
				_moves.append(pos)
	
	return _moves

static func _get_rook_moves(current_coords:Vector2i,getting_moves:bool) -> Array:
	var _moves:Array = []
	
	for i:Vector2i in rook_directions:
		var pos:Vector2i = current_coords
		pos += i
		
		while Scripts.BOARD_MANAGER.is_valid_position(pos):
			if Scripts.PIECE_MANAGER.is_empty(pos):
				_moves.append(pos)
			elif Scripts.PIECE_MANAGER.is_enemy(pos):
				_moves.append(pos)
				break
			elif getting_moves:
				break
			
			pos +=i
	
	return _moves

static func _get_bishop_moves(current_coords:Vector2i,getting_moves:bool) -> Array:
	var _moves:Array = []
	
	for i:Vector2i in bishop_directions:
		var pos:Vector2i = current_coords
		pos += i
		
		while Scripts.BOARD_MANAGER.is_valid_position(pos):
			if Scripts.PIECE_MANAGER.is_empty(pos):
				_moves.append(pos)
			elif Scripts.PIECE_MANAGER.is_enemy(pos):
				_moves.append(pos)
				break
			elif getting_moves:
				break
			
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
				if Scripts.PIECE_MANAGER.is_empty(pos):
					_moves.append(pos)
				elif Scripts.PIECE_MANAGER.is_enemy(pos):
					_moves.append(pos)
	
	
	# Castling
	if Scripts.PIECE_MANAGER.get_piece_data(current_coords,Scripts.CONSTANTS.PIECE_LIST.TIMES_MOVED) == 0:
		if Scripts.PIECE_MANAGER.get_piece_data(Vector2i(current_coords.x,current_coords.y + 3),Scripts.CONSTANTS.PIECE_LIST.PIECE_TYPE) == Scripts.CONSTANTS.PIECE_TYPE.ROOK:
			if Scripts.PIECE_MANAGER.get_piece_data(Vector2i(current_coords.x,current_coords.y + 3),Scripts.CONSTANTS.PIECE_LIST.TIMES_MOVED) == 0:
				if Scripts.PIECE_MANAGER.is_empty(Vector2i(current_coords.x,current_coords.y + 1)):
					if Scripts.PIECE_MANAGER.is_empty(Vector2i(current_coords.x,current_coords.y + 2)):
						_moves.append(Vector2i(current_coords.x,current_coords.y + 2))
	
	return _moves
