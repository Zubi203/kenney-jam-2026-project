shader_type canvas_item;

uniform float progress_red: hint_range(0.0, 1.0) = 0.0;
uniform float progress_green: hint_range(0.0, 1.0) = 0.0;

void fragment() {
	COLOR.rgb = mix(COLOR.rgb, vec3(1.0, 0.0, 0.0), progress_red);
	COLOR.rgb = mix(COLOR.rgb, vec3(0, 1.0, 0), progress_green);
}
