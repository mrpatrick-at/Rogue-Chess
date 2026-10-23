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
    private static readonly PieceType[] W_BACK_ROW =
        [PieceType.W_ROOK, PieceType.W_KNIGHT, PieceType.W_BISHOP, PieceType.W_QUEEN,
        PieceType.W_KING, PieceType.W_BISHOP, PieceType.W_KNIGHT, PieceType.W_ROOK];
    private static readonly PieceType[] B_BACK_ROW =
        [PieceType.B_ROOK, PieceType.B_KNIGHT, PieceType.B_BISHOP, PieceType.B_QUEEN,
        PieceType.B_KING, PieceType.B_BISHOP, PieceType.B_KNIGHT, PieceType.B_ROOK];
    // --- Public Funcs ---
    public static ulong[] ResetPieces() {
        // Returns a Fresh Bitboard with Starting Piece Positions.
        ulong[] Bitboard = new ulong[12];

        for (int i = 0; i < 64; i++) {
            ulong PosBitmask = Bitmath.GetBitmask(i);
            PieceType PieceInt = CalcPiece(PosBitmask, i);
            if (PieceInt == PieceType.None) {
                // No Piece on Tile
                continue;
            }

            Bitboard[(int)PieceInt] |= PosBitmask;
        }

        return Bitboard;
    }

    public static PieceType GetPieceType(int TileInt, ulong[] Bitboard) {
        // Returns the Type of Piece. (Returns -1 if no Piece)
        ulong Bitmask = Bitmath.GetBitmask(TileInt);
        for (int i = 0; i < 12; i++) {
            if ((Bitboard[i] & Bitmask) != 0) {
                return (PieceType)i;
            }
        }

        return PieceType.None;
    }
    public static int[] GetPiecePositionsOfType(ulong PieceUlong) {
        // Returns the All Piece Positions of the Requested Type.
        List<int> PiecePositions = new();

        ulong Pieces = PieceUlong;

        while (Pieces != 0) {
            int pos = BitOperations.TrailingZeroCount(Pieces);
            PiecePositions.Add(pos);

            Pieces &= ~(1UL << pos);
        }


        return PiecePositions.ToArray();
    }
    public static MoveType GetMoveType(PieceType PieceType) {
        return (MoveType)((int)PieceType % 6);
    }
    public static PieceColor GetPieceColor(PieceType PieceType) {
        return (PieceColor)((int)PieceType / 6);
    }
    public static bool IsPiece(PieceType PieceType) {
        if ((int)PieceType == -1) {
            return false;
        }
        return true;
    }
    public static bool IsEnemy(PieceType PieceType, PieceColor TurnColor) {
        PieceColor PieceColor = GetPieceColor(PieceType);

        if (PieceColor == TurnColor) {
            return false;
        }

        return true;
    }

    // --- Private Funcs ---

    private static PieceType CalcPiece(ulong Bitmask, int Index) {
        // Gives The PieceType on given Tile on Startup
        if ((Bitmask & 65535) != 0) {
            if ((Bitmask & 255) != 0) {
                return B_BACK_ROW[Index & 7]; // Black Pieces
            } else {
                return PieceType.B_PAWN; // Black Pawns
            }
        } else if ((Bitmask & 18446462598732840960) != 0) {
            if ((Bitmask & 18374686479671623680) != 0) {
                return W_BACK_ROW[Index & 7]; // White Pieces
            } else {
                return PieceType.W_PAWN; // White Pawns
            }
        }
        return PieceType.None;
    }
}
