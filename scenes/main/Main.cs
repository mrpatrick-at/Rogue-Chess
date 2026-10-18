using Godot;
using Godot.Collections;
using System;
using System.Numerics;

using Chess.systems.math;
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
    int SelectedTileInt = 0;
    PieceType SelectedPieceType = 0;
    ulong SelectedPieceBitmask = 0;
    private int[] PiecePositions = new int[64];
    private float[] PieceOffsets = new float[64];
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
    // Animation Vars
    private float HoverAnimSpeedMod = 10;
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

        // Animations
        for (int i = 0; i < PieceOffsets.Length; i++) {

            if (i == SelectedTileInt) {
                // Hovered Piece
                PieceOffsets[i] = MathF.Min(PieceOffsets[i] + EasingFuncs.EaseOutCubic((float)delta * HoverAnimSpeedMod), 2F);
                continue;
            }

            // Other Pieces
            PieceOffsets[i] = MathF.Max(PieceOffsets[i] - EasingFuncs.EaseOutCubic((float)delta * HoverAnimSpeedMod), 0F);
        }
        // Update Shader
        RendererObj.UpdatePieceOffsets(PieceOffsets);

    }

    public void OnMouseStateChanged(Vector2I MouseBoardPos, Clicktype Clicktype) {

        TileManager.RemoveTileHighlight(TileStates, (int)TileHighlight.Highlighted);

        if (MouseBoardPos == new Vector2I(-1, -1)) {
            // Outside Board
            return;
        }

        int TileInt = TileManager.GetTileInt(MouseBoardPos);

        switch (Clicktype) {
            case Clicktype.None:
                if (CurrentGameState == GameState.NoSelection) {
                    TileStates[TileInt] = (int)TileHighlight.Highlighted;
                }

                SelectedTileInt = TileInt;
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
        PieceType PieceType = PieceManager.GetPieceType(TileInt, Bitboard);

        ulong Bitmask = Bitmath.GetBitmask(TileInt);

        GD.Print("Tile Int: ", TileInt);
        GD.Print("Piece Int: ", PieceType);

        if (CurrentGameState == GameState.NoSelection) {
            SelectPiece(PieceType, TileInt, Bitmask);
        } else {
            TryMovePiece(PieceType, Bitmask);
        }
    }

    // Gameplay Funcs
    public void SelectPiece(PieceType PieceType, int TileInt, ulong Bitmask) {
        // Selects the Requested Piece
        if (!PieceManager.IsPiece(PieceType) || PieceManager.IsEnemy(PieceType, TurnColor)) {
            // Not a valid Selection
            return;
        }

        SelectedPieceMoves = MoveManager.GetPieceMoves(TileInt, PieceType, Bitmask, OccupationBitboard, WhiteBitboard, BlackBitboard);
        SelectedPieceType = PieceType;
        SelectedPieceBitmask = Bitmask;

        TileStates[TileInt] = (int)TileHighlight.Selected;
        CurrentGameState = GameState.PieceSelected;
    }
    public void TryMovePiece(PieceType PieceType, ulong Bitmask) {
        // Quits out of Selection and if Move Valid Moves
        ulong MoveBitmask = Bitmask & SelectedPieceMoves;

        if (MoveBitmask != 0) {
            // Valid Move

            // Clear Target Cell
            if ((int)PieceType >= 0) {
                QueuedBitboard[(int)PieceType] ^= MoveBitmask;
            }

            // Move Piece
            QueuedBitboard[(int)SelectedPieceType] ^= SelectedPieceBitmask;
            QueuedBitboard[(int)SelectedPieceType] |= Bitmask;
        }

        TileManager.RemoveTileHighlight(TileStates, (int)TileHighlight.Moves);
        CurrentGameState = GameState.NoSelection;
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
