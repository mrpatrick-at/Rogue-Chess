extends Node
## enums
## consts
## exports
## public vars
static var menu_is_open:bool = false
static var esc_menu_is_open:bool = false
static var lose_menu_is_open:bool = false
## private vars
## onready vars
@onready var esc_menu: Control = $ChessWorld2D/ChessCamera/Foreground/EscMenu
@onready var lose_menu: Control = $ChessWorld2D/ChessCamera/Foreground/LoseMenu
@onready var foreground: CanvasLayer = $ChessWorld2D/ChessCamera/Foreground
@onready var background: CanvasLayer = $ChessWorld2D/ChessCamera/Background
# obj_ for node refrences
## built-in override methods

func _ready() -> void:
	pass 

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed(&"_input_esc"):
		toggle_esc_menu()
	if Scripts.DATABASE.IN_CHECKMATE:
		get_tree().change_scene_to_file("res://chess_scenes/main_menu/main.tscn")
	

## public methods

func is_a_menu_open() -> void:
	menu_is_open = false
	if esc_menu_is_open or lose_menu_is_open:
		menu_is_open = true
		

static func clear_data() -> void:
	Scripts.DATABASE.color_turn = Scripts.CONSTANTS.PIECE_COLOR.WHITE
	Scripts.DATABASE.turn_amount = 0
	Scripts.DATABASE.fifty_move_rule = 0
	
	Scripts.DATABASE.TILE_DICTIONARY.clear()
	Scripts.DATABASE.TILE_BLACK = 0
	Scripts.DATABASE.TILE_WHITE = 0
	Scripts.DATABASE.TOTAL_TILES = 0
	Scripts.DATABASE.BUILT = false
	
	Scripts.DATABASE.PIECE_DICTIONARY.clear()
	
	Scripts.PIECE_MOVE.got_all_moves = false
	
	Scripts.SELECTION_MANAGER.selected_tile = false
	
	Scripts.PIECE_ANIMATE.moved.clear()

func toggle_esc_menu() -> void:
	if esc_menu.is_visible_in_tree():
		esc_menu.hide()
		esc_menu_is_open = false
	else:
		esc_menu.show()
		esc_menu_is_open = true
	is_a_menu_open()

## private methods
