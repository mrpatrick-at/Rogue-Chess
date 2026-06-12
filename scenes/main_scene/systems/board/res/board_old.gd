extends ColorRect
## enums
## consts
const tile_size: int = 128
const board_size: int = 8
const shader_res: Shader = preload("res://scenes/main_scene/systems/board/shaders/board_shader.gdshader")

const W_BACK_ROW = [
	Consts.PIECE.W_ROOK, Consts.PIECE.W_KNIGHT, Consts.PIECE.W_BISHOP, Consts.PIECE.W_QUEEN, 
	Consts.PIECE.W_KING, Consts.PIECE.W_BISHOP, Consts.PIECE.W_KNIGHT, Consts.PIECE.W_ROOK
]
const B_BACK_ROW = [
	Consts.PIECE.B_ROOK, Consts.PIECE.B_KNIGHT, Consts.PIECE.B_BISHOP, Consts.PIECE.B_QUEEN, 
	Consts.PIECE.B_KING, Consts.PIECE.B_BISHOP, Consts.PIECE.B_KNIGHT, Consts.PIECE.B_ROOK
]
## exports
## public vars
var tiles_highlight: PackedByteArray = []
var bitboards: PackedInt64Array = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
var pieces: Dictionary = {}
var turn_amount: int = 0
var turn_color: int = Consts.COLOR.WHITE

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
	var starting_time: float = Time.get_ticks_usec()
	print_rich("[color=Springgreen]BUILD_BOARD-[/color] Started Building Board")
	self.name = "Board"
	
	tiles_highlight.resize(board_size * board_size)
	#tiles.resize(board_size * board_size)
	self.size = Vector2(board_size * tile_size, board_size * tile_size)
	self.material = ShaderMaterial.new()
	self.material.shader = shader_res
	
	var ending_time2:float = (Time.get_ticks_usec() - starting_time) / 1000
	print_rich("[color=Springgreen]BUILD_BOARD-[/color] Created Board Shader in: [color=gold]%sms[/color]" %[ending_time2])
	
	for x in board_size:
		for y in board_size:
			var coord: Vector2i = Vector2i(x, y)
			var piece_int: int = _calc_piece(coord)
			if piece_int != Consts.PIECE.NONE:
				var piece_type: int = piece_int - 1
				var bit_mask: int = (1 << get_tiles_array_index(coord))
				bitboards[piece_type] |= bit_mask
				print("Piece: %016X"%bitboards[piece_type])
	
	print("bitboard: %s"%bitboards)
	var ending_time:float = (Time.get_ticks_usec() - starting_time) / 1000
	print_rich("[color=Springgreen]BUILD_BOARD-[/color] Created Board of size: [color=gold]%s[/color] in: [color=gold]%sms[/color]" %[board_size, ending_time])

func get_coord() -> Vector2i:
	var local_mouse_pos: Vector2i = get_local_mouse_position()
	var coord: Vector2i
	coord.x = local_mouse_pos.x >> 7
	coord.y = 7 - (local_mouse_pos.y >> 7) # Minus here cuz Godot is stupid ass monkey shit and has y axis inverted for some reason
	return coord

func is_valid_coord(coord: Vector2i) -> bool:
	if coord.x >= 0 and coord.x < board_size and coord.y >= 0 and coord.y < board_size:
		return true
	return false

func is_empty(asked_coords: Vector2i) -> bool:
	if pieces.has(asked_coords):
		return false
	return true

func is_enemy(asked_coords: Vector2i, piece_color: int) -> bool:
	if !is_empty(asked_coords):
		var piece: Piece = pieces[asked_coords]
		if piece.color == piece_color:
			return false
	return true

func get_tiles_array_index(tile_coord: Vector2i) -> int:
	var inverted_y: int = 7 - tile_coord.y
	var array_index: int = (inverted_y << 3) + tile_coord.x
	return array_index

func highlight_tile(tile_coord: Vector2i, highlight_type: int) -> void:
	var array_index: int = get_tiles_array_index(tile_coord)
	tiles_highlight[array_index] = highlight_type
	self.material.set_shader_parameter("tile_states", tiles_highlight)

func unhighlight_tile(tile_coord: Vector2i) -> void:
	highlight_tile(tile_coord, Consts.HIGHLIGHT.NONE)

func highlight_tiles(tiles_to_highlight: PackedVector2Array, highlight_type: int) -> void:
	for tile_coord: Vector2i in tiles_to_highlight:
		highlight_tile(tile_coord, highlight_type)

func unhighlight_tiles(tiles_to_unhighlight: PackedVector2Array) -> void:
	for tile_coord: Vector2i in tiles_to_unhighlight:
		unhighlight_tile(tile_coord)

## private methods

func _calc_piece(coords: Vector2i) -> int:
	if coords.y > 1 and coords.y < 6:
		return Consts.PIECE.NONE
	
	# White Pawns
	if coords.y == 1:
		return Consts.PIECE.W_PAWN
	# Black Pawns
	if coords.y == 6:
		return Consts.PIECE.B_PAWN
	
	# White Pieces
	if coords.y == 0:
		return W_BACK_ROW[coords.x]
	# Black Pieces
	if coords.y == 7:
		return B_BACK_ROW[coords.x]
	
	return Consts.PIECE.NONE # Emergency Stop

func _create_piece(coord: Vector2i, piece_int: int) -> Piece:
	var piece_color:int = Consts.COLOR.WHITE
	var color_string: String = "WHITE"
	var piece_lookup: int = piece_int
	if piece_int > Consts.PIECE.size() - 1:
		piece_color = Consts.COLOR.BLACK
		color_string = "BLACK"
		piece_lookup += -Consts.PIECE.size() + 1
	
	var piece_string: String = Consts.PIECE.keys()[piece_lookup]
	
	var piece: Piece = Piece.new(coord, piece_lookup, piece_color, [color_string, piece_string])
	self.add_child(piece)
	
	return piece
