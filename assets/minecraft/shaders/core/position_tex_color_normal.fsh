#version 150

/*
MIT License

Copyright (c) 2022 fayer3

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

#moj_import <fog.glsl>

#define MC_CLOUD_VERSION 11802

uniform sampler2D Sampler0;
uniform sampler2D Sampler1;


uniform vec4 ColorModulator;
uniform float FogStart;
uniform float FogEnd;
uniform vec4 FogColor;
uniform int FogShape;

uniform mat4 ProjMat;

in vec2 texCoord0;
in vec3 vertexPosition;
in vec4 vertexColor;
in float isUpper;
in vec3 viewPos;
in mat3 tbnMatrix;

out vec4 fragColor;

uniform mat4 IViewRotMat;

mat3 actualIViewRotMat = mat3(IViewRotMat[0][0], IViewRotMat[0][1], IViewRotMat[0][2], IViewRotMat[0][3], IViewRotMat[1][0], IViewRotMat[1][1], IViewRotMat[1][2], IViewRotMat[1][3], IViewRotMat[2][0]);

#define CLOUDS_3D

void main() {
    vec4 color = texture(Sampler0, texCoord0)*vertexColor;
    gl_FragDepth = gl_FragCoord.z;
    #ifdef CLOUDS_3D
      if (isUpper > 0.5) {
        // get offset direction from viewPos, with tbn matrix
        vec3 viewTangent = normalize(viewPos) * tbnMatrix;
        vec3 viewDirection = viewTangent;
        const float POM_STEPS = 16.0;
        viewDirection.xy = (viewDirection.xy*0.3333) / (-viewDirection.z * POM_STEPS);
        viewDirection.xy /= vec2(textureSize(Sampler0, 0));
        
        float viewPositionStep = ((vertexPosition/abs(vertexPosition.y))*actualIViewRotMat).z;
        viewPositionStep = (viewPositionStep * 4.0) / POM_STEPS;
        vec2 coord = texCoord0;
        // offset by half, so the transition doesn't pop that much
        coord = texCoord0 - viewDirection.xy*POM_STEPS*0.5;
        float viewPosition = viewPos.z - viewPositionStep*POM_STEPS*0.5;
        int i = 0;
        for (; i < POM_STEPS && (texture(Sampler0, fract(coord)).a < 1.0 || viewPosition > 0); ++i) { 
          coord += viewDirection.xy;
          viewPosition += viewPositionStep;
        }
        // write parallax depth
        vec3 viewNorm = (viewTangent * 4.0) / -viewTangent.z;
        vec4 depthc = ProjMat * vec4(viewPos.xyz + tbnMatrix*(viewNorm * (i/POM_STEPS-0.5)), 1.0);
        depthc.z /= depthc.w;
        gl_FragDepth = depthc.z*0.5+0.5;
        
        // calculate normal
        vec3 amount = i == 0 ? vec3(0.0) : vec3(max(((1.0-abs(dot(normalize(viewPos),tbnMatrix[2])))*2.0)*abs(viewDirection.xy), vec2(0.05)/ textureSize(Sampler0, 0)), 0.0);
        vec3 normal = 
          normalize(vec3(
          2.0 * (
            texture(Sampler0, coord - amount.zy).a -
            texture(Sampler0, coord + amount.zy).a),
          2.0 * (
            texture(Sampler0, coord - amount.xz).a -
            texture(Sampler0, coord + amount.xz).a), 
          0.01));
        
        // calculate lighing
        vec3 absNorm = abs(normal);
        float light = dot(absNorm, vec3(1,0,0)) * 0.8 + dot(absNorm, vec3(0,1,0)) * 0.9;
        light = min(light, 0.9) + dot(absNorm, vec3(0,0,1)) * (vertexPosition.y > 0 ? 0.7 : 1.0);
        
      // final color
      color = texture(Sampler0, fract(coord));
      color *= vertexColor;
      color.rgb *= light;
      }
    #endif
    if (color.a < 0.5) {
        discard;
    }
    color *= ColorModulator;
    #if MC_CLOUD_VERSION == 11802
      fragColor = linear_fog(color, fog_distance(mat4(1.0), vertexPosition, FogShape), FogStart, FogEnd, FogColor);
    #elif MC_CLOUD_VERSION == 11801
      fragColor = linear_fog(color, cylindrical_distance(mat4(1.0), vertexPosition), FogStart, FogEnd, FogColor);
    #else
      fragColor = linear_fog(color, length(vertexPosition), FogStart, FogEnd, FogColor);
    #endif
}
