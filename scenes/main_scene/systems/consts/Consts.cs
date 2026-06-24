using Godot;
using Godot.Collections;
using System;
namespace Chess.Consts;
public enum PIECE : int {
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
	B_KING = 11,
}
public enum COLOR : int {
	WHITE = 0,
	BLACK = 1,
}
public enum SLIDE_TYPE : int {
	ROOK = 0,
	BISHOP = 1,
}