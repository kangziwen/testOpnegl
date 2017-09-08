//
//  ViewController.m
//  testOpnegl
//
//  Created by kzw on 2017/8/28.
//  Copyright © 2017年 kzw. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (strong, nonatomic)  UISlider *slider;

@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    self.glView = [[OpenGLView alloc] initWithFrame:screenBounds];
    [self.view addSubview:self.glView];
    
    
    self.slider=[[UISlider alloc] initWithFrame:CGRectMake(20, self.view.frame.size.height-60,  self.view.frame.size.width-20, 30)];
    [self.view addSubview:self.slider];
    
    [self.slider addTarget:self action:@selector(changeSlider:) forControlEvents:UIControlEventValueChanged];
}
- (IBAction)changeSlider:(UISlider *)sender {
    NSLog(@"value=%f",sender.value);
    self.glView.posX=sender.value;
}





@end
