shader_type spatial;

uniform vec3 albedo : source_color = vec3(0.0, 0.4, 0.8);
uniform vec3 albedo2 : source_color = vec3(0.0, 0.6, 0.9);
uniform float metallic : hint_range(0.0, 1.0) = 0.0;
uniform float roughness : hint_range(0.0, 1.0) = 0.02;
uniform float wave_speed = 3.0;
uniform float wave_amplitude = 0.2;
uniform float wave_frequency = 4.0;

void vertex() {
	float wave = sin(VERTEX.x * wave_frequency + TIME * wave_speed) * cos(VERTEX.z * wave_frequency + TIME * wave_speed);
	VERTEX.y += wave * wave_amplitude;
}

void fragment() {
	ALBEDO = mix(albedo, albedo2, sin(TIME * wave_speed + (UV.x + UV.y) * 5.0) * 0.5 + 0.5);
	METALLIC = metallic;
	ROUGHNESS = roughness;
	ALPHA = 0.8;
}
