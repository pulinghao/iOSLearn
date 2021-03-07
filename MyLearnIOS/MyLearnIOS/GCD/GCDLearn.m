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

- (void)test3
{
    __block int i = 10;
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"%d",i);
    });
    i = 20;
}

- (void)test4
{
    NSLog(@"A");
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"B");
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"C");
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"D");
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"E");
                });
            });
        });
        
        dispatch_sync(dispatch_get_global_queue(0, 0), ^{
            NSLog(@"F");
            NSLog(@"current thread:%@",[NSThread currentThread]);
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"G");
            });
        });
    });
    NSLog(@"I");
    
}

- (void)test5
{
    dispatch_queue_t serial = dispatch_queue_create("myqueue", DISPATCH_QUEUE_SERIAL);
    dispatch_queue_t con = dispatch_queue_create("conqueue", DISPATCH_QUEUE_CONCURRENT);
    for (int i = 0; i < 20; i++) {
//        dispatch_async(con, ^{
            wait(1);
            dispatch_async(serial, ^{
                NSLog(@"plh %d",i);
            });
//        });
    }
}
@end
