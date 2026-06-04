extends Control
## enums
## consts
## exports
## public vars
static var board: Board
static var grid_info: Array = []
## private vars
## onready vars
# obj_ for node refrences
## built-in override methods

func _ready() -> void:
	board = Board.new()
	add_child(board)
	
	
	pass 

func _process(_delta: float) -> void:
	pass

## public methods

## private methods
