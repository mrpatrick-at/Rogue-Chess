shader_type canvas_item;

uniform bool see_uv = false;
uniform bool tile_background = false;
uniform vec4 color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform vec2 grid_size = vec2(4.0,4.0);
uniform float pixelation_factor : hint_range(0.0, 1000.0, 1.0);

void vertex() { // Called for every vertex the material is visible on.
	
}

void fragment() { // Called for every pixel the material is visible on.
	vec2 uv = vec2(UV.x, UV.y);
	
	uv = fract(uv * grid_size);
	vec2 pixelated_uv = floor(uv * (pixelation_factor)) / pixelation_factor;
	
	COLOR = texture(TEXTURE,pixelated_uv);
	
	if (see_uv) {
		COLOR = vec4(uv,0.0,1.0);
	}
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
