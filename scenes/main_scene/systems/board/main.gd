extends Node2D
## enums
## consts
## exports
## public vars
static var board: Board
static var piece_manager: PieceManager
static var grid_info: Array = []
## private vars
## onready vars
# obj_ for node refrences
## built-in override methods

func _ready() -> void:
	board = Board.new()
	add_child(board)
	piece_manager = PieceManager.new()
	add_child(piece_manager)
	
	
	pass 

func _process(_delta: float) -> void:
	pass

## public methods

## private methods
