using Godot;
using Godot.Collections;
using System;

using Chess.systems.renderer;
using Chess.systems.game.consts;
using Chess.systems.game.piece;
using Chess.systems.game.piece.enums;

namespace Chess.systems.math;
public static partial class Bitmath {
    // --- Public Funcs ---
    public static ulong GetBitmask(int TileInt) {
        // Gets the Bitmask for a given Index
        ulong Bitmask = 1UL << TileInt;
        return Bitmask;
    }
    // --- Private Funcs ---
}
