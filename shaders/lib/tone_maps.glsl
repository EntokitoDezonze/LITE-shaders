/* MakeUp - LITE shaders 4.8 - tone_maps.glsl
Tonemap functions.

Javier Garduño - GNU Lesser General Public License v3.0
*/

vec3 custom_sigmoid(vec3 color) {
    color = 1.4 * color;
    color = color / pow(pow(color, vec3(2.5)) + 1.0, vec3(0.4));

    return pow(color, vec3(1.15));
}

vec3 custom_sigmoid_alt(vec3 color) {
    color = 1.4 * color;
    color = color / pow(pow(color, vec3(2.5)) + 1.0, vec3(0.4));

    return pow(color, vec3(1.2));
}

vec3 Lottes(vec3 x, float expo) { // MakeUp legacy Lottes
    // Lottes 2016, "Advanced Techniques and Optimization of HDR Color Pipelines"
    // float a = 1.3;
    // float d = 0.997;
    // float midIn = 0.2;
    // float midOut = 0.24;

    float pow_a = pow(expo, 1.2961);
    float pow_b = pow(expo, 1.3);
    float product_a = (pow_a * 0.24) - 0.02980411421941949;

    float b =
        (-0.12340677254400192 + pow_b * 0.24) /
        product_a;
    float c =
        (pow_a * 0.12340677254400192 - pow_b * 0.02980411421941949) /
        product_a;

    return pow(x, vec3(1.3)) / (pow(x, vec3(1.2961)) * b + c);
}

vec3 ACESFilm(vec3 x, float outputWhitePoint) {
    const float a = 2.51;
    const float b = 0.03;
    const float c = 2.43;
    const float d = 0.59;
    const float e = 0.14;

    vec3 mapped = (x * (a * x + b)) / (x * (c * x + d) + e);
    mapped = mapped * (1.0 + mapped / (outputWhitePoint * outputWhitePoint));
    
    #ifdef HDR
        return mapped;
    #else
        return clamp(mapped, 0.0, 1.0);
    #endif
}
