shader_type canvas_item;

const vec4 TileColors[2] = vec4[2](
	vec4(1, 1, 1, 1.0),
	vec4(0, 0, 0, 1.0)
);

const vec4 OverlayColors[5] = vec4[5](
	vec4(0.0, 0.0, 0.0, 0.0), // None
	vec4(0.0, 0.0, 1.0, 0.4), // Hover
	vec4(0.2, 1.0, 0.2, 0.4), // Moves
	vec4(0.9, 0.0, 0.0, 0.4), // Captures
	vec4(0.9, 0.0, 0.0, 0.4) // Checks
);

uniform int TileStates[64];

//void vertex() {
	//VERTEX.y *= -1.;
//}

void fragment() {
	vec2 GridPos = floor(UV * 8.0);
	
	int ColorIndex = int(mod(GridPos.x + GridPos.y, 2.0));
	vec4 FinalColor = TileColors[ColorIndex];
	
	int StateIndex = int(GridPos.y * 8.0 + GridPos.x);
	int CurrentState = TileStates[StateIndex];
	
	vec4 Overlay = OverlayColors[CurrentState];
	
	FinalColor.rgb = mix(FinalColor.rgb, Overlay.rgb, Overlay.a);
	
	COLOR = FinalColor;
}
