#version 150

in vec3 Position;
in vec2 UV0;

uniform sampler2D Sampler0;
uniform mat4 ModelViewMat;
uniform mat4 ProjMat;
uniform vec2 ScreenSize;

out vec2 texCoord0;
out vec2 progress;

//0 3
//1 2

void main() {
    texCoord0 = UV0;
    vec3 pos = Position;
    float guiscale = ProjMat[0][0] * ScreenSize.x * 0.5;
    vec2 atlassize = textureSize(Sampler0, 0);
    if (atlassize.y == 1335) {
        ivec2 uv = ivec2(UV0*256);
        switch (gl_VertexID % 4) {
            case 0: if (uv.x == 176 && uv.y < 14) {
                progress = vec2(uv.y,1);
                pos.xy += vec2(-56,-36 - uv.y);
                uv = ivec2(0, 173);
            } break;
            case 1: if (uv == ivec2(176, 13)) {
                progress = vec2(0);
                pos.xy += vec2(-56, 34);
                uv = ivec2(0, 256);
            } break;
            case 2: if (uv == ivec2(190, 13)) {
                progress = vec2(0);
                pos.xy += vec2(106, 34);
                uv = ivec2(176, 256);
            } break;
            case 3: if (uv.x == 190 && uv.y < 14) {
                progress = vec2(uv.y,1);
                pos.xy += vec2(106,-36 - uv.y);
                uv = ivec2(176, 173);
            } break;
        }
        texCoord0 = uv / atlassize;
    }
    gl_Position = ProjMat * ModelViewMat * vec4(pos, 1.0);
}
