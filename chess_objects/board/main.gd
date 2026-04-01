extends Node2D
## enums
## consts
## exports
## public vars
## private vars
## onready vars
@onready var tilemap_layer: TileMapLayer = $TileMapLayer
# obj_ for node refrences
## built-in override methods

func _ready() -> void:
	build_board(9,9)
	pass
func _process(_delta: float) -> void:
	pass

## public methods

func build_board(x_range:int,y_range:int) -> void: # Remember y_range needs to be +1 bc it stops 1 before
	for x in range(1,x_range):
		for y in range(1,y_range):
			var coords:Vector2i = Vector2i(x,y)
			if !Scripts.BOARD_DATABASE.TILE_DICTIONARY.has(coords):
				calculate_tile_color(coords)
				var source_id:int = 0 # Value Controls Layer of which board is rendered at. Can be used to overlay multiple Layers
				create_board_cells(source_id,coords)
	center_tilemap(x_range,y_range)

static func calculate_tile_color(coords:Vector2i) -> void:
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
		Scripts.BOARD_DATABASE.TILE_DICTIONARY.get_or_add(coords,{"colour":1,"test":"gay"})
		colour_of_tile = "White"
	
	if same_or_diffrent == 2: # values diffrent = white tile
		Scripts.BOARD_DATABASE.TILE_WHITE += 1
		Scripts.BOARD_DATABASE.TILE_DICTIONARY.get_or_add(coords,{"colour":2,"test":"gay"})
		colour_of_tile = "Black"
		
	Scripts.BOARD_DATABASE.TOTAL_TILES = Scripts.BOARD_DATABASE.TILE_BLACK + Scripts.BOARD_DATABASE.TILE_WHITE # Total Ints (Should be 64 for Chess board)
	print(colour_of_tile," Tile Found at: ",coords," ; Now there is ",Scripts.BOARD_DATABASE.TOTAL_TILES,"/64 Total Tiles!")
	return

func create_board_cells(source_id:int,coords:Vector2i) -> void:
	var atlas_coords:Vector2i = Vector2i(Scripts.BOARD_DATABASE.TILE_DICTIONARY[coords]["colour"],0) # Blank: 0,0 ; White: 1,0 ; Black: 2,0 ; Selection_Sprite: 3,0 ;
	tilemap_layer.set_cell(coords,source_id,atlas_coords,source_id)

func center_tilemap(x_range:int,y_range:int) -> void:
	position.x = ((x_range * 128.0) / 2.0 ) * -1.0
	position.y = ((y_range * 128.0) / 2.0 ) * -1.0
	print("Tile Map Centered to: ",position.x," , ",position.y,"!")
## private methods
	

## private methods
