#version 450 core


layout(location = 0) in vec3 vertexPosition;
layout(location = 1) in vec3 colorBufferVertex;
uniform mat4 MVP;
out vec3 colorBuffer;


void main() {
    gl_Position=MVP*vec4(vertexPosition,1.0);
    colorBuffer=colorBufferVertex;

}
