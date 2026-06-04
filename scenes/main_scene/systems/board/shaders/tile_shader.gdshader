shader_type canvas_item;

uniform vec2 coord = vec2(0,0);
uniform vec4 tile_color: source_color = vec4(0.0);
uniform vec4 highlight_color: source_color = vec4(0.0);

void vertex() {
	vec2 grid_pos;
	grid_pos.x = coord.x * 128.;
	grid_pos.y = -coord.y * 128.;
	VERTEX = grid_pos + VERTEX;
}

void fragment() {
	COLOR = tile_color;
	vec4 base_color = COLOR;
	
	COLOR = mix(base_color, vec4(highlight_color.rgb, 1.0), highlight_color.a);
}
