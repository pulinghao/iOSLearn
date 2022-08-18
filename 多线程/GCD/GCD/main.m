//
//  main.m
//  GCD
//
//  Created by pulinghao on 2022/8/18.
//

#import <Foundation/Foundation.h>
int I = 0;

void test(){
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_async(group, queue, ^{
        NSLog(@"blk0");
    });
    dispatch_group_async(group, queue, ^{
        sleep(2);
        NSLog(@"blk1");
    });
    dispatch_group_async(group, queue, ^{
        NSLog(@"blk2");
    });
    
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 2ull * NSEC_PER_SEC);
    long result = dispatch_group_wait(group, time);
    if (result == 0) {
        // 全部任务执行完成
        NSLog(@"done");
    } else {
        // 某个任务还在执行
        NSLog(@"false");
    }
}

void test2(){
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_apply(10, queue, ^(size_t index) {
        NSLog(@"%zu",index);
    });
    
    
}



void test3(){
    dispatch_semaphore_t sema = dispatch_semaphore_create(1);
    
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 2ull * NSEC_PER_SEC);
    long result = dispatch_semaphore_wait(sema, time);
    if (result == 0) {
        // 如果sema >= 1，则-1,并返回0
    } else {
        // 否则返回非0
    }
}

void timer(){
    // 定时器任务
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    
    // 5s后执行任务,允许延迟1s
    dispatch_source_set_timer(timer, dispatch_time(DISPATCH_TIME_NOW, 5ull * NSEC_PER_SEC), DISPATCH_TIME_FOREVER, 1ull * NSEC_PER_SEC);
    
    // 指定事件
    dispatch_source_set_event_handler(timer, ^{
        NSLog(@"wake up");
    
        // 这儿取消
    });
    
    dispatch_source_set_cancel_handler(timer, ^{
        NSLog(@"取消");
    });
    
    // 启动timer
    dispatch_resume(timer);
}
int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        NSLog(@"Hello, World!");
//        while(1){
            timer();
        
        sleep(20);
//        }
//        test2();
        
    }
    return 0;
}




