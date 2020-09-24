#version 450 core


out vec3 color;
in vec3 colorBuffer;


void main() {
    // color=vec3(1.0,1.0,0.0);
    // color=vec3(gl_FragCoord.x/1024,0.0,gl_FragCoord.y/768);
    color=colorBuffer;
}
