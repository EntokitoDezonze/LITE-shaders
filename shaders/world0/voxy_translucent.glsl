layout(location = 0) out vec4 out_translucent_color;

void voxy_emitFragment(VoxyFragmentParameters parameters) {

    if (parameters.sampledColour.a < 0.05) {
        discard;
    }
    
    out_translucent_color = vec4(1.0);
}