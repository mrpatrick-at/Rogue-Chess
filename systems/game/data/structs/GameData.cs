// GameData.cs

using Chess.systems.game.piece;
using Chess.systems.game.enums;

namespace Chess.systems.game.data.structs;
public struct GameData() {
    // --- Bitboards ---
    public ulong[] Bitboard = DataManager.ResetPieces(); // Current Positions of all Pieces
    // --- Move Data ---
    private readonly (ulong[] PieceMoves, ulong ThreatenedTiles) MoveData => MoveManager.MakePieceMoves(Bitboard, TurnColor, AllOccupations, WhiteOccupations, BlackOccupations);
    public readonly ulong[] PieceMoves => MoveData.PieceMoves; // Moves for all Pieces
    public readonly ulong ThreatenedTiles => MoveData.ThreatenedTiles; // Tiles Threatened by Enemy Pieces
    // --- Occupation Boards --- (1 Bit for each Tile)
    public readonly ulong AllOccupations => WhiteOccupations | BlackOccupations; // Tiles Occupied Pieces of any Color
    public readonly ulong WhiteOccupations => DataManager.MakeOccupationBoard(TeamColor.White, Bitboard); // Tiles Occupied by White Pieces
    public readonly ulong BlackOccupations => DataManager.MakeOccupationBoard(TeamColor.Black, Bitboard); // Tiles Occupied by Black Pieces
    // public ulong WhiteOccupations; // Tiles Occupied by White Pieces
    // public ulong BlackOccupations; // Tiles Occupied by Black Pieces

    // --- GameState Vars ---
    public int TurnCount = 0;
    public readonly TeamColor TurnColor => (TeamColor)(TurnCount & 1); // Whose Turn it currently is
    public readonly bool InCheck => (Bitboard[5 + 6 * (int)TurnColor] & ThreatenedTiles) != 0;

    // public GameData() {
    //     (PieceMoves, ThreatenedTiles) = MoveManager.MakePieceMoves(Bitboard, TurnColor, AllOccupations, WhiteOccupations, BlackOccupations);
    // }
}
