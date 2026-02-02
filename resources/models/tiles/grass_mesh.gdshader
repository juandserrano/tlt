shader_type spatial;
// Optimization: Use separate render modes to disable expensive PBR features
// diffuse_lambert: Cheaper diffuse calculation than the default (Burley)
// specular_disabled: Removes all specular/reflection calculations (grass is usually rough)
render_mode cull_disabled, diffuse_lambert, specular_disabled;

uniform vec3 top_color : source_color = vec3(0.2, 0.6, 0.1);
uniform vec3 bottom_color : source_color = vec3(0.1, 0.3, 0.05);

// Optimization: Use constants if these don't need to change at runtime for better compiler optimization
uniform float wind_speed = 2.0;
uniform float wind_strength = 0.15;

void vertex() {
    // 1. Create a weight: 1.0 at the top, 0.0 at the bottom
    float mask = 1.0 - UV.y;
    
    // 2. Simple sine wave based on time and world position
    // Adding WORLD_POSITION ensures different blades don't sway in perfect unison
    float time = TIME * wind_speed;
    float wind = sin(time + NODE_POSITION_WORLD.x + NODE_POSITION_WORLD.z);
    
    // 3. Apply movement ONLY to the top
    VERTEX.x += wind * wind_strength * mask;
    VERTEX.z += wind * wind_strength * mask;
    
    // 4. "Pinch" the top vertices together to make a triangle shape
    // Optimization: Use mix/step for branchless logic (avoids branching on GPU)
    // If UV.y < 0.1 (top tip), scale x by 0.1
    VERTEX.x *= mix(0.1, 1.0, step(0.1, UV.y));
}

void fragment() {
    ALBEDO = mix(bottom_color, top_color, UV.y);
	if (!FRONT_FACING) {
		NORMAL = -NORMAL;
	}
}