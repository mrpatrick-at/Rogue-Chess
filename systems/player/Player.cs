using Godot;
using System.Collections.Generic;

using Chess.systems.game.consts;
using Chess.systems.game.board;
using Chess.systems.player.enums;

namespace Chess.systems.player;
// enums
public partial class Player : Node2D {
    // consts
    // exports
    // signals
    [Signal] public delegate void MouseStateChangedEventHandler(Vector2I MouseBoardPos, Clicktype Clicktype);
    [Signal] public delegate void ToggleEscMenuEventHandler();
    // --- Public Vars ---
    // public Board board;
    // public CenterContainer BoardContainer;
    public bool IsMenuOpen = false;
    // public int IndexBelowMouse = 0;
    public List<int> HighlightedTiles = [];
    public bool IsPieceSelected = false;
    public int SelectedPieceIndex = 0;
    public ulong SelectedPieceMoves;
    // --- Private Vars ---
    private Vector2 MousePos = Vector2.Zero;
    private Vector2I MouseBoardPos = Vector2I.Zero;
    // --- Override Methods ---
    public override void _Ready() {
        // BoardContainer = GetNode<CenterContainer>("BoardContainer");
        // board = new Board();
        // BoardContainer.AddChild(board);
    }

    // Called every frame. 'delta' is the elapsed time since the previous frame.
    public override void _Process(double delta) {
        MousePos = GetGlobalMousePosition();

        Vector2I NewMouseBoardPos = new(-1, -1);

        if (BoardManager.IsVecInsideBoard(MousePos)) {
            NewMouseBoardPos = (Vector2I)MousePos / Consts.CellPixelSize;
        }

        if (NewMouseBoardPos != MouseBoardPos) {
            EmitSignal(SignalName.MouseStateChanged, NewMouseBoardPos, (int)Clicktype.None);
        }

        MouseBoardPos = NewMouseBoardPos;

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

    public override void _Input(InputEvent @event) {
        base._Input(@event);
        if (@event is InputEventMouseButton MouseInput) {
            HandleMouseInput(MouseInput);
        }
        if (@event is InputEventKey KeyInput) {
            HandleKeyInput(KeyInput);
        }
    }
    // public void _OnMenuStateChanged(bool TmpIsMenuOpen) {
    //     IsMenuOpen = TmpIsMenuOpen;
    //     GD.Print("Menu State Changed");
    // }
    // public methods

    // private methods
    private void HandleMouseInput(InputEventMouseButton MouseInput) {
        // if (!board.IsValidIndex(IndexBelowMouse)) {
        //     GD.Print($"PLAYER- Tile not in Board");
        //     return;
        // }
        // int Index = IndexBelowMouse;

        GD.Print("PLAYER- Mouse Clicked at: ", MousePos);

        if (MouseInput.IsActionPressed("_input_mouse_left")) {
            EmitSignal(SignalName.MouseStateChanged, MouseBoardPos, (int)Clicktype.Left);
            // if (!IsPieceSelected) {
            //     if (board.IsEmpty(Index) || board.IsEnemy(Index)) {
            //         return;
            //     }
            //     SelectedPieceIndex = Index;
            //     SelectedPieceMoves = board.GetPieceMoves(Index);
            //     IsPieceSelected = true;

            //     // Highlight Tiles
            //     int EnemyColor = 1 & ~board.TurnColor;
            //     ulong EnemyPieces = board.GetOccupiedBitBoard(EnemyColor);
            //     int[] HighlightTiles = new int[64];
            //     HighlightTiles[Index] = (int)Tile.Highlight.Hover;
            //     for (int i = 0; i < 64; i++) {
            //         ulong Bitmask = 1UL << i;
            //         if ((SelectedPieceMoves & Bitmask) != 0) {
            //             HighlightedTiles.Add(i);
            //             if ((EnemyPieces & Bitmask) != 0) {
            //                 HighlightTiles[i] = (int)Tile.Highlight.Capture;
            //                 continue;
            //             }
            //             HighlightTiles[i] = (int)Tile.Highlight.Move;
            //         }
            //     }
            //     board.SetHighlightTiles(HighlightTiles);

            // } else {
            //     if ((SelectedPieceMoves & board.GetBitmask(Index)) != 0) {
            //         board.MovePiece(SelectedPieceIndex, Index);
            //     }
            //     IsPieceSelected = false;
            // }
        }
        if (MouseInput.IsActionPressed("_input_mouse_right")) {
            EmitSignal(SignalName.MouseStateChanged, MouseBoardPos, (int)Clicktype.Right);

            // Vector2I coord = board.GetVec2FromIndex(Index);
            // GD.Print($"PLAYER- Index: {Index}, Coord: {coord}");
            // int piece_int = board.GetPieceInt(Index);
            // if (piece_int != -1) {
            //     String piece_string = board.GetPieceString(piece_int);
            //     GD.Print($"PLAYER- Piece Type: {piece_string}");
            // }
        }
        if (MouseInput.IsActionPressed("_input_mouse_middle")) {
            EmitSignal(SignalName.MouseStateChanged, MouseBoardPos, (int)Clicktype.Middle);
        }

    }
    private void HandleKeyInput(InputEventKey KeyInput) {
        if (KeyInput.IsActionReleased("_input_esc")) {
            EmitSignal(SignalName.ToggleEscMenu);
        }
    }
}


