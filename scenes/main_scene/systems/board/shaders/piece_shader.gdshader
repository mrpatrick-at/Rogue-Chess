shader_type canvas_item;

uniform vec2 coord = vec2(0,0);

void vertex() {
	vec2 grid_pos;
	grid_pos.x = coord.x * 16. + 8.;
	grid_pos.y = -coord.y * 16. - 4.;
	VERTEX = grid_pos + VERTEX;
}

void fragment() {
	vec2 flipped_uv = vec2(UV.x, 1.0 - UV.y);
	vec4 base_color = texture(TEXTURE, flipped_uv);
	
	COLOR = base_color;
}
