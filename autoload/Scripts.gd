extends Node
## enums
## consts
const BOARD_MANAGER:= preload("res://chess_objects/board/main.gd")
const BOARD_DATABASE:= preload("res://chess_objects/board/database.gd")

const CHESS_PLAYER:= preload("res://chess_systems/chess_player/main.gd")
const CHESS_CAMERA2D:= preload("res://chess_systems/chess_camera/main.gd")

const PIECE_MANAGER:= preload("res://chess_objects/pieces/piece_manager/main.gd")
const PIECE_DATABASE:= preload("res://chess_objects/pieces/piece_manager/database.gd")

const PIECE_LIST:= preload("res://chess_objects/pieces/piece_manager/constants.gd").PIECE_LIST
const PIECE_PAWN:= preload("res://chess_objects/pieces/pawn/main.gd")

## exports
## public vars
## private vars
## onready vars
# obj_ for node refrences
## built-in override methods
func _ready() -> void:
	pass
## public methods
## private methods
