using Godot;
using Godot.Collections;
using System;
namespace Chess.Consts;
public class Piece {
	public enum Name : int {
		None = -1,
		W_PAWN = 0,
		W_ROOK = 1,
		W_KNIGHT = 2,
		W_BISHOP = 3,
		W_QUEEN = 4,
		W_KING = 5,
		B_PAWN = 6,
		B_ROOK = 7,
		B_KNIGHT = 8,
		B_BISHOP = 9,
		B_QUEEN = 10,
		B_KING = 11
	}
	public enum Type : int {
		Pawn = 0,
		Rook = 1,
		Knight = 2,
		Bishop = 3,
		Queen = 4,
		King = 5
	}
	public enum Color : int {
		White = 0,
		Black = 1
	}

}
public class Tile {
	public enum Highlight : int {
		None = 0,
		Hover = 1,
		Move = 2,
		Capture = 3,
		Check = 4,
	}
}
public enum SLIDE_TYPE : int {
	ROOK = 0,
	BISHOP = 1,
}