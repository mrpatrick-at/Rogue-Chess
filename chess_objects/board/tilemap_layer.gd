extends TileMapLayer
## enums
## consts
const Dic = {}
## exports
## public vars
## private vars
## onready vars
# obj_ for node refrences
## built-in override methods

func _ready() -> void:
	build_board()
	pass 

func _process(_delta: float) -> void:
	pass

## public methods

func build_board() -> void:
	for i in range(3):
		var source_id:int = 0
		var atlas_coords:Vector2i = Vector2i(0,0)
		for x in range(1,10):
			for y in range(1,10):
				var coords:Vector2i = Vector2i(x,y)
				set_cell(coords,source_id,atlas_coords,source_id)
				print("gay",x,y)
## private methods
