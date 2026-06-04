shader_type canvas_item;

uniform vec2 coord = vec2(0,0);
uniform float y_offset = 0;

void vertex() {
	vec2 grid_pos = vec2(
		(coord.x * 16.0) + 8.0,
		(-coord.y * 16.0) - 4.0 - y_offset
	);
	VERTEX += grid_pos;
	UV.y = 1.0 - UV.y;
}

void fragment() {
	COLOR = texture(TEXTURE, UV);
}
