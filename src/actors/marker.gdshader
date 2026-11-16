shader_type spatial;

#include "res://addons/shaker/vfx/shaders/approx_equal.gdshaderinc"

uniform sampler2D tex;
uniform vec3 color: source_color;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec3 col = texture(tex, UV).rgb;
	if (approx_equal_vec3(col, vec3(1.0, 0.0, 1.0), 0.5)) {
		col = color;
	}
	ALBEDO = col;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
