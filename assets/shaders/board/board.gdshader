shader_type canvas_item;

// --- Board Vars ---
uniform int BoardSize = 8;

// --- Spritesheet ---
uniform sampler2D SpriteSheet : filter_nearest;

// --- Color Vars ---
uniform vec4 BrightTileColor = vec4(1, 1, 1, 1);
uniform vec4 DarkTileColor = vec4(0, 0, 0, 1);

const vec4 OverlayColors[5] = vec4[5](
	vec4(0.0, 0.0, 0.0, 0.0), // None
	vec4(0.0, 0.0, 1.0, 0.4), // Hover
	vec4(0.2, 1.0, 0.2, 0.4), // Moves
	vec4(0.9, 0.0, 0.0, 0.4), // Captures
	vec4(0.9, 0.0, 0.0, 0.4) // Checks
);

// --- Piece Vars ---
uniform int PiecePosistions[64];

uniform int TileStates[64];
uniform float PieceOffsets[64];

//void vertex() {
	//VERTEX.y *= -1.;
//}

vec4 GetSprite(int TileValue, vec2 SpriteUv) {
    vec2 SpriteSize = vec2(1.0 / 6.0, 1.0 / 2.0);

    int SpriteX = TileValue % 6;
    int SpriteY = TileValue / 6;

    vec2 SpriteIndex = vec2(
        float(SpriteX),
        float(SpriteY)
    );

    vec2 AtlasUv =
        SpriteUv * SpriteSize +
        SpriteIndex * SpriteSize;

    return texture(SpriteSheet, AtlasUv);
}

void fragment() {
	// Board Coordinates
	vec2 BoardUv = UV * float(BoardSize);
	vec2 GridPos = floor(BoardUv);
	
	// Coordinates within the current cell
	vec2 LocalUv = fract(BoardUv);
	
	// Array Index
	int ArrayIndex = int(GridPos.x + GridPos.y * 8.0);
	
	// --- Checkerboard Pattern ---
	float IsDarkTile = mod(GridPos.x + GridPos.y, 2.0);
	
	vec4 FinalColor = mix(BrightTileColor, DarkTileColor, IsDarkTile);
	
	// --- Tile Overlay ---
	int CurrentState = TileStates[ArrayIndex];
	vec4 OverlayColor = OverlayColors[CurrentState];
	
	FinalColor = mix(FinalColor, OverlayColor, OverlayColor.a);
	
	// --- Piece Sprite ---
	int PieceIndex = PiecePosistions[ArrayIndex];
	vec2 PieceUv = vec2(LocalUv.x, (LocalUv.y + (1. + PieceOffsets[ArrayIndex]) / 16.) * 0.5 + 0.5) ;
	
	// Main Piece on Cell
	if (PieceIndex >= 0 && PieceIndex < 12) {
		vec4 PieceColor = GetSprite(PieceIndex, PieceUv);
		FinalColor = mix(FinalColor, PieceColor, PieceColor.a);
	}
	
	// Overlapping Piece from Below
	
	if (GridPos.y < 7.0) {
		int BelowArrayIndex = ArrayIndex + 8;
		int BelowPiece = PiecePosistions[BelowArrayIndex];
		
		if (BelowPiece >= 0 && BelowPiece < 12) {
			vec2 BelowPieceUv = vec2(LocalUv.x, (LocalUv.y + (1. + PieceOffsets[BelowArrayIndex]) / 16.) * 0.5);
			
			vec4 PieceColor = GetSprite(BelowPiece, BelowPieceUv);
			FinalColor = mix(FinalColor, PieceColor, PieceColor.a);
		}
	}
	
	COLOR = FinalColor;
}
