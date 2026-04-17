extends Node2D
## enums
## consts
## exports
## public vars
static var blank_node:Node2D
static var blank_sprite:Sprite2D
## private vars
## onready vars
# obj_ for node refrences
## built-in override methods

func _ready() -> void:
	var i:int = 0
	
	# Add Blank Node for Empty Squares
	blank_node = Node2D.new()
	blank_node.name = "PieceNone"
	add_child(blank_node)
	blank_sprite = Sprite2D.new()
	blank_sprite.name = "SpriteNone"
	blank_node.add_child(blank_sprite)
	
	for coords:Vector2i in Scripts.DATABASE.TILE_DICTIONARY.keys():
		i += 1
		y_sort_enabled = true
		var piece_info:Vector2i = _calculate_piece(coords)
		_create_piece(coords,piece_info,i)
	

func _physics_process(_delta:float) -> void:
	pass

## public methods

static func get_piece_data(coords:Vector2i,data:int) -> Variant: # 1. coords 2. value to get
	if Scripts.DATABASE.TILE_DICTIONARY.has(coords):
		var piece_object:int = Scripts.DATABASE.TILE_DICTIONARY[coords]["piece"]
		var value:Variant = Scripts.DATABASE.PIECE_DICTIONARY[piece_object][data]
		return value
	#print("Invalid Coords / Board not Loaded Yet")
	return

static func set_piece_data(coords:Vector2i,data:int,value:Variant) -> void: # 1. coords 2. value to set 3. what to set it to
	if Scripts.DATABASE.TILE_DICTIONARY.has(coords):
		var piece_object:int = Scripts.DATABASE.TILE_DICTIONARY[coords]["piece"]
		Scripts.DATABASE.PIECE_DICTIONARY[piece_object][data] = value

## private methods

static func _calculate_piece(coords:Vector2i) -> Vector2i: # Calculates which Tiles should have Pieces
	var piece:int = Scripts.CONSTANTS.PIECE_TYPE.NONE
	var color:int = Scripts.CONSTANTS.PIECE_COLOR._0
	
	if coords.x == 2:
		piece = Scripts.CONSTANTS.PIECE_TYPE.PAWN
		color = Scripts.CONSTANTS.PIECE_COLOR.WHITE
		print("White Pawn spawned at: ",coords,"!")
	
	if coords.x == 7:
		piece = Scripts.CONSTANTS.PIECE_TYPE.PAWN
		color = Scripts.CONSTANTS.PIECE_COLOR.BLACK
		print("Black Pawn spawned at: ",coords,"!")
	
	if coords.x == 1:
		color = Scripts.CONSTANTS.PIECE_COLOR.WHITE
		
		if coords.y == 1 or coords.y == 8:
			piece = Scripts.CONSTANTS.PIECE_TYPE.ROOK
			print("White Rook spawned at: ",coords,"!")
		
		if coords.y == 2 or coords.y == 7:
			piece = Scripts.CONSTANTS.PIECE_TYPE.KNIGHT
			print("White Knight spawned at: ",coords,"!")
		
		if coords.y == 3 or coords.y == 6:
			piece = Scripts.CONSTANTS.PIECE_TYPE.BISHOP
			print("White Bishop spawned at: ",coords,"!")
		
		if coords.y == 4:
			piece = Scripts.CONSTANTS.PIECE_TYPE.QUEEN
			print("White Queen spawned at: ",coords,"!")
		
		if coords.y == 5:
			piece = Scripts.CONSTANTS.PIECE_TYPE.KING
			Scripts.PIECE_MOVE.white_king_pos = Vector2i(coords.x,coords.y)
			print("White King spawned at: ",coords,"!")
	
	if coords.x == 8:
		color = Scripts.CONSTANTS.PIECE_COLOR.BLACK
		
		if coords.y == 1 or coords.y == 8:
			piece = Scripts.CONSTANTS.PIECE_TYPE.ROOK
			print("Black Rook spawned at: ",coords,"!")
		
		if coords.y == 2 or coords.y == 7:
			piece = Scripts.CONSTANTS.PIECE_TYPE.KNIGHT
			print("Black Knight spawned at: ",coords,"!")
		
		if coords.y == 3 or coords.y == 6:
			piece = Scripts.CONSTANTS.PIECE_TYPE.BISHOP
			print("Black Bishop spawned at: ",coords,"!")
		
		if coords.y == 4:
			piece = Scripts.CONSTANTS.PIECE_TYPE.QUEEN
			print("Black Queen spawned at: ",coords,"!")
		
		if coords.y == 5:
			piece = Scripts.CONSTANTS.PIECE_TYPE.KING
			Scripts.PIECE_MOVE.black_king_pos = Vector2i(coords.x,coords.y)
			print("Black King spawned at: ",coords,"!")
	
	var piece_info:Vector2i = Vector2i(piece,color)
	
	return piece_info

