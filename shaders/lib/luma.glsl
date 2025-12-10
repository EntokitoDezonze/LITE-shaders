/* MakeUp - LITE shaders 4.7.3 - luma.glsl
Luma related functions.

Javier Garduño - GNU Lesser General Public License v3.0
*/

float luma(vec3 color) {
    return dot(color, vec3(0.2126, 0.7152, 0.0722));
} // Number of luminance of color.

vec3 v3_luma(vec3 color) {
    float luma = dot(color, vec3(0.2126, 0.7152, 0.0722));
    return vec3(luma);
} // Equivalent to saturate(color, 0.0)

float color_average(vec3 color) {
    return (color.r + color.g + color.b) / 3;
} // Color average between red, green, and blue channels.

vec3 saturate(vec3 color, float saturation) {
    vec3 luma = vec3(luma(color));
    return mix(luma, color, saturation);
} // Apply saturation to a color based on a float, 1.0 is the default

vec4 saturate_v4(vec4 color, float saturation) {
    vec3 luma = vec3(luma(color.rgb));
    return mix(vec4(luma, color.a), vec4(color.rgb, color.a), saturation);
} // Same as saturate, but for vec4, designed to not affect alpha channel (transparency.)

vec3 vibrance(vec3 color, float amount) {
    float sat = max(color.r, max(color.g, color.b)) - min(color.r, min(color.g, color.b));

    float increase_factor = (1.0 - sat) * amount;
    float final_sat = 1.0 + max(0.0, increase_factor);

    return saturate(color, final_sat);
} // Only saturates low-saturation colors.