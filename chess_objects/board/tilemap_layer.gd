extends TileMapLayer
## enums
## consts
## exports
## public vars
## private vars
## onready vars
# obj_ for node refrences
## built-in override methods

func _ready() -> void:
	build_board()
	pass 

func _process(_delta: float) -> void:
	pass

## public methods

func build_board() -> void:
	var source_id:int = 0
	for x in range(1,9):
		for y in range(1,9):
			calculate_tile_color(x,y)
			var atlas_coords:Vector2i = Vector2i(Scripts.BOARD_DATABASE.TILE_DICTIONARY.get(Vector2i(x,y)),0) # White: 0,0 ; Black: 1,0 ; Selection_Sprite: 2,0 ;
			var coords:Vector2i = Vector2i(x,y) # Black bottom left is 1,1
			set_cell(coords,source_id,atlas_coords,source_id)

static func calculate_tile_color(x:int,y:int) -> void:
	var int_x:int = 0 # Check if x is odd or even
	if (x & 1) == 0:
		int_x += 2
	if (x & 1) == 1:
		int_x += 1
		
	var int_y:int = 0 # Check if y is odd or even
	if (y & 1) == 0:
		int_y += 2
	if (y & 1) == 1:
		int_y += 1
		
	if int_x == 2 and int_y == 2 or int_x == 1 and int_y == 1: # Values same = black tile
		Scripts.BOARD_DATABASE.TILE_BLACK += 1
		Scripts.BOARD_DATABASE.TILE_DICTIONARY.get_or_add(Vector2i(x,y),0)
		print("Black Tile Found: ",x,",",y," Now there is ",Scripts.BOARD_DATABASE.TILE_BLACK,"/32 black tiles!")
	
	if int_x == 2 and int_y == 1 or int_x == 1 and int_y == 2: # values diffrent = white tile
		Scripts.BOARD_DATABASE.TILE_WHITE += 1
		Scripts.BOARD_DATABASE.TILE_DICTIONARY.get_or_add(Vector2i(x,y),1)
		print("White Tile Found: ",x,",",y," Now there is ",Scripts.BOARD_DATABASE.TILE_WHITE,"/32 white tiles!")
		
	Scripts.BOARD_DATABASE.TOTAL_TILES = Scripts.BOARD_DATABASE.TILE_BLACK + Scripts.BOARD_DATABASE.TILE_WHITE # Total Ints (Should be 64 for Chess board)
	print("Total Tiles: ",Scripts.BOARD_DATABASE.TOTAL_TILES,"/64 !")
	return Vector2i(x,y)

func create_board_cells(coords:Vector2i,source_id:int,atlas_coords:Vector2i) -> void:
	set_cell(coords,source_id,atlas_coords,source_id)

## private methods
