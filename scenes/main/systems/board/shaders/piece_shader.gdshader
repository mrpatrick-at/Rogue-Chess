shader_type canvas_item;

uniform vec2 Coord = vec2(0,0);
uniform float YOffset = 0;

void vertex() {
	// Positioning
	vec2 AdjustedCoord = Coord * 16.0;
	vec2 GridPos = vec2(
		AdjustedCoord.x + 8.0,
		AdjustedCoord.y - 4.0 - YOffset
	);
	VERTEX += GridPos;
	
	// Unflip Texture
	UV.y = 1.0 - UV.y;
}

void fragment() {
	COLOR = texture(TEXTURE, UV);
}
