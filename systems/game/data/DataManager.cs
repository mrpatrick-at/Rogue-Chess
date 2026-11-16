using Godot;
using System;
using System.Numerics;

using Chess.systems.math;
using Chess.systems.game.enums;

namespace Chess.systems.game.data;

// enums
public static class BoardDataManager {
    // --- Consts ---
    // --- Public vars ---
    // --- Private vars ---
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
