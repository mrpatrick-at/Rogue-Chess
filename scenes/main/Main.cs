using Godot;
using Godot.Collections;
using System;

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

namespace Chess.scenes.main;
// --- Enums ---
public partial class Main : Node2D {
    // --- Consts ---
    // --- Exports ---
    // --- Public Vars ---
    // --- Private Vars ---
    // Piece Vars
    private ulong[] Bitboard = new ulong[12];
    private ulong[] QueuedBitboard = new ulong[12];
    private ulong OccupationBoard = new();
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

        CurrentGameState = GameState.Waiting;
    }
    public override void _Process(double delta) {
        UpdateGame();
    }

    public void OnMouseStateChanged(Vector2I MouseBoardPos, Clicktype Clicktype) {

        int TileInt = TileManager.GetTileInt(MouseBoardPos);

        if (MouseBoardPos == new Vector2I(-1, -1)) {
            // Outside Board
            return;
        }

        TileManager.RemoveTileState(TileStates, (int)TileState.Highlighted);

        switch (Clicktype) {
            case Clicktype.None:
                TileStates[TileInt] = (int)TileState.Highlighted;
                break;

            case Clicktype.Left:
                TileManager.RemoveTileState(TileStates, (int)TileState.Selected);
                TileStates[TileInt] = (int)TileState.Selected;
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

        if (!PieceManager.IsPiece(PieceInt) || PieceManager.IsEnemy(PieceInt, TurnColor)) {
            // No Piece
            return;
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
        for (int i = 0; i < 64; i++) {
            PiecePositions[i] = -1;
        }

        // Check if Piece Data Updated and act
        for (int i = 0; i < Bitboard.Length; i++) {
            if (QueuedBitboard[i] == Bitboard[i]) {
                // No Change in PieceBoard
                continue;
            }

            // Update Piece Positions
            for (int k = 0; k < 64; k++) {
                ulong Bitmask = Bitmath.GetBitmask(k);

                if ((QueuedBitboard[i] & Bitmask) == 0) {
                    // No Piece on Tile
                    continue;
                }

                PiecePositions[k] = i;
            }

            // Update Bitboard
            // Bitboard[i] = QueuedBitboard[i];
        }

        RendererObj.UpdatePiecePosistions(PiecePositions);
    }
    private void ResetGame() {
        // Resets Game to Starting State
        QueuedBitboard = PieceManager.ResetPieces();
        for (int i = 0; i < Bitboard.Length; i++) {

            GD.Print(QueuedBitboard[i]);
        }
    }
}
