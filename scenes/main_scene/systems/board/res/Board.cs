using Godot;
using Godot.Collections;
using System;
using Chess.Consts;
using System.Numerics;
using System.ComponentModel.DataAnnotations;
[GlobalClass]
public partial class Board : ColorRect
{
	// enums
// consts
// exports
// public vars
public ulong[] BitBoard = new ulong[12];
public Dictionary PieceObjs = [];
public int turn_amount = 0;
public int TurnColor = (int)Piece.Color.White;
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

		for(int Index = 0; Index < 64; Index++){
			ulong Bitmask = GetBitmask(Index);
			int PieceInt = CalcPiece(Bitmask, Index);
			if(PieceInt == -1){ // no piece
				continue;
			};
			CreatePiece(Index, PieceInt);
			
			BitBoard[PieceInt] |= Bitmask;
			GD.PrintRich($"[color=Springgreen]BOARD-[/color] Piece Ulong: [color=gold]{BitBoard[PieceInt]}[/color]");
		};
		
		KnightMoves = PreCalcKnightMoves();
		KingMoves = PreCalcKingMoves();

		float ending_time = (Godot.Time.GetTicksUsec() - starting_time) / 1000f;
		GD.PrintRich("[color=Springgreen]BOARD-[/color] Created Board of size: [color=gold]8[/color] in: [color=gold]",ending_time,"ms[/color]");
	}
	public int GetTileIndex() {
		Vector2I local_mouse_pos = (Vector2I)GetLocalMousePosition();
		if(local_mouse_pos.X < 0 || local_mouse_pos.X > 1023){
			return -1;
		}
		int y = local_mouse_pos.Y >> 7;
		int array_index = (y << 3) + (local_mouse_pos.X >> 7);
		return array_index;
	}
	public bool IsValidIndex(int Index) {
		if(Index >= 0 && Index < 64){
			return true;
		};
		return false;
	}
	public Vector2I GetVec2FromIndex(int Index) {
		int x = Index % 8;
		int y = Index >> 3;
		return new Vector2I(x, y);
	}
	public int GetIndexFromBitmask(ulong Bitmask) {
		return BitOperations.TrailingZeroCount(Bitmask);
	}
	public void HighlightTile(int Index, int highlight_type) {
		tiles_highligt[Index] = highlight_type;
		((ShaderMaterial)Material).SetShaderParameter("tile_states", tiles_highligt);
	}
	public void UnhighlightTile(int Index) {
		HighlightTile(Index, 0);
	}
	public ulong GetBitmask(int Index) {
		ulong Bitmask = 1UL << Index;
		return Bitmask;
	}
	public ulong GetOccupiedBitBoard(int color) {
		ulong occupied_BitBoard = 0UL;
		int start_index = color * 6;
		for(int i = 0; i < 6; i++){
			occupied_BitBoard |= BitBoard[start_index + i];
		};
		return occupied_BitBoard;
	}
	public int GetPieceInt(int Index) { // -1 means no piece
		ulong Bitmask = GetBitmask(Index);
		int PieceInt = -1;
		for(int i = 0; i < 12; i++){
			if((BitBoard[i] & Bitmask) != 0){
				PieceInt = i;
				break;
			};
		};
		return PieceInt;
	}
	public int GetPieceType(int PieceInt) {
		return PieceInt % 6;
	}
	public int GetPieceColor(int PieceInt) {
		return PieceInt / 6;
	}
	public string GetPieceString(int PieceInt) {
		return Enum.GetName(typeof(Piece.Name), PieceInt);
	}
	public bool IsPieceWhite(int PieceInt) {
		if(PieceInt < 6){
			return true;
		}
		return false;
	}
	public bool IsEmpty(int Index) {
		int PieceInt = GetPieceInt(Index);
		if (PieceInt == -1) {
			return true;
		}
		return false;
	}
	public bool IsEnemy(int Index){
		int PieceInt = GetPieceInt(Index);
		bool is_white = IsPieceWhite(PieceInt);
		
		int piece_color = is_white ? (int)Piece.Color.White : (int)Piece.Color.Black;

		if (piece_color == TurnColor) {
			return false;
		}
		return true;
	}
	public ulong[] MakePieceMoves(){
		ulong WhitePieces = GetOccupiedBitBoard((int)Piece.Color.White);
		ulong BlackPieces = GetOccupiedBitBoard((int)Piece.Color.Black);
		ulong AllPieces = WhitePieces | BlackPieces;

		ulong[] Moves = [];

		for (int PieceInt = 0; PieceInt < 12; PieceInt++) {
			int PieceType = GetPieceType(PieceInt);
			int PieceColor = GetPieceColor(PieceInt);
			ulong PieceMask = BitBoard[PieceInt];

			ulong FriendlyPieces = PieceColor == 0 ? WhitePieces : BlackPieces;
			ulong EnemyPieces = AllPieces & ~FriendlyPieces;

			switch (PieceType) {
				case (int)Piece.Type.Pawn:
					Moves[PieceInt] = GetPawnMoves(PieceMask, PieceColor, AllPieces, EnemyPieces);
					break;

				case (int)Piece.Type.Rook:
					Moves[PieceInt] = GetSlideMoves(PieceMask, AllPieces, (int)SLIDE_TYPE.ROOK);
					break;

				case (int)Piece.Type.Knight:
					Moves[PieceInt] = KnightMoves[PieceInt];
					break;

				case (int)Piece.Type.Bishop:
					Moves[PieceInt] = GetSlideMoves(PieceMask, AllPieces, (int)SLIDE_TYPE.BISHOP);
					break;

				case (int)Piece.Type.Queen:
					Moves[PieceInt] = GetSlideMoves(PieceMask, AllPieces, (int)SLIDE_TYPE.ROOK) | GetSlideMoves(PieceMask, AllPieces, (int)SLIDE_TYPE.BISHOP);
					break;

				case (int)Piece.Type.King:
					Moves[PieceInt] = KingMoves[PieceInt];
					break;
			}

			Moves[PieceInt] &= ~FriendlyPieces;
		}

		return Moves;
	}
	public ulong GetPieceMoves(int Index){
		int PieceInt = GetPieceInt(Index);
		ulong WhitePieces = GetOccupiedBitBoard((int)Piece.Color.White);
		ulong BlackPieces = GetOccupiedBitBoard((int)Piece.Color.Black);
		ulong AllPieces = WhitePieces | BlackPieces;

		int PieceType = GetPieceType(PieceInt);
		int PieceColor = GetPieceColor(PieceInt);
		
		ulong FriendlyPieces = PieceColor == 0 ? WhitePieces : BlackPieces;
		ulong EnemyPieces = AllPieces & ~FriendlyPieces;

		ulong Moves = 0UL;

		ulong Bitmask = GetBitmask(Index);

		switch (PieceType){
			case (int)Piece.Type.Pawn:
				Moves = GetPawnMoves(Bitmask, PieceColor, AllPieces, EnemyPieces);
				break;
			
			case (int)Piece.Type.Rook:
				Moves = GetSlideMoves(Bitmask, AllPieces, (int)SLIDE_TYPE.ROOK);
				break;
			
			case (int)Piece.Type.Knight:
				Moves = KnightMoves[Index];
				break;

			case (int)Piece.Type.Bishop:
				Moves = GetSlideMoves(Bitmask, AllPieces, (int)SLIDE_TYPE.BISHOP);
				break;

			case (int)Piece.Type.Queen:
				Moves = GetSlideMoves(Bitmask, AllPieces, (int)SLIDE_TYPE.ROOK) | GetSlideMoves(Bitmask, AllPieces, (int)SLIDE_TYPE.BISHOP);
				break;

			case (int)Piece.Type.King:
				Moves = KingMoves[Index];
				break;
		}

		return Moves &= ~FriendlyPieces;
	}
	public ulong GetPawnMoves(ulong Bitmask, int PieceColor, ulong AllPieces, ulong EnemyPieces){
		ulong Moves;
		ulong CaptureMask;

		ulong NotLeftBorderPawns = Bitmask & ~72340172838076673UL;
		ulong NotRightBorderPawns = Bitmask & ~9259542123273814144UL;
		ulong NeighborMask = (NotLeftBorderPawns << 1 | NotRightBorderPawns >> 1) & EnemyPieces;

		switch (PieceColor) {
			case (int)Piece.Color.White:
				Moves = Bitmask >> 8;
				CaptureMask = NotLeftBorderPawns >> 9;
				CaptureMask |= NotRightBorderPawns >> 7;
				
				Moves |= (NeighborMask >> 8) & ~AllPieces; // EnPassant

				if ((Bitmask & 71776119061217280) == Bitmask) { // white in start pos
					Moves |= Bitmask >> 16;
				}
				break;
			
			default:
				Moves = Bitmask << 8;
				CaptureMask = NotLeftBorderPawns << 7;
				CaptureMask |= NotRightBorderPawns << 9;

				Moves |= (NeighborMask << 8) & ~AllPieces; // EnPassant

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
		Vector2I Coord = GetVec2FromIndex(Index);
		
			int left_tiles = Coord.X;
			int right_tiles = 7 - Coord.X;

			int up_tiles = Coord.Y;
			int down_tiles = 7 - Coord.Y;

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
	public void MovePiece(int OriginIndex, int TargetIndex) {
		int PieceInt = GetPieceInt(OriginIndex);

		int PieceType = GetPieceType(PieceInt);
		GD.Print($"PieceInt: {PieceInt}, PieceType: {PieceType}");

		int CaptureIndex = TargetIndex;
		switch (PieceType){
			case (int)Piece.Type.Pawn:
				int TargetPieceInt = GetPieceInt(TargetIndex);
				if (TargetPieceInt == -1) {
					int Diffrence = OriginIndex - TargetIndex;
					// GD.Print($"Dffrence: {Diffrence}, Abs: {Math.Abs(Diffrence)}");
					if (Math.Abs(Diffrence) is 7 or 9) {
						int Distance = (Math.Abs(Diffrence) - 8) * Math.Sign(Diffrence);
						// GD.Print($"EnPassant! Diffence: {Diffrence}, Distance: {Distance}");
						CaptureIndex = OriginIndex - Distance;
				}
				}
				break;
			
			// case (int)Piece.Type.Rook:
			// 	break;
			
			// case (int)Piece.Type.Knight:
			// 	break;

			// case (int)Piece.Type.Bishop:
			// 	break;

			// case (int)Piece.Type.Queen:
			// 	break;

			// case (int)Piece.Type.King:
			// 	break;
		}

		int CapturePieceInt = GetPieceInt(CaptureIndex);

		// Clear Target Piece
		if (CapturePieceInt != -1) { // If there is a piece on target Coord
			ulong CaptureBitmask = GetBitmask(CaptureIndex);
			BitBoard[CapturePieceInt] &= ~CaptureBitmask;

			// Clear Piece Object
			PieceObj TargetPiece = (PieceObj)PieceObjs[CaptureIndex];
			this.RemoveChild(TargetPiece);
			TargetPiece.Free();
			PieceObjs.Remove(CaptureIndex);
		}
		
		// Move on Bitmask
		ulong OriginBitmask = GetBitmask(OriginIndex);
		ulong TargetBitmask = GetBitmask(TargetIndex);

		BitBoard[PieceInt] &= ~OriginBitmask;
		BitBoard[PieceInt] |= TargetBitmask;

		// Move Piece Object
		PieceObj ObjPiece = (PieceObj)PieceObjs[OriginIndex];
		PieceObjs[TargetIndex] = ObjPiece;
		PieceObjs.Remove(OriginIndex);
		ObjPiece.set_coord(GetVec2FromIndex(TargetIndex));

		TurnColor = 1 & ~TurnColor;
		GD.Print($"BOARD- Piece Moved! Turn Color: {Enum.GetName(typeof(Piece.Color), TurnColor)}");
	}
	public void DeletePiece(int TargetIndex, int TargetPieceInt, ulong TargetBitmask) {
		BitBoard[TargetPieceInt] &= ~TargetBitmask;

			// Clear Piece Object
			PieceObj TargetPiece = (PieceObj)PieceObjs[TargetIndex];
			this.RemoveChild(TargetPiece);
			TargetPiece.Free();
			PieceObjs.Remove(TargetIndex);
	}
	// private methods
	private int CalcPiece(ulong Bitmask, int Index){
		if ((Bitmask & 65535) != 0) {
			if ((Bitmask & 255) != 0) {
				return B_BACK_ROW[Index & 7]; // Black Pieces
			} else {
				return (int)Piece.Name.B_PAWN; // Black Pawn
			}
		} else if ((Bitmask & 18446462598732840960) != 0) {
			if ((Bitmask & 18374686479671623680) != 0) {
				return W_BACK_ROW[Index & 7]; // White Pieces
			} else {
				return (int)Piece.Name.W_PAWN; // White Pawn
			}
		}
		return -1;
	}
	private void CreatePiece(int Index, int PieceInt){
		string piece_string = GetPieceString(PieceInt);
		PieceObj ObjPiece = new();
		this.AddChild(ObjPiece);

		Vector2I Coord = GetVec2FromIndex(Index);

		ObjPiece.Setup(Coord, piece_string);
		PieceObjs.Add(Index, ObjPiece);
	}
	private ulong[] PreCalcKnightMoves(){
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
	private ulong[] PreCalcKingMoves(){
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