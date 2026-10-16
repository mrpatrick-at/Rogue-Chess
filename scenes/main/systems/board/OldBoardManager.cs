using Godot;
using System;
using System.Numerics;

namespace Chess.OldBoardManager;

// enums
public static class OldBoardManager {
    // consts
    // exports
    // signals
    // public vars
    // private vars
    // onready vars
    // built-in override methods

    // public funcs

    // public static funcs
    public static bool IsValidTileInt(int Index) {
        if (Index >= 0 && Index < 64) {
            return true;
        }
        ;
        return false;
    }
    public static Vector2I GetVec2FromIndex(int Index) {
        return new Vector2I(Index % 8, Index >> 3);
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

