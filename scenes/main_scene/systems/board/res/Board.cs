using Godot;
using Godot.Collections;
using System;
using Chess.Consts;
using System.Numerics;
[GlobalClass]
public partial class Board : ColorRect
{
	// enums
// consts
// exports
// public vars
public ulong[] BitBoard = new ulong[12];
public Dictionary piece_objs = [];
public int turn_amount = 0;
public int turn_color = (int)Piece.Color.White;
// private vars
private int[] tiles_highligt = new int[64];
private static readonly Shader shader_res = GD.Load<Shader>("res://scenes/main_scene/systems/board/shaders/board_shader.gdshader");
private ShaderMaterial mat = new();
private static readonly int[] W_BACK_ROW = 
	[(int)Piece.Name.W_ROOK, (int)Piece.Name.W_KNIGHT, (int)Piece.Name.W_BISHOP, (int)Piece.Name.W_QUEEN,
	(int)Piece.Name.W_KING, (int)Piece.Name.W_BISHOP, (int)Piece.Name.W_KNIGHT, (int)Piece.Name.W_ROOK];
private static readonly int[] B_BACK_ROW = 
	[(int)Piece.Name.B_ROOK, (int)Piece.Name.B_KNIGHT, (int)Piece.Name.B_BISHOP, (int)Piece.Name.B_QUEEN,
	(int)Piece.Name.B_KING, (int)Piece.Name.B_BISHOP, (int)Piece.Name.B_KNIGHT, (int)Piece.Name.B_ROOK];
private ulong[] KnightMoves = new ulong[64];
private ulong[] KingMoves = new ulong[64];
// onready vars
// built-in overide methods
	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
		BuildBoard();
	}

	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Process(double delta)
	{
	}

