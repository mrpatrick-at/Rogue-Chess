using Chess.Consts;
using Godot;
using Godot.Collections;
using System;
using System.Collections.Generic;
using System.Linq;
public partial class Player : Node2D
{
// enums
// consts
// exports
// public vars
public Camera2D camera;
public Board board;
public int IndexBelowMouse = 0;
public List<int> HighlightedTiles = [];
public bool IsPieceSelected = false;
public int SelectedPieceIndex = 0;
public ulong SelectedPieceMoves;
// private vars
// onready vars
// built-in override methods
	// Called when the node enters the scene tree for the first time.
	public override void _Ready() {
		camera = this.GetViewport().GetCamera2D();
		board = GetNode<Board>("../BoardManager/Board");
	}

	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Process(double delta) {
		IndexBelowMouse = board.GetTileIndex();
		if (IsPieceSelected) {
			return;
		}

		int Index = IndexBelowMouse;
		if (board.IsValidIndex(Index) && !HighlightedTiles.Contains(Index)) {
			board.HighlightTile(Index, 1);
			HighlightedTiles.Add(Index);

			if (!board.IsEmpty(Index)) {
				PieceObj piece = (PieceObj)board.PieceObjs[Index];
				piece.highlight();
				// highlighted_pieces.Add(Index);
			}
		}
		foreach (int tile in HighlightedTiles) {
			if (tile != Index) {
				board.UnhighlightTile(tile);
				if (board.PieceObjs.ContainsKey(tile)) {
					PieceObj piece = (PieceObj)board.PieceObjs[tile];
					piece.unhighlight();
				}
			}
		}
		HighlightedTiles.RemoveAll(id => id != Index);

	}

    public override void _Input(InputEvent @event) {
        base._Input(@event);
		if (@event is InputEventMouse MouseInput) {
			MouseButtons(MouseInput);
		}
    }
// public methods

// private methods
	private void MouseButtons(InputEventMouse MouseInput) {
		if (MouseInput.IsActionPressed("_input_mouse_left")) {
			int Index = IndexBelowMouse;
			if (board.IsValidIndex(Index)) {
				if (!IsPieceSelected) {
					if (board.IsEmpty(Index) || board.IsEnemy(Index)) {
						return;
					}
					SelectedPieceIndex = Index;
					SelectedPieceMoves = board.GetPieceMoves(Index);
					IsPieceSelected = true;

					// Highlight Tiles
					int EnemyColor = 1 & ~board.TurnColor;
					ulong EnemyPieces = board.GetOccupiedBitBoard(EnemyColor);
					for (int i = 0; i < 64; i++) {
						ulong Bitmask = 1UL << i;
						if ((SelectedPieceMoves & Bitmask) != 0) {
							HighlightedTiles.Add(i);
							if ((EnemyPieces & Bitmask) != 0) {
								board.HighlightTile(i, (int)Tile.Highlight.Capture);
								continue;
							}
							board.HighlightTile(i, (int)Tile.Highlight.Move);
						}
					}

				} else {
					if ((SelectedPieceMoves & board.GetBitmask(Index)) != 0) {
						board.MovePiece(SelectedPieceIndex, Index);
					}
					IsPieceSelected = false;
				}
			}


		}
		if (MouseInput.IsActionPressed("_input_mouse_right")) {
			if (board.IsValidIndex(IndexBelowMouse)) {
				Vector2I coord = board.GetVec2FromIndex(IndexBelowMouse);
				GD.Print($"PLAYER- Index: {IndexBelowMouse}, Coord: {coord}");
				int piece_int = board.GetPieceInt(IndexBelowMouse);
				if (piece_int != -1) {
					String piece_string = board.GetPieceString(piece_int);
					GD.Print($"PLAYER- Piece Type: {piece_string}");
				}
			} else {
				GD.Print($"PLAYER- Tile not in Board");
			}
		}
		if (MouseInput.IsActionPressed("_input_mouse_middle")) {
			GD.Print("PLAYER- Middle Mouse Button Detected");
		}

	}
}


