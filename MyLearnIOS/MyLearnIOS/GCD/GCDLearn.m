//
//  GCDLearn.m
//  MyLearnIOS
//
//  Created by zhanghuiqiang on 2021/1/28.
//

#import "GCDLearn.h"

@implementation GCDLearn

- (void)test{
    dispatch_queue_t queueA = dispatch_queue_create("queueA", NULL);
    dispatch_queue_t queueB = dispatch_queue_create("queueB", NULL);
//    NSLog(@"A======%@， B=====%@",queueA, queueB);
//    dispatch_sync(queueA, ^{
//        NSLog(@"A-------%@", dispatch_get_current_queue());
//        dispatch_sync(queueB, ^{
//            NSLog(@"B-------%@", dispatch_get_current_queue());
//            if(queueA != dispatch_get_current_queue()){
//                dispatch_sync(queueA, ^{ // queueA同步死锁
//
//                 });
//            }
//        });
//    });
    
    dispatch_sync(queueA, ^{
        dispatch_async(queueA, ^{
            dispatch_sync(queueA, ^{
                NSLog(@"");
            });
        });
    });
    

}


- (void)test2
{
    dispatch_queue_t queue = dispatch_queue_create("com.demo.queue", DISPATCH_QUEUE_SERIAL);
    dispatch_queue_t conqueue = dispatch_queue_create("com.demo.queue", DISPATCH_QUEUE_CONCURRENT);

    dispatch_async(queue, ^{
        NSLog(@"%@",[NSThread currentThread]);
        dispatch_sync(conqueue, ^{
            NSLog(@"%@",[NSThread currentThread]);
            NSLog(@"1");
        });
        
        NSLog(@"2");

        dispatch_async(conqueue, ^{
            NSLog(@"%@",[NSThread currentThread]);
            NSLog(@"3");
        });

        NSLog(@"4");
    });
    
}
@end