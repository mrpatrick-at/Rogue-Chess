extends Node
## enums
## consts
const MAIN:= preload("res://chess_scenes/main_scene/main.gd")

const BOARD_MANAGER:= preload("res://chess_systems/board_manager/main.gd")
const SELECTION_MANAGER:= preload("res://chess_systems/selection_manager/selection_manager.gd")

const CHESS_PLAYER:= preload("res://chess_systems/chess_player/main.gd")
const CHESS_CAMERA2D:= preload("res://chess_systems/chess_camera/main.gd")

const PIECE_MANAGER:= preload("res://chess_systems/piece_manager/piece_manager.gd")
const PIECE_MOVE = preload("res://chess_systems/piece_manager/piece_move.gd")
const PIECE_CHECK = preload("res://chess_systems/piece_manager/piece_check.gd")
const PIECE_ANIMATE = preload("res://chess_systems/piece_manager/piece_animate.gd")

const DATABASE:= preload("res://chess_systems/database/database.gd")
const CONSTANTS:= preload("res://chess_systems/database/constants.gd")

const DEBUG_MANAGER:= preload("res://chess_systems/debug/debug_manager.gd")
## exports
## public vars
## private vars
## onready vars
# obj_ for node refrences
## built-in override methods
## public methods
## private methods
