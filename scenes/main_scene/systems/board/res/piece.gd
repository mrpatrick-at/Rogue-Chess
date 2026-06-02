extends Sprite2D
class_name Piece
## enums
## consts
const path: String = "res://assets/images/pieces/%s/%s.png"
## exports
## public vars
var type: int = 0
var color: int = 0
var move_amount: int = 0
## private vars
## onready vars
## built-in override methods

func _init(coord: Vector2i, piece_type: int, piece_color: int, tile_size: int, piece_info: Array) -> void:
	type = piece_type
	color = piece_color
	
	self.name = "%s, %s"%piece_info
	
	var piece_texture: CompressedTexture2D = load(path%piece_info)
	
	self.texture = piece_texture
	var translated_coords:Vector2
	translated_coords.x = coord.x * tile_size
	translated_coords.y = -coord.y * tile_size
	
	self.global_position = translated_coords
	self.scale = Vector2i(8,8)
	self.move_local_x(64)
	self.move_local_y(-32)
	self.z_index = -coord.y + 1

## public methods

func get_moves() -> PackedVector2Array:
	var moves: PackedVector2Array = []
	
	return moves

## private methods
