//
//  ViewController.m
//  条件锁
//
//  Created by pulinghao on 2022/8/4.
//
#import "ViewController.h"

@interface ViewController ()
{
    NSCondition *_condition;
    NSMutableArray *_list;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _condition = [[NSCondition alloc] init];
   _list = [NSMutableArray array];
    [[[NSThread alloc] initWithTarget:self selector:@selector(startProduct) object:nil] start];
    [[[NSThread alloc] initWithTarget:self selector:@selector(startConsume) object:nil] start];
    [_condition broadcast]; // 通知所有在等在等待中的线程
}

- (void)startProduct{
    [self product];
}
- (void)startConsume
{
    [self consume];
}

- (void)product
{
    while (_list.count > 0) {
        [_condition lock];
        [_condition wait];
    }
    NSLog(@"开始生产");
    NSObject *obj = NSObject.new;
    [_list addObject:obj];
    NSLog(@"生产完成:%p",obj);
    [_condition signal];//通知等待中的线程（只对一个线程起作用）
    [_condition unlock];

}

- (void)consume
{
    while (_list.count == 0) {
        [_condition lock];
        [_condition wait];
    }
    NSObject *obj = _list.firstObject;
    NSLog(@"开始消费:%p",obj);
    [_list removeObjectAtIndex:0];
    NSLog(@"消费完成");
    [_condition signal];
    [_condition unlock];
}

@end

