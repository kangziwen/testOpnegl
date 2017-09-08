//
//  OpenGLView.h
//  testOpnegl
//
//  Created by kzw on 2017/8/28.
//  Copyright © 2017年 kzw. All rights reserved.
//

#import <UIKit/UIKit.h>
//矩阵
typedef struct ksMatrix4
{
    float   m[4][4];
} ksMatrix4;
@interface OpenGLView : UIView
//移动x的坐标
@property (nonatomic, assign) float posX;

@end
