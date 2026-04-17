extends RefCounted
## enums
## consts
const hightlight_speed_up:float = 0.05
const hightlight_speed_down:float = 0.03
const highlight_height:int = 32
## exports
## public vars
static var mouse_pos:Vector2i
static var current_coords:Vector2i = Vector2i(0,0)
static var asked_coords:Vector2i = Vector2i(0,0)
static var selected_tile:bool = false
## private vars
static var _tilemap_selection:TileMapLayer
static var _moves:Array = [] # List of Moves of Selected Piece
static var _moved:Dictionary = {} # Keeps Track of Pieces In Hightlight Animation
## onready vars
# obj_ for node refrences
## built-in override methods
## public methods
static func reset_highlight() -> void: # Continously Called. Resets the Hightligted Tile and Writes to the Vars
	mouse_pos = Scripts.BOARD_MANAGER.get_tile_from_mouse()
	_tilemap_selection = Scripts.BOARD_MANAGER.tilemap_selection
	if current_coords == Vector2i(0,0):
		_tilemap_selection.clear()
		hightlight_piece(mouse_pos)

static func highlight_tile() -> void: # Called if esc_menu is hidden. Highlights the Tile below the Mouse
	if current_coords == Vector2i(0,0):
		if Scripts.BOARD_MANAGER.is_valid_position(mouse_pos):
			# Hightlight the Hovered Tile
			_tilemap_selection.set_cell(mouse_pos,1,Vector2i(1,0),0)

static func select_tile() -> void: # Called on First Mouse Click. Hightlights current_coords and all Possible Moves of the Piece on it
	if(
	!Scripts.PIECE_MANAGER.get_piece_data(mouse_pos,Scripts.CONSTANTS.PIECE_LIST.PIECE_TYPE) == Scripts.CONSTANTS.PIECE_TYPE.NONE and
	Scripts.PIECE_MANAGER.get_piece_data(mouse_pos,Scripts.CONSTANTS.PIECE_LIST.PIECE_COLOR) == Scripts.DATABASE.color_turn):
		current_coords = mouse_pos
		
		# Hightlight Piece Itself
		_tilemap_selection.set_cell(current_coords,1,Vector2i(2,0),0)
		
		# Hightlight Possible Moves
		if selected_tile == false:
			selected_tile = true
			if Scripts.PIECE_MOVE.all_moves.is_empty():
				Scripts.PIECE_MOVE.get_all_moves()
			_moves = Scripts.PIECE_MOVE.all_moves[current_coords]
			for i:Vector2i in _moves:
				_tilemap_selection.set_cell(i,1,Vector2i(1,0),0)
	else:
		print("SELECT_TILE- ERROR: Selected Tile dosen't contain Valid Piece")

static func select_destination_tile() -> void: # Called on Second Mouse Click. Calls the Movement to the Tile
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

static func hightlight_piece(coords:Vector2i) -> void: # Continously Called. Slightly moves a Piece Vertical In an Animation
	var piece_object:Node2D = Scripts.PIECE_MANAGER.get_piece_data(coords,Scripts.CONSTANTS.PIECE_LIST.PIECE_OBJ)
	var translated_coords:Vector2 = Scripts.BOARD_MANAGER.get_mouse_from_tile(coords)
	
	if (Scripts.BOARD_MANAGER.is_valid_position(coords) and 
	Scripts.DATABASE.color_turn == Scripts.PIECE_MANAGER.get_piece_data(coords,Scripts.CONSTANTS.PIECE_LIST.PIECE_COLOR) and 
	piece_object.position.y == -96 + translated_coords.y):
		var tween:Tween = piece_object.create_tween()
		var old_y:float = piece_object.position.y
		_moved[piece_object] = [tween,old_y]
		tween.tween_property(piece_object,"position",Vector2(piece_object.position.x,piece_object.position.y -highlight_height), hightlight_speed_up)
	
	if !_moved.is_empty():
			
		for last_piece_object:Node2D in _moved:
			if last_piece_object == piece_object:
				return
			var array:Array = _moved.get(last_piece_object)
			var old_tween:RefCounted = array.get(0)
			var old_y:float = array.get(1)
			old_tween.kill()
			var tween:RefCounted = last_piece_object.create_tween()
			tween.tween_property(last_piece_object,"position",Vector2(last_piece_object.position.x,old_y), hightlight_speed_down)
			_moved.erase(last_piece_object)

## private methods
