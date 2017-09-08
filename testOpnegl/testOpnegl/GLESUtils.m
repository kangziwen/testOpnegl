//
//  GLESUtils.m
//  testOpnegl
//
//  Created by kzw on 2017/8/28.
//  Copyright © 2017年 kzw. All rights reserved.
//

#import "GLESUtils.h"

@implementation GLESUtils
+(GLuint)loadShader:(GLenum)type withFilepath:(NSString *)shaderpath{
    
    NSError *error=nil;
    NSString *shaderString=[NSString stringWithContentsOfFile:shaderpath encoding:NSUTF8StringEncoding error:&error];
    if(!shaderString){
        NSLog(@"着色器文件加载失败");
        return 0;
    }
    return [self loadShader:type withString:shaderString];
}
//加载编译着色器
+(GLuint)loadShader:(GLenum)type withString:(NSString *)shaderString{
   //创建着色器
    GLuint shader=glCreateShader(type);
    if(shader==0){
        NSLog(@"创建着色器具柄失败");
        return 0;
    }
    const char *shaderStringUTF8=[shaderString UTF8String];
    //加载着色器代码
    glShaderSource(shader, 1, &shaderStringUTF8, NULL);
    //编译
    glCompileShader(shader);
    //获取编译的状态
    GLint compile=0;
    glGetShaderiv(shader, GL_COMPILE_STATUS, &compile);
    if(!compile){
        GLint infoLength=0;
        glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &infoLength);
        if(infoLength>1){
            char *info=malloc(sizeof(char)*infoLength);
            glGetShaderInfoLog(shader, infoLength,NULL, info);
            NSLog(@" %s",info);
            free(info);
        }
        glDeleteShader(shader);
        return 0;
    }
    return shader;
}
//创建连接程序
+(GLuint)loadprogram:(NSString *)vertexShaderpath  withFragment:(NSString *)fragmentShaderpath{
    
    GLuint vertext=[self loadShader:GL_VERTEX_SHADER withFilepath:vertexShaderpath];
    if(vertext==0){
        return 0;
    }
    GLuint fragment=[self loadShader:GL_FRAGMENT_SHADER withFilepath:fragmentShaderpath];
    
    if(fragment==0){
        return 0;
    }
    
    //创建程序
   GLuint program=  glCreateProgram();
    if(program==0)
        return 0;
    glAttachShader(program, vertext);
    glAttachShader(program, fragment);
    //连接程序
    glLinkProgram(program);
    
    GLint link=0;
    glGetProgramiv(program, GL_LINK_STATUS, &link);
    if(!link){
      //连接失败
        GLint infolen=0;
        glGetProgramiv(program, GL_INFO_LOG_LENGTH, &infolen);
        if(infolen>1){
            char *info=malloc(sizeof(char)*infolen);
            glGetProgramInfoLog(program, infolen, NULL, info);
            NSLog(@"program %s",info);
            free(info);
        }
        glDeleteProgram(program);
        return 0;
    }
    
    glDeleteShader(vertext);
    glDeleteShader(fragment);
    return program;
}
@end
