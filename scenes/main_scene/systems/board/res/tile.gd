extends MeshInstance2D
class_name Tile
## enums
## consts
## exports
## public vars
var size: int = 0
var color:Color = Color(1.0, 1.0, 1.0, 1.0)
var coord: Vector2i = Vector2i.ZERO
var pos: Vector2i = Vector2i.ZERO

var vertex_list: PackedVector2Array = []
## private vars
## onready vars
# obj_ for node refrences
## built-in override methods

func _ready() -> void:
	pass 

func _process(_delta: float) -> void:
	pass

## public methods

func setup(tile_coord:Vector2i, tile_size:int, is_tile_black: bool) -> void:
	size = tile_size
	if is_tile_black:
		color = Color(0.0, 0.0, 0.0, 1.0)
		
	coord = tile_coord
	pos.x = coord.x * size
	pos.y = -coord.y * size
	position = pos
	_generate_mesh()

## private methods
func _generate_mesh() -> void:
	var offset:int = size >> 1
	var vertices: PackedVector2Array = [
			Vector2i(-offset ,-offset),
			Vector2i(offset, -offset),
			Vector2i(offset, offset),
			Vector2i(-offset, offset),
	]
	
	var tile_indices: PackedInt32Array = [
		0, 1, 2,
		0, 2, 3,
	]
	
	var colors: PackedColorArray = [
		color,
		color,
		color,
		color 
	]
	
	var mesh_array:Array = []
	mesh_array.resize(Mesh.ARRAY_MAX)
	mesh_array[Mesh.ARRAY_VERTEX] = vertices
	mesh_array[Mesh.ARRAY_INDEX] = tile_indices
	mesh_array[Mesh.ARRAY_COLOR] = colors
	#mesh_array[Mesh.ARRAY_TEX_UV] = uvs
	
	var tile_mesh: ArrayMesh = ArrayMesh.new()
	tile_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, mesh_array)
	self.mesh = tile_mesh
	pass
