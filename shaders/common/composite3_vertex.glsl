#include "/lib/config.glsl"

// == Varyings

varying vec2 texcoord;

// == Main function

void main() {
    gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
    texcoord = gl_MultiTexCoord0.xy;
}