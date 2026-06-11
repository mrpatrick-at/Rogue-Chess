extends MeshInstance2D
class_name Piece
## enums
## consts
const shader_res: Shader = preload("res://scenes/main_scene/systems/board/shaders/piece_shader.gdshader")
const path: String = "res://assets/images/pieces/%s/%s.png"
const _knight_directions: PackedVector2Array = [Vector2i(1,2),Vector2i(-1,2), Vector2i(1,-2),Vector2i(-1,-2), Vector2i(2,1),Vector2i(2,-1), Vector2i(-2,1),Vector2i(-2,-1)]
const _rook_directions: PackedVector2Array = [Vector2i(0,1), Vector2i(0,-1), Vector2i(1,0), Vector2i(-1,0)]
const _bishop_directions: PackedVector2Array = [Vector2i(1,1), Vector2i(1,-1), Vector2i(-1,1), Vector2i(-1,-1)]
## exports
## public vars
var coord: Vector2i = Vector2i.ZERO
var type: int = 0
var color: int = 0
var move_amount: int = 0
var moves: PackedVector2Array = []
var board: Board
var animation_tween: Tween
var y_offset: float = 0
## private vars
## onready vars
## built-in override methods

func _init(piece_coord: Vector2i, piece_type: int, piece_color: int, piece_info: Array) -> void:
	var starting_time: float = Time.get_ticks_usec()
	print_rich("[color=Orange]Piece-[/color] Started Building Board")
	coord = piece_coord
	type = piece_type
	color = piece_color
	board = Scripts.BOARD_MANAGER.board
	
	self.name = "%s, %s"%piece_info
	
	var piece_texture: CompressedTexture2D = load(path%piece_info)
	var quadmesh: QuadMesh = QuadMesh.new()
	quadmesh.size = Vector2(16,32)
	
	self.mesh = quadmesh
	self.texture = piece_texture
	
	board.pieces[coord] = self
	self.z_index = -coord.y + 7
	
	self.material = ShaderMaterial.new()
	self.material.shader = shader_res
	var pos_coord: Vector2i = Vector2i(coord.x, coord.y - 7)
	self.material.set_shader_parameter("coord", pos_coord)
	moves = get_moves()
	
	self.scale = Vector2i(8,8)
	
	var ending_time:float = (Time.get_ticks_usec() - starting_time) / 1000
	print_rich("[color=Orange]PIECE-[/color] Created at: [color=gold]%s[/color] in: [color=gold]%sms[/color]" %[coord, ending_time])

## public methods

func get_moves() -> PackedVector2Array:
	var piece_moves: PackedVector2Array = []
	
	match type: # Checks which Piece, then gets Moves
		Consts.PIECE.PAWN:
			piece_moves = _get_pawn_moves()
		Consts.PIECE.ROOK:
			piece_moves = _get_rook_moves()
		Consts.PIECE.KNIGHT:
			piece_moves = _get_knight_moves()
		Consts.PIECE.BISHOP:
			piece_moves = _get_bishop_moves()
		Consts.PIECE.QUEEN:
			piece_moves = _get_rook_moves() + _get_bishop_moves()
		Consts.PIECE.KING:
			piece_moves = _get_king_moves()
	
	return piece_moves

func move_to(target_coord: Vector2i) -> void:
	moves = get_moves()
	if moves.has(target_coord):
		if board.pieces.has(target_coord):
			var piece: Piece = board.pieces[target_coord]
			piece.take_piece()
		
		# En Passant
		if self.type == Consts.PIECE.PAWN and target_coord.x != coord.x and !board.pieces.has(target_coord):
			var pos_passant: Vector2i = Vector2i(target_coord.x, coord.y)
			var piece: Piece = board.pieces[pos_passant]
			piece.take_piece()
		
		# Castling
		if self.type == Consts.PIECE.KING and abs(target_coord.x - coord.x) > 1:
			var rook_coord: Vector2i = Vector2i(0, coord.y)
			var rook_destination: Vector2i = Vector2i(3,coord.y)
			if coord.x < target_coord.x:
				rook_coord = Vector2i(7, coord.y)
				rook_destination = Vector2i(5, coord.y)
			var piece: Piece = board.pieces[rook_coord]
			piece.move_to(rook_destination)
		
		board.pieces.erase(coord)
		board.pieces[target_coord] = self
		
		coord = target_coord
		var pos_coord: Vector2i = Vector2i(coord.x, coord.y - 7)
		self.material.set_shader_parameter("coord", pos_coord)
		self.z_index = -coord.y + 7
		
		move_amount += 1
		board.turn_amount += 1
		
		if board.turn_amount & 1 == 0:
			board.turn_color = Consts.COLOR.WHITE
		else:
			board.turn_color = Consts.COLOR.BLACK
		

func take_piece() -> void:
	board.pieces.erase(self)
	board.remove_child(self)
	self.queue_free()

func highlight() -> void:
	if animation_tween:
		animation_tween.kill()
	animation_tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
	animation_tween.tween_method(_set_shader_value, y_offset, 4.0, 0.07)
	#print("PIECE- Highlighted Piece at: ", coord)

