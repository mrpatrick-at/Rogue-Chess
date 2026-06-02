extends MeshInstance2D
class_name Tile
## enums
## consts
const shader_res: Shader = preload("res://scenes/main_scene/systems/board/shaders/tile_highlight.gdshader")
## exports
## public vars
var coord: Vector2i = Vector2i.ZERO
var size: int = 0
var color: Color = Color(1.0, 1.0, 1.0, 1.0)
var highlight_color: Color = Color(0.0, 0.0, 1.0, 0.392)
var pos: Vector2i = Vector2i.ZERO
## private vars
## onready vars
## built-in override methods

func _init(tile_coord:Vector2i, tile_size:int, is_tile_black: bool) -> void:
	var starting_time: float = Time.get_ticks_usec()
	print_rich("[color=Orange]BUILD_BOARD-[/color] Started Building Tile %s"%tile_coord)
	coord = tile_coord
	self.name = "Tile, %s"%[coord]
	
	size = tile_size
	
	pos.x = coord.x * size
	pos.y = -coord.y * size
	position = pos
	
	self.material = ShaderMaterial.new()
	self.material.shader = shader_res
	if is_tile_black:
		color = Color(0.0, 0.0, 0.0, 1.0)
	
	self.material.set_shader_parameter("tile_color", color)
	_generate_mesh()
	
	var ending_time:float = (Time.get_ticks_usec() - starting_time) / 1000
	print_rich("[color=Orange]BUILD_BOARD-[/color] Created Tile in: [color=gold]%sms[/color]"%ending_time)

## public methods
func hightlight() -> void:
	self.material.set_shader_parameter("highlight_color", highlight_color)

func unhighlight() -> void:
	self.material.set_shader_parameter("highlight_color", Color(0.0, 0.0, 0.0, 0.0))

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
	
	var mesh_array:Array = []
	mesh_array.resize(Mesh.ARRAY_MAX)
	mesh_array[Mesh.ARRAY_VERTEX] = vertices
	mesh_array[Mesh.ARRAY_INDEX] = tile_indices
	#mesh_array[Mesh.ARRAY_TEX_UV] = uvs
	
	var tile_mesh: ArrayMesh = ArrayMesh.new()
	tile_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, mesh_array)
	self.mesh = tile_mesh
