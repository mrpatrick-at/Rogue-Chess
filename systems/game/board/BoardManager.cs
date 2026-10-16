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
    public static bool IsValidTileInt(int TileInt) {
        if (TileInt >= 0 && TileInt < 64) {
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
    public static Vector2I GetVec2FromTileInt(int TileInt) {
        return new Vector2I(TileInt % 8, TileInt >> 3);
    }
    public static int GetTileIntFromBitmask(ulong Bitmask) {
        return BitOperations.TrailingZeroCount(Bitmask);
    }
    // public static string GetPieceString(int PieceInt) {
    //     return Enum.GetName(typeof(Piece.Name), PieceInt);
    // }
    // --- Private Funcs ---
}
