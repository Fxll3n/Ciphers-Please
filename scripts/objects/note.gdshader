shader_type spatial;

void fragment() {
	// Simple shader to draw some non-empty texture
	ALBEDO.r = SCREEN_UV.x;
	ALBEDO.g = SCREEN_UV.y;
	ALBEDO.b = (1.0 - SCREEN_UV.x) * (1.0 - SCREEN_UV.y);
}
