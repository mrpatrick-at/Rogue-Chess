extends Node
## enums
## consts
const BOARD:= preload("res://chess_objects/board/main.gd")
const BOARD_DATABASE:= preload("res://chess_objects/board/database.gd")

const CAMERA2D:= preload("res://chess_systems/chess_camera/main.gd")
const RTS_PLAYER:= preload("res://chess_systems/chess_player/main.gd")
## exports
## public vars
static var MOUSE_CORDS:Vector2i = Vector2i(0,0)
## private vars
## onready vars
# obj_ for node refrences
## built-in override methods
func _ready() -> void:
	pass
## public methods
## private methods
