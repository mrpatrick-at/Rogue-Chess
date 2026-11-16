using Godot;
using Godot.Collections;
using System;

using Chess.systems.math;
using Chess.systems.game.enums;
using System.Numerics;
using System.Collections.Generic;

namespace Chess.systems.game.piece;
public static partial class PieceManager {
    // --- Private Vars ---
    // --- Public Funcs ---
    public static PieceId GetPieceId(int TileInt, ulong[] Bitboard) {
        // Returns the Type of Piece on the requested Tile. (Returns -1 if no Piece)
        ulong Bitmask = Bitmath.GetBitmask(TileInt);
        for (int i = 0; i < 12; i++) {
            if ((Bitboard[i] & Bitmask) != 0) {
                return (PieceId)i;
            }
        }

        return PieceId.None;
    }
    public static int[] GetPiecePositionsOfType(ulong PieceUlong) {
        // Converts a Piece Ulong to an int[] of Positions
        List<int> PiecePositions = new();

        ulong Pieces = PieceUlong;

        while (Pieces != 0) {
            int pos = BitOperations.TrailingZeroCount(Pieces);
            PiecePositions.Add(pos);

            Pieces &= ~(1UL << pos);
        }

        return PiecePositions.ToArray();
    }
    public static MoveType GetMoveType(PieceId PieceID) {
        return (MoveType)((int)PieceID % 6);
    }
    public static TeamColor GetPieceColor(PieceId PieceID) {
        return (TeamColor)((int)PieceID / 6);
    }
    public static bool IsPiece(PieceId PieceID) {
        if ((int)PieceID == -1) {
            return false;
        }
        return true;
    }
    public static bool IsEnemy(PieceId PieceID, TeamColor TurnColor) {
        TeamColor PieceColor = GetPieceColor(PieceID);

        if (PieceColor == TurnColor) {
            return false;
        }

        return true;
    }

    // --- Private Funcs ---
}
