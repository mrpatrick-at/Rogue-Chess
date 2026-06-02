extends Node
## enums
## consts
## exports
## public vars
## private vars
## onready vars
#@onready var esc_menu: Control = $ChessWorld2D/ChessCamera/Foreground/EscMenu
#@onready var lose_menu: Control = $ChessWorld2D/ChessCamera/Foreground/LoseMenu
#@onready var foreground: CanvasLayer = $ChessWorld2D/ChessCamera/Foreground
#@onready var background: CanvasLayer = $ChessWorld2D/ChessCamera/Background
# obj_ for node refrences
## built-in override methods

#func _ready() -> void:
	#pass
#
#func _process(_delta: float) -> void:
	#update_menu_status()
	#
	#if Scripts.DATABASE.is_lost:
		#if Scripts.DATABASE.menu_is_open == true:
			#toggle_esc_menu()
			#update_menu_status()
		#
		#open_lose_menu()
	#
	#else:
		#if Input.is_action_just_pressed(&"_input_esc"):
			#toggle_esc_menu()

## public methods
#
#func open_lose_menu() -> void:
	#lose_menu.show()
	#Scripts.DATABASE.menu_is_open = true

#static func clear_data() -> void:
	#Scripts.DATABASE.color_turn = Scripts.CONSTANTS.PIECE_COLOR.WHITE
	#Scripts.DATABASE.turn_amount = 0
	#Scripts.DATABASE.fifty_move_rule = 0
	#Scripts.DATABASE.is_lost = false
	#Scripts.DATABASE.menu_is_open = false
	#
	#Scripts.DATABASE.TILE_DICTIONARY.clear()
	#Scripts.DATABASE.TILE_BLACK = 0
	#Scripts.DATABASE.TILE_WHITE = 0
	#Scripts.DATABASE.TOTAL_TILES = 0
	#Scripts.DATABASE.BUILT = false
	#
	#Scripts.DATABASE.PIECE_DICTIONARY.clear()
	#
	#Scripts.PIECE_MOVE.king_pos = Scripts.PIECE_MOVE.white_king_pos
	#
	#Scripts.SELECTION_MANAGER.selected_tile = false
	#
	#Scripts.PIECE_ANIMATE.moved.clear()
#
#func update_menu_status() -> void:
	#if esc_menu.is_visible_in_tree():
		#Scripts.DATABASE.menu_is_open = true
	#else:
		#Scripts.DATABASE.menu_is_open = false
#
#func toggle_esc_menu() -> void:
	#if Scripts.DATABASE.menu_is_open == true:
		#esc_menu.hide()
	#else:
		#esc_menu.show()

## private methods
