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
	pass 

func _physics_process(delta: float) -> void:
	build_pieces()
	pass

## public methods

func build_pieces() -> void:
	var database = Scripts.BOARD_DATABASE.TILE_DICTIONARY
	for coords in database.keys():
		if Scripts.BOARD_DATABASE.TILE_DICTIONARY[coords]["piece"] == Scripts.PIECE_LIST._0:
			y_sort_enabled = true
			calculate_pieces(database,coords)
			create_piece(database,coords)

static func calculate_pieces(database:Dictionary,coords:Vector2i) -> void:
	database[coords]["piece"] = Scripts.PIECE_LIST.NONE
	if coords.x == 2:
		database[coords]["piece"] = Scripts.PIECE_LIST.PAWN
		print("Pawn spawned at: ",coords,"!")
	
	if coords.x == 1 and (coords.y == 1 or coords.y == 8):
		database[coords]["piece"] = Scripts.PIECE_LIST.ROOK
		print("Rook spawned at: ",coords,"!")
	
	if coords.x == 1 and (coords.y == 2 or coords.y == 7):
		database[coords]["piece"] = Scripts.PIECE_LIST.KNIGHT
		print("Knight spawned at: ",coords,"!")
	
	if coords.x == 1 and (coords.y == 3 or coords.y == 6):
		database[coords]["piece"] = Scripts.PIECE_LIST.BISHOP
		print("Bishop spawned at: ",coords,"!")
	
	if coords.x == 1 and (coords.y == 4):
		database[coords]["piece"] = Scripts.PIECE_LIST.QUEEN
		print("Queen spawned at: ",coords,"!")
	
	if coords.x == 1 and (coords.y == 5):
		database[coords]["piece"] = Scripts.PIECE_LIST.KING
		print("King spawned at: ",coords,"!")

func create_piece(database:Dictionary,coords:Vector2i) -> void: # TODO: Fix this mess
	var translated_coords = Scripts.BOARD_MANAGER.translate_coords(coords)
	var piece = database[coords]["piece"]
	
	if piece == Scripts.PIECE_LIST.NONE:
		return
	
	if piece == Scripts.PIECE_LIST.PAWN:
		var pawn = load("res://chess_objects/pieces/pawn/main.tscn")
		var pawn_instance:Node2D = pawn.instantiate()
		add_child(pawn_instance)
		pawn_instance.global_position = translated_coords
		pawn_instance.scale = Vector2i(8,8)
		pawn_instance.move_local_y(-96)
	
	if piece == Scripts.PIECE_LIST.ROOK:
		var rook = load("res://chess_objects/pieces/rook/main.tscn")
		var rook_instance:Node2D = rook.instantiate()
		add_child(rook_instance)
		rook_instance.global_position = translated_coords
		rook_instance.scale = Vector2i(8,8)
		rook_instance.move_local_y(-96)
	
	if piece == Scripts.PIECE_LIST.KNIGHT:
		var knight = load("res://chess_objects/pieces/knight/main.tscn")
		var knight_instance:Node2D = knight.instantiate()
		add_child(knight_instance)
		knight_instance.global_position = translated_coords
		knight_instance.scale = Vector2i(8,8)
		knight_instance.move_local_y(-96)
	
	if piece == Scripts.PIECE_LIST.BISHOP:
		var bishop = load("res://chess_objects/pieces/bishop/main.tscn")
		var bishop_instance:Node2D = bishop.instantiate()
		add_child(bishop_instance)
		bishop_instance.global_position = translated_coords
		bishop_instance.scale = Vector2i(8,8)
		bishop_instance.move_local_y(-96)
	
	if piece == Scripts.PIECE_LIST.QUEEN:
		var queen = load("res://chess_objects/pieces/queen/main.tscn")
		var queen_instance:Node2D = queen.instantiate()
		add_child(queen_instance)
		queen_instance.global_position = translated_coords
		queen_instance.scale = Vector2i(8,8)
		queen_instance.move_local_y(-96)
	
	if piece == Scripts.PIECE_LIST.KING:
		var king = load("res://chess_objects/pieces/king/main.tscn")
		var king_instance:Node2D = king.instantiate()
		add_child(king_instance)
		king_instance.global_position = translated_coords
		king_instance.scale = Vector2i(8,8)
		king_instance.move_local_y(-96)
		


## private methods
