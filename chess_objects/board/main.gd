extends Node2D
## enums
## consts
## exports
## public vars
var tilemap_layer: = load("res://chess_objects/board/tilemap_layer.gd")
## private vars
## onready vars
# obj_ for node refrences
## built-in override methods

func _ready() -> void:
	pass
func _process(_delta: float) -> void:
	pass

## public methods

#func build_board() -> void:
	#var source_id:int = 0
	#for x in range(1,9):
		#for y in range(1,9):
			#Scripts.BOARD_TILEMAP.calculate_tile_color(x,y)
			##Scripts.BOARD_TILEMAP.
			#var atlas_coords:Vector2i = Vector2i(Scripts.BOARD_DATABASE.TILE_DICTIONARY.get(Vector2i(x,y)),0) # White: 0,0 ; Black: 1,0 ; Selection_Sprite: 2,0 ;
			#var coords:Vector2i = Vector2i(x,y) # Black bottom left is 1,1
			#tilemap_layer.in
			#tilemap_instance.create_board_cells(coords,source_id,atlas_coords)

## private methods
