shader_type canvas_item;

uniform bool see_uv = false;

uniform highp float spin_rotation_speed = 2.0;
uniform highp float move_speed = 7.0;
uniform highp vec2 offset = vec2(0., 0.);

uniform highp vec4 colour_1 : source_color = vec4(0.871, 0.267, 0.231, 1.0);
uniform highp vec4 colour_2 : source_color = vec4(0.0, 0.42, 0.706, 1.0);
uniform highp vec4 colour_3 : source_color = vec4(0.086, 0.137, 0.145, 1.0);
uniform highp float contrast = 3.5;

uniform highp float lighting = 0.4;
uniform highp float spin_amount = 0.25;
uniform highp float pixel_filter = 740.;
uniform bool is_rotating = false;
#define SPIN_EASE 1.0

void vertex() { // Called for every vertex the material is visible on.
	//VERTEX += vec2(cos(TIME)*100.0, sin(TIME)*100.0);
}

vec4 effect(vec2 screenSize, vec2 screen_coords){
	highp float pixel_size = length(screenSize.xy) / pixel_filter;
	highp vec2 uv = (floor(screen_coords.xy*(1./pixel_size))*pixel_size - 0.5*screenSize.xy)/length(screenSize.xy) - offset;
	highp float uv_len = length(uv);
	
	 highp float speed = (spin_rotation_speed*SPIN_EASE*0.2);
	if(is_rotating){
		speed = TIME * speed;
	}
	speed += 302.2;
	highp float new_pixel_angle = (atan(uv.y, uv.x)) + speed - SPIN_EASE*20.*(1.*spin_amount*uv_len + (1. - 1.*spin_amount));
	highp vec2 mid = (screenSize.xy/length(screenSize.xy))/2.;
	uv = (vec2((uv_len * cos(new_pixel_angle) + mid.x), (uv_len * sin(new_pixel_angle) + mid.y)) - mid);
	
	uv *= 30.;
	speed = TIME*(move_speed);
	highp vec2 uv2 = vec2(uv.x+uv.y);
	
	for(int i=0; i < 5; i++) {
		uv2 += sin(max(uv.x, uv.y)) + uv;
		uv  += 0.5*vec2(cos(5.1123314 + 0.353*uv2.y + speed*0.131121),sin(uv2.x - 0.113*speed));
		uv  -= 1.0*cos(uv.x + uv.y) - 1.0*sin(uv.x*0.711 - uv.y);
	}
	
	
	highp float contrast_mod = (0.25*contrast + 0.5*spin_amount + 1.2);
	highp float paint_res = min(2., max(0.,length(uv)*(0.035)*contrast_mod));
	highp float c1p = max(0.,1. - contrast_mod*abs(1.-paint_res));
	highp float c2p = max(0.,1. - contrast_mod*abs(paint_res));
	highp float c3p = 1. - min(1., c1p + c2p);
	
	highp float ligth = (lighting - 0.2) * max(c1p*5. - 4., 0.) + lighting * max(c2p*5. - 4., 0.); 
	highp vec4 ret_col = (0.3/contrast)*colour_1 + (1. - 0.3/contrast)*(colour_1*c1p + colour_2*c2p + vec4(c3p*colour_3.rgb, c3p*colour_1.a)) + ligth;
	return ret_col;
}

void fragment() { // Called for every pixel the material is visible on.
	 vec2 uv = UV;
	vec4 effect_color = effect(TEXTURE_PIXEL_SIZE, uv);
	COLOR *= effect_color;
	
	//float radius = length(0.5 - UV); /**/
	//float angle = atan(UV.y-0.5, UV.x-0.5); /* Gets Central Position of Shader*/
	//
	//COLOR = color_1;
	//
	//vec2 st = UV;
	//st.y = 1.0 - st.y;
	//
	//
	//COLOR.a = 1.0 - smoothstep(-.1,.1,fract((2.0 * radius - (angle + PI) / TAU) * rays + (clockwise?1.0:-1.0) * TIME * speed)-thickness);
	//
	//COLOR.a *= pow(2.*(.5 - radius), fade*4.);
	
	if (see_uv) {
		COLOR = vec4(UV,0.5,1.0);
	}
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
