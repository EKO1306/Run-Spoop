shader_type canvas_item;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

uniform vec4 outline_color : source_color;
uniform float outline_size = 1.0;


void fragment(){
	bool round_outline = false;
	if (outline_size > 1.0) {
		round_outline = true;
	}
	float size_x = outline_size/float(textureSize(TEXTURE, 0).x);
	float size_y = outline_size/float(textureSize(TEXTURE, 0).y);
	vec4 sprite_color = texture(TEXTURE, UV);
	float alpha;
	if (round_outline) {
		alpha = -8.0 * sprite_color.a;
	} else {
		alpha = -4.0 * sprite_color.a;
	}
	alpha += texture(TEXTURE, UV + vec2(size_x, 0)).a;
	alpha += texture(TEXTURE, UV + vec2(-size_x, 0)).a;
	alpha += texture(TEXTURE, UV + vec2(0, size_y)).a;
	alpha += texture(TEXTURE, UV + vec2(0, -size_y)).a;
	//For outlining corners
	//Change the -4.0 to -8.0 in alpa if adding these lines
	if (round_outline) {
	alpha += texture(TEXTURE, UV + vec2(size_x, size_y)).a;
	alpha += texture(TEXTURE, UV + vec2(-size_x, size_y)).a;
	alpha += texture(TEXTURE, UV + vec2(-size_x, -size_y)).a;
	alpha += texture(TEXTURE, UV + vec2(size_x, -size_y)).a;
	}
	vec4 final_color = mix(sprite_color, outline_color, clamp(alpha, 0.0, 1.0));
	COLOR = vec4(final_color.rgb, clamp(abs(alpha) + sprite_color.a, 0.0, 1.0));
}