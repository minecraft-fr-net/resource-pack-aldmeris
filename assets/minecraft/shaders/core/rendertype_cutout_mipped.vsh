#version 150

#moj_import <light.glsl>
#moj_import <fog.glsl>

in vec3 Position;
in vec4 Color;
in vec2 UV0;
in ivec2 UV2;
in vec3 Normal;

uniform sampler2D Sampler2;
uniform sampler2D Sampler0;
uniform float GameTime;

uniform mat4 ModelViewMat;
uniform mat4 ProjMat;
uniform vec3 ChunkOffset;
uniform int FogShape;

out float vertexDistance;
out vec4 vertexColor;
out vec2 texCoord0;
out vec4 normal;

#define pi 3.1415926535897932

void main() {



    // beliebe this makes teh animations of blocks wave with teh size of a chunk so they aren't just the same for all blocks
    vec3 pos = Position + ChunkOffset;


    // why divide by 2 and multiply by pi more info needed
	vec3 position = Position / 2.0 * pi;

    //constant value going up
    float animation = GameTime * 4000.0;

    float xs = 0.0;
    float zs = 0.0;
    float ys = 0.0;
	float alpha = texture(Sampler0, UV0).a * 255.0;
    if (alpha == 1.0 || alpha == 2.0 || alpha == 252.0) {

        ys = sin(animation);

    }
    if (alpha == 2.0) {
        xs *= 2.0;
        zs *= 2.0;
        ys *= 2.0;

    }

    gl_Position = ProjMat * ModelViewMat * (vec4(pos, 1.0) + vec4( 0.0, ys / 32.0  ,  0.0, 0.0));

    vertexDistance = fog_distance(ModelViewMat, pos, FogShape);
    vertexColor = Color * minecraft_sample_lightmap(Sampler2, UV2);
    texCoord0 = UV0;
    normal = ProjMat * ModelViewMat * vec4(Normal, 0.0);
}
