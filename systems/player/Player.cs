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
        if (!MouseInput.Pressed) {
            return;
        }

        int Click = MouseInput.ButtonIndex switch {
            MouseButton.Left => (int)Clicktype.Left,
            MouseButton.Right => (int)Clicktype.Right,
            MouseButton.Middle => (int)Clicktype.Middle,
            _ => (int)Clicktype.None
        };

        EmitSignal(SignalName.MouseStateChanged, MouseBoardPos, Click);
    }
    private void HandleKeyInput(InputEventKey KeyInput) {
        if (KeyInput.IsActionReleased("_input_esc")) {
            EmitSignal(SignalName.ToggleEscMenu);
        }
    }
}


