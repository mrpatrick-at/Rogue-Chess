// GameData.cs

using Chess.systems.game.piece;
using Chess.systems.game.piece.enums;

namespace Chess.systems.game.gamestate.structs;
public struct GameData {
    // --- Bitboards ---
    public ulong[] Bitboard = PieceManager.ResetPieces(); // Current Positions of all Pieces
    public ulong[] PieceMoves; // Queued Positions for all Pieces
    // --- Occupation Boards --- (1 Bit for each Tile)
    public ulong AllOccupations => WhiteOccupations | BlackOccupations; // Tiles Occupied by any Piece
    public ulong WhiteOccupations = new(); // Tiles Occupied by White Pieces
    public ulong BlackOccupations = new(); // Tiles Occupied by Black Pieces
    public ulong ThreatenedTiles = new(); // Tiles Threatened by Enemy Pieces
    // --- GameState Vars ---
    public PieceColor TurnColor = PieceColor.White; // Whos Turn it is currently

    public GameData() {
        (PieceMoves, ThreatenedTiles) = MoveManager.MakePieceMoves(Bitboard, TurnColor, AllOccupations, WhiteOccupations, BlackOccupations);
    }
}
