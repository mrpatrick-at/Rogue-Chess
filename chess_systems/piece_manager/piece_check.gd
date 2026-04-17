extends RefCounted
## enums
## consts
## exports
## public vars
static var king_pos:Vector2i
## private vars
## onready vars
# obj_ for node refrences
## built-in override methods
## public methods

static func get_valid_moves(_moves:Array) -> Array: # Returns Positions from an Array, after Compraring them to a Valid Position Array
	king_pos = Scripts.PIECE_MOVE.king_pos
	var _valid_moves:Array = []
	if is_in_check(king_pos):
		
		for move:Vector2i in _moves:
			var check_coords:Array = get_check_coords(king_pos) # works so far
			
			for piece:Vector2i in check_coords:
				var _tiles_inbetween:Array = get_tiles_between_points(piece,king_pos)
				
				if _tiles_inbetween.has(move):
					_valid_moves.append(move)
				
				if _valid_moves.is_empty():
					Scripts.DATABASE.IN_CHECKMATE = true
					print("GET_VALID_MOVES- Checkmate! ")
	
	else:
		_valid_moves.append_array(_moves)
	
	print("GET_VALID_MOVES- _valid_moves: ",_valid_moves)
	return _valid_moves

static func is_in_checkmate() -> bool: # Checks if King is in CHeckmate TODO: Improve this
	var check_coords:Array = get_check_coords(king_pos)
	print("IS_IN_CHECKMATE- check coords: ",check_coords)
	
	if is_in_check(king_pos):
		#var king_moves:Array = get_moves(king_pos)
		#for move:Vector2i in king_moves:
			#if !is_in_check(move):
				#print("IS_IN_CHECKMATE- King can Escape!")
				#return false
		
		print("IS_IN_CHECKMATE- Checkmate!")
		return true # Piece in Checkmate 
	
	print("IS_IN_CHECKMATE- No Check Detected!")
	return false # Piece not in Check

static func is_in_check(check_pos:Vector2i) -> bool: # Returns True if Piece on check_pos is in check
	if get_check_coords(check_pos).size() > 0:
		return true
	return false

static func get_check_coords(check_pos:Vector2i) -> Array: # Returns Array of all Pieces Checking the Piece on check_pos
	var check_coords:Array = []
	
	var pawn_direction:int
	if Scripts.DATABASE.color_turn == Scripts.CONSTANTS.PIECE_COLOR.WHITE:
		pawn_direction = 1
	else:
		pawn_direction = -1
	
	var pawn_attacks:Array = [check_pos + Vector2i(pawn_direction,-1),check_pos + Vector2i(pawn_direction,1)]
	
	for pos:Vector2i in pawn_attacks:
		if Scripts.BOARD_MANAGER.is_valid_position(pos):
			if Scripts.PIECE_MOVE.is_enemy(check_pos,pos):
				var piece:int = Scripts.PIECE_MANAGER.get_piece_data(pos,Scripts.CONSTANTS.PIECE_LIST.PIECE_TYPE)
				if piece == Scripts.CONSTANTS.PIECE_TYPE.PAWN:
					print("IS_IN_CHECK- pawn_check")
					check_coords.append(pos)
	
	for pos:Vector2i in Scripts.PIECE_MOVE._get_knight_moves(check_pos):
		var piece:int = Scripts.PIECE_MANAGER.get_piece_data(pos,Scripts.CONSTANTS.PIECE_LIST.PIECE_TYPE)
		if piece == Scripts.CONSTANTS.PIECE_TYPE.KNIGHT:
			print("IS_IN_CHECK- knight_check")
			check_coords.append(pos)
	
	for pos:Vector2i in Scripts.PIECE_MOVE._get_rook_moves(check_pos):
		var piece:int = Scripts.PIECE_MANAGER.get_piece_data(pos,Scripts.CONSTANTS.PIECE_LIST.PIECE_TYPE)
		if piece == Scripts.CONSTANTS.PIECE_TYPE.ROOK:
			print("IS_IN_CHECK- rook_check")
			check_coords.append(pos)
		elif piece == Scripts.CONSTANTS.PIECE_TYPE.QUEEN:
			print("IS_IN_CHECK- queen_check")
			check_coords.append(pos)
	
	for pos:Vector2i in Scripts.PIECE_MOVE._get_bishop_moves(check_pos):
		var piece:int = Scripts.PIECE_MANAGER.get_piece_data(pos,Scripts.CONSTANTS.PIECE_LIST.PIECE_TYPE)
		if piece == Scripts.CONSTANTS.PIECE_TYPE.BISHOP:
			print("IS_IN_CHECK- bishop_check")
			check_coords.append(pos)
		elif piece == Scripts.CONSTANTS.PIECE_TYPE.QUEEN:
			print("IS_IN_CHECK- queen_check")
			check_coords.append(pos)
	
	for x in range(-1,2):
		for y in range(-1,2):
			var pos:Vector2i = check_pos
			pos.x += x
			pos.y += y
			if pos == check_pos:
				continue
			
			if Scripts.BOARD_MANAGER.is_valid_position(pos):
				if Scripts.PIECE_MOVE.is_enemy(check_pos,pos):
					if Scripts.PIECE_MANAGER.get_piece_data(pos,Scripts.CONSTANTS.PIECE_LIST.PIECE_TYPE) == Scripts.CONSTANTS.PIECE_TYPE.KING:
						print("IS_IN_CHECK- king_check????????????????")
						check_coords.append(pos)
	
	print("IS_IN_CHECK- Piece is Checked from these coords: ",check_coords)
	return check_coords

static func get_tiles_between_points(starting_pos:Vector2i,target_pos:Vector2i) -> Array: # Returns Array of all Positions between 2 Points + starting_pos
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
	
	print("GET_TILES_BETWEEN_POINTS- step values: ",Vector2i(value_x,value_y))
	var step:Vector2i = Vector2i(starting_pos)
	var _steps:Array = []
	
	while step != target_pos:
		_steps.append(step)
		if step.x != target_pos.x:
			step.x += value_x
		if step.y != target_pos.y:
			step.y += value_y
		print("GET_TILES_BETWEEN_POINTS- steps +1")
		
	print("GET_TILES_BETWEEN_POINTS- steps: ",_steps)
	
	return _steps

## private methods
