uniform vec4 colors[64];
uniform vec4 convertColors[64];

vec4 effect(vec4 color, sampler2D tex, vec2 texture_coords, vec2 screen_coords) {
	vec4 pixel = Texel(tex, texture_coords);
	int length = 63;

	for(int i=0;i<length;i++) {
		int j = i;

		if (pixel.a == 0.0)
			return pixel;

		if (distance(pixel.r, colors[j].r) < 0.01
		&& distance(pixel.g, colors[j].g) < 0.01
		&& distance(pixel.b, colors[j].b) < 0.01
		&& distance(pixel.a, colors[j].a) < 0.01)
			return convertColors[j];
	}
}