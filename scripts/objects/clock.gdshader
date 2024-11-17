shader_type canvas_item;

uniform uint bits;

void fragment() {
	// Called for every pixel the material is visible on.
	vec4 tex = texture(TEXTURE, UV);
	uint seg = uint(tex.r * 8.0);
	float lit = float((tex.r == tex.g) && (bits & (128u >> seg)) > 0u);
	COLOR = vec4(lit, lit, lit, lit * tex.a);
}
