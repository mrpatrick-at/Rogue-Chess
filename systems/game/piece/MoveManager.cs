using Godot;
using Godot.Collections;
using System;

using Chess.systems.math;
using Chess.systems.game.consts;
using Chess.systems.game.board;
using Chess.systems.game.piece.enums;
using System.Security.Authentication.ExtendedProtection;
using Chess.OldConsts;

namespace Chess.systems.game.piece;
public static partial class MoveManager {
    // --- Private Vars ---
    private static readonly ulong[] KingMoves = PreCalcKingMoves();
    private static readonly ulong[] KnightMoves = PreCalcKnightMoves();
    // --- Public Funcs ---
    public static ulong[] MakePieceMoves(ulong[] Bitboard, PieceColor TurnColor, ulong OccupationBitboard, ulong WhiteBitboard, ulong BlackBitboard) {
        ulong[] Moves = new ulong[64];

        ulong FriendlyBitboard = TurnColor == PieceColor.White ? WhiteBitboard : BlackBitboard;
        ulong EnemyBitboard = OccupationBitboard & ~FriendlyBitboard;

        for (int i = 0; i < 64; i++) {
            ulong Bitmask = Bitmath.GetBitmask(i);
            PieceType PieceType = PieceManager.GetPieceType(i, Bitboard);
            MoveType MoveType = PieceManager.GetMoveType(PieceType);

            Moves[i] = MoveType switch {
                MoveType.Pawn => GetPawnMoves(Bitmask, TurnColor, OccupationBitboard, EnemyBitboard),
                MoveType.Rook => GetSlideMoves(Bitmask, OccupationBitboard, (int)SlideType.Rook),
                MoveType.Knight => KnightMoves[i],
                MoveType.Bishop => GetSlideMoves(Bitmask, OccupationBitboard, (int)SlideType.Bishop),
                MoveType.Queen => GetSlideMoves(Bitmask, OccupationBitboard, (int)SlideType.Rook) | GetSlideMoves(Bitmask, OccupationBitboard, (int)SlideType.Bishop),
                MoveType.King => KingMoves[i],
                _ => 0
            };

            Moves[i] &= ~FriendlyBitboard;

            GD.Print(Moves[i]);
        }

        return Moves;
    }
    public static ulong GetPieceMoves(int TileInt, PieceType PieceType, ulong Bitmask, ulong OccupationBitboard, ulong WhiteBitboard, ulong BlackBitboard) {
        MoveType MoveType = PieceManager.GetMoveType(PieceType);
        PieceColor Color = PieceManager.GetPieceColor(PieceType);

        ulong FriendlyBitboard = Color == 0 ? WhiteBitboard : BlackBitboard;
        ulong EnemyBitboard = OccupationBitboard & ~FriendlyBitboard;

        // ulong Bitmask = Bitmath.GetBitmask(TileInt);

        ulong Moves = MoveType switch {
            MoveType.Pawn => GetPawnMoves(Bitmask, Color, OccupationBitboard, EnemyBitboard),
            MoveType.Rook => GetSlideMoves(Bitmask, OccupationBitboard, (int)SlideType.Rook),
            MoveType.Knight => KnightMoves[TileInt],
            MoveType.Bishop => GetSlideMoves(Bitmask, OccupationBitboard, (int)SlideType.Bishop),
            MoveType.Queen => GetSlideMoves(Bitmask, OccupationBitboard, (int)SlideType.Rook) | GetSlideMoves(Bitmask, OccupationBitboard, (int)SlideType.Bishop),
            MoveType.King => KingMoves[TileInt],
            _ => 0
        };

        return Moves &= ~FriendlyBitboard;
    }
    // --- Private Funcs ---
    private static ulong GetPawnMoves(ulong Bitmask, PieceColor Color, ulong OccupationBitboard, ulong EnemyBitboard) {
        ulong Moves;
        ulong CaptureMask;

        ulong NotLeftBorderPawns = Bitmask & ~72340172838076673UL;
        ulong NotRightBorderPawns = Bitmask & ~9259542123273814144UL;
        ulong NeighborMask = (NotLeftBorderPawns << 1 | NotRightBorderPawns >> 1) & EnemyBitboard;

        switch (Color) {
            case PieceColor.White:
                Moves = Bitmask >> 8;
                CaptureMask = NotLeftBorderPawns >> 9;
                CaptureMask |= NotRightBorderPawns >> 7;

                Moves |= (NeighborMask >> 8) & ~OccupationBitboard; // EnPassant

                if ((Bitmask & 71776119061217280) == Bitmask) { // white in start pos
                    Moves |= Bitmask >> 16;
                }
                break;

            default:
                Moves = Bitmask << 8;
                CaptureMask = NotLeftBorderPawns << 7;
                CaptureMask |= NotRightBorderPawns << 9;

                Moves |= (NeighborMask << 8) & ~OccupationBitboard; // EnPassant

                if ((Bitmask & 65280) == Bitmask) { // black in start pos
                    Moves |= Bitmask << 16;
                }
                break;
        }

        Moves &= ~OccupationBitboard;
        Moves |= CaptureMask & OccupationBitboard;
        return Moves;
    }
    private static ulong GetSlideMoves(ulong Bitmask, ulong OccupationBitboard, ulong slide_type) {
        ulong Moves = 0UL;
        int TileInt = BoardManager.GetTileIntFromBitmask(Bitmask);
        Vector2I Coord = BoardManager.GetVec2FromTileInt(TileInt);

        int left_tiles = Coord.X;
        int right_tiles = 7 - Coord.X;

        int up_tiles = Coord.Y;
        int down_tiles = 7 - Coord.Y;

        if (slide_type == (int)SlideType.Rook) {
            for (int x = 0; x < left_tiles; x++) {
                ulong step_bitmask = Bitmask >> (x + 1);
                Moves |= step_bitmask;
                if ((step_bitmask & OccupationBitboard) != 0) {
                    break;
                }
            }
            for (int x = 0; x < right_tiles; x++) {
                ulong step_bitmask = Bitmask << (x + 1);
                Moves |= step_bitmask;
                if ((step_bitmask & OccupationBitboard) != 0) {
                    break;
                }
            }
            for (int y = 0; y < up_tiles; y++) {
                ulong step_bitmask = Bitmask >> ((y + 1) << 3);
                Moves |= step_bitmask;
                if ((step_bitmask & OccupationBitboard) != 0) {
                    break;
                }
            }
            for (int y = 0; y < down_tiles; y++) {
                ulong step_bitmask = Bitmask << ((y + 1) << 3);
                Moves |= step_bitmask;
                if ((step_bitmask & OccupationBitboard) != 0) {
                    break;
                }
            }
        } else {
            for (int xy = 0; xy < left_tiles; xy++) {
                if (xy < up_tiles) {
                    ulong step_bitmask = Bitmask >> ((xy + 1) * 9);
                    Moves |= step_bitmask;
                    if ((step_bitmask & OccupationBitboard) != 0) {
                        break;
                    }
                }
                if (xy < down_tiles) {
                    ulong step_bitmask = Bitmask << ((xy + 1) * 7);
                    Moves |= step_bitmask;
                    if ((step_bitmask & OccupationBitboard) != 0) {
                        break;
                    }
                }
            }
            for (int yx = 0; yx < right_tiles; yx++) {
                if (yx < up_tiles) {
                    ulong step_bitmask = Bitmask >> ((yx + 1) * 7);
                    Moves |= step_bitmask;
                    if ((step_bitmask & OccupationBitboard) != 0) {
                        break;
                    }
                }
                if (yx < down_tiles) {
                    ulong step_bitmask = Bitmask << ((yx + 1) * 9);
                    Moves |= step_bitmask;
                    if ((step_bitmask & OccupationBitboard) != 0) {
                        break;
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
