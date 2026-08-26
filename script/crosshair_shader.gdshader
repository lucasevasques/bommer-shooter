shader_type canvas_item;

uniform sampler2D screen_texture: hint_screen_texture, repeat_disable,filter_nearest;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	COLOR = textureLod(screen_texture, SCREEN_UV, 0.5);
	float dot_center = distance (SCREEN_UV, vec2(0.5, 0.5));
	dot_center = ceil(dot_center - 0.005);
	COLOR.rgb *= dot_center + 0.8;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
