// GameData.cs

using Chess.systems.game.piece;
using Chess.systems.game.enums;

namespace Chess.systems.game.data.structs;
public struct GameData {
    // --- Bitboards ---
    public ulong[] Bitboard = DataManager.ResetPieces(); // Current Positions of all Pieces
    public ulong[] PieceMoves; // Moves for all Pieces
    // --- Occupation Boards --- (1 Bit for each Tile)
    public readonly ulong AllOccupations => WhiteOccupations | BlackOccupations; // Tiles Occupied Pieces of any Color
    public readonly ulong WhiteOccupations => DataManager.MakeOccupationBoard(TeamColor.White, Bitboard); // Tiles Occupied by White Pieces
    public readonly ulong BlackOccupations => DataManager.MakeOccupationBoard(TeamColor.Black, Bitboard); // Tiles Occupied by Black Pieces
    public ulong ThreatenedTiles = new(); // Tiles Threatened by Enemy Pieces
    // --- GameState Vars ---
    public TeamColor TurnColor = TeamColor.White; // Whos Turn it is currently

    public GameData() {
        (PieceMoves, ThreatenedTiles) = MoveManager.MakePieceMoves(Bitboard, TurnColor, AllOccupations, WhiteOccupations, BlackOccupations);
    }
}
