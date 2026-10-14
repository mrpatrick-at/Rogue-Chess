shader_type canvas_item;

uniform float circle_radius:hint_range(0.0, 1.0) = 0.5;
uniform float repeat_amount:hint_range(1.0, 100.0) = 10.;
uniform float zoom:hint_range(0.0, 100.0) = 10.;

uniform vec3 color_1: source_color;
uniform vec3 color_2: source_color;
uniform vec3 color_3: source_color;
uniform sampler2D noise: repeat_enable;

vec2 polar_coordinates(vec2 uv, vec2 center){
	vec2 dir = uv - center;
	float radius = length(dir) * 2.0;
	float angle = atan(dir.y, dir.x) * 1.0/(3.1416 * 2.0);
	return mod(vec2(radius * zoom / 1. - sin(TIME)/ 0.5, angle * repeat_amount), 1.0);
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
}

void fragment() {
	vec2 center = vec2(0.5);
	vec2 rotated_uv = rotate(UV, center, TIME/40.);
	
	vec2 polar_uv = polar_coordinates(rotated_uv, center);
	
	COLOR = vec4(polar_uv.x,polar_uv.y,0.,1.);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
