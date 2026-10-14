using Godot;
using Godot.Collections;
using System;

using Chess.systems.bitmath;
using Chess.systems.game.consts;
using Chess.systems.game.piece.enums;

namespace Chess.systems.game.piece;
public static partial class PieceManager {
    // --- Private Vars
    private static readonly PieceType[] W_BACK_ROW =
        [PieceType.W_ROOK, PieceType.W_KNIGHT, PieceType.W_BISHOP, PieceType.W_QUEEN,
        PieceType.W_KING, PieceType.W_BISHOP, PieceType.W_KNIGHT, PieceType.W_ROOK];
    private static readonly PieceType[] B_BACK_ROW =
        [PieceType.B_ROOK, PieceType.B_KNIGHT, PieceType.B_BISHOP, PieceType.B_QUEEN,
        PieceType.B_KING, PieceType.B_BISHOP, PieceType.B_KNIGHT, PieceType.B_ROOK];
    // --- Public Funcs ---
    public static ulong[] ResetPieces() {
        ulong[] Bitboard = new ulong[12];

        for (int i = 0; i < 64; i++) {
            ulong PosBitmask = BitMath.GetBitmask(i);
            PieceType PieceInt = CalcPiece(PosBitmask, i);
            if (PieceInt == PieceType.None) {
                // No Piece on Tile
                continue;
            }

            Bitboard[(int)PieceInt] |= PosBitmask;
        }

        return Bitboard;
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