func unhighlight() -> void:
	await get_tree().create_timer(0.03).timeout
	if animation_tween:
		animation_tween.kill()
	animation_tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
	animation_tween.tween_method(_set_shader_value, y_offset, 0.0, 0.05)
	#print("PIECE- Unhighlighted Piece at: ", coord)

func reset_highlight() -> void:
	if animation_tween:
		animation_tween.kill()
	_set_shader_value(0)

## private methods

func _set_shader_value(value: float) -> void:
	y_offset = value
	self.material.set_shader_parameter("y_offset", value);

func _get_pawn_moves() -> PackedVector2Array:
	var piece_moves: PackedVector2Array = []
	var move_range: int = 1
	
	var direction_int: int = 1
	if color == Consts.COLOR.BLACK:
		direction_int = -1
	
	if move_amount == 0:
		move_range = 2
	
	# Main Movement
	for i: int in move_range:
		var pos: Vector2i = coord
		pos.y += (i + 1) * direction_int
		if !board.is_valid_coord(pos):
			break
		if !board.is_empty(pos):
			break
		
		piece_moves.append(pos)
	
	# Piece Capturing
	var direction_y: int = coord.y + direction_int
	var capture_squares: PackedVector2Array = [Vector2i(coord.x - 1, direction_y),Vector2i(coord.x + 1, direction_y)]
	for pos:Vector2i in capture_squares:
		if !board.is_valid_coord(pos):
			continue
		if board.is_empty(pos):
			# En Passant Rules
			var pos_passant: Vector2i = Vector2i(pos.x, coord.y)
			if board.pieces.has(pos_passant):
				var piece: Piece = board.pieces[pos_passant]
				if board.is_enemy(pos_passant, color) and piece.move_amount == 1 and piece.type == Consts.PIECE.PAWN:
					piece_moves.append(pos)
			continue
		if !board.is_enemy(pos, color):
			continue
		piece_moves.append(pos)
		# En Passant Rules
		#var pos_passant: Vector2i = Vector2i(pos.y, coord.y)
		#var passant_piece: Piece = board.pieces[pos_passant]
		#if passant_piece.type == Scripts.CONSTANTS.PIECE_TYPE.PAWN:
			#if passant_piece.move_amount == 1:
				#if Scripts.PIECE_MANAGER.get_piece_data(pos_passant,Scripts.CONSTANTS.PIECE_LIST.PAWN_MOVED_TWO_TILES) == Scripts.CONSTANTS.PAWN_MOVED_TWO_TILES.TRUE:
					#piece_moves.append(pos)
	return piece_moves

func _get_rook_moves() -> Array:
	var piece_moves:Array = []
	
	for direction: Vector2i in _rook_directions:
		var pos: Vector2i = coord + direction
		
		while board.is_valid_coord(pos):
			
			if board.is_empty(pos):
				piece_moves.append(pos)
				pos += direction
				continue
			
			if board.is_enemy(pos, color):
				piece_moves.append(pos)
			
			break
	
	return piece_moves

func _get_knight_moves() -> PackedVector2Array: # TODO: Prob can Make this a little bit better !!!
	var piece_moves: PackedVector2Array = []
	
	for direction: Vector2i in _knight_directions:
		var pos:Vector2i = coord + direction
		
		if board.is_valid_coord(pos):
			
			if board.is_empty(pos) or board.is_enemy(pos, color):
				piece_moves.append(pos)
	
	return piece_moves

func _get_bishop_moves() -> Array:
	var piece_moves:Array = []
	
	for direction: Vector2i in _bishop_directions:
		var pos: Vector2i = coord + direction
		
		while board.is_valid_coord(pos):
			
			if board.is_empty(pos):
				piece_moves.append(pos)
				pos += direction
				continue
			
			if board.is_enemy(pos, color):
				piece_moves.append(pos)
			
			break
	
	return piece_moves

func _get_king_moves() -> Array: # TODO: Wow I just discovered how absolutely shit the Castling Code is. FIX IN FUTURE!!!!
	var piece_moves:Array = []
	
	for x in 3:
		for y in 3:
			var pos:Vector2i = coord
			pos.x += x - 1
			pos.y += y - 1
			
			if board.is_valid_coord(pos):
				if board.is_empty(pos):
					piece_moves.append(pos)
					continue
				
				if board.is_enemy(pos, color):
					piece_moves.append(pos)
	
	# Castling
	if move_amount == 0:
		var rook_coords: PackedVector2Array = [Vector2i(0, coord.y), Vector2i(7, coord.y)]
		for rook_coord: Vector2i in rook_coords:
			if board.is_empty(rook_coord):
				continue
			
			var piece: Piece = board.pieces[rook_coord]
			if piece.move_amount != 0:
				continue
			
			var between_coords: PackedVector2Array = [Vector2i(1, coord.y), Vector2i(2, coord.y), Vector2i(3, coord.y)]
			if rook_coord.x > coord.x:
				between_coords = [Vector2i(5, coord.y), Vector2i(6, coord.y)]
			
			var can_castle: bool = true
			for between_coord in between_coords:
				if board.is_empty(between_coord):
					continue
				can_castle = false
				break
			
			if can_castle:
				piece_moves.append(between_coords[1])
	
	return piece_moves
