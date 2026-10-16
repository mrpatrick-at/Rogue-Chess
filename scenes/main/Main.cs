using Godot;
using Godot.Collections;
using System;
using System.Numerics;

using Chess.systems.bitmath;
using Chess.systems.renderer;
using Chess.systems.player;
using Chess.systems.player.enums;
using Chess.systems.game.consts;
using Chess.systems.game.piece;
using Chess.systems.game.piece.enums;
using Chess.systems.game.tile;
using Chess.systems.game.tile.enums;
using Chess.systems.game;
using Vector2 = Godot.Vector2;


namespace Chess.scenes.main;
// --- Enums ---
public partial class Main : Node2D {
    // --- Consts ---
    // --- Exports ---
    // --- Public Vars ---
    // --- Private Vars ---
    // Bitboard Vars
    private ulong[] Bitboard = new ulong[12];
    private ulong[] QueuedBitboard = new ulong[12];
    private ulong OccupationBitboard = 0;
    private ulong WhiteBitboard = 0;
    private ulong BlackBitboard = 0;
    // Selected Piece Vars
    ulong SelectedPieceMoves = 0;
    int SelectedPieceTile = 0;
    int SelectedPieceType = 0;
    ulong SelectedPieceBitmask = 0;
    private int[] PiecePositions = new int[64];
    // Tile Vars
    private int[] TileStates = new int[64];
    // Gamestate Vars
    private GameState CurrentGameState = GameState.Loading;
    private int TurnAmount = 0;
    private PieceColor TurnColor = PieceColor.White;
    // Obj Vars
    private Player PlayerObj;
    private Camera2D CamObj;
    private Renderer RendererObj;
    // --- Override Funcs ---
    public override void _Ready() {
        PlayerObj = new() {
            Name = "PlayerObj"
        };
        this.AddChild(PlayerObj);

        PlayerObj.MouseStateChanged += OnMouseStateChanged;

        CamObj = new() {
            Position = Consts.BoardPixelSize / 2,
            // AnchorMode = Camera2D.AnchorModeEnum.FixedTopLeft,
            Zoom = new Vector2(3, 3),
            Name = "CamObj"
        };
        this.AddChild(CamObj);

        RendererObj = new() {
            Name = "RendererObj",
        };
        this.AddChild(RendererObj);

        ResetGame();

        CurrentGameState = GameState.NoSelection;
    }
    public override void _Process(double delta) {
        UpdateGame();
    }

    public void OnMouseStateChanged(Vector2I MouseBoardPos, Clicktype Clicktype) {

        int TileInt = TileManager.GetTileInt(MouseBoardPos);

        TileManager.RemoveTileHighlight(TileStates, (int)TileHighlight.Highlighted);

        if (MouseBoardPos == new Vector2I(-1, -1)) {
            // Outside Board
            return;
        }

        switch (Clicktype) {
            case Clicktype.None:
                if (CurrentGameState == GameState.NoSelection) {
                    TileStates[TileInt] = (int)TileHighlight.Highlighted;
                }
                break;

            case Clicktype.Left:
                TileManager.RemoveTileHighlight(TileStates, (int)TileHighlight.Selected);
                OnLMB(TileInt);
                GD.Print("PLAYER- LMB Detected at: ", MouseBoardPos);
                break;

            case Clicktype.Right:
                GD.Print("PLAYER- RMB Detected at: ", MouseBoardPos);
                break;

            case Clicktype.Middle:
                GD.Print("PLAYER- MMB Detected at: ", MouseBoardPos);
                break;
        }

        RendererObj.UpdateTileStates(TileStates);
    }

    // --- Public Funcs ---

