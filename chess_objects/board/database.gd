extends RefCounted
## enums
## consts
## exports
## public vars
static var TILE_DICTIONARY:Dictionary = {} # Dictionary for holding coords data
static var TILE_BLACK:int = 0 # Black Tile Amount
static var TILE_WHITE:int = 0 # White Tile Amount
static var TOTAL_TILES:int = 0 # Total Tile Amount
static var BUILT:bool = false # If Board is already built
static var highlighted_tile:Vector2i = Vector2i.ZERO
static var selected_tile_from:Vector2i = Vector2i.ZERO
static var selected_tile_to:Vector2i = Vector2i.ZERO
## private vars
## onready vars
# obj_ for node refrences
## built-in override methods
## public methods
## private methods
