using Godot;
using System;

using Chess.systems.game.consts;
using Chess.systems.game.tile.enums;

namespace Chess.systems.game.tile;
public static partial class TileManager {
    // --- Public Vars ---
    // --- Private Vars ---
    // --- Public Funcs ---
    public static int GetTileInt(Vector2I TileCoord) {
        return TileCoord.X + TileCoord.Y * Consts.BoardSize.X;
    }

    public static int[] RemoveTileState(int[] TileStates, int TargetState) {
        for (int i = 0; i < TileStates.Length; i++) {
            if (TileStates[i] == TargetState) {
                TileStates[i] = (int)TileState.None;
            }
        }

        return TileStates;
    }
    // --- Private Funcs ---
}
