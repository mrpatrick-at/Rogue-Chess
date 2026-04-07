extends RefCounted
## enums
## consts
## exports
## public vars
static var _moves:Array
static var directions:Array
static var current_coords:Vector2i
## private vars
## onready vars
# obj_ for node refrences
## built-in override methods
## public methods

static func get_moves(coords:Vector2i) -> Array:
	_moves = []
	current_coords = coords
	match abs(Scripts.PIECE_MANAGER.get_piece_data(current_coords,Scripts.PIECE_CONSTS.PIECE_LIST.TYPE)):
		Scripts.PIECE_CONSTS.TYPE_LIST.PAWN:
			_moves = _get_pawn_moves()
		Scripts.PIECE_CONSTS.TYPE_LIST.ROOK:
			_moves = _get_rook_moves()
		Scripts.PIECE_CONSTS.TYPE_LIST.KNIGHT:
			_moves = _get_knight_moves()
		Scripts.PIECE_CONSTS.TYPE_LIST.BISHOP:
			_moves = _get_bishop_moves()
		Scripts.PIECE_CONSTS.TYPE_LIST.QUEEN:
			_moves = _get_rook_moves() + _get_bishop_moves()
		Scripts.PIECE_CONSTS.TYPE_LIST.KING:
			_moves = _get_king_moves()
	#print("piece_move/get_moves- _moves: ",_moves)
	return _moves

static func move_piece(current_coords:Vector2i,asked_coords:Vector2i) -> void: # Calls all funcs used for movement
	if asked_coords in _moves:
		var piece:int = Scripts.BOARD_DATABASE.TILE_DICTIONARY[current_coords]["piece"]
		var translated_coords:Vector2 = Scripts.BOARD_MANAGER.translate_coords(asked_coords)
		
		# Capture Enemy Piece
		if is_enemy(asked_coords): # Add advanced logic for capturing here later if needed
			var enemy_piece_object = Scripts.PIECE_MANAGER.get_piece_data(asked_coords,Scripts.PIECE_CONSTS.PIECE_LIST.PIECE_OBJ)
			enemy_piece_object.hide()
			print("Enemy Piece Captured")
		
		# Remove Old Data
		Scripts.BOARD_DATABASE.TILE_DICTIONARY[current_coords]["piece"] = 0
		
		# Add New Data
		Scripts.BOARD_DATABASE.TILE_DICTIONARY[asked_coords]["piece"] = piece
		Scripts.PIECE_MANAGER.set_piece_data(asked_coords,Scripts.PIECE_CONSTS.PIECE_LIST.PAWN_MOVED,Scripts.PIECE_CONSTS.PAWN_MOVED.TRUE)
		 
		# Move Piece
		var piece_object:Node2D = Scripts.PIECE_MANAGER.get_piece_data(asked_coords,Scripts.PIECE_CONSTS.PIECE_LIST.PIECE_OBJ)
		piece_object.global_position = translated_coords
		piece_object.move_local_y(-96)
		
	else:
		print("piece_manager/move_piece- coords not in _moves")
	
	return

static func is_empty(asked_coords:Vector2i) -> bool:
	if Scripts.PIECE_MANAGER.get_piece_data(asked_coords,Scripts.PIECE_CONSTS.PIECE_LIST.TYPE) == Scripts.PIECE_LIST.NONE:
		return true
	return false

static func is_enemy(asked_coords:Vector2i) -> bool: # TODO: Finish this. NOT WORKING YET !!!!!!!! ONLY REFRENCE !!!! NO ENEMY TEAM EXISTS YET !!!!!
	if Scripts.PIECE_MANAGER.get_piece_data(current_coords,Scripts.PIECE_CONSTS.PIECE_LIST.PIECE_COLOR) == Scripts.PIECE_CONSTS.PIECE_COLOR.WHITE:
		if Scripts.PIECE_MANAGER.get_piece_data(asked_coords,Scripts.PIECE_CONSTS.PIECE_LIST.PIECE_COLOR) == Scripts.PIECE_CONSTS.PIECE_COLOR.BLACK:
			return true
	elif Scripts.PIECE_MANAGER.get_piece_data(asked_coords,Scripts.PIECE_CONSTS.PIECE_LIST.PIECE_COLOR) == Scripts.PIECE_CONSTS.PIECE_COLOR.WHITE:
		return true
	return false



