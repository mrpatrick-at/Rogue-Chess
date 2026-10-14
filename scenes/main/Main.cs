using Godot;
using Godot.Collections;
using System;

using Chess.systems.bitmath;
using Chess.systems.renderer;
using Chess.systems.game.consts;
using Chess.systems.game.piece;
using Chess.systems.game.piece.enums;

namespace Chess.scenes.main;
// --- Enums ---
public partial class Main : Node2D {
    // --- Consts ---
    // --- Exports ---
    // --- Public Vars ---
    // --- Private Vars ---
    private ulong[] Bitboard = new ulong[12];
    private ulong[] QueuedBitboard = new ulong[12];
    private ulong OccupationBoard = new();

    private int[] PiecePositions = new int[64];
    private Dictionary PieceObjs = [];
    private int TurnAmount = 0;
    private PieceColor TurnColor = PieceColor.White;
    // Objs
    // private Camera2D CamObj;
    private Renderer RendererObj;
    private Player PlayerObj;
    // --- Override Funcs ---
    public override void _Ready() {
        // PlayerObj = new() {
        //     Name = "PlayerObj"
        // };
        // this.AddChild(PlayerObj);

        // PlayerObj.DirectionRequest += OnDirectionRequest;

        // CamObj = new() {
        //     Zoom = new Vector2(3, 3),
        //     Name = "CamObj"
        // };
        // this.AddChild(CamObj);

        RendererObj = new() {
            Name = "RendererObj",
        };
        this.AddChild(RendererObj);

        ResetGame();
    }
    public override void _Process(double delta) {
        UpdateGame();
    }

    // --- Public Funcs ---

    // --- Private Funcs ---
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
                ulong Bitmask = BitMath.GetBitmask(k);

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
