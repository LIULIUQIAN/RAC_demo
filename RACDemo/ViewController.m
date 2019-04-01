//
//  ViewController.m
//  RACDemo
//
//  Created by 刘六乾 on 2019/3/25.
//  Copyright © 2019年 刘六乾. All rights reserved.
//

#import "ViewController.h"
#import "ReactiveObjC.h"
#import "TestView.h"
#import "TestModel.h"
#import "RACReturnSignal.h"

@interface ViewController ()
@property (nonatomic, assign) int count;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self demo20];
    
}
#pragma mark -信号过滤
-(void)demo20{
    UITextField *name = [[UITextField alloc] initWithFrame:CGRectMake(100, 100, 200, 44)];
    name.backgroundColor = [UIColor yellowColor];
    [self.view addSubview:name];
    
    [[name.rac_textSignal filter:^BOOL(NSString * _Nullable value) {
        return value.length > 6 && value.length < 10;
    }] subscribeNext:^(NSString * _Nullable x) {
        NSLog(@"%@",x);
    }];
}

#pragma mark -信号合并
-(void)demo19{
    UITextField *name = [[UITextField alloc] initWithFrame:CGRectMake(100, 100, 200, 44)];
    name.backgroundColor = [UIColor yellowColor];
    [self.view addSubview:name];
    
    UITextField *pwd = [[UITextField alloc] initWithFrame:CGRectMake(100, 150, 200, 44)];
    pwd.backgroundColor = [UIColor yellowColor];
    [self.view addSubview:pwd];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(100, 200, 100, 100)];
    [btn setTitle:@"点击" forState:(UIControlStateNormal)];
    btn.backgroundColor = [UIColor blueColor];
    [self.view addSubview:btn];
    [[btn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        NSLog(@"%@",x);
    }];
    
    [[name.rac_textSignal combineLatestWith:pwd.rac_textSignal] subscribeNext:^(RACTwoTuple<NSString *,id> * _Nullable x) {
        RACTupleUnpack(NSString *name, NSString *pwd) = x;
        btn.enabled = name.length > 0 && pwd.length > 0;
    }];
    
    [[RACSignal combineLatest:@[name.rac_textSignal,pwd.rac_textSignal] reduce:^id(NSString *name ,NSString *pwd){
        return @(name.length > 0 && pwd.length > 0);
    }] subscribeNext:^(id  _Nullable x) {
        btn.enabled = [x boolValue];
    }];
}
#pragma mark -zipWith
-(void)demo18{
    RACSubject *s1 = [RACReplaySubject subject];
    RACSubject *s3 = [RACReplaySubject subject];
    
    [s1 sendNext:@"s1"];
    [s3 sendNext:@"s3"];
    
    [[s3 zipWith:s1] subscribeNext:^(id  _Nullable x) {
        
        RACTupleUnpack(NSString *str1, NSString *str2) = x;
        NSLog(@"%@ %@",str1,str2);
        
    }];
}
#pragma mark -merge
-(void)demo17{
    RACSubject *s1 = [RACReplaySubject subject];
    RACSubject *s2 = [RACReplaySubject subject];
    RACSubject *s3 = [RACReplaySubject subject];
    
    [s2 sendNext:@"s2"];
    [s1 sendNext:@"s1"];
    [s3 sendNext:@"s3"];
    
    [[[s3 merge:s1] merge:s2] subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@",x);
    }];
}
#pragma mark -then:忽略信号
-(void)demo16{
    [[[self signal1] then:^RACSignal * _Nonnull{
        return [self signal2];
    }] subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@",x);
    }];
}

-(RACSignal *)signal1{
    RACSubject *signal = [RACReplaySubject subject];
    [self loadData1:^(id data) {
        //loadDtat2需要loadDtat1的参数可以在此做记录
        [signal sendNext:data];
        [signal sendCompleted];
    }];
    return signal;
}
-(RACSignal *)signal2{
    RACSubject *signal = [RACReplaySubject subject];
    [self loadDtat2:^(id data) {
        [signal sendNext:data];
        [signal sendCompleted];
    }];
    return signal;
}
-(void)loadData1:(void(^)(id))success{
    success(@"第一个请求数据");
}
-(void)loadDtat2:(void(^)(id))success{
    success(@"第二个请求数据");
}

