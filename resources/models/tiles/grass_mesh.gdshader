shader_type spatial;
render_mode cull_disabled;

uniform vec3 top_color : source_color = vec3(0.2, 0.6, 0.1);
uniform vec3 bottom_color : source_color = vec3(0.1, 0.3, 0.05);
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
    // This moves the top left and top right vertices toward the center
    if (UV.y < 0.1) {
        VERTEX.x *= 0.1; 
    }
	
}

void fragment() {
    ALBEDO = mix(bottom_color, top_color, UV.y);
	if (!FRONT_FACING) {
		NORMAL = -NORMAL;
	}
}