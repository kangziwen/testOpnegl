//
//  OpenGLView.m
//  testOpnegl
//
//  Created by kzw on 2017/8/28.
//  Copyright © 2017年 kzw. All rights reserved.
//

#import "OpenGLView.h"
#import "GLESUtils.h"
@interface OpenGLView(){
    //程序句柄
    GLuint _program;
    //glslpostion句柄
    GLuint _position;
    //
    GLuint _colorRenderBuffer;
    GLuint _framBuffer;
    //矩阵
    GLint _modelViewSlot;
    //创建矩阵
    ksMatrix4 _modelViewMatrix;


}
@property(nonatomic,strong)CAEAGLLayer *eaglLayer;
@property(nonatomic,strong)EAGLContext *context;

@end
@implementation OpenGLView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupLayer];
        [self setupContext];
        [self setupProgram];
    }
    
    return self;
}
//uiview 方法
+(Class)layerClass{
    // 只有 [CAEAGLLayer class] 类型的 layer 才支持在其上描绘 OpenGL 内容。

    return [CAEAGLLayer class];
}
- (void)setupLayer{
    self.eaglLayer=(CAEAGLLayer *)self.layer;
    // CALayer 默认是透明的，必须将它设为不透明才能让其可见
    self.eaglLayer.opaque=YES;
    // 设置描绘属性，在这里设置不维持渲染内容以及颜色格式为 RGBA8
//    self.eaglLayer.drawableProperties=@{kEAGLDrawablePropertyRetainedBacking:@(NO),kEAGLDrawablePropertyColorFormat:kEAGLColorFormatRGBA8};
    
    // 设置描绘属性，在这里设置不维持渲染内容以及颜色格式为 RGBA8
    _eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                     [NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
}
- (void)setupContext{
    EAGLRenderingAPI api=kEAGLRenderingAPIOpenGLES2;
    self.context=[[EAGLContext alloc] initWithAPI:api];
    if(!self.context){
        NSLog(@"创建context失败");
    }
    if(![EAGLContext setCurrentContext:self.context]){
        NSLog(@"setCurrentContext失败");
    }
    
}
- (void)setupProgram{
    NSString *verstr=[[NSBundle mainBundle] pathForResource:@"VerShader" ofType:@"glsl"];
    NSString *fragmentstr=[[NSBundle mainBundle] pathForResource:@"FragmentShader" ofType:@"glsl"];
    _program=[GLESUtils loadprogram:verstr withFragment:fragmentstr];
    if(_program==0){
        NSLog(@"_program 错误");
        
    }
    glUseProgram(_program);
    _position=glGetAttribLocation(_program, "vPosition");
    
    _modelViewSlot = glGetUniformLocation(_program, "modelView");

    
}
//矩阵变换，更新
- (void)updateTransform{
    //初始化单位矩阵
    ksMatrixLoadIdentity(&_modelViewMatrix);
    ksMatrixTranslate(&_modelViewMatrix,0,0,0);
    ksMatrixScale(&_modelViewMatrix, _posX, _posX, _posX);
    
    /*
     上面这个函数，将我先前创建的矩阵，以数组的形式传递过去。主要的是调用glUniformMatrix4fv这个函数，将矩阵传递到Shader中。它的参数分别为：下标位置，矩阵数量，是否进行转置，矩阵。从中可以看出，我没有对对传递进去的矩阵进行转置操作，因为我觉得在外部我已经构造了column-major形式的矩阵了。
     */
    glUniformMatrix4fv(_modelViewSlot, 1, GL_FALSE, (GLfloat*)&_modelViewMatrix.m[0][0]);
}
- (void)layoutSubviews
{
    [EAGLContext setCurrentContext:_context];
    
    [self destoryBuffers];
    
    [self setupBuffers];
    
    [self updateTransform];
    
    [self render];
}

- (void)setPosX:(float)x
{
    _posX = x;
    [self updateTransform];
    [self render];
}
-(void)destoryBuffers{
    glDeleteRenderbuffers(1, &_colorRenderBuffer);
    _colorRenderBuffer=0;
    glDeleteFramebuffers(1, &_framBuffer);
    _framBuffer=0;
}

-(void)setupBuffers{
    glGenRenderbuffers(1, &_colorRenderBuffer);
//    glBindBuffer(GL_RENDERBUFFER, _colorRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBuffer);
    // 为 color renderbuffer 分配存储空间
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:_eaglLayer];
    
    glGenFramebuffers(1, &_framBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _framBuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _colorRenderBuffer);
}
-(void)render{
    glClearColor(0.0, 1.0, 0.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);

    glViewport(0, 0, self.frame.size.width, self.frame.size.height);
    GLfloat ver[]={
      0.0,0.5,0.0,
        -0.5,-0.5,0.0,
        0.5,-0.5,0.0
    };
    
    glVertexAttribPointer(_position, 3, GL_FLOAT, GL_FALSE, 0, ver);
    glEnableVertexAttribArray(_position);
    glDrawArrays(GL_TRIANGLES, 0, 3);
    [self.context presentRenderbuffer:GL_RENDERBUFFER];
}

//初始化单位矩阵
/*
 1 0 0 0
 0 1 0 0
 0 0 0 1
 0 0 0 1
 */
void ksMatrixLoadIdentity(ksMatrix4 * result)
{
    memset(result, 0x0, sizeof(ksMatrix4));
    
    result->m[0][0] = 1.0f;
    result->m[1][1] = 1.0f;
    result->m[2][2] = 1.0f;
    result->m[3][3] = 1.0f;
}

//位移变化
/*
 位移
 */
void ksMatrixTranslate(ksMatrix4 * result, float tx, float ty, float tz)
{
    result->m[3][0] += (result->m[0][0] * tx + result->m[1][0] * ty + result->m[2][0] * tz);
    result->m[3][1] += (result->m[0][1] * tx + result->m[1][1] * ty + result->m[2][1] * tz);
    result->m[3][2] += (result->m[0][2] * tx + result->m[1][2] * ty + result->m[2][2] * tz);
    result->m[3][3] += (result->m[0][3] * tx + result->m[1][3] * ty + result->m[2][3] * tz);
}

/*
   缩放变换
 */
void ksMatrixScale(ksMatrix4 * result, float sx, float sy, float sz)
{
    result->m[0][0] *= sx;
    result->m[0][1] *= sx;
    result->m[0][2] *= sx;
    result->m[0][3] *= sx;
    
    result->m[1][0] *= sy;
    result->m[1][1] *= sy;
    result->m[1][2] *= sy;
    result->m[1][3] *= sy;
    
    result->m[2][0] *= sz;
    result->m[2][1] *= sz;
    result->m[2][2] *= sz;
    result->m[2][3] *= sz;
}

@end
