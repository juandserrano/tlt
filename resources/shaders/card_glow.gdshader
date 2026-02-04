// Card shader with tilt effect and outer glow for selection
// Based on Hei's 3D-camera perspective shader
// License: MIT

shader_type canvas_item;

// Camera FOV
uniform float fov : hint_range(1, 179) = 90;
uniform bool cull_back = true;
uniform float y_rot : hint_range(-180, 180) = 0.0;
uniform float x_rot : hint_range(-180, 180) = 0.0;
// At 0, the image retains its size when unrotated.
// At 1, the image is resized so that it can do a full
// rotation without clipping inside its rect.
uniform float inset : hint_range(0, 1) = 0.0;

// Glow parameters
uniform bool show_glow = false;
uniform vec4 glow_color : source_color = vec4(1.0, 0.8, 0.2, 1.0);
uniform float glow_size : hint_range(0.0, 0.1) = 0.02;
uniform float glow_intensity : hint_range(0.0, 2.0) = 1.0;

varying flat vec2 o;
varying vec3 p;

// Creates rotation matrix
void vertex(){
	float sin_b = sin(y_rot / 180.0 * PI);
	float cos_b = cos(y_rot / 180.0 * PI);
	float sin_c = sin(x_rot / 180.0 * PI);
	float cos_c = cos(x_rot / 180.0 * PI);
	
	mat3 inv_rot_mat;
	inv_rot_mat[0][0] = cos_b;
	inv_rot_mat[0][1] = 0.0;
	inv_rot_mat[0][2] = -sin_b;
	
	inv_rot_mat[1][0] = sin_b * sin_c;
	inv_rot_mat[1][1] = cos_c;
	inv_rot_mat[1][2] = cos_b * sin_c;
	
	inv_rot_mat[2][0] = sin_b * cos_c;
	inv_rot_mat[2][1] = -sin_c;
	inv_rot_mat[2][2] = cos_b * cos_c;
	
	
	float t = tan(fov / 360.0 * PI);
	p = inv_rot_mat * vec3((UV - 0.5), 0.5 / t);
	float v = (0.5 / t) + 0.5;
	p.xy *= v * inv_rot_mat[2].z;
	o = v * inv_rot_mat[2].xy;

	VERTEX += (UV - 0.5) / TEXTURE_PIXEL_SIZE * t * (1.0 - inset);
}

void fragment(){
	if (cull_back && p.z <= 0.0) discard;
	vec2 uv = (p.xy / p.z).xy - o;
	vec4 tex_color = texture(TEXTURE, uv + 0.5);
	tex_color.a *= step(max(abs(uv.x), abs(uv.y)), 0.5);
	
	// Add bloom-like glow effect when selected
	if (show_glow) {
		// Multi-layer sampling for bloom effect
		float glow = 0.0;
		int samples = 16; // More samples for smoother bloom
		int layers = 3;   // Multiple layers at different distances
		
		for (int layer = 0; layer < layers; layer++) {
			float layer_distance = glow_size * (1.0 + float(layer) * 0.5);
			float layer_weight = 1.0 / (1.0 + float(layer)); // Closer layers contribute more
			
			for (int i = 0; i < samples; i++) {
				float angle = float(i) * (2.0 * PI / float(samples));
				vec2 offset = vec2(cos(angle), sin(angle)) * layer_distance;
				vec4 sample_color = texture(TEXTURE, uv + 0.5 + offset);
				sample_color.a *= step(max(abs((uv + offset).x), abs((uv + offset).y)), 0.5);
				
				// Gaussian-like falloff for softer bloom
				float distance_factor = 1.0 - (float(layer) / float(layers));
				glow += sample_color.a * layer_weight * distance_factor;
			}
		}
		
		glow /= float(samples * layers);
		
		// Create soft bloom around the edges
		float edge_glow = glow * (1.0 - tex_color.a) * glow_intensity;
		
		// Add some bloom to the card itself for extra radiance
		float card_bloom = glow * tex_color.a * 0.3 * glow_intensity;
		
		// Blend with a softer, more radiant approach
		vec3 bloom_color = glow_color.rgb * edge_glow;
		COLOR.rgb = mix(bloom_color, tex_color.rgb + bloom_color * 0.5, tex_color.a);
		COLOR.rgb += glow_color.rgb * card_bloom; // Add radiance to the card
		COLOR.a = max(tex_color.a, edge_glow * glow_color.a * 0.8);
	} else {
		COLOR = tex_color;
	}
}
