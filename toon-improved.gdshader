shader_type spatial;

uniform sampler2D albedo_texture: source_color;

uniform float diffuse_threshold : hint_range(0.0, 1.0) = 0.5;
uniform float shadow_strength : hint_range(0.0, 1.0) = 0.5;

uniform float specular_threshold : hint_range(0.9, 1.0) = 0.99;
uniform float specular_strength : hint_range(0.0, 4.0) = 2.0;
uniform vec3 specular_color : source_color = vec3(1.0, 1.0, 1.0);

uniform float rim_width = 2.0;
uniform float rim_power = 4.0;
uniform float rim_strength : hint_range(0.0, 2.0) = 1.0;
uniform vec3 rim_color : source_color = vec3(1.0, 1.0, 1.0);

uniform bool lit_part_fersnel_only = false;

void light() {
	vec3 albedo_color = texture(albedo_texture, UV).rgb;
	float ndotl = dot(NORMAL, LIGHT);
	
	// Shadow Map (ATTENUATION). 
	// This makes the light value 0.0 if blocked by another object.
	float lit_intensity = ndotl * ATTENUATION;

	// Calculate Toon Step based on the attenuated light
	float diffuse_step = lit_intensity > diffuse_threshold ? 1.0 : 0.0;

	// Determine final diffuse color (Light vs Shadow)
	vec3 diffuse_col = diffuse_step == 0.0
		? albedo_color * shadow_strength
		: albedo_color;

	DIFFUSE_LIGHT = diffuse_col;

	// Specular
	vec3 H = normalize(LIGHT + VIEW);
	float spec = dot(NORMAL, H);
	float spec_step = spec > specular_threshold ? 1.0 : 0.0;
	
	// Multiply by ATTENUATION so specular doesn't appear inside cast shadows
	SPECULAR_LIGHT = specular_color * specular_strength * spec_step * ATTENUATION;

	// Rim
	float rim_dot = 1.0 - dot(VIEW, NORMAL);
	float rim = smoothstep(0.0, rim_width, rim_dot) * rim_width;
	rim = pow(rim, rim_power) * rim_strength;

	// Rim shouldn't exist if the light is completely blocked/cast shadow
	rim *= ATTENUATION;

	// Fade rim based on surface angle (tapering)
	if (lit_part_fersnel_only) {
		// lit_intensity here ensures it fades on self-shadows & cast shadows smoothly.
		float rim_mask = smoothstep(0.0, 1.0, clamp(lit_intensity, 0.0, 1.0));
		rim *= rim_mask;
	}
	DIFFUSE_LIGHT += rim * rim_color;
}