#pragma mark -flattenMap/map
-(void)demo15{
    RACSubject *s1 = [RACReplaySubject subject];
    RACSubject *s2 = [RACReplaySubject subject];
    RACSubject *s3 = [RACReplaySubject subject];
    
    [s1 sendNext:@"s1"];
    [s1 sendCompleted];
    [s2 sendNext:@"s2"];
    [s2 sendCompleted];
    [s3 sendNext:@"s3"];
    [s3 sendCompleted];
    
    [[[s2 concat:s3] concat:s1] subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@",x);
    }];
}
#pragma mark -flattenMap/map
-(void)demo14{
    UITextField *field = [[UITextField alloc] initWithFrame:CGRectMake(100, 100, 200, 44)];
    field.backgroundColor = [UIColor yellowColor];
    [self.view addSubview:field];
    
    [[field.rac_textSignal flattenMap:^__kindof RACSignal * _Nullable(NSString * _Nullable value) {
        return [RACReturnSignal return:[NSString stringWithFormat:@"修改文本框输入的值：%@",value]];
    }] subscribeNext:^(id  _Nullable x) {
        NSLog(@"==%@",x);
    }];
    
    [[field.rac_textSignal map:^id _Nullable(NSString * _Nullable value) {
        return [NSString stringWithFormat:@"修改文本框输入的值：%@",value];
    }] subscribeNext:^(id  _Nullable x) {
        NSLog(@"==%@",x);
    }];

}
#pragma mark -多个信号发送完成后统一调用
-(void)demo13{
    RACSignal *signal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [subscriber sendNext:@"signal1"];
        [subscriber sendCompleted];
        return nil;
    }];
    
    RACSignal *signal2 = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [subscriber sendNext:@"signal2"];
        [subscriber sendCompleted];
        return nil;
    }];
    
    [self rac_liftSelector:@selector(endMethods:str2:) withSignalsFromArray:@[signal,signal2]];
}
-(void)endMethods:(NSString *)str1 str2:(NSString *)str2{
    
    NSLog(@"str1 =%@",str1);
    NSLog(@"str2 =%@",str2);
}

#pragma mark -监听文本改变
-(void)demo12{
    UITextField *field = [[UITextField alloc] initWithFrame:CGRectMake(100, 100, 200, 44)];
    field.backgroundColor = [UIColor yellowColor];
    [self.view addSubview:field];
    
    [field.rac_textSignal subscribeNext:^(NSString * _Nullable x) {
        
        NSLog(@"%@",x);
    }];
}

#pragma mark -监听通知
-(void)demo11{
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:@"changeName" object:nil] subscribeNext:^(NSNotification * _Nullable x) {
        NSLog(@"%@",x);
    }];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"changeName" object:nil userInfo:@{@"name":@"zhangsan"}];
}
#pragma mark -监听按钮点击
-(void)demo10{
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
    [btn setTitle:@"点击" forState:(UIControlStateNormal)];
    btn.backgroundColor = [UIColor blueColor];
    [self.view addSubview:btn];
    [[btn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        NSLog(@"%@",x);
    }];
}

#pragma mark -代替KVO
-(void)demo9{
    //KVO
    [[self rac_valuesForKeyPath:@keypath(self, count) observer:self] subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@",x);
    }];
    
    [RACObserve(self, count) subscribeNext:^(id  _Nullable x) {
        
        NSLog(@"%@",x);
    }];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    self.count++;
}

#pragma mark -RACCommand监听按钮点击
-(void)demo8{
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
    [btn setTitle:@"点击" forState:(UIControlStateNormal)];
    btn.backgroundColor = [UIColor blueColor];
    [self.view addSubview:btn];
    
    RACSubject *enableSignal = [RACSubject subject];
    btn.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        
        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            // 信号Block
            [subscriber sendNext:input];
            
            // 请求完成的时候去调用
            [subscriber sendCompleted];
            return nil;
        }];
    }];
    
    [[btn.rac_command.executing skip:1] subscribeNext:^(NSNumber * _Nullable x) {
        BOOL executing = [x boolValue];
        [enableSignal sendNext:@(!executing)];
    }];
    
    // 监听
    [btn.rac_command.executionSignals.switchToLatest subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@",x);
    }];
    
}
#pragma mark -RACCommand
-(void)demo7{
    // 创建RACCommand
    RACCommand *command = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        
        NSLog(@"RACCommand,%@",input);
        
        // 创建信号
        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            
            [subscriber sendNext:@"data"];
            [subscriber sendCompleted];
            return nil;
        }];
    }];
    
    //订阅RACCommand中的信号
    //    [command.executionSignals subscribeNext:^(id  _Nullable x) {
    //
    //        NSLog(@"%@",x);
    //        [x subscribeNext:^(id  _Nullable x) {
    //            NSLog(@"%@",x);
    //        }];
    //    }];
    //订阅RACCommand中的信号(第二种写法)
    [command.executionSignals.switchToLatest subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@",x);
    }];
    
    // 监听命令是否执行完毕,skip表示跳过第一次信号
    [[command.executing skip:1] subscribeNext:^(NSNumber * _Nullable x) {
        if ([x boolValue]) {
            NSLog(@"正在执行");
        }else{
            NSLog(@"执行完成");
        }
    }];
    
    // 执行RACCommand
    [command execute:@"11"];
    
}

