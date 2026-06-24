using Godot;
using Godot.Collections;
using Godot.NativeInterop;
using Microsoft.VisualBasic;
using System;
using System.Linq;
[GlobalClass]
public partial class Board : ColorRect
{
	// enums
public enum PIECE : int {
	W_PAWN,
	W_ROOK,
	W_KNIGHT,
	W_BISHOP,
	W_QUEEN,
	W_KING,
	B_PAWN,
	B_ROOK,
	B_KNIGHT,
	B_BISHOP,
	B_QUEEN,
	B_KING,
}
public enum COLOR : int {
	WHITE,
	BLACK
}
public enum SLIDE_TYPE : int {
	ROOK,
	BISHOP
}
// consts
// exports
// public vars
public ulong[] bitboard = new ulong[12];
public Dictionary piece_objs = new();
public int turn_amount = 0;
public int turn_color = (int)COLOR.WHITE;
// private vars
private int[] tiles_highligt = new int[64];
private static readonly Shader shader_res = GD.Load<Shader>("res://scenes/main_scene/systems/board/shaders/board_shader.gdshader");
private ShaderMaterial mat = new ShaderMaterial();
private static readonly int[] W_BACK_ROW = 
	{(int)PIECE.W_ROOK, (int)PIECE.W_KNIGHT, (int)PIECE.W_BISHOP, (int)PIECE.W_QUEEN,
	(int)PIECE.W_KING, (int)PIECE.W_BISHOP, (int)PIECE.W_KNIGHT, (int)PIECE.W_ROOK};
private static readonly int[] B_BACK_ROW = 
	{(int)PIECE.B_ROOK, (int)PIECE.B_KNIGHT, (int)PIECE.B_BISHOP, (int)PIECE.B_QUEEN,
	(int)PIECE.B_KING, (int)PIECE.B_BISHOP, (int)PIECE.B_KNIGHT, (int)PIECE.B_ROOK};
private ulong[] knight_moves = new ulong[64];
private ulong[] king_moves = new ulong[64];
// onready vars
// built-in overide methods
	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
		build_board();
	}

	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Process(double delta)
	{
	}

