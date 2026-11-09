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
    // private ulong OccupationBitboard = 0;
    // private ulong WhiteBitboard = 0;
    // private ulong BlackBitboard = 0;
    private GameData GameData = new();
    // Selected Piece Vars
    // private ulong[] PieceMoveBitmasks = new ulong[64];
    ulong SelectedPieceMoves = 0;
    int SelectedTileInt = 0;
    PieceId SelectedPieceId = 0;
    ulong SelectedPieceBitmask = 0;
    // Piece Shader Vars
    private int[] PiecePositions = new int[64];
    private float[] PieceOffsets = new float[64];
    // Tile Vars
    private int[] TileStates = new int[64];
    // Gamestate Vars
    private GameState CurrentGameState = GameState.Loading;
    private int TurnCount = 0;
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

        // ResetGame();

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

    // --- Signal Funcs ---
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
    // * Input Funcs
    private void OnLMB(int TileInt) {
        PieceId PieceID = PieceManager.GetPieceId(TileInt, GameData.Bitboard);

        ulong Bitmask = Bitmath.GetBitmask(TileInt);

        GD.Print("Tile Int: ", TileInt);
        GD.Print("Piece Int: ", PieceID);

        if (CurrentGameState == GameState.NoSelection) {
            // Try to select Piece
            if (!PieceManager.IsPiece(PieceID) || PieceManager.IsEnemy(PieceID, GameData.TurnColor)) {
                // Not a valid Selection
                return;
            }

            SelectPiece(PieceID, TileInt, Bitmask);

            // Highlight Possible Moves
            TileStates[TileInt] = (int)TileHighlight.Selected;
            CurrentGameState = GameState.PieceSelected;
        } else {
            // Try to Move Piece
            ulong MoveBitmask = Bitmask & SelectedPieceMoves;

            if (MoveBitmask != 0) {
                MovePiece(PieceID, MoveBitmask, Bitmask);

                FinishTurn();
            }

            // Unhighlight Possible Moves
            CurrentGameState = GameState.NoSelection;
            TileManager.RemoveTileHighlight(TileStates, (int)TileHighlight.Moves);
        }

        UpdateShaderData();
    }

    // * Gameplay Funcs
    private void SelectPiece(PieceId PieceID, int TileInt, ulong Bitmask) {
        // Selects the Piece on the given Tile

        SelectedPieceMoves = GameData.PieceMoves[TileInt];
        SelectedPieceId = PieceID;
        SelectedPieceBitmask = Bitmask;
    }
    private void MovePiece(PieceId PieceID, ulong MoveBitmask, ulong Bitmask) {
        // Moves the given Piece to the given Tile

        // Clear Target Cell
        if ((int)PieceID >= 0) {
            GameData.Bitboard[(int)PieceID] ^= MoveBitmask;
        }

        // Move Piece
        GameData.Bitboard[(int)SelectedPieceId] ^= SelectedPieceBitmask;
        GameData.Bitboard[(int)SelectedPieceId] |= Bitmask;
    }

    // * Gamestate Funcs
    private void FinishTurn() {
        // "Finishes" the current turn and prepares everything for the Next Turn

        // Update Turn Count and Color
        TurnCount += 1;
        GameData.TurnColor = (TeamColor)(TurnCount & 1);
        // Update Game Data
        UpdateGameData();
        (GameData.PieceMoves, GameData.ThreatenedTiles) = MoveManager.MakePieceMoves(GameData.Bitboard, GameData.TurnColor, GameData.AllOccupations, GameData.WhiteOccupations, GameData.BlackOccupations);
    }
    private void UpdateGameData() {
        // Updates Data Related to GameState and Pieces

        // Update Occupation Boards
        GameData.WhiteOccupations = MakeOccupationBoard(TeamColor.White, GameData.Bitboard);
        GameData.BlackOccupations = MakeOccupationBoard(TeamColor.Black, GameData.Bitboard);
    }
    private ulong MakeOccupationBoard(TeamColor Color, ulong[] Bitboard) {
        ulong NewOccupationBoard = 0;

        int ColorOffset = 6 * (int)Color;

        for (int i = ColorOffset; i < ColorOffset + 6; i++) {
            NewOccupationBoard |= Bitboard[i];
        }

        return NewOccupationBoard;
    }

    private void UpdateShaderData() {
        // Updates Data related to the Shader

        if (CurrentGameState == GameState.NoSelection) {
            // Update Piece Array for Shader
            for (int i = 0; i < 64; i++) {
                PieceId PieceID = PieceManager.GetPieceId(i, GameData.Bitboard);

                PiecePositions[i] = (int)PieceID;
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
        GameData = new();
    }
}
