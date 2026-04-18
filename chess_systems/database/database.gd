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

## Checking Data
static var IN_CHECKMATE:bool = false # WTF DO THESE EVEN DO !?!?!?!?
static var IN_DRAW:bool = false
static var IN_STALEMATE:bool = false

## public methods
## private methods
