extern vec4 absColor;

vec4 effect(vec4 color, sampler2D tex, vec2 texture_coords, vec2 screen_coords) {
	vec4 pixel = Texel(tex, texture_coords);

	if (pixel.a <= 0.0)
		discard;

	return absColor;
}