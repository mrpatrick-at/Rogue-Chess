using Godot;
using Godot.Collections;
using System;

using Chess.systems.math;
using Chess.systems.game.consts;
using Chess.systems.game.piece.enums;
using Chess.OldConsts;
using System.Numerics;
using System.Collections.Generic;

namespace Chess.systems.game.piece;
public static partial class PieceManager {
    // --- Private Vars ---
    private static readonly PieceId[] W_BACK_ROW =
        [PieceId.W_ROOK, PieceId.W_KNIGHT, PieceId.W_BISHOP, PieceId.W_QUEEN,
        PieceId.W_KING, PieceId.W_BISHOP, PieceId.W_KNIGHT, PieceId.W_ROOK];
    private static readonly PieceId[] B_BACK_ROW =
        [PieceId.B_ROOK, PieceId.B_KNIGHT, PieceId.B_BISHOP, PieceId.B_QUEEN,
        PieceId.B_KING, PieceId.B_BISHOP, PieceId.B_KNIGHT, PieceId.B_ROOK];
    // --- Public Funcs ---
    public static ulong[] ResetPieces() {
        // Returns a Fresh Bitboard with Starting Piece Positions.
        ulong[] Bitboard = new ulong[12];

        for (int i = 0; i < 64; i++) {
            ulong PosBitmask = Bitmath.GetBitmask(i);
            PieceId PieceID = CalcPiece(PosBitmask, i);
            if (PieceID == PieceId.None) {
                // No Piece on Tile
                continue;
            }

            Bitboard[(int)PieceID] |= PosBitmask;
        }

        return Bitboard;
    }

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

    private static PieceId CalcPiece(ulong Bitmask, int Index) {
        // Gives The PieceType on given Tile on Startup
        if ((Bitmask & 65535) != 0) {
            if ((Bitmask & 255) != 0) {
                return B_BACK_ROW[Index & 7]; // Black Pieces
            } else {
                return PieceId.B_PAWN; // Black Pawns
            }
        } else if ((Bitmask & 18446462598732840960) != 0) {
            if ((Bitmask & 18374686479671623680) != 0) {
                return W_BACK_ROW[Index & 7]; // White Pieces
            } else {
                return PieceId.W_PAWN; // White Pawns
            }
        }
        return PieceId.None;
    }
}
