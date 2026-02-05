shader_type spatial;
render_mode blend_add, cull_disabled, unshaded;

uniform vec4 main_color : source_color = vec4(1.0, 0.8, 0.2, 1.0);
uniform float dissolve : hint_range(0.0, 1.0) = 0.0;
uniform float radius : hint_range(0.0, 1.0) = 0.5;
uniform float thickness : hint_range(0.0, 0.5) = 0.02;

uniform float wobble_frequency : hint_range(0.0, 20.0) = 10.0;
uniform float wobble_amplitude : hint_range(0.0, 0.5) = 0.05;

void vertex() {
	float dist_from_center = length(VERTEX.xz);
	
	// Create a wave that moves outward from center
	// Using dist_from_center makes the wave radial
	float wave = sin(dist_from_center * wobble_frequency - TIME * 5.0);
	
	// Apply height displacement
	VERTEX.y += wave * wobble_amplitude;
}

void fragment() {
	// 1. Map UV coordinates to [-1, 1] range for SDF calculation
	vec2 uv = UV * 2.0 - 1.0;
	float dist = length(uv);
	
	// 2. Procedural Wobble
	float angle = atan(uv.y, uv.x);
	float wobble = sin(angle * wobble_frequency + TIME * 3.5) * wobble_amplitude;
	
	// 3. SDF Ring Shape
	// float radius = 0.75; // Replaced by uniform
	// float thickness = 0.02; // Replaced by uniform
	
	// Distance to the circle boundary (with wobble)
	float d = abs(dist - (radius + wobble)) - thickness;
	
	// Smooth edges (Anti-aliasing)
	float edgeSmoothing = 0.015;
	float ringMask = 1.0 - smoothstep(-edgeSmoothing, edgeSmoothing, d);
	
	// 4. Energy Fluctuations
	float energy = sin(angle * 6.0 + TIME * 4.0) * 0.25 + 0.75;
	float pulse = (sin(TIME * 2.5) * 0.2) + 0.8;
	
	// Final color and alpha
	vec3 color = main_color.rgb * energy * pulse * 3.5;
	float alpha = main_color.a * ringMask * energy * pulse;
	
	// Dissolve logic for game mechanic
	alpha *= (1.0 - dissolve);
	
	// Kill pixels outside the ring for efficiency
	if (alpha < 0.01) discard;
	
	ALBEDO = color;
	ALPHA = alpha;
}