// public methods
	public void build_board(){
		ulong starting_time = Godot.Time.GetTicksUsec();
		GD.PrintRich("[color=Springgreen]BOARD-[/color] Started Building Board");
		this.Name = "Board";

		this.Size = new Vector2I(8 * 128, 8 * 128);
		mat.Shader =  shader_res;
		this.Material = mat;
		float shader_ending_time = (Godot.Time.GetTicksUsec() - starting_time) / 1000f;
		GD.PrintRich("[color=Springgreen]BOARD-[/color] Created Board Shader in: [color=gold]",shader_ending_time,"ms[/color]");

		for(int i = 0; i < 64; i++){
			int piece_int = _calc_piece(i);
			if(piece_int == -1){ // no piece
				continue;
			};
			Vector2I coord = get_vec2_from_index(i);
			_create_piece(i, coord, piece_int);
			ulong bitmask = get_bitmask(i);
			bitboard[piece_int] |= bitmask;
			GD.PrintRich($"[color=Springgreen]BOARD-[/color] Piece Ulong: [color=gold]{bitboard[piece_int]}[/color]");
		};
		
		knight_moves = _precalc_knight_moves();
		king_moves = _precalc_king_moves();

		float ending_time = (Godot.Time.GetTicksUsec() - starting_time) / 1000f;
		GD.PrintRich("[color=Springgreen]BOARD-[/color] Created Board of size: [color=gold]8[/color] in: [color=gold]",ending_time,"ms[/color]");
	}
	public int get_tile_index(){
		Vector2I local_mouse_pos = (Vector2I)GetLocalMousePosition();
		if(local_mouse_pos.X < 0 || local_mouse_pos.X > 1023){
			return -1;
		}
		int y = local_mouse_pos.Y >> 7;
		int array_index = (y << 3) + (local_mouse_pos.X >> 7);
		return array_index;
	}
	public bool is_valid_index(int index){
		if(index >= 0 && index < 64){
			return true;
		};
		return false;
	}
	public int get_index_from_vec2(Vector2I coord){
		int array_index = (coord.Y << 3) + coord.X;
		return array_index;
	}
	public Vector2I get_vec2_from_index(int index){
		int x = index & 7;
		int y = index >> 3;
		return new Vector2I(x, y);
	}
	public void highlight_tile(int index, int highlight_type){
		tiles_highligt[index] = highlight_type;
		((ShaderMaterial)Material).SetShaderParameter("tile_states", tiles_highligt);
	}
	public void unhighlight_tile(int index){
		highlight_tile(index, 0);
	}
	public ulong get_bitmask(int index){
		ulong bitmask = 1UL << index;
		return bitmask;
	}
	public ulong get_occupied_bitboard(int color){
		ulong occupied_bitboard = 0UL;
		int start_index = color * 6;
		for(int i = 0; i < 6; i++){
			occupied_bitboard |= bitboard[start_index + i];
		};
		return occupied_bitboard;
	}
	public int get_piece_int(int index){ // -1 means no piece
		ulong bitmask = get_bitmask(index);
		int piece_int = -1;
		for(int i = 0; i < 12; i++){
			if((bitboard[i] & bitmask) != 0){
				piece_int = i;
				break;
			};
		};
		return piece_int;
	}
	public string get_piece_string(int piece_int){
		return Enum.GetName(typeof(PIECE), piece_int);
	}
	public bool is_piece_white(int piece_int){
		if(piece_int < 6){
			return true;
		}
		return false;
	}
	public bool is_empty(int index){
		int piece_int = get_piece_int(index);
		if (piece_int == -1) {
			return true;
		}
		return false;
	}
	public bool is_enemy(int index){
		int piece_int = get_piece_int(index);
		bool is_white = is_piece_white(piece_int);
		
		int piece_color = is_white ? (int)COLOR.WHITE : (int)COLOR.BLACK;

		if (piece_color == turn_color) {
			return false;
		}
		return true;
	}
	public int[] get_piece_moves(int index){
		int piece_int = get_piece_int(index);
		ulong white_pieces = get_occupied_bitboard((int)COLOR.WHITE);
		ulong black_pieces = get_occupied_bitboard((int)COLOR.BLACK);
		ulong all_pieces = white_pieces | black_pieces;

		bool is_white = is_piece_white(piece_int);
		ulong friendly_pieces = is_white ? white_pieces : black_pieces;

		ulong moves = 0UL;

		switch (piece_int){
			case (int)PIECE.W_PAWN:
			case (int)PIECE.B_PAWN:
				moves = get_pawn_moves(index, is_white, all_pieces, friendly_pieces);
				break;
			
			case (int)PIECE.W_ROOK:
			case (int)PIECE.B_ROOK:
				moves = get_slide_moves(index, is_white, all_pieces, (int)SLIDE_TYPE.ROOK);
				break;
			
			case (int)PIECE.W_KNIGHT:
			case (int)PIECE.B_KNIGHT:
				moves = knight_moves[index];
				break;

			case (int)PIECE.W_BISHOP:
			case (int)PIECE.B_BISHOP:
				moves = get_slide_moves(index, is_white, all_pieces, (int)SLIDE_TYPE.BISHOP);
				break;

			case (int)PIECE.W_QUEEN:
			case (int)PIECE.B_QUEEN:
				moves = get_slide_moves(index, is_white, all_pieces, (int)SLIDE_TYPE.ROOK) | get_slide_moves(index, is_white, all_pieces, (int)SLIDE_TYPE.BISHOP);
				break;

			case (int)PIECE.W_KING:
			case (int)PIECE.B_KING:
				moves = king_moves[index];
				break;
		}

		int[] translated_moves = new int[64];

		for(int i = 0; i < 64; i++){
			if((moves & (1UL << i)) != 0){
				translated_moves[i] = 1;
			};
		};

		return translated_moves;
	}
	public ulong get_pawn_moves(int index, bool is_white, ulong all_pieces, ulong friendly_pieces){
		ulong bitmask = get_bitmask(index);
		ulong moves = is_white ? bitmask >> 8 : bitmask << 8;

		if (index > 7 && index < 16) { //black
			moves |= bitmask << 16;
		} else if (index > 47 && index < 56) {
			moves |= bitmask >> 16;
		}

		int remainer = index % 7;

		ulong capturemask = 0UL;

		if(remainer != 0){ // can go left
			capturemask |= is_white ? bitmask >> 9 : bitmask << 7;
		}

		if(remainer != 7){ // can go right
			capturemask |= is_white ? bitmask >> 7 : bitmask << 9;
		}

		ulong enemy_pieces = all_pieces ^ friendly_pieces;

		moves |= capturemask & enemy_pieces;
		return moves;
	}
	public ulong get_slide_moves(int index, bool is_white, ulong all_pieces, ulong slide_type){
		ulong bitmask = get_bitmask(index);
		ulong moves = 0UL;
		Vector2I coord = get_vec2_from_index(index);
		
			int left_tiles = coord.X;
			int right_tiles = 7 - coord.X;

			int up_tiles = coord.Y;
			int down_tiles = 7 - coord.Y;

		if (slide_type == (int)SLIDE_TYPE.ROOK){
			for (int x = 0; x < left_tiles; x++) {
				moves |= bitmask >> (x + 1);
			}
			for (int x = 0; x < right_tiles; x++) {
				moves |= bitmask << (x + 1);
			}
			for (int y = 0; y < up_tiles; y++) {
				moves |= bitmask >> ((y + 1) << 3);
			}
			for (int y = 0; y < down_tiles; y++) {
				moves |= bitmask << ((y + 1) << 3);
			}
		} else {
			for (int xy = 0; xy < left_tiles; xy++) {
				if (xy < up_tiles) {
					moves |= bitmask >> ((xy + 1) * 9);
				}
				if (xy < down_tiles) {
					moves |= bitmask << ((xy + 1) * 7);
				}
			}
			for (int yx = 0; yx < right_tiles; yx++) {
				if (yx < up_tiles) {
					moves |= bitmask >> ((yx + 1) * 7);
				}
				if (yx < down_tiles) {
					moves |= bitmask << ((yx + 1) * 9);
				}
			}
		}
		return moves;
	}
	public void move_piece(int index, int new_index) {
		ulong new_bitmask = get_bitmask(new_index);

		int capture_piece_int = get_piece_int(new_index);
		if (capture_piece_int != -1) { // If there is a piece on target coord
			bitboard[capture_piece_int] ^= new_bitmask;
			Piece capture_piece = (Piece)piece_objs[new_index];
			piece_objs.Remove(new_index);
			this.RemoveChild(capture_piece);
			capture_piece.Free();
		}

		ulong bitmask = get_bitmask(index);
		int piece_int = get_piece_int(index);
		bitboard[piece_int] ^= bitmask;
		bitboard[piece_int] |= new_bitmask;

		Piece piece = (Piece)piece_objs[index];
		piece_objs[new_index] = piece;
		piece_objs.Remove(index);
		piece.set_coord(get_vec2_from_index(new_index));

		turn_color ^= 1;
		GD.Print($"BOARD- Piece Moved! Turn Color: {Enum.GetName(typeof(COLOR), turn_color)}");
	}
	// private methods
	private int _calc_piece(int index){
		if (index < 16) {
			if (index < 8) {
				return B_BACK_ROW[index & 7]; // Black Pieces
			} else {
				return (int)PIECE.B_PAWN; // Black Pawn
			}
		} else if (index > 47) {
			if (index > 55) {
				return W_BACK_ROW[index & 7]; // White Pieces
			} else {
				return (int)PIECE.W_PAWN; // White Pawn
			}
		}
		return -1;
	}
	private void _create_piece(int index, Vector2I coord, int piece_int){
		string piece_string = get_piece_string(piece_int);
		Piece piece = new Piece();
		this.AddChild(piece);
		piece.setup(coord, piece_string);
		piece_objs.Add(index, piece);
	}
	private ulong[] _precalc_knight_moves(){
		ulong[] moves = new ulong[64];
		for (int i = 0; i < 64; i++) {
			ulong bitmask = get_bitmask(i);

			ulong piece_moves = new ulong();

			if ((bitmask & 65535) == 0) { // can go 2 up
				if ((bitmask & 72340172838076673) == 0) { // can go 1 left
					piece_moves |= bitmask >> 17;
				}
				if ((bitmask & 9259542123273814144) == 0) { // can go 1 right
					piece_moves |= bitmask >> 15;
				}
			}

			if ((bitmask & 18446462598732840960) == 0) { // can go 2 down
				if ((bitmask & 72340172838076673) == 0) { // can go 1 left
					piece_moves |= bitmask << 15;
				}
				if ((bitmask & 9259542123273814144) == 0) { // can go 1 right
					piece_moves |= bitmask << 17;
				}
			}

			if ((bitmask & 217020518514230019) == 0) { // can go 2 left
				if ((bitmask & 255) == 0) { // can go 1 up
					piece_moves |= bitmask >> 10;
				}
				if ((bitmask & 18374686479671623680) == 0) { // can go 1 down
					piece_moves |= bitmask << 6;
				}
			}

			if ((bitmask & 13889313184910721216) == 0) { // can go 2 right
				if ((bitmask & 255) == 0) { // can go 1 up
					piece_moves |= bitmask >> 6;
				}
				if ((bitmask & 18374686479671623680) == 0) { // can go 1 down
					piece_moves |= bitmask << 10;
				}
			}

			moves[i] = piece_moves;
		}

		return moves;
	}
	private ulong[] _precalc_king_moves(){
		ulong[] moves = new ulong[64];
		return moves;
	}
}