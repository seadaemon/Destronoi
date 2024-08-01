shader_type spatial;
//render_mode diffuse_toon;
render_mode specular_toon;
//render_mode wireframe;
void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	ALBEDO = VERTEX;
	// Called for every pixel the material is visible on.
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
