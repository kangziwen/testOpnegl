attribute vec4 vPosition;
uniform mat4 modelView;
void main(void){
    gl_Position = modelView*vPosition;
}
