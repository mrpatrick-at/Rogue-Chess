extends RefCounted
## enums
## consts
const hightlight_speed_up:float = 0.05
const hightlight_speed_down:float = 0.03
const highlight_height:int = 32
## exports
## public vars
## private vars
static var _moved:Dictionary = {} # Keeps Track of Pieces In Hightlight Animation
static var _highlighted_piece:Node2D
## onready vars
# obj_ for node refrences
## built-in override methods
## public methods

static func reset_animation() -> void:
	if !_moved.is_empty():
		for last_piece_object:Node2D in _moved:
			if last_piece_object != _highlighted_piece:
				var array:Array = _moved[last_piece_object]
				var old_tween:RefCounted = array.get(0)
				var old_pos:Vector2 = array.get(1)
				old_tween.kill()
				var tween:RefCounted = last_piece_object.create_tween()
				tween.tween_property(last_piece_object,"position",old_pos, hightlight_speed_down)
				_moved.erase(last_piece_object)

static func hightlight_piece(coords:Vector2i) -> void: # Continously Called. Slightly moves a Piece Vertical In an Animation
	_highlighted_piece = Scripts.PIECE_MANAGER.get_piece_data(coords,Scripts.CONSTANTS.PIECE_LIST.PIECE_OBJ)
	var translated_coords:Vector2 = Scripts.BOARD_MANAGER.get_mouse_from_tile(coords)
	
	if (Scripts.BOARD_MANAGER.is_valid_position(coords) and 
	Scripts.DATABASE.color_turn == Scripts.PIECE_MANAGER.get_piece_data(coords,Scripts.CONSTANTS.PIECE_LIST.PIECE_COLOR) and 
	_highlighted_piece.position.y == -96 + translated_coords.y):
		var tween:Tween = _highlighted_piece.create_tween()
		var old_pos:Vector2 = _highlighted_piece.position
		_moved[_highlighted_piece] = [tween,old_pos]
		tween.tween_property(_highlighted_piece,"position",Vector2(_highlighted_piece.position.x,_highlighted_piece.position.y -highlight_height), hightlight_speed_up)
	
	reset_animation()

## private methods
