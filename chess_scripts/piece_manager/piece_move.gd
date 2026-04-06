extends RefCounted
## enums
## consts
## exports
## public vars
static var current_x:int
static var current_y:int
static var asked_x:int
static var asked_y:int
static var possible_move:bool
static var database:Dictionary
static var direction:String

static var _moves
static var directions
## private vars
## onready vars
# obj_ for node refrences
## built-in override methods
## public methods

static func get_moves(current_coords:Vector2i) -> Array:
	_moves = []
	match abs(Scripts.PIECE_MANAGER.get_piece_data(current_coords,Scripts.PIECE_CONSTS.PIECE_LIST.TYPE)):
		Scripts.PIECE_CONSTS.TYPE_LIST.PAWN:
			_moves = get_pawn_moves(current_coords)
		Scripts.PIECE_CONSTS.TYPE_LIST.ROOK:
			_moves = get_rook_moves(current_coords)
		Scripts.PIECE_CONSTS.TYPE_LIST.KNIGHT:
			_moves = get_knight_moves(current_coords)
		Scripts.PIECE_CONSTS.TYPE_LIST.BISHOP:
			_moves = get_bishop_moves(current_coords)
		Scripts.PIECE_CONSTS.TYPE_LIST.QUEEN:
			_moves = get_rook_moves(current_coords) + get_bishop_moves(current_coords)
		Scripts.PIECE_CONSTS.TYPE_LIST.KING:
			_moves = get_king_moves(current_coords)
	print("piece_move/get_moves- _moves: ",_moves)
	return _moves

#static func is_valid_position(asked_coords:Vector2i) -> bool:
	#if asked_coords.x >= 1 and asked_coords.x < 9 and asked_coords.y >= 1 and asked_coords.y < 9:
		#return true
	#return false

static func is_empty(asked_coords:Vector2i) -> bool:
	if Scripts.PIECE_MANAGER.get_piece_data(asked_coords,Scripts.PIECE_CONSTS.PIECE_LIST.TYPE) == Scripts.PIECE_LIST.NONE:
		return true
	return false

static func is_enemy(asked_coords:Vector2i) -> bool: # TODO: Finish this. NOT WORKING YET !!!!!!!! ONLY REFRENCE !!!! NO ENEMY TEAM EXISTS YET !!!!!
	print("type ",Scripts.PIECE_MANAGER.get_piece_data(asked_coords,Scripts.PIECE_CONSTS.PIECE_LIST.TYPE))
	if Scripts.PIECE_MANAGER.get_piece_data(asked_coords,Scripts.PIECE_CONSTS.PIECE_LIST.TYPE) == Scripts.PIECE_LIST.NONE:
		return true
	return false

static func get_pawn_moves(current_coords:Vector2i) -> Array: # TODO: EN PASSANT
	_moves = []
	var move_range:Array
	if Scripts.PIECE_MANAGER.get_piece_data(current_coords,Scripts.PIECE_CONSTS.PIECE_LIST.PAWN_MOVED) == false:
		move_range = range(1,3)
	else:
		move_range = range(1,2)
	
	for x in move_range:
		var pos = current_coords
		pos.x += x
		if Scripts.BOARD_MANAGER.is_valid_position(pos):
			if is_empty(pos):
				_moves.append(pos)
			elif is_enemy(pos):
				_moves.append(pos)
	
	return _moves

static func get_knight_moves(current_coords:Vector2i) -> Array: # Idk if this is the best it can be, but maybe it is
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

static func get_rook_moves(current_coords:Vector2i) -> Array:
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

static func get_bishop_moves(current_coords:Vector2i) -> Array:
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

static func get_king_moves(current_coords:Vector2i) -> Array:
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

## private methods
