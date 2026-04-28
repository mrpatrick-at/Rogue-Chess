extends Node2D
## enums
## consts
const quadrant_size:int = 128
const x_range:int = 9
const y_range:int = 9

## exports
## public vars
static var tilemap_selection:TileMapLayer
static var tilemap_board:TileMapLayer
## private vars
## onready vars

# obj_ for node refrences
## built-in override methods

func _ready() -> void: # Runs on Startup
	build_board()

func _physics_process(_delta:float) -> void: # Runs Every Tick
	pass
## public methods

func build_board() -> void: # Remember y_range needs to be +1 bc it stops 1 before
	var time_before:float = Time.get_ticks_usec()
	print_rich("[color=Springgreen]BUILD_BOARD-[/color] Started Building Board at: [color=gold]%sms[/color]"
	%[time_before/1000])
	_create_tilemap_layers()
	for x in range(1,x_range):
		for y in range(1,y_range):
			var coords:Vector2i = Vector2i(x,y)
			if coords not in Scripts.DATABASE.TILE_DICTIONARY:
				_calculate_tile_color(coords)
				_create_board_cells(coords)
	_center_tilemap()
	
	print_rich("[color=Springgreen]BUILD_BOARD-[/color] Created Board of size: [color=gold]%s[/color] in: [color=gold]%sms[/color]"
	%[tilemap_board.get_used_rect(), Scripts.DEBUG_MANAGER.end_timer(time_before)])
	

static func is_valid_position(_asked_coords:Vector2i) -> bool:
	if _asked_coords.x >= 1 and _asked_coords.x < 9 and _asked_coords.y >= 1 and _asked_coords.y < 9:
		return true
	return false

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

static func get_tiles_between_points(starting_pos:Vector2i,target_pos:Vector2i,getting_check:bool) -> Array: # Returns starting_pos + Array of all Positions between the two Points
	var value_x:int
	var value_y:int
	
	if starting_pos.x < target_pos.x:
		value_x = 1
	elif starting_pos.x == target_pos.x:
		value_x = 0
	else:
		value_x = -1
		
	if starting_pos.y < target_pos.y:
		value_y = 1
	elif starting_pos.y == target_pos.y:
		value_y = 0
	else:
		value_y = -1
	
	#print("GET_TILES_BETWEEN_POINTS- step values: ",Vector2i(value_x,value_y))
	var step:Vector2i = Vector2i(starting_pos)
	var _steps:Array = []
	var pieces_between:Array = []
	
	while step != target_pos:
		_steps.append(step)
		
		if step.x != target_pos.x:
			step.x += value_x
		if step.y != target_pos.y:
			step.y += value_y
		
		if getting_check and !Scripts.PIECE_MANAGER.is_empty(step) and step != target_pos:
			pieces_between.append(step)
			print("GET_TILES_BETWEEN_POINTS- Piece Found at",step)
	
	Scripts.PIECE_CHECK.king_potential_between_coords_pieces_between[starting_pos] = pieces_between
	print("Piece between potential check",Scripts.PIECE_CHECK.king_potential_between_coords_pieces_between)
	#print("GET_TILES_BETWEEN_POINTS- Amount of Pieces Between King and Checking Piece: %s"
	#%piece_amount)
	
	return _steps

## private methods

func _create_tilemap_layers(tile_set:TileSet = preload("res://assets/images/board/tile_set.tres")) -> void:
	tilemap_selection = TileMapLayer.new()
	tilemap_board = TileMapLayer.new()
	
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
	
	print_rich("[color=Turquoise]CREATE_TILESET_LAYERS-[/color] Tileset ID Count: [color=gold]%s[/color]"%tile_set.get_source_count())

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
		Scripts.DATABASE.TILE_BLACK += 1
		Scripts.DATABASE.TILE_DICTIONARY.get_or_add(coords,{
		"color": Scripts.CONSTANTS.COLOR_LIST.BLACK,
		})
		
		colour_of_tile = "Black"
	
	if same_or_diffrent == 2: # values diffrent = white tile
		Scripts.DATABASE.TILE_WHITE += 1
		Scripts.DATABASE.TILE_DICTIONARY.get_or_add(coords,{
		"color": Scripts.CONSTANTS.COLOR_LIST.WHITE,
		})
		
		colour_of_tile = "White"
		
	Scripts.DATABASE.TOTAL_TILES = Scripts.DATABASE.TILE_BLACK + Scripts.DATABASE.TILE_WHITE # Total Ints (Should be 64 for Chess board)
	#print(colour_of_tile," Tile Found at: ",coords," ; Now there is ",Scripts.DATABASE.TOTAL_TILES,"/64 Total Tiles!")
	return

static func _create_board_cells(coords:Vector2i) -> void: # Create Board Cells Based on the Colour Value
	var atlas_coords:Vector2i = Vector2i(Scripts.DATABASE.TILE_DICTIONARY[coords]["color"],0) # Blank: 0,0 ; White: 1,0 ; Black: 2,0 ; Selection_Sprite: 3,0 ;
	var atlas_selection_coords:Vector2i = Vector2i(0,0) # Blank: 0,0 ; Selection: 1,0 ;
	tilemap_board.set_cell(coords,0,atlas_coords,0)
	tilemap_selection.set_cell(coords,1,atlas_selection_coords,0)

func _center_tilemap() -> void: # Rotates and Centers ALL Tilemaps
	rotation_degrees = -90
	global_position.x = ((x_range * 128.0) / 2.0 ) *-1
	global_position.y = ((y_range * 128.0) / 2.0 ) *1
	print_rich("[color=Turquoise]CENTER_TILEMAP-[/color] Tile Map Centered to: [color=gold]%s[/color]"%position)
