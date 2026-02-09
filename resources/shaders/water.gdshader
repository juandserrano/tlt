shader_type spatial;

uniform vec3 albedo : source_color = vec3(0.0, 0.4, 0.8);
uniform vec3 albedo2 : source_color = vec3(0.0, 0.6, 0.9);
uniform float metallic : hint_range(0.0, 1.0) = 0.0;
uniform float roughness : hint_range(0.0, 1.0) = 0.02;
uniform sampler2D texture_normal;
uniform sampler2D texture_normal2;
uniform float wave_speed = 3.0;
uniform float wave_amplitude = 0.2;
uniform float wave_frequency = 4.0;
uniform vec2 wave_direction = vec2(2.0, 0.0);
uniform vec2 wave_direction2 = vec2(0.0, 1.0);
uniform float time_scale : hint_range(0.0, 0.2, 0.005) = 0.025;

float fresnel(float amount, vec3 normal, vec3 view){
	return pow((1.0 - clamp(dot(normalize(normal), normalize(view)), 0.0, 1.0)), amount);
}

void vertex() {
	float wave = sin(VERTEX.x * wave_frequency + TIME * wave_speed) * cos(VERTEX.z * wave_frequency + TIME * wave_speed);
	VERTEX.y += wave * wave_amplitude;
}

void fragment() {
	vec2 time = (TIME * wave_direction) * time_scale;
	vec2 time2 = (TIME * wave_direction2) * time_scale;
	vec3 normal_blend = mix(texture(texture_normal, UV + time).rgb, texture(texture_normal2, UV + time2).rgb, 0.5);
	float fresnel = fresnel(5.0, NORMAL, VIEW);
	vec3 surface_color = mix(albedo, albedo2, fresnel);
	
	NORMAL_MAP = normal_blend;
	ALBEDO = surface_color;
	METALLIC = metallic;
	ROUGHNESS = roughness;
	ALPHA = 0.8;
}
