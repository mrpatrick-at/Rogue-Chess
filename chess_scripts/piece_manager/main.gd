extends Node2D
## enums
## consts
## exports
## public vars
## private vars
## onready vars
@onready var piece_none:Node2D = $PieceNone
# obj_ for node refrences
## built-in override methods

func _ready() -> void:
	initialize_pieces()
	pass 

func _physics_process(_delta:float) -> void:
	pass

## public methods

func initialize_pieces() -> void:
	var i:int = 0
	for coords in Scripts.BOARD_DATABASE.TILE_DICTIONARY.keys():
		i += 1
		y_sort_enabled = true
		var piece:int = _calculate_piece(coords)
		_create_piece(coords,piece,i)

static func call_move(current_coords:Vector2i,asked_coords:Vector2i,_moves:Array) -> void:
	new().move_piece(current_coords,asked_coords,_moves)

func move_piece(current_coords:Vector2i,asked_coords:Vector2i,_moves:Array) -> void: # Calls all funcs used for movement
	if asked_coords in _moves:
		var piece:int = Scripts.BOARD_DATABASE.TILE_DICTIONARY[current_coords]["piece"]
		var translated_coords:Vector2 = Scripts.BOARD_MANAGER.translate_coords(asked_coords)
		
		# Remove Old Data
		print("piece_manager/move_piece- before ",Scripts.BOARD_DATABASE.TILE_DICTIONARY[current_coords]["piece"])
		Scripts.BOARD_DATABASE.TILE_DICTIONARY[current_coords]["piece"] = 0
		print("piece_manager/move_piece- after ",Scripts.BOARD_DATABASE.TILE_DICTIONARY[current_coords]["piece"])
		
		# Add New Data
		Scripts.BOARD_DATABASE.TILE_DICTIONARY[asked_coords]["piece"] = piece
		print(Scripts.BOARD_DATABASE.TILE_DICTIONARY[asked_coords]["piece"])
		 
		# Move Piece
		var piece_object:Node2D = get_piece_data(asked_coords,Scripts.PIECE_CONSTS.PIECE_LIST.PIECE_OBJ)
		piece_object.global_position = translated_coords
		piece_object.move_local_y(-96)
		
	else:
		print("piece_manager/move_piece- coords not in _moves")
	
	return

static func get_piece_data(coords:Vector2i,data:int) -> Variant: # 1. coords 2. value to get
	var piece_object = Scripts.BOARD_DATABASE.TILE_DICTIONARY[coords]["piece"]
	var value = Scripts.PIECE_DATABASE.PIECE_DICTIONARY[piece_object][data]
	return value

static func set_piece_data(coords:Vector2i,data:int,value:int) -> void: # 1. coords 2. value to set 3. what to set it to
	var piece_object = Scripts.BOARD_DATABASE.TILE_DICTIONARY[coords]["piece"]
	Scripts.PIECE_DATABASE.PIECE_DICTIONARY.get_or_add(piece_object,{data:value})

## private methods

static func _calculate_piece(coords:Vector2i) -> int: # Calculates which Tiles should have Pieces
	var piece:int = Scripts.PIECE_LIST.NONE
	
	if coords.x == 2:
		piece = Scripts.PIECE_LIST.PAWN
		print("Pawn spawned at: ",coords,"!")
	
	if coords.x == 1 and (coords.y == 1 or coords.y == 8):
		piece = Scripts.PIECE_LIST.ROOK
		print("Rook spawned at: ",coords,"!")
	
	if coords.x == 1 and (coords.y == 2 or coords.y == 7):
		piece = Scripts.PIECE_LIST.KNIGHT
		print("Knight spawned at: ",coords,"!")
	
	if coords.x == 1 and (coords.y == 3 or coords.y == 6):
		piece = Scripts.PIECE_LIST.BISHOP
		print("Bishop spawned at: ",coords,"!")
	
	if coords.x == 1 and (coords.y == 4):
		piece = Scripts.PIECE_LIST.QUEEN
		print("Queen spawned at: ",coords,"!")
	
	if coords.x == 1 and (coords.y == 5):
		piece = Scripts.PIECE_LIST.KING
		print("King spawned at: ",coords,"!")
	
	return piece

func _create_piece(coords:Vector2i,piece:int,i:int) -> void: # Looks at DataBase then creates Node2D's that contain the Piece Sprites
	var piece_object
	var piece_sprite
	
	if piece == Scripts.PIECE_CONSTS.TYPE_LIST.NONE:
		piece_object = $PieceNone
		piece_sprite = $PieceNone/Sprite2D
		i = 0
	
	else:
		piece_object = Node2D.new()
		add_child(piece_object)
		piece_sprite = Sprite2D.new()
		piece_object.add_child(piece_sprite)
		var translated_coords = Scripts.BOARD_MANAGER.translate_coords(coords)
		piece_object.global_position = translated_coords
		piece_object.scale = Vector2i(8,8)
		piece_object.move_local_y(-96)
	
	Scripts.BOARD_DATABASE.TILE_DICTIONARY[coords]["piece"] = i
	Scripts.PIECE_DATABASE.PIECE_DICTIONARY.set(i,{ # Remember values with "" in here are not done yet and need to be set to an Int thru consts file
		Scripts.PIECE_CONSTS.PIECE_LIST.PIECE_OBJ:piece_object,
		Scripts.PIECE_CONSTS.PIECE_LIST.TYPE:piece,
		"piece_sprite":piece_sprite,
		"piece_object_position":piece_object.position,
		})
	
	var sprite:CompressedTexture2D
	
	if piece == Scripts.PIECE_LIST.PAWN:
		sprite = load("res://assets/pieces/white/pawn.png")
		Scripts.PIECE_DATABASE.PIECE_DICTIONARY[i][Scripts.PIECE_CONSTS.PIECE_LIST.PAWN_MOVED] = false
	
	if piece == Scripts.PIECE_LIST.ROOK:
		sprite = load("res://assets/pieces/white/rook.png")
		
	if piece == Scripts.PIECE_LIST.KNIGHT:
		sprite = load("res://assets/pieces/white/knight.png")
		
	if piece == Scripts.PIECE_LIST.BISHOP:
		sprite = load("res://assets/pieces/white/bishop.png")
		
	if piece == Scripts.PIECE_LIST.QUEEN:
		sprite = load("res://assets/pieces/white/queen.png")
		
	if piece == Scripts.PIECE_LIST.KING:
		sprite = load("res://assets/pieces/white/king.png")
	
	piece_sprite.texture = sprite
