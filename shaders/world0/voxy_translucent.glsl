layout(location = 0) out vec4 out_translucent_color;

void voxy_emitFragment(VoxyFragmentParameters parameters) {
    // Voxy usa o buffer 0 (colorTex0) para a cor transparente.
    // É crucial que você gerencie o blend/alpha corretamente.
    
    // Supondo que a cor amostrada já tenha o alpha
    if (parameters.sampledColour.a < 0.05) {
        discard;
    }
    
    out_translucent_color = vec4(1.0);
}