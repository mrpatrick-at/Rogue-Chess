shader_type canvas_item;

uniform float circle_radius:hint_range(0.0, 1.0) = 0.5;

uniform vec3 color_1: source_color;
uniform vec3 color_2: source_color;
uniform vec3 color_3: source_color;
uniform sampler2D noise: repeat_enable;

vec2 polar_coordinates(vec2 uv, vec2 center, float zoom, float repeat){
	vec2 dir = uv - center;
	float radius = length(dir) * 2.0;
	float angle = atan(dir.y, dir.x) * 1.0/(3.1416 * 2.0);
	return mod(vec2(radius * zoom, angle * repeat), 1.0);
}

vec2 rotate(vec2 uv, vec2 pivot, float angle){
	mat2 rotation = mat2(vec2(sin(angle), -cos(angle)),
						vec2(cos(angle), sin(angle)));
	
	uv -= pivot;
	uv = uv * rotation;
	uv += pivot;
	return uv;
}


void vertex() {
	// a parameter determining magnitude of the displacement
}

void fragment() {
	vec2 rotated_uv = rotate(UV, vec2(0.5), TIME/6.);
	
	vec2 polar_uv = polar_coordinates(rotated_uv.xy, vec2(0.5), 1., 10.0);
	
	COLOR.rgb = texture(TEXTURE, polar_uv).rgb;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
