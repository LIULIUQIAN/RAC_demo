//
//  TestModel.m
//  RACDemo
//
//  Created by 刘六乾 on 2019/3/25.
//  Copyright © 2019年 刘六乾. All rights reserved.
//

#import "TestModel.h"

@implementation TestModel
+(instancetype)initDic:(NSDictionary *)dic{
    TestModel *m = [[TestModel alloc] init];
    [m setValuesForKeysWithDictionary:dic];
    return m;
}
@end
