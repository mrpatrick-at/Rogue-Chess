using Godot;
using Godot.Collections;
using System;

using Chess.systems.math;
using Chess.systems.game.consts;
using Chess.systems.game.board;
using Chess.systems.game.enums;

namespace Chess.systems.game.piece;
public static partial class MoveManager {
    // --- Private Vars ---
    private static readonly ulong[] KingMoves = PreCalcKingMoves();
    private static readonly ulong[] KnightMoves = PreCalcKnightMoves();
    // --- Public Funcs ---
    public static (ulong[], ulong) MakePieceMoves(ulong[] Bitboard, TeamColor TurnColor, ulong OccupationBitboard, ulong WhiteBitboard, ulong BlackBitboard) {
        // Calcs valid Moves and Tiles the Enemy is threatening
        ulong[] Moves = new ulong[64];
        ulong ThreatenedTiles = new();

        ulong FriendlyBitboard = TurnColor == TeamColor.White ? WhiteBitboard : BlackBitboard;
        ulong EnemyBitboard = OccupationBitboard & ~FriendlyBitboard;

        TeamColor EnemyColor = TurnColor == TeamColor.White ? TeamColor.Black : TeamColor.White;

        // Make Enemy Moves
        ulong[] EnemyMoves = MakeTeamMoves(Bitboard, EnemyColor, OccupationBitboard, ~0UL, 0);
        for (int i = 0; i < EnemyMoves.Length; i++) {
            ThreatenedTiles |= EnemyMoves[i];
        }

        // Make Friendly Moves
        ulong[] FriendlyMoves = MakeTeamMoves(Bitboard, TurnColor, OccupationBitboard, EnemyBitboard, ThreatenedTiles);
        for (int i = 0; i < FriendlyMoves.Length; i++) {
            Moves[i] = FriendlyMoves[i] & ~FriendlyBitboard;
        }

        return (Moves, ThreatenedTiles);
    }

