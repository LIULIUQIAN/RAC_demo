//
//  TestView.m
//  RACDemo
//
//  Created by 刘六乾 on 2019/3/25.
//  Copyright © 2019年 刘六乾. All rights reserved.
//

#import "TestView.h"

@implementation TestView

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    [self.subject sendNext:@"123"];
}

@end

