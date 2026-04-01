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
static var selected_tile:Vector2i = Vector2i(0,0)
static var selected_tile_from:Vector2i = Vector2i(0,0)
## private vars
## onready vars
#@onready var tilemap_board:TileMapLayer = $TileMapLayer_Selection/TileMapLayer_Board
#@onready var tilemap_selection:TileMapLayer = $TileMapLayer_Selection
# obj_ for node refrences
## built-in override methods

func _ready() -> void:
	build_board()
	pass

func _physics_process(delta:float) -> void:
	if InputEventMouse:
		select_tile()
	pass

## public methods

func build_board() -> void: # Remember y_range needs to be +1 bc it stops 1 before
	create_tilemap_layers()
	for x in range(1,x_range):
		for y in range(1,y_range):
			var coords:Vector2i = Vector2i(x,y)
			if !Scripts.BOARD_DATABASE.TILE_DICTIONARY.has(coords):
				_calculate_tile_color(coords)
				_create_board_cells(coords)
				Scripts.PIECE_MANAGER.new().build_pieces(coords)
				
	print("Created Board of size: ",tilemap_board.get_used_rect(),"!") # TODO: Make it Error if Board size does not equal expected size
	_center_tilemap(x_range,y_range)

func request_tile_below_mouse() -> Vector2i: # Translates Mouse coords into Board coords
	var tilemap_selection_local_mouse_coords:Vector2 = tilemap_selection.get_local_mouse_position()
	var tilemap_selection_coords:Vector2i
	
	if tilemap_board == null: # Error if tilemap_board cant be found
		print("Tilemap is null")
	
	tilemap_selection_coords = tilemap_board.local_to_map(tilemap_selection_local_mouse_coords)
	#Scripts.BOARD_DATABASE.TILEMAP_SELECTION_MOUSE_CORDS = tilemap_selection_coords # Uncomment to store Value in Database
	
	# Debug
	#print("Updated highlighted Tile: ",tilemap_selection_local_mouse_coords," ; Tilemap Coords: ",tilemap_selection_coords,"!")
	return tilemap_selection_coords

func select_tile() -> void:
	var tilemap_selection_mouse_coords:Vector2i = request_tile_below_mouse()
	# Check if Tile inside Board
	var valid_tile:bool = false
	if (tilemap_selection_mouse_coords.x  > 0 and tilemap_selection_mouse_coords.x < x_range) and (
		tilemap_selection_mouse_coords.y > 0 and tilemap_selection_mouse_coords.y < y_range):
		valid_tile = true
	
	# Loop for tile highlight
	tilemap_selection.clear()
	if valid_tile == true:
		if selected_tile == Vector2i(0,0):
			tilemap_selection.set_cell(tilemap_selection_mouse_coords,1,Vector2i(1,0),0)
			if Input.is_action_just_pressed(&"_input_mouse_left"):
				selected_tile = tilemap_selection_mouse_coords
		# Chess Piece Movement
		else:
			# The Piece to Move: coord
			tilemap_selection.set_cell(selected_tile,1,Vector2i(2,0),0)
			selected_tile_from = selected_tile
			if Input.is_action_just_pressed(&"_input_mouse_left"):
				# Where to Move to: coord
				selected_tile = tilemap_selection_mouse_coords
				tilemap_selection.set_cell(selected_tile,1,Vector2i(2,0),0)
				print("Move Piece from: ",selected_tile_from,", Move Piece to: ",selected_tile)
				Scripts.PIECE_PAWN.call_movement(selected_tile_from,selected_tile)
				selected_tile = Vector2i(0,0)
	else:
		if Input.is_action_just_pressed(&"_input_mouse_left"):
			# Error if tilemap_selection_mouse_coords Outside Board
			print("Error: Tile Outside Board!")

func create_tilemap_layers(quadrant_size:int = 128,tile_set:TileSet = preload("res://chess_objects/board/tile_set.tres")) -> void:
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

## private methods

static func _calculate_tile_color(coords:Vector2i) -> void:
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
	
	var colour_of_tile:String = "unkown"
	var same_or_diffrent:int = 0
	
	if int_x == 2 and int_y == 2 or int_x == 1 and int_y == 1:
		same_or_diffrent = 1
	else:
		same_or_diffrent = 2
		
	if same_or_diffrent == 1: # Values same = black tile
		Scripts.BOARD_DATABASE.TILE_BLACK += 1
		Scripts.BOARD_DATABASE.TILE_DICTIONARY.get_or_add(coords,{"colour":2})
		colour_of_tile = "White"
	
	if same_or_diffrent == 2: # values diffrent = white tile
		Scripts.BOARD_DATABASE.TILE_WHITE += 1
		Scripts.BOARD_DATABASE.TILE_DICTIONARY.get_or_add(coords,{"colour":1})
		colour_of_tile = "Black"
		
	Scripts.BOARD_DATABASE.TOTAL_TILES = Scripts.BOARD_DATABASE.TILE_BLACK + Scripts.BOARD_DATABASE.TILE_WHITE # Total Ints (Should be 64 for Chess board)
	print(colour_of_tile," Tile Found at: ",coords," ; Now there is ",Scripts.BOARD_DATABASE.TOTAL_TILES,"/64 Total Tiles!")
	return

func _create_board_cells(coords:Vector2i) -> void:
	var atlas_coords:Vector2i = Vector2i(Scripts.BOARD_DATABASE.TILE_DICTIONARY[coords]["colour"],0) # Blank: 0,0 ; White: 1,0 ; Black: 2,0 ; Selection_Sprite: 3,0 ;
	var atlas_selection_coords:Vector2i = Vector2i(0,0) # Blank: 0,0 ; Selection: 1,0 ;
	tilemap_board.set_cell(coords,0,atlas_coords,0)
	tilemap_selection.set_cell(coords,1,atlas_selection_coords,0)

func _center_tilemap(x_range:int,y_range:int) -> void:
	rotation_degrees = -90
	position.x = ((x_range * 128.0) / 2.0 )
	position.y = ((y_range * 128.0) / 2.0 )
	print("Tile Map Centered to: ",position.x," , ",position.y,"!")
