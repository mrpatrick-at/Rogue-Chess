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
public int index_below_mouse = 0;
public List<int> highlighted_tiles = new List<int>();
public bool selected_tile = false;
public int selected_piece_index = 0;
public ulong selected_piece_moves;
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
		index_below_mouse = board.GetTileIndex();
		if (selected_tile) {
			return;
		}

		int index = index_below_mouse;
		if (board.IsValidIndex(index) && !highlighted_tiles.Contains(index)) {
			board.HighlightTile(index, 1);
			highlighted_tiles.Add(index);

			if (!board.IsEmpty(index)) {
				PieceObj piece = (PieceObj)board.piece_objs[index];
				piece.highlight();
				// highlighted_pieces.Add(index);
			}
		}
		foreach (int tile in highlighted_tiles) {
			if (tile != index) {
				board.UnhighlightTile(tile);
				if (board.piece_objs.ContainsKey(tile)) {
					PieceObj piece = (PieceObj)board.piece_objs[tile];
					piece.unhighlight();
				}
			}
		}
		highlighted_tiles.RemoveAll(id => id != index);

	}

    public override void _Input(InputEvent @event) {
        base._Input(@event);
		if (@event is InputEventMouse) {
			_mouse_buttons((InputEventMouse)@event);
		}
    }
// public methods

// private methods
	private void _mouse_buttons(InputEventMouse @event) {
		if (@event.IsActionPressed("_input_mouse_left")) {
			int index = index_below_mouse;
			if (board.IsValidIndex(index)) {
				if (selected_tile == false) {
					selected_piece_index = index;
					if (!board.IsEmpty(index) && !board.IsEnemy(index)) {
						selected_piece_moves = board.GetPieceMoves(index);

						selected_tile = true;
						for (int i = 0; i < 64; i++) { // Tidy this Later
							if ((selected_piece_moves & (1UL << i)) == (1UL << i)) {
								board.HighlightTile(i, 1);
								highlighted_tiles.Add(i);
							}
						}

					}
				} else {
					if ((selected_piece_moves & board.GetBitmask(index)) != 0) {
						board.MovePiece(selected_piece_index, index);
					}
					selected_tile = false;
				}
			}


		}
		if (@event.IsActionPressed("_input_mouse_right")) {
			if (board.IsValidIndex(index_below_mouse)) {
				Vector2I coord = board.GetVec2FromIndex(index_below_mouse);
				GD.Print($"PLAYER- Index: {index_below_mouse}, Coord: {coord}");
				int piece_int = board.GetPieceIndex(index_below_mouse);
				if (piece_int != -1) {
					String piece_string = board.GetPieceString(piece_int);
					GD.Print($"PLAYER- Piece Type: {piece_string}");
				}
			} else {
				GD.Print($"PLAYER- Tile not in Board");
			}
		}
		if (@event.IsActionPressed("_input_mouse_middle")) {
			GD.Print("PLAYER- Middle Mouse Button Detected");
		}

	}
}


