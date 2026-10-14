using Godot;
using Godot.Collections;
using System;

using Chess.systems.renderer;
using Chess.systems.game.consts;
using Chess.systems.game.piece;
using Chess.systems.game.piece.enums;

namespace Chess.systems.bitmath;
public static partial class BitMath {
    // --- Public Funcs ---
    public static ulong GetBitmask(int Index) {
        // Gets the Bitmask for a given Index
        ulong Bitmask = 1UL << Index;
        return Bitmask;
    }
    // --- Private Funcs ---
}
