shader_type canvas_item;
uniform vec4 white_tile_color : source_color = vec4(1, 1, 1, 1.0);
uniform vec4 black_tile_color : source_color = vec4(0, 0, 0, 1.0);

uniform vec4 hover_color : source_color = vec4(0.0, 0.0, 1.0, 0.4);
uniform vec4 move_color : source_color = vec4(0.2, 1.0, 0.2, 0.4);
uniform vec4 capture_color : source_color = vec4(0.9, 0.0, 0.0, 0.4);
uniform vec4 check_color : source_color = vec4(0.9, 0.0, 0.0, 0.4);

uniform int tile_states[64];

//void vertex() {
	//VERTEX.y *= -1.;
//}

void fragment() {
	vec2 mult_pos = UV * 8.0;
	ivec2 grid_pos = ivec2(mult_pos); // pos of tile on grid
	
	bool is_black = (grid_pos.x + grid_pos.y) % 2 == 1; // if remainder of both numbers added aint 1 it aint black
	vec4 final_color = is_black ? black_tile_color : white_tile_color;
	
	int array_index = int(grid_pos.x + grid_pos.y << 8);
	int current_state = tile_states[array_index];
	
	vec4 overlay = vec4(0.0);
	
	if (current_state == 1) {
		overlay = hover_color; // blue for hover yehaw
	} else if (current_state == 2) {
		overlay = move_color; // green for valid moves
	} else if (current_state == 3) {
		overlay = capture_color;
	} else if (current_state == 4) {
		overlay = check_color;
	}
	final_color.rgb = mix(final_color.rgb, overlay.rgb, overlay.a);
	
	COLOR = final_color;
}