    // --- Private Funcs ---
    // Input Funcs
    private void OnLMB(int TileInt) {
        int PieceInt = PieceManager.GetPieceInt(TileInt, Bitboard);

        ulong Bitmask = Bitmath.GetBitmask(TileInt);

        GD.Print("Tile Int: ", TileInt);
        GD.Print("Piece Int: ", PieceInt);

        if (CurrentGameState == GameState.NoSelection) {
            // No Piece currently selected.

            if (!PieceManager.IsPiece(PieceInt) || PieceManager.IsEnemy(PieceInt, TurnColor)) {
                // Not a valid Selection
                return;
            }

            SelectedPieceMoves = MoveManager.GetPieceMoves(TileInt, PieceInt, Bitmask, OccupationBitboard, WhiteBitboard, BlackBitboard);
            SelectedPieceTile = TileInt;
            SelectedPieceType = PieceInt;
            SelectedPieceBitmask = Bitmask;

            TileStates[TileInt] = (int)TileHighlight.Selected;
            CurrentGameState = GameState.PieceSelected;
        } else {
            // A Piece is already selected.

            ulong MoveBitmask = Bitmask & SelectedPieceMoves;

            if (MoveBitmask != 0) {
                // Valid Move

                // Clear Target Cell
                if (PieceInt >= 0) {
                    QueuedBitboard[PieceInt] ^= MoveBitmask;
                }

                // Move Piece
                QueuedBitboard[SelectedPieceType] ^= SelectedPieceBitmask;
                QueuedBitboard[SelectedPieceType] |= Bitmask;
            }

            TileManager.RemoveTileHighlight(TileStates, (int)TileHighlight.Moves);
            CurrentGameState = GameState.NoSelection;
        }




        // IndexBelowMouse = board.GetTileIndex();
        // if (IsPieceSelected) {
        //     return;
        // }

        // int Index = IndexBelowMouse;
        // if (!IsMenuOpen && board.IsValidIndex(Index) && !HighlightedTiles.Contains(Index)) {
        //     board.HighlightTile(Index, 1);
        //     HighlightedTiles.Add(Index);

        //     if (!board.IsEmpty(Index)) {
        //         PieceObj piece = (PieceObj)board.PieceObjs[Index];
        //         piece.highlight();
        //         // highlighted_pieces.Add(Index);
        //     }
        // }

        // foreach (int tile in HighlightedTiles) {
        //     if (tile != Index) {
        //         board.UnhighlightTile(tile);
        //         if (board.PieceObjs.ContainsKey(tile)) {
        //             PieceObj piece = (PieceObj)board.PieceObjs[tile];
        //             piece.unhighlight();
        //         }
        //     }
        // }
        // HighlightedTiles.RemoveAll(id => id != Index);
    }

    // Gamestate Funcs
    private void UpdateGame() {
        // Runs every Game Update

        if (CurrentGameState == GameState.NoSelection) {
            // Reset Occupation Board
            ulong NewOccupationBitboard = 0;
            ulong NewWhiteBitboard = 0;
            ulong NewBlackBitboard = 0;

            for (int i = 0; i < 12; i++) {
                NewOccupationBitboard |= QueuedBitboard[i];
                if (i < 6) {
                    NewWhiteBitboard |= QueuedBitboard[i];
                } else {
                    NewBlackBitboard |= QueuedBitboard[i];
                }
            }

            if (NewOccupationBitboard == OccupationBitboard) {
                // No Change on Board
                return;
            }

            OccupationBitboard = NewOccupationBitboard;
            WhiteBitboard = NewWhiteBitboard;
            BlackBitboard = NewBlackBitboard;

            // Remove Empty Tiles from PiecePositions
            for (int i = 0; i < 64; i++) {
                ulong Bitmask = Bitmath.GetBitmask(i);
                if ((OccupationBitboard & Bitmask) == 0) {
                    // Tile is Empty
                    PiecePositions[i] = -1;
                }
            }

            // Check if Piece Data Updated and act
            for (int i = 0; i < 12; i++) {
                if (QueuedBitboard[i] == Bitboard[i]) {
                    // No Change in PieceBoard
                    continue;
                }

                // Update Piece Positions
                for (int k = 0; k < 64; k++) {
                    ulong Bitmask = Bitmath.GetBitmask(k);

                    if ((QueuedBitboard[i] & Bitmask) == 0) {
                        // No Piece of this Type on the Tile
                        continue;
                    }

                    PiecePositions[k] = i;
                }

                // Update Bitboard
                Bitboard[i] = QueuedBitboard[i];
            }

            RendererObj.UpdatePiecePosistions(PiecePositions);
        } else if (CurrentGameState == GameState.PieceSelected) {
            for (int i = 0; i < 64; i++) {
                i += BitOperations.TrailingZeroCount(SelectedPieceMoves >> i);
                if (i >= 64) {
                    break;
                }
                TileStates[i] = (int)TileHighlight.Moves;
            }
            RendererObj.UpdateTileStates(TileStates);
        }
    }
    private void ResetGame() {
        // Resets Game to Starting State
        QueuedBitboard = PieceManager.ResetPieces();
    }
}
