using Godot;
using Microsoft.VisualBasic;
using System;
[GlobalClass]
public partial class Board_cs : ColorRect
{
	// enums
public enum PIECE {
	NONE,
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
// consts
// exports
// public vars
public static readonly Shader shader_res = GD.Load<Shader>("res://scenes/main_scene/systems/board/shaders/board_shader.gdshader");
public static readonly int[] W_BACK_ROW = 
	{(int)PIECE.W_ROOK, (int)PIECE.W_KNIGHT, (int)PIECE.W_BISHOP, (int)PIECE.W_QUEEN,
	(int)PIECE.W_KING, (int)PIECE.W_BISHOP, (int)PIECE.W_KNIGHT, (int)PIECE.W_ROOK};
public static readonly int[] B_BACK_ROW = 
	{(int)PIECE.B_ROOK, (int)PIECE.B_KNIGHT, (int)PIECE.B_BISHOP, (int)PIECE.B_QUEEN,
	(int)PIECE.B_KING, (int)PIECE.B_BISHOP, (int)PIECE.B_KNIGHT, (int)PIECE.B_ROOK};
public ulong[] bitboard = new ulong[12];
// private vars
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
		GD.PrintRich("[color=Springgreen]BUILD_BOARD-[/color] Started Building Board");
		this.Name = "Board";

		this.Size = new Vector2I(8 * 128, 8 * 128);
		ShaderMaterial mat = new ShaderMaterial();
		mat.Shader =  shader_res;
		this.Material = mat;
		float shader_ending_time = (Godot.Time.GetTicksUsec() - starting_time) / 1000f;
		GD.PrintRich("[color=Springgreen]BUILD_BOARD-[/color] Created Board Shader in: [color=gold]",shader_ending_time,"ms[/color]");

		for(int y = 0; y < 8; y++){
			for(int x = 0; x < 8; x++){
				GD.Print("x: ",x,", y: ",y);
				int piece_int = _calc_piece(x, y);
				if(piece_int != (int)PIECE.NONE){
					ulong bit_mask = (ulong)1 << get_tiles_array_index(x, y);
					int piece_type = piece_int - 1;
					bitboard[piece_type] |= bit_mask;
					GD.Print("Piece: ", bitboard[piece_type]);
				}
			};
		};
		float ending_time = (Godot.Time.GetTicksUsec() - starting_time) / 1000f;
		GD.PrintRich("[color=Springgreen]BUILD_BOARD-[/color] Created Board of size: [color=gold]8[/color] in: [color=gold]",ending_time,"ms[/color]");
	}
	public Vector2I get_coord(){
		Vector2I local_mouse_pos = (Vector2I)GetLocalMousePosition();
		int x = local_mouse_pos.X >> 7;
		int y = 7 - (local_mouse_pos.Y >> 7);
		Vector2I coord = new Vector2I(x, y);
		return coord;
	}
	public bool is_valid_coord(Vector2I coord){
		if(coord.X >= 0 && coord.X <= 7 && coord.Y >= 0 && coord.Y <= 7){
			return true;
		};
		return false;
	}
	public bool is_empty(Vector2I coord){ // refrence placeholder
		return true;
	}
	public bool is_enemy(Vector2I coord){ // refrence placeholder
		return true;
	}
	public int get_tiles_array_index(int x, int y){
		int inverted_y = 7 - y;
		int array_index = ((inverted_y << 3) + x);
		return array_index;
	}
// private methods
	private int _calc_piece(int x, int y){
		if(y > 1 && y < 6){
			return (int)PIECE.NONE; // Empty Square
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
}