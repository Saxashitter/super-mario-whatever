uniform vec4 colors[64];
uniform vec4 convertColors[64];

vec4 effect(vec4 color, sampler2D tex, vec2 texture_coords, vec2 screen_coords) {
	vec4 pixel = Texel(tex, texture_coords);
	int length = 63;

	for(int i=0;i<length;i++) {
		if (distance(pixel, colors[i]) < 0.01)
			return convertColors[i];
	}

	return pixel;
}