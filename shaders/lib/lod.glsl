float get_lod() {
    float dist = depth; 
    float curve = log2(sqrt(dist) * 0.15 - (RENDER_SCALE * 0.1));
    float resBias = log2(RENDER_SCALE) * 0.333;

    float bias = (curve) + resBias;
    return clamp(bias, -4.0, 4.0);
}