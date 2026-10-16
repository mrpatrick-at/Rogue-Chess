// Consts.cs

using Godot;
using Godot.Collections;
using System;

namespace Chess.systems.game.consts;

public readonly struct Consts {
    public static readonly Vector2I BoardSize = new(8, 8);
    public static readonly Vector2I CellPixelSize = new(32, 32);
    public static readonly Vector2I BoardPixelSize = BoardSize * CellPixelSize;
}
public readonly struct Piece {
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
    public enum SlideType : int {
        Rook = 0,
        Bishop = 1
    }
}
public readonly struct Tile {
    public enum Highlight : int {
        None = 0,
        Hover = 1,
        Move = 2,
        Capture = 3,
        Check = 4,
    }
}
