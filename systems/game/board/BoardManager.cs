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
    public static bool IsVecInsideBoard(Godot.Vector2 Vec) {
        if (Vec.X >= 0 && Vec.X < Consts.BoardPixelSize.X && Vec.Y >= 0 && Vec.Y < Consts.BoardPixelSize.Y) {
            return true;
        }
        return false;
    }
    public static int GetTileIdFromBitmask(ulong Bitmask) {
        return BitOperations.TrailingZeroCount(Bitmask);
    }
    // public static string GetPieceString(int PieceInt) {
    //     return Enum.GetName(typeof(Piece.Name), PieceInt);
    // }
    // --- Private Funcs ---
}
