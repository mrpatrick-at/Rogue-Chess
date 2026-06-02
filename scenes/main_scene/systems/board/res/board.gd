@tool
extends Node2D
class_name Board
## enums
## consts
const tile_size:int = 128
const board_size:int = 8

## exports
## public vars
var tiles:int = 0
var pieces:int = 0
## private vars
## onready vars

# obj_ for node refrences
## built-in override methods

func _ready() -> void: # Runs on Startup
	build_board()

func _physics_process(_delta:float) -> void: # Runs Every Tick
	pass
## public methods

func build_board() -> void: # Remember y_range needs to be +1 bc it stops 1 before
	var time_before:float = Time.get_ticks_usec()
	print_rich("[color=Springgreen]BUILD_BOARD-[/color] Started Building Board at: [color=gold]%sms[/color]"
	%[time_before/1000])
	_create_tiles()
	#for x in board_size:
		#for y in board_size:
			#var coords:Vector2i = Vector2i(x,y)
			#if coords not in Scripts.DATABASE.TILE_DICTIONARY:
				#_create_board_cells(coords)
	#_center_tilemap()
	
	#print_rich("[color=Springgreen]BUILD_BOARD-[/color] Created Board of size: [color=gold]%s[/color] in: [color=gold]%sms[/color]"
	#%[tilemap_board.get_used_rect(), Scripts.DEBUG_MANAGER.end_timer(time_before)])

#static func is_valid_position(_asked_coords:Vector2i) -> bool:
	#if _asked_coords.x >= 1 and _asked_coords.x < 9 and _asked_coords.y >= 1 and _asked_coords.y < 9:
		#return true
	#return false
#
#static func get_tile_from_mouse() -> Vector2i: # Translates Mouse coords into Board coords
	#var tilemap_selection_local_mouse_coords:Vector2 = tilemap_selection.get_local_mouse_position()
	#var tilemap_selection_coords:Vector2i
	#
	#if tilemap_board == null: # Error if tilemap_board cant be found
		#print("Tilemap is null")
	#
	#tilemap_selection_coords = tilemap_board.local_to_map(tilemap_selection_local_mouse_coords)
	#
	##print("Updated highlighted Tile: ",tilemap_selection_local_mouse_coords," ; Tilemap Coords: ",tilemap_selection_coords,"!")
	#return tilemap_selection_coords
#
#static func get_mouse_from_tile(coords:Vector2i) -> Vector2: # Translates Coords from map to global
	#var translated_coords:Vector2 = tilemap_board.to_global(tilemap_board.map_to_local(coords))
	#return translated_coords

static func get_tiles_between_points(starting_pos:Vector2i,target_pos:Vector2i) -> Array: # Returns starting_pos + Array of all Positions between the two Points
	var value_x:int
	var value_y:int
	
	if starting_pos.x < target_pos.x:
		value_x = 1
	elif starting_pos.x == target_pos.x:
		value_x = 0
	else:
		value_x = -1
		
	if starting_pos.y < target_pos.y:
		value_y = 1
	elif starting_pos.y == target_pos.y:
		value_y = 0
	else:
		value_y = -1
	
	#print("GET_TILES_BETWEEN_POINTS- step values: ",Vector2i(value_x,value_y))
	var step:Vector2i = Vector2i(starting_pos)
	var _steps:Array = []
	var pieces_between:Array = []
	
	while step != target_pos:
		_steps.append(step)
		
		if step.x != target_pos.x:
			step.x += value_x
		if step.y != target_pos.y:
			step.y += value_y
		
		if !Scripts.PIECE_MANAGER.is_empty(step) and step != target_pos:
			pieces_between.append(step)
			print("GET_TILES_BETWEEN_POINTS- Piece Found at",step)
	
	#print("GET_TILES_BETWEEN_POINTS- Amount of Pieces Between King and Checking Piece: %s"
	#%piece_amount)
	
	return [_steps,pieces_between] # [0] = between tiles; [1] = between pieces

## private methods

func _create_tiles(tile_set:TileSet = preload("res://assets/images/board/tile_set.tres")) -> void:
	for x in board_size:
		for y in board_size:
			var is_tile_black:bool = _get_tile_color(x, y)
			var tile: Tile = Tile.new()
			add_child(tile)
			tile.setup(Vector2i(x,y), tile_size, is_tile_black)
			
	
	print_rich("[color=Turquoise]CREATE_TILESET_LAYERS-[/color] Tileset ID Count: [color=gold]%s[/color]"%tile_set.get_source_count())

func _get_tile_color(x: int, y: int) -> bool: # Returns false if White and True if Black
	var is_x_even: bool = false
	var is_y_even: bool = false
	var is_tile_black: bool = false
	
	if x & 1 == 0:
		is_x_even = true
	
	if y & 1 == 0:
		is_y_even = true
	
	if is_x_even == is_y_even: # tile is black
		is_tile_black = true
	return is_tile_black

#static func _create_board_cells(coords:Vector2i) -> void: # Create Board Cells Based on the Colour Value
	#var atlas_coords:Vector2i = Vector2i(Scripts.DATABASE.TILE_DICTIONARY[coords]["color"],0) # Blank: 0,0 ; White: 1,0 ; Black: 2,0 ; Selection_Sprite: 3,0 ;
	#var atlas_selection_coords:Vector2i = Vector2i(0,0) # Blank: 0,0 ; Selection: 1,0 ;
	#tilemap_board.set_cell(coords,0,atlas_coords,0)
	#tilemap_selection.set_cell(coords,1,atlas_selection_coords,0)
#
#func _center_tilemap() -> void: # Rotates and Centers ALL Tilemaps
	#rotation_degrees = -90
	#global_position.x = ((x_range * 128.0) / 2.0 ) *-1
	#global_position.y = ((y_range * 128.0) / 2.0 ) *1
	#print_rich("[color=Turquoise]CENTER_TILEMAP-[/color] Tile Map Centered to: [color=gold]%s[/color]"%position)
