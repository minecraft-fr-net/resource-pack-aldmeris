#version 150

uniform sampler2D Sampler0;

uniform vec4 ColorModulator;

in vec2 texCoord0;
in vec2 progress;

out vec4 fragColor;

void main() {
    vec2 uv = texCoord0;
    vec4 color = texture(Sampler0, uv);
    int fuel = int(round(progress.x/progress.y));
    vec2 atlassize = textureSize(Sampler0, 0);
    if (atlassize.y == 1335 && fuel == clamp(fuel, 0, 14) && ivec2(uv*atlassize).y > 170) {
        uv.y += fuel*83./atlassize.y;
        color = texture(Sampler0, uv);
    }
    if (color.a == 0.0) discard;
    fragColor = color * ColorModulator;
}