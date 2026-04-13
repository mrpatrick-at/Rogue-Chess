shader_type canvas_item;

//uniform int my_enum:hint_enum("Zero", "One", "Two");
//uniform sampler2D my_tex;
uniform bool see_uv = false;
uniform bool cam_passthru = false;
uniform float offset = 0.01;
uniform sampler2D screen_tex : hint_screen_texture, repeat_disable, filter_linear;
uniform vec4 overlay_color:source_color = vec4(0.0, 0.0, 0.0, 1.0);

void vertex() { // Called for every vertex the material is visible on.
	
}

void fragment() { // Called for every pixel the material is visible on.
	vec4 color;
	vec4 color2;
	vec4 color3;
	
	if (cam_passthru) {
	color = texture(screen_tex, SCREEN_UV);
	color2 = texture(screen_tex, SCREEN_UV + offset);
	color3 = texture(screen_tex, SCREEN_UV - offset);
	}
	else {
	color = texture(TEXTURE, UV);
	color2 = texture(TEXTURE, UV + offset);
	color3 = texture(TEXTURE, UV - offset);
	}
	COLOR = vec4(color.r,color2.g,color3.b,color.a);
	
	vec2 uv = vec2(UV.x, 1.0 - UV.y);
	
	float crt_speed = 4.0;
	
	float crt = sin(uv.y * 400.0 - TIME * crt_speed) * 0.1 + 0.1;
	float crt2 = sin(uv.y * 20.0 - TIME * (crt_speed / 2.0)) * 0.1 + 0.3;
	COLOR.rgb += vec3(crt,crt+0.1,crt) * 0.3 + vec3(crt2,crt2,crt2) * 0.3;
	
	//COLOR += overlay_color;
	
	if (see_uv) {
		COLOR = vec4(UV,0.0,1.0);
	}

}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
