extends RefCounted
## Scripts Data
static var color_turn:int = Scripts.CONSTANTS.PIECE_COLOR.WHITE # Whose Turn it is
static var turn_amount:int = 0 # How many Turns have been Made
static var fifty_move_rule:int = 0 # How many moves have been Made towards a Draw

## Board Data
static var TILE_DICTIONARY:Dictionary = {} # Dictionary for holding coords data

static var TILE_BLACK:int = 0 # Black Tile Amount
static var TILE_WHITE:int = 0 # White Tile Amount
static var TOTAL_TILES:int = 0 # Total Tile Amount

static var BUILT:bool = false # If Board is already built

## Piece Data
static var PIECE_DICTIONARY:Dictionary = {} # Dictionary for holding piece data

## public methods

static func get_piece_object(coords:Vector2i) -> Variant:
	var piece_object:int = Scripts.DATABASE.TILE_DICTIONARY[coords]["piece"]
	return piece_object

static func get_piece_data(coords:Vector2i,data:int) -> Variant: # 1. coords 2. value to get
	var piece_object:int = get_piece_object(coords)
	var value:Variant = Scripts.DATABASE.PIECE_DICTIONARY[piece_object][data]
	return value

static func set_piece_data(coords:Vector2i,data:int,value:int) -> void: # 1. coords 2. value to set 3. what to set it to
	var piece_object:int = get_piece_object(coords)
	Scripts.DATABASE.PIECE_DICTIONARY[piece_object][data] = value

## private methods
