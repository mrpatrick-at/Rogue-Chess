extends Node2D
## enums
## consts
## exports
## public vars
## private vars
## onready vars
# obj_ for node refrences
## built-in override methods

func _ready() -> void:
	var database = Scripts.BOARD_DATABASE.TILE_DICTIONARY
	for coords in database.keys():
		if database[coords]["piece"]["piece_type"] == Scripts.PIECE_LIST._0:
			y_sort_enabled = true
			_calculate_piece(database,coords)
			_create_piece(database,coords)
	pass 

func _physics_process(_delta:float) -> void:
	#var database = Scripts.BOARD_DATABASE.TILE_DICTIONARY
	#for coords in database.keys():
		#if database[coords]["piece"]["piece_type"] == Scripts.PIECE_LIST._0:
			#y_sort_enabled = true
			#_calculate_piece(database,coords)
			#_create_piece(database,coords)
	pass

## public methods

static func call_movement(current_coords:Vector2i,asked_coords:Vector2i) -> void: # Calls all funcs used for movement
	var possible_move = Scripts.PIECE_MOVEMENT_CALC.calculate_movement(current_coords,asked_coords)
	#print("Piece, Current Coords: ",current_coords,", Asked, Coords: ",asked_coords,", Is Move Possible?: ",possible_move)
	
	if possible_move:
		move_piece(current_coords,asked_coords)
	return

static func move_piece(current_coords:Vector2i,asked_coords:Vector2i) -> void:
	var piece_object = Scripts.BOARD_DATABASE.TILE_DICTIONARY[current_coords]["piece"]["piece_object"]
	var piece_type = Scripts.BOARD_DATABASE.TILE_DICTIONARY[current_coords]["piece"]["piece_type"]
	var translated_coords = Scripts.BOARD_MANAGER.translate_coords(asked_coords)
	
	
	# Remove Old Data
	Scripts.BOARD_DATABASE.TILE_DICTIONARY[current_coords]["piece"]["piece_type"] = Scripts.PIECE_LIST.NONE
	Scripts.BOARD_DATABASE.TILE_DICTIONARY[current_coords]["piece"]["piece_object"] = null
	
	# Add New Data
	piece_object.global_position = translated_coords
	Scripts.BOARD_DATABASE.TILE_DICTIONARY[asked_coords]["piece"]["piece_type"] = piece_type
	Scripts.BOARD_DATABASE.TILE_DICTIONARY[asked_coords]["piece"]["piece_object"] = piece_object
	piece_object.move_local_y(-96)
	#print(Scripts.BOARD_DATABASE.TILE_DICTIONARY[asked_coords])
## private methods

static func _calculate_piece(database:Dictionary,coords:Vector2i) -> void: # Calculates which Tiles should have Pieces
	database[coords]["piece"]["piece_type"] = Scripts.PIECE_LIST.NONE
	if coords.x == 2:
		database[coords]["piece"]["piece_type"] = Scripts.PIECE_LIST.PAWN
		print("Pawn spawned at: ",coords,"!")
	
	if coords.x == 1 and (coords.y == 1 or coords.y == 8):
		database[coords]["piece"]["piece_type"] = Scripts.PIECE_LIST.ROOK
		print("Rook spawned at: ",coords,"!")
	
	if coords.x == 1 and (coords.y == 2 or coords.y == 7):
		database[coords]["piece"]["piece_type"] = Scripts.PIECE_LIST.KNIGHT
		print("Knight spawned at: ",coords,"!")
	
	if coords.x == 1 and (coords.y == 3 or coords.y == 6):
		database[coords]["piece"]["piece_type"] = Scripts.PIECE_LIST.BISHOP
		print("Bishop spawned at: ",coords,"!")
	
	if coords.x == 1 and (coords.y == 4):
		database[coords]["piece"]["piece_type"] = Scripts.PIECE_LIST.QUEEN
		print("Queen spawned at: ",coords,"!")
	
	if coords.x == 1 and (coords.y == 5):
		database[coords]["piece"]["piece_type"] = Scripts.PIECE_LIST.KING
		print("King spawned at: ",coords,"!")

func _create_piece(database:Dictionary,coords:Vector2i) -> void: # Creates The Pieces
	var piece = database[coords]["piece"]["piece_type"]
	
	if piece == Scripts.PIECE_LIST.NONE:
		return
	
	var translated_coords = Scripts.BOARD_MANAGER.translate_coords(coords)
	var piece_object:Node2D = Node2D.new()
	add_child(piece_object)
	var piece_sprite:Sprite2D = Sprite2D.new()
	piece_object.add_child(piece_sprite)
	
	var sprite:CompressedTexture2D
	
	if piece == Scripts.PIECE_LIST.PAWN:
		sprite = load("res://assets/pieces/white/pawn.png")
	
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
	
	piece_object.global_position = translated_coords
	piece_object.scale = Vector2i(8,8)
	piece_object.move_local_y(-96)
	Scripts.BOARD_DATABASE.TILE_DICTIONARY[coords]["piece"]["piece_object"] = piece_object
	Scripts.BOARD_DATABASE.TILE_DICTIONARY[coords]["piece"]["sprite_object"] = piece_sprite
	Scripts.BOARD_DATABASE.TILE_DICTIONARY[coords]["piece"]["piece_object_position"] = piece_object.position
