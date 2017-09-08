//
//  GLESUtils.h
//  testOpnegl
//
//  Created by kzw on 2017/8/28.
//  Copyright © 2017年 kzw. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>
@interface GLESUtils : NSObject
//创建连接程序
+(GLuint)loadprogram:(NSString *)vertexShaderpath  withFragment:(NSString *)fragmentShaderpath;
@end
