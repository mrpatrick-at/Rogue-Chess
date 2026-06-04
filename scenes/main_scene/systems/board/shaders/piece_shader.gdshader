shader_type canvas_item;

uniform ivec2 coord = ivec2(0,0);
uniform int y_offset = 0;

void vertex() {
	ivec2 grid_pos;
	grid_pos.x = coord.x << 4 + 8;
	grid_pos.y = -coord.y << 4 - 4 - y_offset;
	VERTEX = vec2(grid_pos) + VERTEX;
}

void fragment() {
	vec2 flipped_uv = vec2(UV.x, 1.0 - UV.y);
	vec4 base_color = texture(TEXTURE, flipped_uv);
	
	COLOR = base_color;
}
