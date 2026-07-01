// Shirt recolor shader for Sunnyside World character sprites.
//
// Detects shirt pixels by hue (red range ≈ 340°–20°) + saturation guard.
// No mask texture required — the shirt hue is distinct from skin (beige) and
// outfit/overalls (navy blue), so hue-based detection is reliable.
//
// For matched pixels: maps original luminance within the sprite's red range
// to a linear gradient between the two target colors.
//
shader_type canvas_item;
render_mode blend_mix;

// Target shirt gradient: dark shade → light shade
uniform vec3 shirt_dark  : source_color = vec3(0.659, 0.094, 0.188);  // default #a81830
uniform vec3 shirt_light : source_color = vec3(0.941, 0.439, 0.439);  // default #f07070

// Luminance range of the original red shirt pixels in the sprite.
// Pixels outside this range that are still "red-hued" are treated as outlines
// and kept unchanged.
uniform float lum_min : hint_range(0.0, 1.0) = 0.22;
uniform float lum_max : hint_range(0.0, 1.0) = 0.65;

void fragment() {
	vec4 col = texture(TEXTURE, UV);
	if (col.a < 0.01) {
		COLOR = vec4(0.0);
	} else {
		float r = col.r, g = col.g, b = col.b;
		float cmax  = max(r, max(g, b));
		float cmin  = min(r, min(g, b));
		float delta = cmax - cmin;

		float hue = 0.0;
		if (delta > 0.001) {
			if (cmax == r)      hue = mod((g - b) / delta, 6.0) / 6.0;
			else if (cmax == g) hue = ((b - r) / delta + 2.0) / 6.0;
			else                hue = ((r - g) / delta + 4.0) / 6.0;
		}
		float hue_deg = hue * 360.0;
		float sat     = (cmax > 0.001) ? delta / cmax : 0.0;
		float lum     = 0.299 * r + 0.587 * g + 0.114 * b;

		bool is_shirt = (hue_deg >= 340.0 || hue_deg <= 20.0)
		             && sat > 0.35
		             && lum >= lum_min && lum <= lum_max;

		if (is_shirt) {
			float t = clamp((lum - lum_min) / max(lum_max - lum_min, 0.001), 0.0, 1.0);
			COLOR = vec4(mix(shirt_dark, shirt_light, t), col.a);
		} else {
			COLOR = col;
		}
	}
}
