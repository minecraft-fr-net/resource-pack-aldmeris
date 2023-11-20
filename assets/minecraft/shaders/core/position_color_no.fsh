#version 150

in vec4 vertexColor;
uniform vec4 ColorModulator;

out vec4 fragColor;

void main() {

    vec3 pos1, pos2, pos3;
pos1 = pos2 = pos3 = vec3(0);

switch (gl_VertexID % 4) {
    case 0: cornerPos1 = vec3(pos.xy,1); break;
    case 1: cornerPos2 = vec3(pos.xy,1); break;
    case 2: cornerPos3 = vec3(pos.xy,1); break;
}

    vec2 cornerPx1 = cornerPos1.xy / cornerPos1.z;
vec2 cornerPx2 = cornerPos2.xy / cornerPos2.z;
vec2 cornerPx3 = cornerPos3.xy / cornerPos3.z;
vec2 minPos = min(cornerPx1, min(cornerPx2, cornerPx3));
vec2 maxPos = max(cornerPx1, max(cornerPx2, cornerPx3));

float quadHeight = int( round( abs( (minPos.y - maxPos.y) ) ) );
float quadWidth = int( round( abs( (minPos.x - maxPos.x) ) ) );

    vec4 color = vertexColor;
    if (color.a == 0.0) {
        discard;
    }
    fragColor = color * ColorModulator;
}
