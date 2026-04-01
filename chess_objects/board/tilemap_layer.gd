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
	build_board(9,9)
	pass 

func _process(_delta: float) -> void:
	pass

## public methods

func build_board(x_range:int,y_range:int) -> void: # Remember y_range needs to be +1 bc it stops 1 before
	for x in range(1,x_range):
		for y in range(1,y_range):
			if !Scripts.BOARD_DATABASE.TILE_DICTIONARY.has(Vector2i(x,y)):
				var coords:Vector2i = Vector2i(x,y)
				calculate_tile_color(coords)
				var source_id:int = 0 # Black bottom left is 1,1
				var atlas_coords:Vector2i = Vector2i(Scripts.BOARD_DATABASE.TILE_DICTIONARY.get(coords),0) # Blank: 0,0 ; White: 1,0 ; Black: 2,0 ; Selection_Sprite: 3,0 ;
				set_cell(coords,source_id,atlas_coords,source_id)

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
		Scripts.BOARD_DATABASE.TILE_DICTIONARY.get_or_add(coords,1)
		# TODO: Make the Data storage into a dictionary inside a dictionary to hold more than 1 value
		#Scripts.BOARD_DATABASE.TILE_DICTIONARY.get_or_add(Vector2i(x,y){tile_colour: 1,gay_colour: 2,})
		colour_of_tile = "White"
	
	if same_or_diffrent == 2: # values diffrent = white tile
		Scripts.BOARD_DATABASE.TILE_WHITE += 1
		Scripts.BOARD_DATABASE.TILE_DICTIONARY.get_or_add(coords,2)
		colour_of_tile = "Black"
	
	Scripts.BOARD_DATABASE.TOTAL_TILES = Scripts.BOARD_DATABASE.TILE_BLACK + Scripts.BOARD_DATABASE.TILE_WHITE # Total Ints (Should be 64 for Chess board)
	print(colour_of_tile," Tile Found at: ",coords," ; Now there is ",Scripts.BOARD_DATABASE.TOTAL_TILES,"/64 tiles!")
	return

func create_board_cells(coords:Vector2i,source_id:int,atlas_coords:Vector2i) -> void:
	set_cell(coords,source_id,atlas_coords,source_id)

## private methods
