extends Node2D
## enums
## consts
## exports
## public vars
static var built:bool = false
static var tilemap_selection:TileMapLayer = TileMapLayer.new()
static var tilemap_board:TileMapLayer = TileMapLayer.new()
static var x_range:int = 9
static var y_range:int = 9
static var asked_coords:Vector2i = Vector2i(0,0)
static var current_coords:Vector2i = Vector2i(0,0)
## private vars
## onready vars
#@onready var tilemap_board:TileMapLayer = $TileMapLayer_Selection/TileMapLayer_Board
#@onready var tilemap_selection:TileMapLayer = $TileMapLayer_Selection
# obj_ for node refrences
## built-in override methods

func _ready() -> void: # Runs on Startup
	_create_tilemap_layers()
	build_board()
	_center_tilemap()
	pass

func _physics_process(_delta:float) -> void: # Runs Every Tick
	Scripts.PIECE_MOVE.is_in_check()
	if InputEventMouse:
		select_tile()
	pass

## public methods

static func build_board() -> void: # Remember y_range needs to be +1 bc it stops 1 before
	for x in range(1,x_range):
		for y in range(1,y_range):
			var coords:Vector2i = Vector2i(x,y)
			if coords not in Scripts.BOARD_DATABASE.TILE_DICTIONARY:
				_calculate_tile_color(coords)
				_create_board_cells(coords)
	_create_background()
	
	print("Created Board of size: ",tilemap_board.get_used_rect(),"!") # TODO: Make it Error if Board size does not equal expected size

static func is_valid_position(_asked_coords:Vector2i) -> bool:
	if _asked_coords.x >= 1 and _asked_coords.x < 9 and _asked_coords.y >= 1 and _asked_coords.y < 9:
		return true
	return false

static func select_tile() -> void: # Highlight the Tile below the Mouse TODO: Make Cleaner and more Functional
	var mouse_pos:Vector2i = get_tile_from_mouse()
	if current_coords == Vector2i(0,0):
		tilemap_selection.clear()
		# Highlight Tiles if hovered
		if is_valid_position(mouse_pos):
			tilemap_selection.set_cell(mouse_pos,1,Vector2i(1,0),0)
			
			# Initiate Piece Movement
			if Input.is_action_just_pressed(&"_input_mouse_left") and (
			!Scripts.PIECE_MANAGER.get_piece_data(mouse_pos,Scripts.PIECE_CONSTS.PIECE_LIST.TYPE) == Scripts.PIECE_CONSTS.TYPE_LIST.NONE and
			Scripts.PIECE_MANAGER.get_piece_data(mouse_pos,Scripts.PIECE_CONSTS.PIECE_LIST.PIECE_COLOR) == Scripts.color_turn):
				current_coords = mouse_pos
		
	elif is_valid_position(mouse_pos):
		
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

static func get_tile_from_mouse() -> Vector2i: # Translates Mouse coords into Board coords
	var tilemap_selection_local_mouse_coords:Vector2 = tilemap_selection.get_local_mouse_position()
	var tilemap_selection_coords:Vector2i
	
	if tilemap_board == null: # Error if tilemap_board cant be found
		print("Tilemap is null")
	
	tilemap_selection_coords = tilemap_board.local_to_map(tilemap_selection_local_mouse_coords)
	
	#print("Updated highlighted Tile: ",tilemap_selection_local_mouse_coords," ; Tilemap Coords: ",tilemap_selection_coords,"!")
	return tilemap_selection_coords

static func get_mouse_from_tile(coords:Vector2i) -> Vector2: # Translates Coords from map to global
	var translated_coords:Vector2 = tilemap_board.to_global(tilemap_board.map_to_local(coords))
	return translated_coords

## private methods

func _create_tilemap_layers(quadrant_size:int = 128,tile_set:TileSet = preload("res://chess_objects/board/tile_set.tres")) -> void:
	# Config tilemap_selection
	add_child(tilemap_selection)
	tilemap_selection.rendering_quadrant_size = quadrant_size
	tilemap_selection.physics_quadrant_size = quadrant_size
	tilemap_selection.tile_set = tile_set
	
	# Config tilemap_board
	tilemap_selection.add_child(tilemap_board)
	tilemap_board.show_behind_parent = true
	tilemap_board.rendering_quadrant_size = quadrant_size
	tilemap_board.physics_quadrant_size = quadrant_size
	tilemap_board.tile_set = tile_set
	
	print("tileset id count: ",tile_set.get_source_count())

static func _calculate_tile_color(coords:Vector2i) -> void: # Assing A Value to Each Tile used for Colouring
	var int_x:int = 0 # Check if x is odd or even
	if (coords.x & 1) == 0:
		int_x += 2
	if (coords.x & 1) == 1:
		int_x += 1
		
	var int_y:int = 0 # Check if y is odd or even
	if (coords.y & 1) == 0:
		int_y += 2
	if (coords.y & 1) == 1:
		int_y += 1
	
	var colour_of_tile:String = "none" # Only used for debug message
	var same_or_diffrent:int = 0
	
	if int_x == 2 and int_y == 2 or int_x == 1 and int_y == 1:
		same_or_diffrent = 1
	else:
		same_or_diffrent = 2
		
	if same_or_diffrent == 1: # Values same = black tile
		Scripts.BOARD_DATABASE.TILE_BLACK += 1
		Scripts.BOARD_DATABASE.TILE_DICTIONARY.get_or_add(coords,{
		"color": Scripts.BOARD_CONSTS.COLOR_LIST.BLACK,
		})
		
		colour_of_tile = "Black"
	
	if same_or_diffrent == 2: # values diffrent = white tile
		Scripts.BOARD_DATABASE.TILE_WHITE += 1
		Scripts.BOARD_DATABASE.TILE_DICTIONARY.get_or_add(coords,{
		"color": Scripts.BOARD_CONSTS.COLOR_LIST.WHITE,
		})
		
		colour_of_tile = "White"
		
	Scripts.BOARD_DATABASE.TOTAL_TILES = Scripts.BOARD_DATABASE.TILE_BLACK + Scripts.BOARD_DATABASE.TILE_WHITE # Total Ints (Should be 64 for Chess board)
	print(colour_of_tile," Tile Found at: ",coords," ; Now there is ",Scripts.BOARD_DATABASE.TOTAL_TILES,"/64 Total Tiles!")
	return

static func _create_board_cells(coords:Vector2i) -> void: # Create Board Cells Based on the Colour Value
	var atlas_coords:Vector2i = Vector2i(Scripts.BOARD_DATABASE.TILE_DICTIONARY[coords]["color"],0) # Blank: 0,0 ; White: 1,0 ; Black: 2,0 ; Selection_Sprite: 3,0 ;
	var atlas_selection_coords:Vector2i = Vector2i(0,0) # Blank: 0,0 ; Selection: 1,0 ;
	tilemap_board.set_cell(coords,0,atlas_coords,0)
	tilemap_selection.set_cell(coords,1,atlas_selection_coords,0)

func _center_tilemap() -> void: # Rotates and Centers ALL Tilemaps
	rotation_degrees = -90
	global_position.x = ((x_range * 128.0) / 2.0 ) *-1
	global_position.y = ((y_range * 128.0) / 2.0 ) *1
	print("Tile Map Centered to: ",position.x," , ",position.y,"!")

static func _create_background() -> void: # Creates the Board Background TODO: Make this
	pass
	
	
	
	
	
	
	
	
