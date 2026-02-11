shader_type spatial;

uniform vec3 albedo_color : source_color = vec3(1.0, 1.0, 1.0);

uniform float diffuse_threshold : hint_range(0.0, 1.0) = 0.5;
uniform float shadow_strength : hint_range(0.0, 1.0) = 0.5;

uniform float specular_threshold : hint_range(0.9, 1.0) = 0.99;
uniform float specular_strength : hint_range(0.0, 4.0) = 2.0;
uniform vec3 specular_color : source_color = vec3(1.0, 1.0, 1.0);

uniform float rim_width = 2.0;
uniform float rim_power = 4.0;
uniform float rim_strength : hint_range(0.0, 2.0) = 1.0;
uniform vec3 rim_color : source_color = vec3(1.0, 1.0, 1.0);

void light() {

	float ndotl = dot(NORMAL, LIGHT);
	float diffuse_step = ndotl > diffuse_threshold ? 1.0 : 0.0;

	vec3 diffuse_col = diffuse_step == 0.0
		? albedo_color * shadow_strength
		: albedo_color;

	DIFFUSE_LIGHT = diffuse_col;

	vec3 H = normalize(LIGHT + VIEW);
	float spec = dot(NORMAL, H);
	float spec_step = spec > specular_threshold ? 1.0 : 0.0;

	SPECULAR_LIGHT = specular_color * specular_strength * spec_step;

	float rim_dot = 1.0 - dot(VIEW, NORMAL);
	float rim = smoothstep(0.0, rim_width, rim_dot) * rim_width;
	rim = pow(rim, rim_power) * rim_strength;

	DIFFUSE_LIGHT += rim * rim_color;
}