func _create_piece(coords:Vector2i,piece_info:Vector2i,i:int) -> void: # Looks at DataBase then creates Node2D's that contain the Piece Sprites
	var piece:int = piece_info.x 
	var color:int = piece_info.y
	var piece_object:Node2D
	var piece_sprite:Sprite2D
	
	if piece == Scripts.CONSTANTS.PIECE_TYPE.NONE:
		piece_object = blank_node
		piece_sprite = blank_sprite
		i = 0
	
	else:
		piece_object = Node2D.new()
		add_child(piece_object)
		piece_sprite = Sprite2D.new()
		piece_object.add_child(piece_sprite)
		var translated_coords:Vector2 = Scripts.BOARD_MANAGER.get_mouse_from_tile(coords)
		piece_object.global_position = translated_coords
		piece_object.scale = Vector2i(8,8)
		piece_object.move_local_y(-96)
	
	Scripts.DATABASE.TILE_DICTIONARY[coords]["piece"] = i
	Scripts.DATABASE.PIECE_DICTIONARY.set(i,{ # Remember values with "" in here are not done yet and need to be set to an Int thru consts file
		Scripts.CONSTANTS.PIECE_LIST.PIECE_TYPE:piece,
		Scripts.CONSTANTS.PIECE_LIST.PIECE_COLOR:color,
		Scripts.CONSTANTS.PIECE_LIST.PIECE_OBJ:piece_object,
		Scripts.CONSTANTS.PIECE_LIST.PIECE_SPRITE:piece_sprite,
		Scripts.CONSTANTS.PIECE_LIST.TIMES_MOVED:0,
		})
	
	var sprite:CompressedTexture2D
	
	if piece == Scripts.CONSTANTS.PIECE_TYPE.PAWN:
		if color == Scripts.CONSTANTS.PIECE_COLOR.WHITE:
			sprite = load("res://assets/pieces/white/w_pawn.png")
		if color == Scripts.CONSTANTS.PIECE_COLOR.BLACK:
			sprite = load("res://assets/pieces/black/b_pawn.png")
		Scripts.DATABASE.PIECE_DICTIONARY[i][Scripts.CONSTANTS.PIECE_LIST.PAWN_MOVED_TWO_TILES] = Scripts.CONSTANTS.PAWN_MOVED_TWO_TILES.FALSE
	
	if piece == Scripts.CONSTANTS.PIECE_TYPE.ROOK:
		if color == Scripts.CONSTANTS.PIECE_COLOR.WHITE:
			sprite = load("res://assets/pieces/white/w_rook.png")
		if color == Scripts.CONSTANTS.PIECE_COLOR.BLACK:
			sprite = load("res://assets/pieces/black/b_rook.png")
		
	if piece == Scripts.CONSTANTS.PIECE_TYPE.KNIGHT:
		if color == Scripts.CONSTANTS.PIECE_COLOR.WHITE:
			sprite = load("res://assets/pieces/white/w_knight.png")
		if color == Scripts.CONSTANTS.PIECE_COLOR.BLACK:
			sprite = load("res://assets/pieces/black/b_knight.png")
		
	if piece == Scripts.CONSTANTS.PIECE_TYPE.BISHOP:
		if color == Scripts.CONSTANTS.PIECE_COLOR.WHITE:
			sprite = load("res://assets/pieces/white/w_bishop.png")
		if color == Scripts.CONSTANTS.PIECE_COLOR.BLACK:
			sprite = load("res://assets/pieces/black/b_bishop.png")
		
	if piece == Scripts.CONSTANTS.PIECE_TYPE.QUEEN:
		if color == Scripts.CONSTANTS.PIECE_COLOR.WHITE:
			sprite = load("res://assets/pieces/white/w_queen.png")
		if color == Scripts.CONSTANTS.PIECE_COLOR.BLACK:
			sprite = load("res://assets/pieces/black/b_queen.png")
		
	if piece == Scripts.CONSTANTS.PIECE_TYPE.KING:
		if color == Scripts.CONSTANTS.PIECE_COLOR.WHITE:
			sprite = load("res://assets/pieces/white/w_king.png")
		if color == Scripts.CONSTANTS.PIECE_COLOR.BLACK:
			sprite = load("res://assets/pieces/black/b_king.png")
	
	piece_sprite.texture = sprite
