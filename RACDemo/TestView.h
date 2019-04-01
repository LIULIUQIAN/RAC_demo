//
//  TestView.h
//  RACDemo
//
//  Created by 刘六乾 on 2019/3/25.
//  Copyright © 2019年 刘六乾. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ReactiveObjC.h"

NS_ASSUME_NONNULL_BEGIN

@interface TestView : UIView

@property (nonatomic, strong) RACSubject *subject;

@end

NS_ASSUME_NONNULL_END
