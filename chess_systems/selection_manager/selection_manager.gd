extends RefCounted
## enums
## consts
## exports
## public vars
## private vars
static var piece_highlighted:bool = false
static var last_piece_object:Node2D
static var last_translated_coords:Vector2i

static var current_coords:Vector2i = Vector2i(0,0)
static var asked_coords:Vector2i = Vector2i(0,0)
## onready vars
# obj_ for node refrences
## built-in override methods
## public methods
static func select_tile() -> void: # Highlight the Tile below the Mouse TODO: Make Cleaner and more Functional
	var mouse_pos:Vector2i = Scripts.BOARD_MANAGER.get_tile_from_mouse()
	var tilemap_selection:TileMapLayer = Scripts.BOARD_MANAGER.tilemap_selection
	
	# Repeadetly Clear the Tilemap
	if current_coords == Vector2i(0,0):
		tilemap_selection.clear()
		hightlight_piece(mouse_pos)
	
	if Scripts.BOARD_MANAGER.is_valid_position(mouse_pos):
		# If no Tile Selected
		if current_coords == Vector2i(0,0):
			tilemap_selection.set_cell(mouse_pos,1,Vector2i(1,0),0)
			
			# Initiate Piece Movement
			if Input.is_action_just_pressed(&"_input_mouse_left") and (
			!Scripts.PIECE_MANAGER.get_piece_data(mouse_pos,Scripts.CONSTANTS.PIECE_LIST.PIECE_TYPE) == Scripts.CONSTANTS.PIECE_TYPE.NONE and
			Scripts.PIECE_MANAGER.get_piece_data(mouse_pos,Scripts.CONSTANTS.PIECE_LIST.PIECE_COLOR) == Scripts.color_turn):
				current_coords = mouse_pos
		else:
			
			# Hightlight Piece Itself
			tilemap_selection.set_cell(current_coords,1,Vector2i(2,0),0)
			
			# Hightlight Possible Moves
			var _moves:Array = Scripts.PIECE_MOVE.get_moves(current_coords)
			for i:Vector2i in _moves:
				tilemap_selection.set_cell(i,1,Vector2i(1,0),0)
			
			if Input.is_action_just_pressed(&"_input_mouse_left"):
				# Where to Move to: coord
				asked_coords = mouse_pos
				tilemap_selection.set_cell(asked_coords,1,Vector2i(2,0),0)
				print("Move Piece from: ",current_coords,", Move Piece to: ",asked_coords)
				
				# Call Movement
				Scripts.PIECE_MOVE.make_move(current_coords,asked_coords)
				current_coords = Vector2i(0,0)
				asked_coords = Vector2i(0,0)
				
	else:
		if Input.is_action_just_pressed(&"_input_mouse_left"): # Error if mouse_pos Outside Board
				print("Error: Tile Outside Board!")

static func hightlight_piece(coords:Vector2i) -> void:
	var piece_object:Node2D = Scripts.PIECE_MANAGER.get_piece_data(coords,Scripts.CONSTANTS.PIECE_LIST.PIECE_OBJ)
	var translated_coords:Vector2 = Scripts.BOARD_MANAGER.get_mouse_from_tile(coords)
	
	if piece_highlighted == true and last_piece_object != piece_object:
		piece_highlighted = false
		last_piece_object.move_local_y(+32)
	
	elif (Scripts.BOARD_MANAGER.is_valid_position(coords) and 
	Scripts.color_turn == Scripts.PIECE_MANAGER.get_piece_data(coords,Scripts.CONSTANTS.PIECE_LIST.PIECE_COLOR) and 
	piece_object.position.y == -96 + translated_coords.y):
		piece_object.move_local_y(-32)
		last_piece_object = piece_object
		last_translated_coords = translated_coords
		piece_highlighted = true


## private methods
