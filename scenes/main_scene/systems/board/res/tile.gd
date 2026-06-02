extends MeshInstance2D
class_name Tile
## enums
## consts
## exports
## public vars
var coord: Vector2i = Vector2i.ZERO
var size: int = 0
var color:Color = Color(1.0, 1.0, 1.0, 1.0)
var pos: Vector2i = Vector2i.ZERO
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
	coord = tile_coord
	self.name = "Tile, %s"%[coord]
	
	size = tile_size
	if is_tile_black:
		color = Color(0.0, 0.0, 0.0, 1.0)
	
	pos.x = coord.x * size
	pos.y = -coord.y * size
	position = pos
	
	_generate_mesh()

## private methods
func _generate_mesh() -> void:
	var vertices: PackedVector2Array = [
			Vector2i(0 ,0),
			Vector2i(size ,0),
			Vector2i(size ,size),
			Vector2i(0 ,size),
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
