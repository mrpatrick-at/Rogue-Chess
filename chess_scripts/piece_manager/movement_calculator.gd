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

## private vars
## onready vars
# obj_ for node refrences
## built-in override methods
## public methods

static func calculate_movement(current_coords:Vector2i,asked_coords:Vector2i) -> bool: # Checks Tile Dict for Piece on coords then calls the according calculate_movement
	current_x = current_coords.x
	current_y = current_coords.y
	asked_x = asked_coords.x
	asked_y = asked_coords.y
	database = Scripts.BOARD_DATABASE.TILE_DICTIONARY
	direction = "none" 
	
	
	var piece_type:int = Scripts.BOARD_DATABASE.TILE_DICTIONARY[current_coords]["piece"]["piece_type"]
	possible_move = false
	
	if  database[asked_coords]["piece"]["piece_type"] == Scripts.PIECE_LIST.NONE: # Check if asked cords contain a Piece
		
		if piece_type == Scripts.PIECE_LIST.PAWN:
			_pawn_movement()
		
		# Rook
		if piece_type == Scripts.PIECE_LIST.ROOK:
			_rook_movement()
		
		# Knight
		if piece_type == Scripts.PIECE_LIST.KNIGHT:
			_knight_movement()
		
		# Bishop
		if piece_type == Scripts.PIECE_LIST.BISHOP:
			_bishop_movement()
		
		# Queen
		if piece_type == Scripts.PIECE_LIST.QUEEN:
			_rook_movement()
			_bishop_movement()
		
		# King
		if piece_type == Scripts.PIECE_LIST.KING:
			_king_movement()
	
	print("Is move possible? = ",possible_move,", Move Direction = ",direction)
	return possible_move

## private methods

static func _pawn_movement() -> bool: # TODO: EN PASANT!!!!!!!!!!!!!!!!
	var distance_x:int = asked_x - current_x
	
	# Normal Behaviour
	if asked_y == current_y:
		if distance_x == 1 or distance_x == 2:
			var distance = (current_x - asked_x) -1
			possible_move = true
			direction = "up"
			for i in distance:
				var n = i +1
				if !database[Vector2i(current_x + n,current_y)]["piece"]["piece_type"] == Scripts.PIECE_LIST.NONE:
					possible_move = false
					print("Error Piece detected at: ",n)
					break
	
	# En Passant TODO: EN PASSANT !!!!!!!!!!!
	
	return possible_move

static func _rook_movement() -> bool:
	var distance_x:int = asked_x - current_x
	var distance_y:int = asked_y - current_y
	
	if asked_y == current_y:
		
		if asked_x > current_x:
			var distance = (asked_x - current_x) -1
			direction = "up"
			possible_move = true
			for i in distance:
				var n = i +1
				if !database[Vector2i(current_x +n,current_y)]["piece"]["piece_type"] == Scripts.PIECE_LIST.NONE:
					possible_move = false
					print("Error Piece detected at: ",n)
					break
		
		if asked_x < current_x:
			var distance = (current_x - asked_x) -1
			direction = "down"
			possible_move = true
			for i in distance:
				var n = i +1
				if !database[Vector2i(current_x -n,current_y)]["piece"]["piece_type"] == Scripts.PIECE_LIST.NONE:
					possible_move = false
					print("Error Piece detected at: ",n)
					break
	
	if asked_x == current_x:
		
		if asked_y > current_y:
			var distance = (asked_y - current_y) -1
			direction = "right"
			possible_move = true
			for i in distance:
				var n = i +1
				if !database[Vector2i(current_x,current_y +n)]["piece"]["piece_type"] == Scripts.PIECE_LIST.NONE:
					possible_move = false
					print("Error Piece detected at: ",n)
					break
		
		if asked_y < current_y:
			var distance = (current_y - asked_y) -1
			direction = "left"
			possible_move = true
			for i in distance:
				var n = i +1
				if !database[Vector2i(current_x,current_y -n)]["piece"]["piece_type"] == Scripts.PIECE_LIST.NONE:
					possible_move = false
					print("Error Piece detected at: ",n)
					break
	
	return possible_move

static func _knight_movement() -> bool:
	if asked_x == current_x + 2:
		if asked_y == current_y +1:
			possible_move = true
			direction = "up-right"
		if asked_y == current_y -1:
			possible_move = true
			direction = "up-left"
	
	if asked_x == current_x - 2:
		if asked_y == current_y +1:
			possible_move = true
			direction = "down-right"
		if asked_y == current_y -1:
			possible_move = true
			direction = "down-left"
	
	if asked_y == current_y + 2:
		if asked_x == current_x +1:
			possible_move = true
			direction = "right-up"
		if asked_x == current_x -1:
			possible_move = true
			direction = "right-down"
	
	if asked_y == current_y - 2:
		if asked_x == current_x +1:
			possible_move = true
			direction = "left-up"
		if asked_x == current_x -1:
			possible_move = true
			direction = "left-down"
	
	return possible_move

static func _bishop_movement() -> bool:
	var distance_x:int = asked_x - current_x
	var distance_y:int = asked_y - current_y
	
	if distance_y == distance_x:
		if distance_x >= 0:
			possible_move = true
			direction = "up-right"
			for i in distance_x -1:
				var n = i + 1
				var distance = Vector2i(current_x +n,current_y +n)
				if !database[Vector2i(distance)]["piece"]["piece_type"] == Scripts.PIECE_LIST.NONE:
					possible_move = false
					print("Error Piece detected at: ",n)
					break
		
		if distance_x <= 0:
			possible_move = true
			direction = "down-left"
			for i in (distance_x * -1) -1:
				var n = i + 1
				var distance = Vector2i(current_x +n,current_y +n)
				if !database[Vector2i(distance)]["piece"]["piece_type"] == Scripts.PIECE_LIST.NONE:
					possible_move = false
					print("Error Piece detected at: ",n)
					break
	
	elif distance_y == (distance_x * -1):
		if (distance_x * -1) >= 0:
			possible_move = true
			direction = "up-left"
			for i in distance_x -1:
				var n = i + 1
				var distance = Vector2i(current_x +n,current_y +n)
				if !database[Vector2i(distance)]["piece"]["piece_type"] == Scripts.PIECE_LIST.NONE:
					possible_move = false
					print("Error Piece detected at: ",n)
					break
		
		if (distance_x * -1) <= 0:
			possible_move = true
			direction = "down-left"
			for i in (distance_x * -1) -1:
				var n = i + 1
				var distance = Vector2i(current_x +n,current_y +n)
				if !database[Vector2i(distance)]["piece"]["piece_type"] == Scripts.PIECE_LIST.NONE:
					possible_move = false
					print("Error Piece detected at: ",n)
					break
	
	return possible_move

static func _king_movement() -> bool:
	if asked_x == current_x +1:
			
		if asked_y == asked_y:
			possible_move = true
			direction = "up"
			
		if asked_y == current_y - 1:
			possible_move = true
			direction = "up-left"
			
		if asked_y == current_y + 1:
			possible_move = true
			direction = "up-right"
		
	if asked_x == current_x:
			
		if asked_y == current_y - 1:
			possible_move = true
			direction = "left"
			
		if asked_y == current_y + 1:
			possible_move = true
			direction = "down"
	
	if asked_x == current_x -1:
		
		if asked_y == asked_y:
			possible_move = true
			direction = "down"
		
		if asked_y == current_y - 1:
			possible_move = true
			direction = "down-left"
		
		if asked_y == current_y + 1:
			possible_move = true
			direction = "down-right"
	
	return possible_move
