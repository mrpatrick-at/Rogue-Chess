using Godot;
using System;
using System.Numerics;

namespace Chess.OldBoardManager;

// enums
public static class BoardManager {
    // consts
    // exports
    // signals
    // public vars
    // private vars
    // onready vars
    // built-in override methods

    // public funcs

    // public static funcs
    public static bool IsValidIndex(int Index) {
        if (Index >= 0 && Index < 64) {
            return true;
        }
        ;
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
    public static int GetPieceType(int PieceInt) {
        return PieceInt % 6;
    }
    public static int GetPieceColor(int PieceInt) {
        return PieceInt / 6;
    }
    // public static string GetPieceString(int PieceInt) {
    //     return Enum.GetName(typeof(Piece.Name), PieceInt);
    // }
    // private funcs
}

