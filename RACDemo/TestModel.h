//
//  TestModel.h
//  RACDemo
//
//  Created by 刘六乾 on 2019/3/25.
//  Copyright © 2019年 刘六乾. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TestModel : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *describe;
+(instancetype)initDic:(NSDictionary *)dic;

@end

NS_ASSUME_NONNULL_END
