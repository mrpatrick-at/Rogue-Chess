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
public enum PIECE {
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
public enum COLOR {
	WHITE,
	BLACK
}
// consts
// exports
// public vars
public ulong[] bitboard = new ulong[12];
public Dictionary piece_objs = new();
public int turn_amount = 0;
public int turn_color = 0;
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
			Vector2I coord = get_vec2_from_index(i);
			int piece_int = _calc_piece(coord.X, coord.Y);
			if(piece_int == -1){ // no piece
				continue;
			};
			_create_piece(i, coord, piece_int);
			ulong bitmask = get_bitmask(i);
			bitboard[piece_int] |= bitmask;
			GD.PrintRich($"[color=Springgreen]BOARD-[/color] Piece Ulong: [color=gold]{bitboard[piece_int]}[/color]");
		};

		float ending_time = (Godot.Time.GetTicksUsec() - starting_time) / 1000f;
		GD.PrintRich("[color=Springgreen]BOARD-[/color] Created Board of size: [color=gold]8[/color] in: [color=gold]",ending_time,"ms[/color]");
	}
	public int get_tile_index(){
		Vector2I local_mouse_pos = (Vector2I)GetLocalMousePosition();
		if(local_mouse_pos.X <= 0 || local_mouse_pos.X >= 1024){
			return -1;
		}
		int y = local_mouse_pos.Y >> 7;
		int array_index = (y << 3) + (local_mouse_pos.X >> 7);
		return array_index;
	}
	public bool is_valid_index(int index){
		if(index >= 0 && index <= 63){
			return true;
		};
		return false;
	}
	public int get_index_from_vec2(Vector2I coord){
		int inverted_y = 7 - coord.Y;
		int array_index = (inverted_y << 3) + coord.X;
		return array_index;
	}
	public Vector2I get_vec2_from_index(int index){
		int x = index & 7;
		int y = 7 - (index >> 3);
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
	public int get_piece_type(int index){ // -1 means no piece
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
	public bool is_empty(int index){ // refrence placeholder
		return true;
	}
	public bool is_enemy(int index, int color){ // refrence placeholder
		return true;
	}
	public ulong get_piece_moves(int index, int piece_int){
		ulong white_pieces = get_occupied_bitboard((int)COLOR.WHITE);
		ulong black_pieces = get_occupied_bitboard((int)COLOR.BLACK);
		ulong all_pieces = white_pieces | black_pieces;

		bool is_white = is_piece_white(piece_int);
		ulong friendly_pieces = is_white ? white_pieces : black_pieces;

		ulong moves = 0UL;

		switch (piece_int){
			case (int)PIECE.W_PAWN:
			case (int)PIECE.B_PAWN:
		}

		return moves;
	}
// private methods
	private int _calc_piece(int x, int y){
		if(y > 1 && y < 6){
			return -1; // Empty Square
		};

		if(y == 1){
			return (int)PIECE.W_PAWN; // White Pawn
		};
		if(y == 6){
			return (int)PIECE.B_PAWN; // Black Pawn
		};

		if(y == 0){
			return W_BACK_ROW[x]; // White Pieces
		};
	
		return B_BACK_ROW[x]; // Black Pieces
	}
	private void _create_piece(int index, Vector2I coord, int piece_int){
		string piece_string = get_piece_string(piece_int);
		Piece piece = new Piece();
		this.AddChild(piece);
		piece.setup(coord, piece_string);
		piece_objs.Add(index, piece);
	}
}