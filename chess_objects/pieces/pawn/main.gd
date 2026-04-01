extends Node2D
## enums
## consts
## exports
## public vars
## private vars
## onready vars
# obj_ for node refrences
## built-in override methods

func _ready() -> void:
	pass 

func _process(_delta: float) -> void:
	pass

## public methods

static func call_movement(current_coords:Vector2i,asked_coords:Vector2i) -> void:
	#Scripts.PIECE_MANAGER.build_pieces()
	var current_x = current_coords.x
	var current_y = current_coords.y
	var asked_x = asked_coords.x
	var asked_y = asked_coords.y
	var possible_move:bool = false
	
	# Mathematical Behaviour for Pawn
	if asked_x == current_x + 2 and (asked_y == current_y +1 or asked_y == current_y -1):
		possible_move = true
	
	if possible_move:
		print("Pawn, Current Coords: ",current_coords,", Asked, Coords: ",asked_coords,", Is Move Possible?: ",possible_move)

## private methods
