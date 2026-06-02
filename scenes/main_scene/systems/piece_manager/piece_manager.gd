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
	build_pieces()

## public methods

static func get_piece_data(coords:Vector2i,value_to_get:int) -> Variant: # 1. coords 2. value to get
	if Scripts.DATABASE.TILE_DICTIONARY.has(coords):
		var piece_object:int = Scripts.DATABASE.TILE_DICTIONARY[coords][Scripts.CONSTANTS.BOARD_LIST.PIECE]
		var value:Variant = Scripts.DATABASE.PIECE_DICTIONARY[piece_object][value_to_get]
		return value
	#print("Invalid Coords / Board not Loaded Yet")
	return

static func set_piece_data(coords:Vector2i,value_to_set:int,value:Variant) -> void: # 1. coords 2. value to set 3. what to set it to
	if Scripts.DATABASE.TILE_DICTIONARY.has(coords):
		var piece_object:int = Scripts.DATABASE.TILE_DICTIONARY[coords][Scripts.CONSTANTS.BOARD_LIST.PIECE]
		Scripts.DATABASE.PIECE_DICTIONARY[piece_object][value_to_set] = value

static func clear_piece_data(coords:Vector2i,value_to_clear:int) -> void: # 1. coords 2. value to clear, ATTENTION: WILL CLEAR ALL VALUES IN THE DATA ARRAY OF THE PIECE
	if Scripts.DATABASE.TILE_DICTIONARY.has(coords):
		var piece_object:int = Scripts.DATABASE.TILE_DICTIONARY[coords][Scripts.CONSTANTS.BOARD_LIST.PIECE]
		if Scripts.DATABASE.PIECE_DICTIONARY[piece_object].has(value_to_clear):
			match(typeof(Scripts.DATABASE.PIECE_DICTIONARY[piece_object][value_to_clear])): # Add Types when needed.
				TYPE_ARRAY:
					Scripts.DATABASE.PIECE_DICTIONARY[piece_object][value_to_clear].clear()
			return
			
		#print("CLEAR_PIECE_DATA- ",coords," dosen't have: ",value_to_clear)
		return
		
	#print("CLEAR_PIECE_DATA- ",coords," don't exist")
	return

static func is_empty(asked_coords:Vector2i) -> bool: # Checks if Tile is Empty, duh
	if Scripts.PIECE_MANAGER.get_piece_data(asked_coords,Scripts.CONSTANTS.PIECE_LIST.PIECE_TYPE) == Scripts.CONSTANTS.PIECE_TYPE.NONE:
		return true
	return false

static func is_enemy(asked_coords:Vector2i) -> bool: # Checks if piece on piece_coords is diffrent team than piece on asked_coords
	if Scripts.DATABASE.color_turn == Scripts.CONSTANTS.PIECE_COLOR.WHITE:
		if Scripts.PIECE_MANAGER.get_piece_data(asked_coords,Scripts.CONSTANTS.PIECE_LIST.PIECE_COLOR) == Scripts.CONSTANTS.PIECE_COLOR.BLACK:
			return true
	elif Scripts.PIECE_MANAGER.get_piece_data(asked_coords,Scripts.CONSTANTS.PIECE_LIST.PIECE_COLOR) == Scripts.CONSTANTS.PIECE_COLOR.WHITE:
		return true
	return false


## private methods

func build_pieces() -> void:
	var time_before:float = Time.get_ticks_usec()
	print_rich("[color=Springgreen]BUILD_PIECES-[/color] Started Building Pieces at: [color=gold]%sms[/color]"
	%[time_before/1000])
	
	# Add Blank Node for Empty Squares
	blank_node = Node2D.new()
	blank_node.name = "PieceNone"
	add_child(blank_node)
	blank_sprite = Sprite2D.new()
	blank_sprite.name = "SpriteNone"
	blank_node.add_child(blank_sprite)
	
	var i:int = 0
	
	for coords:Vector2i in Scripts.DATABASE.TILE_DICTIONARY.keys():
		var piece_info:Array = _calculate_piece(coords)
		i += 1
		y_sort_enabled = true
		_create_piece(coords,piece_info,i)
	
	print_rich("[color=Springgreen]BUILD_PIECES-[/color] Finished Creating Pieces in: [color=gold]%sms[/color]"
	%[Scripts.DEBUG_MANAGER.end_timer(time_before)])
	
	# Initially Load In all Moves
	Scripts.PIECE_MOVE.get_all_moves()