#pragma mark -RACMulticastConnection解决信号被多次订阅
-(void)demo6{
    RACSignal *signal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        
        NSLog(@"信号被订阅");
        
        [subscriber sendNext:@"data"];
        
        return nil;
    }];
    
    //    [signal subscribeNext:^(id  _Nullable x) {
    //        NSLog(@"%@",x);
    //    }];
    //
    //    [signal subscribeNext:^(id  _Nullable x) {
    //        NSLog(@"%@",x);
    //    }];
    
    RACMulticastConnection *connection = [signal publish];
    [connection.signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@",x);
    }];
    
    [connection.signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@",x);
    }];
    
    [connection connect];
}

#pragma mark -遍历数组/字典/字典转模型
-(void)demo5{
    //遍历数组
    NSArray *ary = @[@"11",@"22",@"33"];
    [ary.rac_sequence.signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@",x);
    }];
    
    //遍历字典
    NSDictionary *dic = @{@"a":@"11",@"b":@"22",@"c":@"33"};
    [dic.rac_sequence.signal subscribeNext:^(id  _Nullable x) {
        RACTupleUnpack(NSString *key, NSString *value) = x;
        NSLog(@"%@=%@",key,value);
    }];
    
    //字典转模型
    NSArray *dicArray = @[@{@"name":@"zhangsan",@"describe":@"zhangsanxxxx"},
                          @{@"name":@"lisi",@"describe":@"lisixxxx"},
                          @{@"name":@"wangwu",@"describe":@"wangwuxxxx"}];
    
    NSArray *arrayM = [[dicArray.rac_sequence map:^id _Nullable(id  _Nullable value) {
        return [TestModel initDic:value];
    }] array];
    NSLog(@"%@",arrayM);
}
#pragma mark -RAC代理
-(void)demo4{
    TestView *view = [[TestView alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
    view.backgroundColor = UIColor.blueColor;
    [self.view addSubview:view];
    
    RACSubject *subject = [RACSubject subject];
    view.subject = subject;
    [subject subscribeNext:^(id  _Nullable x) {
        
        NSLog(@"%@",x);
        
    }];
}
#pragma mark -RACReplaySubject
-(void)demo3{
    RACReplaySubject *subject = [RACReplaySubject subject];
    [subject sendNext:@"123"];
    
    [subject subscribeNext:^(id  _Nullable x) {
        
        NSLog(@"%@",x);
    }];
    
    [subject subscribeNext:^(id  _Nullable x) {
        
        NSLog(@"%@",x);
    }];
}
#pragma mark -RACSubject
-(void)demo2{
    // 必须先订阅 在发送信号
    // 创建信号
    RACSubject *subject = [RACSubject subject];
    // 订阅
    [subject subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@",x);
    }];
    [subject subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@",x);
    }];
    // 发送信号
    [subject sendNext:@"data"];
}

#pragma mark -RACSignal简单创建
-(void)demo1{
    //创建信号
    RACSignal *signal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        // 发送信号变化
        NSLog(@"RACSignal");
        
        [subscriber sendNext:@"data"];
        [subscriber sendCompleted];
        
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"RACDisposable");
        }];
    }];
    
    // 订阅信号
    [signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"x=%@",x);
    } error:^(NSError * _Nullable error) {
        NSLog(@"error");
    } completed:^{
        NSLog(@"completed");
    }];
}


@end
