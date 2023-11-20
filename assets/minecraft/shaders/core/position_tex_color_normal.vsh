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

#define MC_CLOUD_VERSION 11802

#if MC_CLOUD_VERSION == 11700
  const float VANILLA_CLOUD_HEIGHT = 128.0;
#else
  const float VANILLA_CLOUD_HEIGHT = 192.0;
#endif

const float CLOUD_HEIGHT = 192.00000000;
const float CLOUD_HEIGHT_LAYER2 = 220.00000000;
const float CLOUD_HEIGHT_LAYER3 = 256.00000000;

#moj_import <fog.glsl>

in vec3 Position;
in vec2 UV0;
in vec4 Color;
in vec3 Normal;

uniform mat4 ProjMat;
uniform mat4 ModelViewMat;
uniform mat4 IViewRotMat;

mat3 actualIViewRotMat = mat3(IViewRotMat[0][0], IViewRotMat[0][1], IViewRotMat[0][2], IViewRotMat[0][3], IViewRotMat[1][0], IViewRotMat[1][1], IViewRotMat[1][2], IViewRotMat[1][3], IViewRotMat[2][0]);


uniform sampler2D Sampler0;

out vec2 texCoord0;
out vec3 vertexPosition;
out vec4 vertexColor;
out float isUpper;

out vec3 viewPos;
out mat3 tbnMatrix;

//#define FAST_CLOUDS

void offsetCloudPlane(float newHeight, float upper, vec2 uvOffset, vec2 positionOffset) {
  isUpper = upper;
  texCoord0 = UV0 + (Position.xz + uvOffset) / vec2(textureSize(Sampler0, 0));
  
  vec3 newPosition = vec3(
    (Position.x + positionOffset.x)*2.0, 
    Position.y + (newHeight - VANILLA_CLOUD_HEIGHT) - sign(Normal.y)*2.0, 
    (Position.z + positionOffset.y)*2.0);
  
  vertexPosition = actualIViewRotMat*(ModelViewMat * vec4(newPosition, 1.0)).xyz;
  
  if (upper > 0.5){
    tbnMatrix = mat3(
      vec3(1,0,0) * actualIViewRotMat,
      vec3(0,0,1) * actualIViewRotMat,
      vec3(0,-sign(vertexPosition.y),0) * actualIViewRotMat);
    if (Normal.y < 0.0){
      vertexColor.rgb *= 1.4285714285714285714285714285714;
    }
  }
  if (upper < -0.5) {
    if (CLOUD_HEIGHT != VANILLA_CLOUD_HEIGHT) {
      newPosition.y -= sign(vertexPosition.y)*2.0;
      vertexPosition = actualIViewRotMat*(ModelViewMat * vec4(newPosition, 1.0)).xyz;
    } else {
      newPosition.y += sign(Normal.y)*2.0;
      vertexPosition = actualIViewRotMat*(ModelViewMat * vec4(newPosition, 1.0)).xyz;
    }
    if (Normal.y < 0.0 && vertexPosition.y < 0) {
      vertexColor.rgb *= 1.4285714285714285714285714285714;
    } else if (Normal.y > 0.0 && vertexPosition.y > 0) {
      vertexColor.rgb *= 0.7;
    }
  }
  viewPos = (ModelViewMat * vec4(newPosition, 1.0)).xyz;
  
  gl_Position = ProjMat * vec4(viewPos, 1.0);
}
void main() {
  
    isUpper = 0.0;
    texCoord0 = UV0;
    vertexColor = Color;
    
    if (abs(Normal.y) > 0.9) {
      gl_Position = vec4(-10.0);
      float playerDistance = (actualIViewRotMat*(ModelViewMat * vec4(Position, 1.0)).xyz).y;
      // prefere downfacing plane, since that is the only one for fast clouds
      if (( Normal.y < 0.0) || (((Position.z < 7.9  || (Position.z < 8.1 && (gl_VertexID % 4 == 0 || gl_VertexID % 4 == 1)) && (CLOUD_HEIGHT == VANILLA_CLOUD_HEIGHT)) || playerDistance < 0.0) && Normal.y > 0.0)) {
      #ifdef FAST_CLOUDS
        if (Position.x < -0.1  || (Position.x < 0.1 && (gl_VertexID % 4 == 1 || gl_VertexID % 4 == 2))) {
          if (Position.z < -0.1  || (Position.z < 0.1 && (gl_VertexID % 4 == 0 || gl_VertexID % 4 == 1))) {
      #else
        if (Position.x < 7.9  || (Position.x < 8.1 && (gl_VertexID % 4 == 1 || gl_VertexID % 4 == 2))) {
          if (Position.z < 7.9  || (Position.z < 8.1 && (gl_VertexID % 4 == 0 || gl_VertexID % 4 == 1))) {
      #endif
            // usual top/bottom
            #ifndef FAST_CLOUDS
            offsetCloudPlane(CLOUD_HEIGHT, -1.0, vec2(-40.0, 24.0), vec2(-20.0, 12.0));
            #endif
          } else {
            // layer2
            offsetCloudPlane(CLOUD_HEIGHT_LAYER2, 1.0, vec2(24.0, -40.0)+vec2(0.5)*textureSize(Sampler0, 0), vec2(12.0, -20.0));
          }
        }
        else { // try not to offset if both sides are drawn
        #ifdef FAST_CLOUDS
          if (Position.z < -0.1  || (Position.z < 0.1 && (gl_VertexID % 4 == 0 || gl_VertexID % 4 == 1))) {
        #else
          if (Position.z < 7.9  || (Position.z < 8.1 && (gl_VertexID % 4 == 0 || gl_VertexID % 4 == 1))) {
        #endif
            // opposite top/bottom
            offsetCloudPlane(CLOUD_HEIGHT, -1.0, vec2(-40.0, 24.0), vec2(-20.0, 12.0));
          } else {
            //layer3
            offsetCloudPlane(CLOUD_HEIGHT_LAYER3, 1.0, vec2(-40.0, -40.0)+vec2(0.25, 0.75)*textureSize(Sampler0, 0), vec2(-20.0, -20.0));
          }
        }
      }
    } else {
      vec3 newPosition = Position+vec3(0, CLOUD_HEIGHT - VANILLA_CLOUD_HEIGHT,0);
      vertexPosition = actualIViewRotMat*(ModelViewMat * vec4(newPosition, 1.0)).xyz;
      gl_Position = ProjMat * ModelViewMat * vec4(newPosition, 1.0);
    }
}