static func _calculate_piece(coords:Vector2i) -> Array: # Calculates which Tiles should have Pieces
	# White Pawns
	if coords.x == 2:
		return [Scripts.CONSTANTS.PIECE_TYPE.PAWN,Scripts.CONSTANTS.PIECE_COLOR.WHITE]
	
	# Black Pawns
	if coords.x == 7:
		return [Scripts.CONSTANTS.PIECE_TYPE.PAWN,Scripts.CONSTANTS.PIECE_COLOR.BLACK]
	
	# White Pieces
	if coords.x == 1:
		
		if coords.y == 1 or coords.y == 8:
			return [Scripts.CONSTANTS.PIECE_TYPE.ROOK,Scripts.CONSTANTS.PIECE_COLOR.WHITE]
		
		if coords.y == 2 or coords.y == 7:
			return [Scripts.CONSTANTS.PIECE_TYPE.KNIGHT,Scripts.CONSTANTS.PIECE_COLOR.WHITE]
		
		if coords.y == 3 or coords.y == 6:
			return [Scripts.CONSTANTS.PIECE_TYPE.BISHOP,Scripts.CONSTANTS.PIECE_COLOR.WHITE]
		
		if coords.y == 4:
			return [Scripts.CONSTANTS.PIECE_TYPE.QUEEN,Scripts.CONSTANTS.PIECE_COLOR.WHITE]
		
		if coords.y == 5:
			Scripts.PIECE_MOVE.black_king_pos = Vector2i(coords.x,coords.y)
			return [Scripts.CONSTANTS.PIECE_TYPE.KING,Scripts.CONSTANTS.PIECE_COLOR.WHITE]
	
	# Black Pieces
	if coords.x == 8:
		
		if coords.y == 1 or coords.y == 8:
			return [Scripts.CONSTANTS.PIECE_TYPE.ROOK,Scripts.CONSTANTS.PIECE_COLOR.BLACK]
		
		if coords.y == 2 or coords.y == 7:
			return [Scripts.CONSTANTS.PIECE_TYPE.KNIGHT,Scripts.CONSTANTS.PIECE_COLOR.BLACK]
		
		if coords.y == 3 or coords.y == 6:
			return [Scripts.CONSTANTS.PIECE_TYPE.BISHOP,Scripts.CONSTANTS.PIECE_COLOR.BLACK]
		
		if coords.y == 4:
			return [Scripts.CONSTANTS.PIECE_TYPE.QUEEN,Scripts.CONSTANTS.PIECE_COLOR.BLACK]
		
		if coords.y == 5:
			Scripts.PIECE_MOVE.black_king_pos = Vector2i(coords.x,coords.y)
			return [Scripts.CONSTANTS.PIECE_TYPE.KING,Scripts.CONSTANTS.PIECE_COLOR.BLACK]
	
	return [Scripts.CONSTANTS.PIECE_TYPE.NONE,Scripts.CONSTANTS.PIECE_COLOR._0]

func _create_piece(coords:Vector2i,piece_info:Array,i:int) -> void: # Looks at DataBase then creates Node2D's that contain the Piece Sprites
	var piece:int = piece_info[0]
	var color:int = piece_info[1]
	
	var piece_object:Node2D
	var piece_sprite:Sprite2D
	
	if piece == Scripts.CONSTANTS.PIECE_TYPE.NONE:
		piece_object = blank_node
		piece_sprite = blank_sprite
		i = 0
	
	else: # Create and configure The Piece Object
		piece_object = Node2D.new()
		add_child(piece_object)
		piece_sprite = _get_piece_sprite(piece,color)
		piece_object.add_child(piece_sprite)
		var translated_coords:Vector2 = Scripts.BOARD_MANAGER.get_mouse_from_tile(coords)
		piece_object.global_position = translated_coords
		piece_object.scale = Vector2i(8,8)
		piece_object.move_local_y(-96)
	
	# Apply Piece Data
	Scripts.DATABASE.TILE_DICTIONARY[coords][Scripts.CONSTANTS.BOARD_LIST.PIECE] = i
	Scripts.DATABASE.PIECE_DICTIONARY.set(i,{
		Scripts.CONSTANTS.PIECE_LIST.PIECE_TYPE:piece,
		Scripts.CONSTANTS.PIECE_LIST.PIECE_COLOR:color,
		Scripts.CONSTANTS.PIECE_LIST.PIECE_OBJ:piece_object,
		Scripts.CONSTANTS.PIECE_LIST.PIECE_SPRITE:piece_sprite,
		Scripts.CONSTANTS.PIECE_LIST.TIMES_MOVED:0,
		Scripts.CONSTANTS.PIECE_LIST.PAWN_MOVED_TWO_TILES:Scripts.CONSTANTS.PAWN_MOVED_TWO_TILES.FALSE,
		})

static func _get_piece_sprite(piece:int,color:int) -> Sprite2D:
	var piece_sprite:Sprite2D = Sprite2D.new()
	
	var color_string:String
	if color == Scripts.CONSTANTS.PIECE_COLOR.WHITE:
		color_string = "white"
	else:
		color_string = "black"
	
	if piece == Scripts.CONSTANTS.PIECE_TYPE.PAWN:
		piece_sprite.texture = load("res://assets/images/pieces/%s/pawn.png"%color_string)
		return piece_sprite
	
	if piece == Scripts.CONSTANTS.PIECE_TYPE.ROOK:
		piece_sprite.texture = load("res://assets/images/pieces/%s/rook.png"%color_string)
		return piece_sprite
	
	if piece == Scripts.CONSTANTS.PIECE_TYPE.KNIGHT:
		piece_sprite.texture = load("res://assets/images/pieces/%s/knight.png"%color_string)
		return piece_sprite
	
	if piece == Scripts.CONSTANTS.PIECE_TYPE.BISHOP:
		piece_sprite.texture = load("res://assets/images/pieces/%s/bishop.png"%color_string)
		return piece_sprite
	
	if piece == Scripts.CONSTANTS.PIECE_TYPE.QUEEN:
		piece_sprite.texture = load("res://assets/images/pieces/%s/queen.png"%color_string)
		return piece_sprite
	
	if piece == Scripts.CONSTANTS.PIECE_TYPE.KING:
		piece_sprite.texture = load("res://assets/images/pieces/%s/king.png"%color_string)
		return piece_sprite
	
	return piece_sprite
