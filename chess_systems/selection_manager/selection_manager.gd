extends RefCounted
## enums
## consts
## exports
## public vars
static var current_coords:Vector2i = Vector2i(0,0)
static var asked_coords:Vector2i = Vector2i(0,0)
static var selected_tile:bool = false
## private vars
static var _tilemap_selection:TileMapLayer
static var _moves:Array = [] # List of Moves of Selected Piece
## onready vars
# obj_ for node refrences
## built-in override methods
## public methods
static func reset_highlight() -> void: # Continously Called. Resets the Hightligted Tile and Writes to the Vars
	_tilemap_selection = Scripts.BOARD_MANAGER.tilemap_selection
	if current_coords == Vector2i(0,0):
		_tilemap_selection.clear()

static func highlight_tile(mouse_pos:Vector2i) -> void: # Called if esc_menu is hidden. Highlights the Tile below the Mouse
	if current_coords == Vector2i(0,0):
		if Scripts.BOARD_MANAGER.is_valid_position(mouse_pos):
			# Hightlight the Hovered Tile
			_tilemap_selection.set_cell(mouse_pos,1,Vector2i(1,0),0)

static func select_tile(mouse_pos:Vector2i) -> void: # Called on First Mouse Click. Hightlights current_coords and all Possible Moves of the Piece on it
	if(
	!Scripts.PIECE_MANAGER.get_piece_data(mouse_pos,Scripts.CONSTANTS.PIECE_LIST.PIECE_TYPE) == Scripts.CONSTANTS.PIECE_TYPE.NONE and
	Scripts.PIECE_MANAGER.get_piece_data(mouse_pos,Scripts.CONSTANTS.PIECE_LIST.PIECE_COLOR) == Scripts.DATABASE.color_turn):
		current_coords = mouse_pos
		
		# Hightlight Piece Itself
		_tilemap_selection.set_cell(current_coords,1,Vector2i(2,0),0)
		
		# Hightlight Possible Moves
		if selected_tile == false:
			selected_tile = true
			if !Scripts.PIECE_MOVE.got_all_moves: # If Movement Dict not already Loaded: Load it in Bitch
				Scripts.PIECE_MOVE.set_all_moves()
			_moves = Scripts.PIECE_MANAGER.get_piece_data(current_coords,Scripts.CONSTANTS.PIECE_LIST.MOVE_ARRAY)
			for i:Vector2i in _moves:
				_tilemap_selection.set_cell(i,1,Vector2i(1,0),0)
	else:
		print("SELECT_TILE- ERROR: Selected Tile dosen't contain Valid Piece")

static func select_destination_tile(mouse_pos:Vector2i) -> void: # Called on Second Mouse Click. Calls the Movement to the Tile
	if Scripts.BOARD_MANAGER.is_valid_position(mouse_pos):
		# Where to Move to: coord
		asked_coords = mouse_pos
		_tilemap_selection.set_cell(asked_coords,1,Vector2i(2,0),0)
		print("SELECT_DESTINATION_TILE- Move Piece from: ",current_coords,", Move Piece to: ",asked_coords)
		
		# Call Movement
		Scripts.PIECE_MOVE.make_move(current_coords,asked_coords,_moves)
		current_coords = Vector2i(0,0)
		asked_coords = Vector2i(0,0)
		selected_tile = false
	else:
		print("SELECT_DESTINATION_TILE- ERROR: Tile Outside Board!")

## private methods
