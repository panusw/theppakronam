// Palette-swap shader for Sunnyside World RGB sprites.
//
// Works on pre-colored pixel art (NOT red-channel-indexed sprites).
// For each pixel: find its nearest color in the source palette,
// then replace it with the corresponding color in the target palette.
//
// Usage — attach a ShaderMaterial to each sprite layer and set:
//   source_palette : 1×N ImageTexture  — colors sampled from the default Sunnyside sprite
//   target_palette : 1×N ImageTexture  — replacement colors (skin tone / hair / outfit option)
//   palette_size   : N (number of color entries in the texture)
//   tolerance      : ~0.04 works well for crisp pixel art with distinct color counts
//
// Generated at runtime by CharacterColors.gd → apply_to_material()
shader_type canvas_item;
render_mode blend_mix;

// Source: the original Sunnyside character colors to match (sampled in Aseprite)
// No source_color hint — palette textures are built from GDScript Color values (sRGB),
// read back raw so distance() comparison stays in the same space as the sprite pixels.
uniform sampler2D source_palette : filter_nearest, repeat_disable;
// Target: replacement colors (same index layout as source)
uniform sampler2D target_palette : filter_nearest, repeat_disable;

// How many colors are encoded in the palette textures
uniform int palette_size : hint_range(1, 64) = 8;

// Color-match sensitivity. Increase if edges aren't swapped; decrease to avoid bleed.
uniform float tolerance : hint_range(0.005, 0.2) = 0.04;

void fragment() {
	vec4 col = texture(TEXTURE, UV);
	if (col.a < 0.01) {
		COLOR = vec4(0.0);
	} else {
		vec3  px        = col.rgb;
		float best_dist = tolerance;
		int   best_idx  = -1;

		for (int i = 0; i < palette_size; i++) {
			float u    = (float(i) + 0.5) / float(palette_size);
			vec3  ref  = texture(source_palette, vec2(u, 0.5)).rgb;
			float dist = distance(px, ref);
			if (dist < best_dist) {
				best_dist = dist;
				best_idx  = i;
			}
		}

		if (best_idx >= 0) {
			float u   = (float(best_idx) + 0.5) / float(palette_size);
			vec3  tgt = texture(target_palette, vec2(u, 0.5)).rgb;
			COLOR = vec4(tgt, col.a);
		} else {
			COLOR = col;
		}
	}
}
