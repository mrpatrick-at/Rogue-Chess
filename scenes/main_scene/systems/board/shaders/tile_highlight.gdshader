shader_type canvas_item;

uniform vec4 tile_color: source_color = vec4(0.0);
uniform vec4 highlight_color: source_color = vec4(0.0);

void fragment() {
	COLOR = tile_color;
	vec4 base_color = COLOR;
	
	COLOR = mix(base_color, vec4(highlight_color.rgb, 1.0), highlight_color.a);
}