## private methods

static func _get_pawn_moves() -> Array: # TODO: EN PASSANT
	_moves = []
	var move_range:Array
	var capture_squares:Array
	if Scripts.PIECE_MANAGER.get_piece_data(current_coords,Scripts.PIECE_CONSTS.PIECE_LIST.PIECE_COLOR) == Scripts.PIECE_CONSTS.PIECE_COLOR.WHITE:
		capture_squares = [Vector2i(1,1),Vector2i(1,-1)]
		if Scripts.PIECE_MANAGER.get_piece_data(current_coords,Scripts.PIECE_CONSTS.PIECE_LIST.PAWN_MOVED) == Scripts.PIECE_CONSTS.PAWN_MOVED.FALSE:
			move_range = range(1,3)
		else:
			move_range = range(1,2)
	else:
		capture_squares = [Vector2i(-1,-1),Vector2i(-1,1)]
		if Scripts.PIECE_MANAGER.get_piece_data(current_coords,Scripts.PIECE_CONSTS.PIECE_LIST.PAWN_MOVED) == Scripts.PIECE_CONSTS.PAWN_MOVED.FALSE:
			move_range = range(-2,1)
		else:
			move_range = range(-1,1)
	
	# Main Movement
	for x in move_range:
		var pos = current_coords
		pos.x += x
		if Scripts.BOARD_MANAGER.is_valid_position(pos):
			if is_empty(pos):
				_moves.append(pos)
	
	# Piece Capturing
	for i in capture_squares:
		var pos = current_coords
		pos += i
		if Scripts.BOARD_MANAGER.is_valid_position(pos):
			if is_enemy(pos):
				_moves.append(pos)
	
	return _moves

static func _get_knight_moves() -> Array: # Idk if this is the best it can be, but maybe it is
	_moves = []
	directions = [Vector2i(1,2),Vector2i(-1,2), Vector2i(1,-2),Vector2i(-1,-2), Vector2i(2,1),Vector2i(2,-1), Vector2i(-2,1),Vector2i(-2,-1)]
	
	for i in directions:
		var pos = current_coords
		pos += i
		if Scripts.BOARD_MANAGER.is_valid_position(pos):
			if is_empty(pos):
				_moves.append(pos)
			elif is_enemy(pos):
				_moves.append(pos)
	
	return _moves

static func _get_rook_moves() -> Array:
	_moves = []
	directions = [Vector2i(0,1), Vector2i(0,-1), Vector2i(1,0), Vector2i(-1,0)]
	
	for i in directions:
		var pos = current_coords
		pos += i
		
		while Scripts.BOARD_MANAGER.is_valid_position(pos):
			if is_empty(pos):
				_moves.append(pos)
			elif is_enemy(pos):
				_moves.append(pos)
				break
			else: break
			
			pos +=i
	
	return _moves

static func _get_bishop_moves() -> Array:
	_moves = []
	directions = [Vector2i(1,1), Vector2i(1,-1), Vector2i(-1,1), Vector2i(-1,-1)]
	
	for i in directions:
		var pos = current_coords
		pos += i
		
		while Scripts.BOARD_MANAGER.is_valid_position(pos):
			if is_empty(pos):
				_moves.append(pos)
			elif is_enemy(pos):
				_moves.append(pos)
				break
			else: break
			
			pos +=i
	
	return _moves

static func _get_king_moves() -> Array:
	_moves = []
	
	for x in range(-1,2):
		for y in range(-1,2):
			var pos:Vector2i = current_coords
			pos.x += x
			pos.y += y
			
			if Scripts.BOARD_MANAGER.is_valid_position(pos):
				if is_empty(pos):
					_moves.append(pos)
				elif is_enemy(pos):
					_moves.append(pos)
	
	return _moves
