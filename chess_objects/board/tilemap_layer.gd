extends TileMapLayer
## enums
## consts
## exports
## public vars
static var tile_black:int = 0
static var tile_white:int = 0
static var total_tiles:int = 0
static var tile_dict:Dictionary = {}
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
	#for i in range(3):
	var source_id:int = 0
	for x in range(1,9):
		for y in range(1,9):
			calculate_tile_color(x,y)
			var atlas_coords:Vector2i = Vector2i(tile_dict.get(Vector2i(x,y)),0) # White: 0,0 ; Black: 1,0 ; Selection_Sprite: 2,0 ;
			var coords:Vector2i = Vector2i(x,y) # Black bottom left is 1,1
			set_cell(coords,source_id,atlas_coords,source_id)
			#print("gay",x,y)

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
		tile_black += 1
		tile_dict.get_or_add(Vector2i(x,y),0) # TODO: Make a seperate Dictionary Script
		print("Black Tile Found: ",x,",",y," Now there is ",tile_black,"/32 black tiles!")
	
	if int_x == 2 and int_y == 1 or int_x == 1 and int_y == 2: # values diffrent = white tile
		tile_white += 1
		tile_dict.get_or_add(Vector2i(x,y),1) # TODO: Make a seperate Dictionary Script
		print("White Tile Found: ",x,",",y," Now there is ",tile_white,"/32 white tiles!")
		
	total_tiles = tile_black + tile_white # Total Ints (Should be 64 for Chess board)
	print("Total Tiles: ",total_tiles,"/64 !")
	return Vector2i(x,y)

#static func check_array_for_data_and_appaned(value:Variant) -> bool:
	
	
	
	
	
	
	
	#if not integers.has(value):
		#integers.append(value)
		#return false
	#return true
## private methods
