extends Node
## enums
enum PIECE {
	NONE,
	W_PAWN,
	W_ROOK,
	W_KNIGHT,
	W_BISHOP,
	W_QUEEN,
	W_KING,
	B_PAWN,
	B_ROOK,
	B_KNIGHT,
	B_BISHOP,
	B_QUEEN,
	B_KING,
}
enum COLOR {
	WHITE,
	BLACK
}
enum HIGHLIGHT {
	NONE,
	HOVER,
	MOVE,
	CAPTURE,
	CHECK
}
## consts
const tile_size:int = 128
## exports
## public vars
## private vars
## onready vars
## built-in override methods

func _ready() -> void:
	pass 

func _process(_delta: float) -> void:
	pass

## public methods

## private methods
