extends RefCounted
## enums
## consts
## exports
## public vars
## private vars
## onready vars
# obj_ for node refrences
## built-in override methods
## public methods

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
			if Scripts.PIECE_MANAGER.is_enemy(pos):
				check_coords.append(pos)
				var piece:int = Scripts.PIECE_MANAGER.get_piece_data(pos,Scripts.CONSTANTS.PIECE_LIST.PIECE_TYPE)
				if piece == Scripts.CONSTANTS.PIECE_TYPE.PAWN:
					#print("IS_IN_CHECK- pawn_check")
					check_coords.append(pos)
	
	for pos:Vector2i in Scripts.PIECE_MOVE._get_knight_moves(check_pos):
		if Scripts.PIECE_MANAGER.is_enemy(pos):
			var piece:int = Scripts.PIECE_MANAGER.get_piece_data(pos,Scripts.CONSTANTS.PIECE_LIST.PIECE_TYPE)
			if piece == Scripts.CONSTANTS.PIECE_TYPE.KNIGHT:
				#print("IS_IN_CHECK- knight_check")
				check_coords.append(pos)
	
	for pos:Vector2i in Scripts.PIECE_MOVE._get_rook_moves(check_pos,false):
		if Scripts.PIECE_MANAGER.is_enemy(pos):
			var piece:int = Scripts.PIECE_MANAGER.get_piece_data(pos,Scripts.CONSTANTS.PIECE_LIST.PIECE_TYPE)
			if piece == Scripts.CONSTANTS.PIECE_TYPE.ROOK:
				#print("IS_IN_CHECK- rook_check")
				check_coords.append(pos)
			elif piece == Scripts.CONSTANTS.PIECE_TYPE.QUEEN:
				#print("IS_IN_CHECK- queen_check")
				check_coords.append(pos)
	
	for pos:Vector2i in Scripts.PIECE_MOVE._get_bishop_moves(check_pos,false):
		if Scripts.PIECE_MANAGER.is_enemy(pos):
			var piece:int = Scripts.PIECE_MANAGER.get_piece_data(pos,Scripts.CONSTANTS.PIECE_LIST.PIECE_TYPE)
			if piece == Scripts.CONSTANTS.PIECE_TYPE.BISHOP:
				#print("IS_IN_CHECK- bishop_check")
				check_coords.append(pos)
			elif piece == Scripts.CONSTANTS.PIECE_TYPE.QUEEN:
				#print("IS_IN_CHECK- queen_check")
				check_coords.append(pos)
	
	for x in range(-1,2):
		for y in range(-1,2):
			var pos:Vector2i = check_pos
			pos.x += x
			pos.y += y
			if pos == check_pos:
				continue
			
			if Scripts.BOARD_MANAGER.is_valid_position(pos):
				if Scripts.PIECE_MANAGER.is_enemy(pos):
					
					if Scripts.PIECE_MANAGER.get_piece_data(pos,Scripts.CONSTANTS.PIECE_LIST.PIECE_TYPE) == Scripts.CONSTANTS.PIECE_TYPE.KING:
						check_coords.append(pos)
						#print("IS_IN_CHECK- king_check????????????????")
	
	#print("GET_CHECK_COORDS- Piece is Checked from these coords: ",check_coords)
	return check_coords

## private methods
