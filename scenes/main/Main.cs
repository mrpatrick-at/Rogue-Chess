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
using Chess.systems.game.gamestate.enums;
using Chess.systems.game.gamestate.structs;
using Vector2 = Godot.Vector2;


namespace Chess.scenes.main;
// --- Enums ---
public partial class Main : Node2D {
    // --- Consts ---
    // --- Exports ---
    // --- Public Vars ---
    // --- Private Vars ---
    // Bitboard Vars
    // private ulong[] QueuedBitboard = new ulong[12];
    // private ulong OccupationBitboard = 0;
    // private ulong WhiteBitboard = 0;
    // private ulong BlackBitboard = 0;
    private GameData GameData = new();
    // Selected Piece Vars
    // private ulong[] PieceMoveBitmasks = new ulong[64];
    ulong SelectedPieceMoves = 0;
    int SelectedTileInt = 0;
    PieceType SelectedPieceType = 0;
    ulong SelectedPieceBitmask = 0;
    // Piece Shader Vars
    private int[] PiecePositions = new int[64];
    private float[] PieceOffsets = new float[64];
    // Tile Vars
    private int[] TileStates = new int[64];
    // Gamestate Vars
    private GameState CurrentGameState = GameState.Loading;
    private int TurnAmount = 0;
    // private PieceColor TurnColor = PieceColor.White;
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

        UpdateGameData();

        UpdateShaderData();

    }
    public override void _Process(double delta) {
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
        PieceType PieceType = PieceManager.GetPieceType(TileInt, GameData.Bitboard);

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
    private void SelectPiece(PieceType PieceType, int TileInt, ulong Bitmask) {
        // Selects the Requested Piece
        if (!PieceManager.IsPiece(PieceType) || PieceManager.IsEnemy(PieceType, GameData.TurnColor)) {
            // Not a valid Selection
            return;
        }

        SelectedPieceMoves = GameData.PieceMoves[TileInt];
        SelectedPieceType = PieceType;
        SelectedPieceBitmask = Bitmask;

        TileStates[TileInt] = (int)TileHighlight.Selected;
        CurrentGameState = GameState.PieceSelected;

        UpdateShaderData();
    }
    private void TryMovePiece(PieceType PieceType, ulong Bitmask) {
        // Quits out of Selection and if Move Valid Moves
        ulong MoveBitmask = Bitmask & SelectedPieceMoves;

        if (MoveBitmask != 0) {
            // Valid Move

            // Clear Target Cell
            if ((int)PieceType >= 0) {
                GameData.Bitboard[(int)PieceType] ^= MoveBitmask;
            }

            // Move Piece
            GameData.Bitboard[(int)SelectedPieceType] ^= SelectedPieceBitmask;
            GameData.Bitboard[(int)SelectedPieceType] |= Bitmask;

            // Update GameState
            TurnAmount += 1;
            GameData.TurnColor = (PieceColor)(TurnAmount & 1);
            UpdateGameData();
            GameData.PieceMoves = MoveManager.MakePieceMoves(GameData.Bitboard, GameData.TurnColor, GameData.AllOccupations, GameData.WhiteOccupations, GameData.BlackOccupations);
        }

        CurrentGameState = GameState.NoSelection;

        // Update Shader
        TileManager.RemoveTileHighlight(TileStates, (int)TileHighlight.Moves);

        UpdateShaderData();
    }

    // Gamestate Funcs
    private void UpdateGameData() {
        // Updates Data Related to GameState and Pieces

        // Update Occupation Boards
        ulong NewWhiteBitboard = 0;
        ulong NewBlackBitboard = 0;

        for (int i = 0; i < 12; i++) {
            if (i < 6) {
                NewWhiteBitboard |= GameData.Bitboard[i];
            } else {
                NewBlackBitboard |= GameData.Bitboard[i];
            }
        }

        GameData.WhiteOccupations = NewWhiteBitboard;
        GameData.BlackOccupations = NewBlackBitboard;

    }
    private void UpdateShaderData() {
        // Updates Data related to the Shader

        if (CurrentGameState == GameState.NoSelection) {
            // Update Piece Array for Shader
            for (int i = 0; i < 64; i++) {
                PieceType PieceType = PieceManager.GetPieceType(i, GameData.Bitboard);

                PiecePositions[i] = (int)PieceType;
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
        // // Resets Game to Starting State
        // GameData.QueuedBitboard = PieceManager.ResetPieces();

        // Generates The Moves for the Start
        GameData.PieceMoves = MoveManager.MakePieceMoves(GameData.QueuedBitboard, GameData.TurnColor, GameData.AllOccupations, GameData.WhiteOccupations, GameData.BlackOccupations);
    }
}
