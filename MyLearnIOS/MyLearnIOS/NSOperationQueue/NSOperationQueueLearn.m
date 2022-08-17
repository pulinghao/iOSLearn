//
//  NSOperationQueueLearn.m
//  MyLearnIOS
//
//  Created by zhanghuiqiang on 2021/1/29.
//

#import "NSOperationQueueLearn.h"

@interface MyOperation : NSOperation

@end

@implementation MyOperation

- (void)main{
    NSLog(@"my operation");
}

@end

@implementation NSOperationQueueLearn

- (void)test
{
    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(network:) object:@{@"name":@"moxiaohui"}];
    [operation waitUntilFinished];
    [operation setName:@"moxiaoyan"];
    [operation setCompletionBlock:^{ // 任务执行完成后在子线程中执行
      NSLog(@"Completion %@", [NSThread currentThread]);
    }];
    [operation start];
    NSLog(@"是否阻塞主线程"); // 会
    // 执行结果:
    // 执行 operation <NSThread: 0x600000c24040>{number = 1, name = main} {
//    name = moxiaohui;
  
    // 完成 operation
    // 是否阻塞主线程
    // Completion <NSThread: 0x600003139680>{number = 4, name = (null)}
}

- (void)network:(NSDictionary *)info {
  NSLog(@"执行 operation %@ %@", [NSThread currentThread], info);
  sleep(2);
  NSLog(@"完成 operation");
}

- (void)testQueue
{
    // 1. NSInvocationOperation
    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(network:) object:@{@"name":@"moxiaohui"}];
    [operation setName:@"moxiaoyan"];
    [operation setCompletionBlock:^{ // 任务执行完成后在子线程中执行
      NSLog(@"Completion %@", [NSThread currentThread]);
    }];
//    [operation start];
//    NSLog(@"是否阻塞主线程"); // 会
//    // 可以设置特殊的先后执行顺序：addDependency
////    [operation2 addDependency:operation1]; // 添加依赖
////    [operation3 removeDependency:operation1]; // 移除依赖
//
//    [operation start];  // NSInvocationOperation alloc init 创建的需要手动开启
//    [operation cancel]; // 取消单个任务，只会对还未执行的任务有效
//    [operation waitUntilFinished]; // 阻塞当前线程，直到任务执行完毕后继续 (最好不要在主线程中等待，会阻塞)
//    // 观察任务状态:
//    [operation isReady];  // 是否就绪
//    [operation isExecuting]; // 是否正在执行中
//    [operation isFinished]; // 是否执行完毕
//    [operation isCancelled];  // 是否已取消
//    [operation isAsynchronous]; // 是否异步执行
//    [operation isConcurrent]; // 已废弃，用`isAsynchronous`
//    NSOperationQueuePriority priority = [operation queuePriority]; // 优先级
//    NSArray<NSOperation *> *dependencies = [operation dependencies]; // 依赖的任务数组

    // 2.NSBlockOperation
    NSBlockOperation *block = [NSBlockOperation blockOperationWithBlock:^{ // 默认在主线程中
      NSLog(@"执行2 block %@", [NSThread currentThread]);
      sleep(1);
      NSLog(@"完成2 block");
    }];
    // 通过 addExecutionBlock 添加的任务，会开辟多个子线程，并发执行
//    [block addExecutionBlock:^{
//      NSLog(@"执行3 block %@", [NSThread currentThread]);
//      sleep(1);
//      NSLog(@"完成3 block");
//    }];
//    [block addExecutionBlock:^{
//      NSLog(@"执行4 block %@", [NSThread currentThread]);
//      sleep(3);
//      NSLog(@"完成4 block");
//    }];
//    [block addExecutionBlock:^{
//      NSLog(@"执行5 block %@", [NSThread currentThread]);
//      sleep(2);
//      NSLog(@"完成5 block");
//    }];
//    [block start];
    
    // 3.NSOperationQueue
        // NSOperationQueue 创建队列，管理Operation对象，根据Operation开辟适量的线程
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    // 设置最大并发数: 1:串行 >=2:并行  默认:-1(无穷大)
    // 注意：设置的是队列里面最多能并发运行的操作任务个数，而不是线程个数, (另外开启线程的数量是由系统决定的，所以这个值具体表示什么？)
    [queue setMaxConcurrentOperationCount:2];
    // 将任务添加到队列中
    [queue addOperation:operation];
    NSLog(@"是否阻塞主线程");
    [queue addOperation:block];
    [queue addOperationWithBlock:^{
      NSLog(@"执行6 %@", [NSThread currentThread]);
      sleep(2);
      NSLog(@"完成6");
    }];
    [queue addBarrierBlock:^{ // 队列中所有任务完成后执行
      NSLog(@"all complete");
    }];
//    [queue setSuspended:YES]; // 暂停队列
//    [queue setSuspended:NO];  // 继续队列
//    [queue cancelAllOperations]; // 取消所有任务
//    [queue waitUntilAllOperationsAreFinished]; // 阻塞当前线程，直到所有任务执行完毕后继续(最好不要在主线程中等待，会阻塞)
}

- (void)reloadData:(NSString *)str
{
    
}

- (void)clearData{
    
}
@end