// public methods
	public void BuildBoard(){
		ulong starting_time = Godot.Time.GetTicksUsec();
		GD.PrintRich("[color=Springgreen]BOARD-[/color] Started Building Board");
		this.Name = "Board";

		this.Size = new Vector2I(1024, 1024);
		mat.Shader =  shader_res;
		this.Material = mat;
		float shader_ending_time = (Godot.Time.GetTicksUsec() - starting_time) / 1000f;
		GD.PrintRich("[color=Springgreen]BOARD-[/color] Created Board Shader in: [color=gold]",shader_ending_time,"ms[/color]");

		for(int i = 0; i < 64; i++){
			ulong Bitmask = GetBitmask(i);
			int piece_int = CalcPiece(Bitmask, i);
			if(piece_int == -1){ // no piece
				continue;
			};
			Vector2I coord = GetVec2FromIndex(i);
			CreatePiece(i, coord, piece_int);
			BitBoard[piece_int] |= Bitmask;
			GD.PrintRich($"[color=Springgreen]BOARD-[/color] Piece Ulong: [color=gold]{BitBoard[piece_int]}[/color]");
		};
		
		KnightMoves = _precalc_knight_moves();
		KingMoves = _precalc_king_moves();

		float ending_time = (Godot.Time.GetTicksUsec() - starting_time) / 1000f;
		GD.PrintRich("[color=Springgreen]BOARD-[/color] Created Board of size: [color=gold]8[/color] in: [color=gold]",ending_time,"ms[/color]");
	}
	public int GetTileIndex(){
		Vector2I local_mouse_pos = (Vector2I)GetLocalMousePosition();
		if(local_mouse_pos.X < 0 || local_mouse_pos.X > 1023){
			return -1;
		}
		int y = local_mouse_pos.Y >> 7;
		int array_index = (y << 3) + (local_mouse_pos.X >> 7);
		return array_index;
	}
	public bool IsValidIndex(int index){
		if(index >= 0 && index < 64){
			return true;
		};
		return false;
	}
	public int GetIndexFromVec2(Vector2I coord){
		int array_index = (coord.Y << 3) + coord.X;
		return array_index;
	}
	public Vector2I GetVec2FromIndex(int index){
		int x = index % 8;
		int y = index >> 3;
		return new Vector2I(x, y);
	}
	public int GetIndexFromBitmask(ulong Bitmask) {
		return BitOperations.TrailingZeroCount(Bitmask);
	}
	public void HighlightTile(int index, int highlight_type){
		tiles_highligt[index] = highlight_type;
		((ShaderMaterial)Material).SetShaderParameter("tile_states", tiles_highligt);
	}
	public void UnhighlightTile(int index){
		HighlightTile(index, 0);
	}
	public ulong GetBitmask(int index){
		ulong Bitmask = 1UL << index;
		return Bitmask;
	}
	public ulong GetOccupiedBitBoard(int color){
		ulong occupied_BitBoard = 0UL;
		int start_index = color * 6;
		for(int i = 0; i < 6; i++){
			occupied_BitBoard |= BitBoard[start_index + i];
		};
		return occupied_BitBoard;
	}
	public int GetPieceIndex(int index){ // -1 means no piece
		ulong Bitmask = GetBitmask(index);
		int piece_int = -1;
		for(int i = 0; i < 12; i++){
			if((BitBoard[i] & Bitmask) != 0){
				piece_int = i;
				break;
			};
		};
		return piece_int;
	}
	public string GetPieceString(int piece_int){
		return Enum.GetName(typeof(Piece.Name), piece_int);
	}
	public bool IsPieceWhite(int piece_int){
		if(piece_int < 6){
			return true;
		}
		return false;
	}
	public bool IsEmpty(int index){
		int piece_int = GetPieceIndex(index);
		if (piece_int == -1) {
			return true;
		}
		return false;
	}
	public bool IsEnemy(int index){
		int piece_int = GetPieceIndex(index);
		bool is_white = IsPieceWhite(piece_int);
		
		int piece_color = is_white ? (int)Piece.Color.White : (int)Piece.Color.Black;

		if (piece_color == turn_color) {
			return false;
		}
		return true;
	}
	public ulong[] MakePieceMoves(){
		ulong AllPieces = 0UL;
		for (int PieceIndex = 0; PieceIndex < 12; PieceIndex++) {
			AllPieces |= BitBoard[PieceIndex];
		}

		ulong[] Moves = [];

		for (int PieceIndex = 0; PieceIndex < 12; PieceIndex++) {
			int PieceType = PieceIndex % 6;
			int PieceColor = PieceIndex / 6;
			ulong PieceMask = BitBoard[PieceIndex];

			switch (PieceType) {
				case (int)Piece.Type.Pawn:
					Moves[PieceIndex] = GetPawnMoves(PieceMask, PieceColor, AllPieces);
					break;

				case (int)Piece.Type.Rook:
					Moves[PieceIndex] = GetSlideMoves(PieceMask, AllPieces, (int)SLIDE_TYPE.ROOK);
					break;

				case (int)Piece.Type.Knight:
					Moves[PieceIndex] = KnightMoves[PieceIndex];
					break;

				case (int)Piece.Type.Bishop:
					break;

				case (int)Piece.Type.Queen:
					break;

				case (int)Piece.Type.King:
					Moves[PieceIndex] = KingMoves[PieceIndex];
					break;
			}


			

		}

		return Moves;
	}
	public ulong GetPieceMoves(int Index){
		int PieceIndex = GetPieceIndex(Index);
		ulong white_pieces = GetOccupiedBitBoard((int)Piece.Color.White);
		ulong black_pieces = GetOccupiedBitBoard((int)Piece.Color.Black);
		ulong AllPieces = white_pieces | black_pieces;

		bool is_white = IsPieceWhite(PieceIndex);
		ulong friendly_pieces = is_white ? white_pieces : black_pieces;

		ulong Moves = 0UL;

		ulong Bitmask = GetBitmask(Index);

		switch (PieceIndex){
			case (int)Piece.Name.W_PAWN:
			case (int)Piece.Name.B_PAWN:
				int PieceColor = PieceIndex / 6;
				Moves = GetPawnMoves(Bitmask, PieceColor, AllPieces);
				break;
			
			case (int)Piece.Name.W_ROOK:
			case (int)Piece.Name.B_ROOK:
				Moves = GetSlideMoves(Bitmask, AllPieces, (int)SLIDE_TYPE.ROOK);
				break;
			
			case (int)Piece.Name.W_KNIGHT:
			case (int)Piece.Name.B_KNIGHT:
				Moves = KnightMoves[Index];
				break;

			case (int)Piece.Name.W_BISHOP:
			case (int)Piece.Name.B_BISHOP:
				Moves = GetSlideMoves(Bitmask, AllPieces, (int)SLIDE_TYPE.BISHOP);
				break;

			case (int)Piece.Name.W_QUEEN:
			case (int)Piece.Name.B_QUEEN:
				Moves = GetSlideMoves(Bitmask, AllPieces, (int)SLIDE_TYPE.ROOK) | GetSlideMoves(Bitmask, AllPieces, (int)SLIDE_TYPE.BISHOP);
				break;

			case (int)Piece.Name.W_KING:
			case (int)Piece.Name.B_KING:
				Moves = KingMoves[Index];
				break;
		}

		return Moves &= ~friendly_pieces;
	}
	public ulong GetPawnMoves(ulong Bitmask, int PieceColor, ulong AllPieces){
		ulong Moves;
		ulong CaptureMask;

		ulong NotLeftBorderPawns = Bitmask & ~72340172838076673UL;
		ulong NotRightBorderPawns = Bitmask & ~9259542123273814144UL;

		switch (PieceColor) {
			case (int)Piece.Color.White:
				Moves = Bitmask >> 8;
				CaptureMask = NotLeftBorderPawns >> 9;
				CaptureMask |= NotRightBorderPawns >> 7;
				if ((Bitmask & 71776119061217280) == Bitmask) { // white in start pos
					Moves |= Bitmask >> 16;
				}
				break;
			
			default:
				Moves = Bitmask << 8;
				CaptureMask = NotLeftBorderPawns << 7;
				CaptureMask |= NotRightBorderPawns << 9;
				if ((Bitmask & 65280) == Bitmask) { // black in start pos
					Moves |= Bitmask << 16;
				}
				break;
		}

		Moves &= ~AllPieces;
		Moves |= CaptureMask & AllPieces;
		return Moves;
	}
	public ulong GetSlideMoves(ulong Bitmask, ulong AllPieces, ulong slide_type){
		ulong Moves = 0UL;
		int Index = GetIndexFromBitmask(Bitmask);
		Vector2I coord = GetVec2FromIndex(Index);
		
			int left_tiles = coord.X;
			int right_tiles = 7 - coord.X;

			int up_tiles = coord.Y;
			int down_tiles = 7 - coord.Y;

		if (slide_type == (int)SLIDE_TYPE.ROOK){
			for (int x = 0; x < left_tiles; x++) {
				ulong step_bitmask =  Bitmask >> (x + 1);
				Moves |= step_bitmask;
				if ((step_bitmask & AllPieces) != 0) {
					break;
				}
			}
			for (int x = 0; x < right_tiles; x++) {
				ulong step_bitmask = Bitmask << (x + 1);
				Moves |= step_bitmask;
				if ((step_bitmask & AllPieces) != 0) {
					break;
				}
			}
			for (int y = 0; y < up_tiles; y++) {
				ulong step_bitmask = Bitmask >> ((y + 1) << 3);
				Moves |= step_bitmask;
				if ((step_bitmask & AllPieces) != 0) {
					break;
				}
			}
			for (int y = 0; y < down_tiles; y++) {
				ulong step_bitmask = Bitmask << ((y + 1) << 3);
				Moves |= step_bitmask;
				if ((step_bitmask & AllPieces) != 0) {
					break;
				}
			}
		} else {
			for (int xy = 0; xy < left_tiles; xy++) {
				if (xy < up_tiles) {
					ulong step_bitmask = Bitmask >> ((xy + 1) * 9);
					Moves |= step_bitmask;
					if ((step_bitmask & AllPieces) != 0) {
						break;
					}
				}
				if (xy < down_tiles) {
					ulong step_bitmask = Bitmask << ((xy + 1) * 7);
					Moves |= step_bitmask;
					if ((step_bitmask & AllPieces) != 0) {
						break;
					}
				}
			}
			for (int yx = 0; yx < right_tiles; yx++) {
				if (yx < up_tiles) {
					ulong step_bitmask = Bitmask >> ((yx + 1) * 7);
					Moves |= step_bitmask;
					if ((step_bitmask & AllPieces) != 0) {
						break;
					}
				}
				if (yx < down_tiles) {
					ulong step_bitmask = Bitmask << ((yx + 1) * 9);
					Moves |= step_bitmask;
					if ((step_bitmask & AllPieces) != 0) {
						break;
					}
				}
			}
		}
		return Moves;
	}
	public void MovePiece(int index, int new_index) {
		ulong new_bitmask = GetBitmask(new_index);

		int capture_piece_int = GetPieceIndex(new_index);
		if (capture_piece_int != -1) { // If there is a piece on target coord
			BitBoard[capture_piece_int] ^= new_bitmask;
			PieceObj capture_piece = (PieceObj)piece_objs[new_index];
			piece_objs.Remove(new_index);
			this.RemoveChild(capture_piece);
			capture_piece.Free();
		}

		ulong Bitmask = GetBitmask(index);
		int piece_int = GetPieceIndex(index);
		BitBoard[piece_int] ^= Bitmask;
		BitBoard[piece_int] |= new_bitmask;

		PieceObj piece = (PieceObj)piece_objs[index];
		piece_objs[new_index] = piece;
		piece_objs.Remove(index);
		piece.set_coord(GetVec2FromIndex(new_index));

		turn_color ^= 1;
		GD.Print($"BOARD- Piece Moved! Turn Color: {Enum.GetName(typeof(Piece.Color), turn_color)}");
	}
	// private methods
	private int CalcPiece(ulong Bitmask, int index){
		if ((Bitmask & 65535) != 0) {
			if ((Bitmask & 255) != 0) {
				return B_BACK_ROW[index & 7]; // Black Pieces
			} else {
				return (int)Piece.Name.B_PAWN; // Black Pawn
			}
		} else if ((Bitmask & 18446462598732840960) != 0) {
			if ((Bitmask & 18374686479671623680) != 0) {
				return W_BACK_ROW[index & 7]; // White Pieces
			} else {
				return (int)Piece.Name.W_PAWN; // White Pawn
			}
		}
		return -1;
	}
	private void CreatePiece(int index, Vector2I coord, int piece_int){
		string piece_string = GetPieceString(piece_int);
		PieceObj piece = new PieceObj();
		this.AddChild(piece);
		piece.setup(coord, piece_string);
		piece_objs.Add(index, piece);
	}
	private ulong[] _precalc_knight_moves(){
		ulong[] Moves = new ulong[64];
		for (int i = 0; i < 64; i++) {
			ulong Bitmask = GetBitmask(i);

			if ((Bitmask & 65535) == 0) { // can go 2 up
				if ((Bitmask & 72340172838076673) == 0) { // can go 1 left
					Moves[i] |= Bitmask >> 17;
				}
				if ((Bitmask & 9259542123273814144) == 0) { // can go 1 right
					Moves[i] |= Bitmask >> 15;
				}
			}

			if ((Bitmask & 18446462598732840960) == 0) { // can go 2 down
				if ((Bitmask & 72340172838076673) == 0) { // can go 1 left
					Moves[i] |= Bitmask << 15;
				}
				if ((Bitmask & 9259542123273814144) == 0) { // can go 1 right
					Moves[i] |= Bitmask << 17;
				}
			}

			if ((Bitmask & 217020518514230019) == 0) { // can go 2 left
				if ((Bitmask & 255) == 0) { // can go 1 up
					Moves[i] |= Bitmask >> 10;
				}
				if ((Bitmask & 18374686479671623680) == 0) { // can go 1 down
					Moves[i] |= Bitmask << 6;
				}
			}

			if ((Bitmask & 13889313184910721216) == 0) { // can go 2 right
				if ((Bitmask & 255) == 0) { // can go 1 up
					Moves[i] |= Bitmask >> 6;
				}
				if ((Bitmask & 18374686479671623680) == 0) { // can go 1 down
					Moves[i] |= Bitmask << 10;
				}
			}
		}

		return Moves;
	}
	private ulong[] _precalc_king_moves(){
		ulong[] Moves = new ulong[64];
		for (int i = 0; i < 64; i++) {
			ulong Bitmask = GetBitmask(i);
			if ((Bitmask & 255) == 0) { // can go up
				Moves[i] |= Bitmask >> 8;

				if ((Bitmask & 72340172838076673) == 0) { // can go left
					Moves[i] |= Bitmask >> 9;
				}
				if ((Bitmask & 9259542123273814144) == 0) { // can go right
					Moves[i] |= Bitmask >> 7;
				}

			}
			if ((Bitmask & 18374686479671623680) == 0) { // can go down
				Moves[i] |= Bitmask << 8;

				if ((Bitmask & 72340172838076673) == 0) { // can go left
					Moves[i] |= Bitmask << 7;
				}
				if ((Bitmask & 9259542123273814144) == 0) { // can go right
					Moves[i] |= Bitmask << 9;
				}

			}
			if ((Bitmask & 72340172838076673) == 0) { // can go left
				Moves[i] |= Bitmask >> 1;
			}
			if ((Bitmask & 9259542123273814144) == 0) { // can go right
				Moves[i] |= Bitmask << 1;
			}

		}
		return Moves;
	}
}