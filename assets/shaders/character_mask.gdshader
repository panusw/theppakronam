// Mask-based palette swap for Sunnyside World character sprites.
//
// Mask PNG channels:
//   Body sprites : R=skin  G=outfit  B=shirt
//   Hair sprites : R=hair  G=shirt-boundary  B=outfit-boundary
//
// For each masked pixel: normalize luminance within the sprite's original
// color range, then interpolate between dark and light target colors.
// Non-masked pixels (outlines, eyebrows) keep their original color.

shader_type canvas_item;
render_mode blend_mix;

uniform sampler2D mask_texture : filter_nearest, repeat_disable;

// Region 1 target colors (skin on body, hair on hair sprites)
uniform vec3 color1_dark  : source_color = vec3(0.78, 0.50, 0.36);
uniform vec3 color1_light : source_color = vec3(0.96, 0.81, 0.63);

// Region 2 target colors (outfit on body, shirt-boundary on hair sprites)
uniform vec3 color2_dark  : source_color = vec3(0.14, 0.17, 0.26);
uniform vec3 color2_light : source_color = vec3(0.31, 0.38, 0.50);

// Region 3 target colors (shirt on body, outfit-boundary on hair sprites)
uniform vec3 color3_dark  : source_color = vec3(0.65, 0.12, 0.20);
uniform vec3 color3_light : source_color = vec3(0.98, 0.44, 0.48);

// Luminance range of original sprite pixels per region
// (set once per material based on sprite type — see CharacterColors.gd)
uniform float lum1_min = 0.507;
uniform float lum1_max = 0.726;
uniform float lum2_min = 0.171;
uniform float lum2_max = 0.270;
uniform float lum3_min = 0.288;
uniform float lum3_max = 0.608;

void fragment() {
	vec4 orig = texture(TEXTURE, UV);
	if (orig.a < 0.01) { COLOR = vec4(0.0); return; }

	vec4  mask = texture(mask_texture, UV);
	float lum  = dot(orig.rgb, vec3(0.299, 0.587, 0.114));
	vec3  col  = orig.rgb;

	if (mask.r > 0.5) {
		float t = clamp((lum - lum1_min) / max(lum1_max - lum1_min, 0.001), 0.0, 1.0);
		col = mix(color1_dark, color1_light, t);
	} else if (mask.g > 0.5) {
		float t = clamp((lum - lum2_min) / max(lum2_max - lum2_min, 0.001), 0.0, 1.0);
		col = mix(color2_dark, color2_light, t);
	} else if (mask.b > 0.5) {
		float t = clamp((lum - lum3_min) / max(lum3_max - lum3_min, 0.001), 0.0, 1.0);
		col = mix(color3_dark, color3_light, t);
	}

	COLOR = vec4(col, orig.a);
}
