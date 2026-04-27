extends RefCounted
## enums
## consts
## exports
## public vars
# "potential" here means: If you ignore your own pieces
# Coords of All Pieces checking King
static var king_check_coords:Array = []
static var king_potential_check_coords:Array = []

# If King is checked
static var king_in_check:bool = false
static var king_in_potential_check:bool = false

# Tiles between all Pieces checking King and King Itself
static var king_between_coords:Array = []
static var king_potential_between_coords:Array = []
## private vars
## onready vars
# obj_ for node refrences
## built-in override methods
## public methods

static func update_check_vars(king_pos:Vector2i) -> void: # Updates this Scripts Vars
	print_rich("[color=Turquoise]UPDATE_CHECK_VARS-[/color] Called")
	# Clear and Update Check Arrays
	king_check_coords.clear()
	king_potential_check_coords.clear()
	
	king_check_coords = get_check_coords(king_pos,true)
	print("UPDATE_CHECK_VARS- Pieces Checking King: ",king_check_coords)
	
	king_potential_check_coords = get_check_coords(king_pos,false)
	print("UPDATE_CHECK_VARS- Pieces Potentially Checking King: ",king_potential_check_coords)
	
	# Clear and Update Check bools and Between Coords
	king_in_check = false
	king_in_potential_check = false
	king_between_coords.clear()
	king_potential_between_coords.clear()
	
	if !king_check_coords.is_empty():
		king_in_check = true
		for checking_piece:Vector2i in king_check_coords:
			king_between_coords.append_array(Scripts.BOARD_MANAGER.get_tiles_between_points(checking_piece,king_pos))
	
	if !king_potential_check_coords.is_empty():
		king_in_potential_check = true
		for checking_piece:Vector2i in king_potential_check_coords:
			king_potential_between_coords.append_array(Scripts.BOARD_MANAGER.get_tiles_between_points(checking_piece,king_pos))
	

static func get_check_coords(check_pos:Vector2i,potential_check:bool) -> Array: # Returns Array of all Pieces Checking the Piece on check_pos
	print_rich("[color=Turquoise]GET_CHECK_COORDS-[/color] Called")
	var _tmp_check_coords:Array = []
	
	var pawn_direction:int
	if Scripts.DATABASE.color_turn == Scripts.CONSTANTS.PIECE_COLOR.WHITE:
		pawn_direction = 1
	else:
		pawn_direction = -1
	
	var pawn_attacks:Array = [check_pos + Vector2i(pawn_direction,-1),check_pos + Vector2i(pawn_direction,1)]
	
	for pos:Vector2i in pawn_attacks:
		if Scripts.BOARD_MANAGER.is_valid_position(pos):
			if Scripts.PIECE_MANAGER.is_enemy(pos):
				_tmp_check_coords.append(pos)
				var piece:int = Scripts.PIECE_MANAGER.get_piece_data(pos,Scripts.CONSTANTS.PIECE_LIST.PIECE_TYPE)
				if piece == Scripts.CONSTANTS.PIECE_TYPE.PAWN:
					#print("IS_IN_CHECK- pawn_check")
					_tmp_check_coords.append(pos)
	
	for pos:Vector2i in Scripts.PIECE_MOVE._get_knight_moves(check_pos):
		if Scripts.PIECE_MANAGER.is_enemy(pos):
			var piece:int = Scripts.PIECE_MANAGER.get_piece_data(pos,Scripts.CONSTANTS.PIECE_LIST.PIECE_TYPE)
			if piece == Scripts.CONSTANTS.PIECE_TYPE.KNIGHT:
				#print("IS_IN_CHECK- knight_check")
				_tmp_check_coords.append(pos)
	
	for pos:Vector2i in Scripts.PIECE_MOVE._get_rook_moves(check_pos,potential_check):
		if Scripts.PIECE_MANAGER.is_enemy(pos):
			var piece:int = Scripts.PIECE_MANAGER.get_piece_data(pos,Scripts.CONSTANTS.PIECE_LIST.PIECE_TYPE)
			if piece == Scripts.CONSTANTS.PIECE_TYPE.ROOK:
				#print("IS_IN_CHECK- rook_check")
				_tmp_check_coords.append(pos)
			elif piece == Scripts.CONSTANTS.PIECE_TYPE.QUEEN:
				#print("IS_IN_CHECK- queen_check")
				_tmp_check_coords.append(pos)
	
	for pos:Vector2i in Scripts.PIECE_MOVE._get_bishop_moves(check_pos,potential_check):
		if Scripts.PIECE_MANAGER.is_enemy(pos):
			var piece:int = Scripts.PIECE_MANAGER.get_piece_data(pos,Scripts.CONSTANTS.PIECE_LIST.PIECE_TYPE)
			if piece == Scripts.CONSTANTS.PIECE_TYPE.BISHOP:
				#print("IS_IN_CHECK- bishop_check")
				_tmp_check_coords.append(pos)
			elif piece == Scripts.CONSTANTS.PIECE_TYPE.QUEEN:
				#print("IS_IN_CHECK- queen_check")
				_tmp_check_coords.append(pos)
	
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
						_tmp_check_coords.append(pos)
						#print("IS_IN_CHECK- king_check????????????????")
	
	#print("GET__tmp_check_coords- Piece is Checked from these coords: ",_tmp_check_coords)
	return _tmp_check_coords

## private methods
