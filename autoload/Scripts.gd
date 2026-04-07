extends Node
## enums
## consts
const BOARD_MANAGER:= preload("res://chess_objects/board/main.gd")
const BOARD_DATABASE:= preload("res://chess_objects/board/database.gd")
const BOARD_CONSTS:= preload("res://chess_objects/board/constants.gd")
const BOARD_LIST:= preload("res://chess_objects/board/constants.gd").BOARD_LIST

const CHESS_PLAYER:= preload("res://chess_systems/chess_player/main.gd")
const CHESS_CAMERA2D:= preload("res://chess_systems/chess_camera/main.gd")

const PIECE_MANAGER:= preload("res://chess_scripts/piece_manager/main.gd")
const PIECE_DATABASE:= preload("res://chess_scripts/piece_manager/database.gd")
const PIECE_MOVEMENT_CALC = preload("res://chess_scripts/piece_manager/piece_move.gd")
const PIECE_CONSTS:= preload("res://chess_scripts/piece_manager/constants.gd")
const PIECE_LIST:= preload("res://chess_scripts/piece_manager/constants.gd").TYPE_LIST

## exports
## public vars
static var color_turn:int = Scripts.PIECE_CONSTS.PIECE_COLOR.WHITE
static var turn_amount:int = 0
## private vars
## onready vars
# obj_ for node refrences
## built-in override methods
func _ready() -> void:
	pass
## public methods
## private methods
