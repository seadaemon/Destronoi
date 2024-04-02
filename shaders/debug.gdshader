shader_type spatial;

const vec3 red = vec3(1,0,0);
const vec3 green = vec3(0,1,0);
const vec3 blue = vec3(0,0,1);
const vec3 yellow = vec3(1,1,0);

const vec3 colors[3] = {yellow, yellow, yellow};

varying vec3 v_col;
void vertex() {
	// Called for every vertex the material is visible on.
	v_col = colors[VERTEX_ID % 3];
	v_col = COLOR.rgb;
}

void fragment() {
	vec3 col = vec3(0,0,0);
	col = v_col; //mix(blue,green,(UV.x + UV.y)/2.0);
	ALBEDO = col;
	// Called for every pixel the material is visible on.
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
