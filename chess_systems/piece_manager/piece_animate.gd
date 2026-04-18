extends RefCounted
## enums
## consts
const hightlight_speed_up:float = 0.05
const hightlight_speed_down:float = 0.03
const highlight_height:int = 32
## exports
## public vars
static var moved:Dictionary = {} # Keeps Track of Pieces In Hightlight Animation
static var highlighted_piece:Node2D
## private vars
## onready vars
# obj_ for node refrences
## built-in override methods
## public methods

static func reset_animation() -> void: # Continously Called. Resets Piece Positon
	if !moved.is_empty():
		for last_piece_object:Node2D in moved:
			if last_piece_object != highlighted_piece:
				var array:Array = moved[last_piece_object]
				var old_tween:RefCounted = array.get(0)
				var old_pos:Vector2 = array.get(1)
				old_tween.kill()
				var tween:RefCounted = last_piece_object.create_tween()
				tween.tween_property(last_piece_object,"position",old_pos, hightlight_speed_down)
				moved.erase(last_piece_object)

static func hightlight_piece(coords:Vector2i) -> void: # Slightly moves a Piece Vertical In an Animation
	highlighted_piece = Scripts.PIECE_MANAGER.get_piece_data(coords,Scripts.CONSTANTS.PIECE_LIST.PIECE_OBJ)
	var translated_coords:Vector2 = Scripts.BOARD_MANAGER.get_mouse_from_tile(coords)
	
	if (Scripts.BOARD_MANAGER.is_valid_position(coords) and 
	Scripts.DATABASE.color_turn == Scripts.PIECE_MANAGER.get_piece_data(coords,Scripts.CONSTANTS.PIECE_LIST.PIECE_COLOR) and 
	highlighted_piece.position.y == -96 + translated_coords.y):
		var tween:Tween = highlighted_piece.create_tween()
		var old_pos:Vector2 = highlighted_piece.position
		moved[highlighted_piece] = [tween,old_pos]
		tween.tween_property(highlighted_piece,"position",Vector2(highlighted_piece.position.x,highlighted_piece.position.y -highlight_height), hightlight_speed_up)


## private methods