    // --- Private Funcs ---
    private static ulong[] MakeTeamMoves(ulong[] Bitboard, TeamColor PieceColor, ulong OccupationBitboard, ulong EnemyBitboard, ulong ThreatenedTiles) {
        // Make Moves for all Pieces of the requested Team
        ulong[] ColorMoves = new ulong[64];

        for (int i = 0; i < 6; i++) {
            // Loop thru every Type of Piece

            int PieceType = i + 6 * (int)PieceColor;
            ulong PieceUlong = Bitboard[PieceType];

            if (PieceUlong == 0) {
                // No Pieces of this Type
                continue;
            }

            MoveType MoveType = PieceManager.GetMoveType((PieceId)PieceType);

            int[] PiecePositions = PieceManager.GetPiecePositionsOfType(PieceUlong);

            for (int k = 0; k < PiecePositions.Length; k++) {
                // Loop for every Piece of this Type
                int PiecePos = PiecePositions[k];

                ulong Bitmask = Bitmath.GetBitmask(PiecePos);

                ulong PieceMoves = MoveType switch {
                    MoveType.Pawn => GetPawnMoves(Bitmask, PieceColor, OccupationBitboard, EnemyBitboard),
                    MoveType.Rook => GetSlideMoves(Bitmask, OccupationBitboard, SlideType.Rook),
                    MoveType.Knight => KnightMoves[PiecePos],
                    MoveType.Bishop => GetSlideMoves(Bitmask, OccupationBitboard, SlideType.Bishop),
                    MoveType.Queen => GetSlideMoves(Bitmask, OccupationBitboard, SlideType.Rook) | GetSlideMoves(Bitmask, OccupationBitboard, SlideType.Bishop),
                    MoveType.King => KingMoves[PiecePos] & ~ThreatenedTiles,
                    _ => 0
                };

                ColorMoves[PiecePos] = PieceMoves;
            }
        }

        return ColorMoves;
    }
    private static ulong GetPawnMoves(ulong Bitmask, TeamColor PieceColor, ulong OccupationBitboard, ulong EnemyBitboard) {
        ulong Moves;
        ulong CaptureMask;

        ulong NotLeftBorderPawns = Bitmask & ~72340172838076673UL;
        ulong NotRightBorderPawns = Bitmask & ~9259542123273814144UL;
        ulong NeighborMask = (NotLeftBorderPawns << 1 | NotRightBorderPawns >> 1) & EnemyBitboard;

        switch (PieceColor) {
            case TeamColor.White:
                Moves = Bitmask >> 8;
                // Captures
                CaptureMask = NotLeftBorderPawns >> 9;
                CaptureMask |= NotRightBorderPawns >> 7;

                // EnPassant
                Moves |= (NeighborMask >> 8) & ~OccupationBitboard;

                if ((Bitmask & 71776119061217280) == Bitmask) {
                    // White in Start Pos
                    if ((OccupationBitboard & Bitmask >> 8) == 0) {
                        Moves |= Bitmask >> 16;
                    }
                }
                break;

            default:
                Moves = Bitmask << 8;
                // Captures
                CaptureMask = NotLeftBorderPawns << 7;
                CaptureMask |= NotRightBorderPawns << 9;

                // EnPassant
                Moves |= (NeighborMask << 8) & ~OccupationBitboard;

                if ((Bitmask & 65280) == Bitmask) {
                    // Black in Start Pos
                    if ((OccupationBitboard & Bitmask << 8) == 0) {
                        Moves |= Bitmask << 16;
                    }
                }
                break;
        }

        Moves &= ~OccupationBitboard;
        Moves |= CaptureMask & EnemyBitboard;
        return Moves;
    }
    private static ulong GetSlideMoves(ulong Bitmask, ulong OccupationBitboard, SlideType slideType) {
        ulong Moves = 0UL;

        int TileId = BoardManager.GetTileIdFromBitmask(Bitmask);

        int leftTiles = TileId % 8; // The Amount of Tiles left of the Piece
        int rightTiles = 7 - leftTiles; // The Amount of Tiles Right of the Piece

        int aboveTiles = TileId / 8; // The Amount of Tiles above the Piece
        int belowTiles = 7 - aboveTiles; // The Amount of Tiles below the Piece

        if (slideType == SlideType.Rook) {
            // Get Moves for Rook
            for (int x = 1; x <= leftTiles; x++) {
                ulong stepBitmask = Bitmask >> x;
                Moves |= stepBitmask;
                if ((stepBitmask & OccupationBitboard) != 0) {
                    break;
                }
            }
            for (int x = 1; x <= rightTiles; x++) {
                ulong stepBitmask = Bitmask << x;
                Moves |= stepBitmask;
                if ((stepBitmask & OccupationBitboard) != 0) {
                    break;
                }
            }
            for (int y = 1; y <= aboveTiles; y++) {
                ulong stepBitmask = Bitmask >> (y << 3);
                Moves |= stepBitmask;
                if ((stepBitmask & OccupationBitboard) != 0) {
                    break;
                }
            }
            for (int y = 1; y <= belowTiles; y++) {
                ulong stepBitmask = Bitmask << (y << 3);
                Moves |= stepBitmask;
                if ((stepBitmask & OccupationBitboard) != 0) {
                    break;
                }
            }
        } else {
            // Get Moves for Bishop
            bool aboveFinished = false;
            bool belowFinished = false;

            for (int x = 1; x <= leftTiles; x++) {
                // Left Diagonals
                if (!aboveFinished && x <= aboveTiles) {
                    // Up-Left
                    ulong stepBitmask = Bitmask >> ((x << 3) + x);
                    Moves |= stepBitmask;
                    if ((stepBitmask & OccupationBitboard) != 0) {
                        // Reached End Above
                        aboveFinished = true;
                    }
                }
                if (!belowFinished && x <= belowTiles) {
                    // Down-Left
                    ulong stepBitmask = Bitmask << ((x << 3) - x);
                    Moves |= stepBitmask;
                    if ((stepBitmask & OccupationBitboard) != 0) {
                        // Reached End Below
                        belowFinished = true;
                    }
                }
            }

            aboveFinished = false;
            belowFinished = false;

            for (int x = 1; x <= rightTiles; x++) {
                // Right Diagonals
                if (!aboveFinished && x <= aboveTiles) {
                    // Up-Right
                    ulong stepBitmask = Bitmask >> ((x << 3) - x);
                    Moves |= stepBitmask;
                    if ((stepBitmask & OccupationBitboard) != 0) {
                        // Reached End Above
                        aboveFinished = true;
                    }
                }
                if (!belowFinished && x <= belowTiles) {
                    // Down-Right
                    ulong stepBitmask = Bitmask << ((x << 3) + x);
                    Moves |= stepBitmask;
                    if ((stepBitmask & OccupationBitboard) != 0) {
                        // Reached End Below
                        belowFinished = true;
                    }
                }
            }
        }

        return Moves;
    }
    // Piece Move Precalc
    private static ulong[] PreCalcKingMoves() {
        ulong[] Moves = new ulong[64];
        for (int i = 0; i < 64; i++) {
            ulong Bitmask = Bitmath.GetBitmask(i);
            if ((Bitmask & 255) == 0) { // can go up
                Moves[i] |= Bitmask >> 8;

                if ((Bitmask & 72340172838076673) == 0) { // can go left
                    Moves[i] |= Bitmask >> 9;
                }
                if ((Bitmask & 9259542123273814144) == 0) { // can go right
                    Moves[i] |= Bitmask >> 7;
                }

            }
            if ((Bitmask & 18374686479671623680) == 0) { // can go down
                Moves[i] |= Bitmask << 8;

                if ((Bitmask & 72340172838076673) == 0) { // can go left
                    Moves[i] |= Bitmask << 7;
                }
                if ((Bitmask & 9259542123273814144) == 0) { // can go right
                    Moves[i] |= Bitmask << 9;
                }

            }
            if ((Bitmask & 72340172838076673) == 0) { // can go left
                Moves[i] |= Bitmask >> 1;
            }
            if ((Bitmask & 9259542123273814144) == 0) { // can go right
                Moves[i] |= Bitmask << 1;
            }

        }
        return Moves;
    }
    private static ulong[] PreCalcKnightMoves() {
        ulong[] Moves = new ulong[64];
        for (int i = 0; i < 64; i++) {
            ulong Bitmask = Bitmath.GetBitmask(i);

            if ((Bitmask & 65535) == 0) { // can go 2 up
                if ((Bitmask & 72340172838076673) == 0) { // can go 1 left
                    Moves[i] |= Bitmask >> 17;
                }
                if ((Bitmask & 9259542123273814144) == 0) { // can go 1 right
                    Moves[i] |= Bitmask >> 15;
                }
            }

            if ((Bitmask & 18446462598732840960) == 0) { // can go 2 down
                if ((Bitmask & 72340172838076673) == 0) { // can go 1 left
                    Moves[i] |= Bitmask << 15;
                }
                if ((Bitmask & 9259542123273814144) == 0) { // can go 1 right
                    Moves[i] |= Bitmask << 17;
                }
            }

            if ((Bitmask & 217020518514230019) == 0) { // can go 2 left
                if ((Bitmask & 255) == 0) { // can go 1 up
                    Moves[i] |= Bitmask >> 10;
                }
                if ((Bitmask & 18374686479671623680) == 0) { // can go 1 down
                    Moves[i] |= Bitmask << 6;
                }
            }

            if ((Bitmask & 13889313184910721216) == 0) { // can go 2 right
                if ((Bitmask & 255) == 0) { // can go 1 up
                    Moves[i] |= Bitmask >> 6;
                }
                if ((Bitmask & 18374686479671623680) == 0) { // can go 1 down
                    Moves[i] |= Bitmask << 10;
                }
            }
        }

        return Moves;
    }
}
