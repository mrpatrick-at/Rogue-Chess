using Godot;
using System;
using System.Numerics;

using Chess.systems.game.consts;

namespace Chess.systems.game.board;

// enums
public static class BoardManager {
    // --- Consts ---
    // --- Public vars ---
    // --- Private vars ---

    // --- Public Funcs ---
    public static bool IsValidIndex(int Index) {
        if (Index >= 0 && Index < 64) {
            return true;
        }
        return false;
    }
    public static bool IsVecInsideBoard(Godot.Vector2 Vec) {
        if (Vec.X >= 0 && Vec.X < Consts.BoardPixelSize.X && Vec.Y >= 0 && Vec.Y < Consts.BoardPixelSize.Y) {
            return true;
        }
        return false;
    }
    public static Vector2I GetVec2FromIndex(int Index) {
        int x = Index % 8;
        int y = Index >> 3;
        return new Vector2I(x, y);
    }
    public static int GetIndexFromBitmask(ulong Bitmask) {
        return BitOperations.TrailingZeroCount(Bitmask);
    }
    public static ulong GetBitmask(int Index) {
        ulong Bitmask = 1UL << Index;
        return Bitmask;
    }
    // public static string GetPieceString(int PieceInt) {
    //     return Enum.GetName(typeof(Piece.Name), PieceInt);
    // }
    // --- Private Funcs ---
}
