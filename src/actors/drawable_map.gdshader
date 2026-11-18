shader_type spatial;
#include "res://addons/shaker/vfx/shaders/approx_equal.gdshaderinc"

uniform sampler2D fg_texture;
uniform sampler2D bg_texture;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 fg_col = texture(fg_texture, UV);
	vec4 bg_col = texture(bg_texture, UV);
	
	ALBEDO = mix(bg_col.rgb, fg_col.rgb, fg_col.a);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
