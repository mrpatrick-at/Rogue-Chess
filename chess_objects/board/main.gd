extends Node2D
## enums
## consts
## exports
## public vars
var built:bool = false
## private vars
## onready vars
@onready var tilemap_board:TileMapLayer = $TileMapLayer_Selection/TileMapLayer_Board
@onready var tilemap_selection:TileMapLayer = $TileMapLayer_Selection
# obj_ for node refrences
## built-in override methods

func _ready() -> void:
	build_board(9,9)
	pass

func _physics_process(delta:float) -> void:
	if InputEventMouse:
		request_tile_below_mouse()
		select_tile()
	pass

## public methods

func build_board(x_range:int,y_range:int) -> void: # Remember y_range needs to be +1 bc it stops 1 before
	for x in range(1,x_range):
		for y in range(1,y_range):
			var coords:Vector2i = Vector2i(x,y)
			if !Scripts.BOARD_DATABASE.TILE_DICTIONARY.has(coords):
				_calculate_tile_color(coords)
				var source_id:int = 0 # Value Controls Layer of which board is rendered at. Can be used to overlay multiple Layers
				_create_board_cells(source_id,coords)
	print("Created Board of size: ",tilemap_board.get_used_rect(),"!") # TODO: Make it Error if Board size does not equal expected size
	_center_tilemap(x_range,y_range)

func request_tile_below_mouse() -> void: # Translates Mouse coords into Board coords
	var local_mouse_coords:Vector2 = tilemap_board.get_local_mouse_position()
	var tilemap_coords:Vector2i
	
	if tilemap_board == null: # Error if tilemap_board cant be found
		print("Tilemap is null")
	
	tilemap_coords = tilemap_board.local_to_map(local_mouse_coords)
	Scripts.MOUSE_CORDS = tilemap_coords
	#print("Local mouse coords: ",local_mouse_coords," ; "," Tilemap coords: ",Scripts.MOUSE_CORDS)
	return

func select_tile() -> void:
	if Input.is_action_just_released(&"_input_mouse_left"):
		var mouse_coords:Vector2i = Scripts.MOUSE_CORDS
		var source_id:int = 0
		var atlas_blank_coords:Vector2i = Vector2i(0,0)
		var atlas_selection_coords:Vector2i = Vector2i(1,0)
		var mouse_last_coords:Vector2i
		tilemap_selection.set_cell(mouse_last_coords,source_id,atlas_blank_coords,source_id)
		tilemap_selection.set_cell(mouse_coords,source_id,atlas_selection_coords,source_id)
		var local_mouse_coords:Vector2 = tilemap_selection.get_local_mouse_position()
		var tilemap_coords:Vector2i
		
		if tilemap_board == null: # Error if tilemap_board cant be found
			print("Tilemap is null")
		
		tilemap_coords = tilemap_board.local_to_map(local_mouse_coords)
		Scripts.MOUSE_CORDS = tilemap_coords
		print("Local mouse coords: ",local_mouse_coords," ; "," Tilemap coords: ",Scripts.MOUSE_CORDS)
		
		print("Left Mouse click detected")

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
		Scripts.BOARD_DATABASE.TILE_DICTIONARY.get_or_add(coords,{"colour":2,"test":"gay"})
		colour_of_tile = "White"
	
	if same_or_diffrent == 2: # values diffrent = white tile
		Scripts.BOARD_DATABASE.TILE_WHITE += 1
		Scripts.BOARD_DATABASE.TILE_DICTIONARY.get_or_add(coords,{"colour":1,"test":"gay"})
		colour_of_tile = "Black"
		
	Scripts.BOARD_DATABASE.TOTAL_TILES = Scripts.BOARD_DATABASE.TILE_BLACK + Scripts.BOARD_DATABASE.TILE_WHITE # Total Ints (Should be 64 for Chess board)
	print(colour_of_tile," Tile Found at: ",coords," ; Now there is ",Scripts.BOARD_DATABASE.TOTAL_TILES,"/64 Total Tiles!")
	return

func _create_board_cells(source_id:int,coords:Vector2i) -> void:
	var atlas_coords:Vector2i = Vector2i(Scripts.BOARD_DATABASE.TILE_DICTIONARY[coords]["colour"],0) # Blank: 0,0 ; White: 1,0 ; Black: 2,0 ; Selection_Sprite: 3,0 ;
	var atlas_selection_coords:Vector2i = Vector2i(0,0) # Blank: 0,0 ; Selection: 1,0 ;
	tilemap_board.set_cell(coords,source_id,atlas_coords,source_id)
	tilemap_selection.set_cell(coords,source_id,atlas_selection_coords,source_id)

func _center_tilemap(x_range:int,y_range:int) -> void:
	rotation_degrees = -90
	#position.x = ((x_range * 128.0) / 2.0 ) * 1.0
	#position.y = ((y_range * 128.0) / 2.0 ) * 1.0
	print("Tile Map Centered to: ",position.x," , ",position.y,"!")
