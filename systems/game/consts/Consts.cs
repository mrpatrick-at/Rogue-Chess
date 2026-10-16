// Consts.cs

using Godot;
using Godot.Collections;
using System;

namespace Chess.systems.game.consts;

public readonly struct Consts {
    public static readonly Vector2I BoardSize = new(8, 8);
    public static readonly Vector2I CellPixelSize = new(32, 32);
    public static readonly Vector2I BoardPixelSize = BoardSize * CellPixelSize;
}
public readonly struct Tile {
    public enum Highlight : int {
        None = 0,
        Hover = 1,
        Move = 2,
        Capture = 3,
        Check = 4,
    }
}
