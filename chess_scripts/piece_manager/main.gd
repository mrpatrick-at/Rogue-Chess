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

func _process(_delta: float) -> void:
	build_pieces()
	pass

## public methods

func build_pieces() -> void:
	var database = Scripts.BOARD_DATABASE.TILE_DICTIONARY
	for coords in database.keys():
		if Scripts.BOARD_DATABASE.TILE_DICTIONARY[coords]["piece"] == Scripts.PIECE_LIST._0:
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
	var translated_coords = Scripts.BOARD_MANAGER.new().translated_coords(database,coords)
	var database_tile = Scripts.BOARD_DATABASE.TILE_DICTIONARY
	var piece = database[coords]["piece"]
	if piece == Scripts.PIECE_LIST.NONE:
		return
	if piece == Scripts.PIECE_LIST.PAWN:
		var pawn = load("res://chess_objects/pieces/pawn/main.tscn")
		var pawn_instance:Node2D = pawn.instantiate()
		add_child(pawn_instance)
		pawn_instance.global_position = translated_coords
		#pawn_instance.global_transform.y = translated_coords
		
		
	#print(piece)
	pass

## private methods
