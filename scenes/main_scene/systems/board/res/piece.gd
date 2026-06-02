extends Sprite2D
class_name Piece
## enums
## consts
const path: String = "res://assets/images/pieces/%s/%s.png"
## exports
## public vars
var piece_type: int = 0
## private vars
## onready vars
## built-in override methods

func _init(coord: Vector2i, piece_int: int, tile_size: int, piece_info: Array) -> void:
	piece_type = piece_int
	
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

## private methods
