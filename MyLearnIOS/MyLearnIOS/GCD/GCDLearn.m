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

@end
