//
//  GCDLearn.m
//  MyLearnIOS
//
//  Created by zhanghuiqiang on 2021/1/28.
//

#import "GCDLearn.h"

typedef struct Student{
    char *name;
    int  age;
    int  classNum;
}Student;

typedef void(^myBlock)();
@interface GCDLearn()

@property (nonatomic, copy) myBlock block;


@end

@implementation GCDLearn

- (instancetype)init
{
    self = [super init];
    if (self) {
        dispatch_block_t blk =
        dispatch_block_create_with_qos_class(0, QOS_CLASS_UTILITY, 0, ^{
            
        });
        
        
        Student s ={
            .name = "Kt",
            .age = 13,
            .classNum = 1,
        };
        Student p;
        p.name = "pP";
        p.age = 11;
        p.classNum = 2;
        dispatch_async(dispatch_get_main_queue(), blk);
    }
    return self;
}

- (void)test{
    dispatch_queue_t queueA = dispatch_queue_create("queueA", NULL);
    dispatch_async(queueA, ^{
        [self performSelector:@selector(test2) withObject:[NSObject new] afterDelay:1.0];
    });
    
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
    dispatch_sync(queue, ^{
        
    });
    dispatch_queue_t conqueue = dispatch_queue_create("com.demo.queue", DISPATCH_QUEUE_CONCURRENT);

    dispatch_async(queue, ^{
        NSLog(@"%@",[NSThread currentThread]);
        dispatch_async(queue, ^{
            NSLog(@"%@",[NSThread currentThread]);
            NSLog(@"1");
        });
        
        NSLog(@"2");

        dispatch_async(queue, ^{
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
//    dispatch_queue_t serial = dispatch_queue_create("myqueue", DISPATCH_QUEUE_SERIAL);
//    dispatch_queue_t con = dispatch_queue_create("conqueue", DISPATCH_QUEUE_CONCURRENT);
//    for (int i = 0; i < 20; i++) {
//            dispatch_async(serial, ^{
//                NSLog(@"plh %d",i);
//            });
//    }
    dispatch_queue_t serial1 = dispatch_queue_create("myqueue1", DISPATCH_QUEUE_SERIAL);
    dispatch_queue_t serial2 = dispatch_queue_create("myqueue2", DISPATCH_QUEUE_SERIAL);
    dispatch_async(serial1, ^{
        dispatch_async(serial2, ^{
            //
            NSLog(@"task1--%@",[NSThread currentThread]);
        });
        
        dispatch_sync(serial2, ^{
            // 这个任务会等待task1执行完，因为队列里现在有一个任务了，等待执行
            NSLog(@"task2--%@",[NSThread currentThread]);
        });
        
        // 这个任务会等待task 2执行完
        NSLog(@"task3--%@",[NSThread currentThread]);

    });
}

- (void)threadExplosion
{
    dispatch_queue_t con = dispatch_queue_create("myqueue", DISPATCH_QUEUE_CONCURRENT);
    // bad
    for (int i = 0; i < 999; i++) {
        dispatch_async(con, ^{
            NSLog(@"%d",i);
        });
    }
    dispatch_barrier_sync(con, ^{
        // do sth.
    });
    
    //good
    dispatch_apply(999, con, ^(size_t i) {
        NSLog(@"%d",i);
    });
    
    
}


/// 学习使用 dispatch_set_target_queue
/// dispatch_set_target_queue 函数有两个作用：第一，变更队列的执行优先级；第二，目标队列可以成为原队列的执行阶层。
/// 第一个参数是要执行变更的队列（不能指定主队列和全局队列）
/// 第二个参数是目标队列（指定全局队列）
- (void)useTargetQueue
{
    //优先级变更的串行队列，初始是默认优先级
    dispatch_queue_t serialQueue = dispatch_queue_create("com.gcd.setTargetQueue.serialQueue", NULL);

    //优先级不变的串行队列（参照），初始是默认优先级
    dispatch_queue_t serialDefaultQueue = dispatch_queue_create("com.gcd.setTargetQueue.serialDefaultQueue", NULL);

    //变更前
    dispatch_async(serialQueue, ^{
        NSLog(@"1");
    });
    dispatch_async(serialDefaultQueue, ^{
        NSLog(@"2");
    });

    //获取优先级为后台优先级的全局队列
    dispatch_queue_t globalDefaultQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    
    // 将 serialQueue 的优先级，设置为 DISPATCH_QUEUE_PRIORITY_BACKGROUND 的全局队列优先级一样
    dispatch_set_target_queue(serialQueue, globalDefaultQueue);

    //变更后
    dispatch_async(serialQueue, ^{
        NSLog(@"1");
    });
    dispatch_async(serialDefaultQueue, ^{
        NSLog(@"2");
    });
}

/// 设置执行阶层
- (void)useTargetQueue2
{
    dispatch_queue_t serialQueue1 = dispatch_queue_create("com.gcd.setTargetQueue2.serialQueue1", NULL);
    dispatch_queue_t serialQueue2 = dispatch_queue_create("com.gcd.setTargetQueue2.serialQueue2", NULL);
    dispatch_queue_t serialQueue3 = dispatch_queue_create("com.gcd.setTargetQueue2.serialQueue3", NULL);
    dispatch_queue_t serialQueue4 = dispatch_queue_create("com.gcd.setTargetQueue2.serialQueue4", NULL);
    dispatch_queue_t serialQueue5 = dispatch_queue_create("com.gcd.setTargetQueue2.serialQueue5", NULL);
    
    dispatch_async(serialQueue1, ^{
        NSLog(@"1");
    });
    dispatch_async(serialQueue2, ^{
        NSLog(@"2");
    });
    dispatch_async(serialQueue3, ^{
        NSLog(@"3");
    });
    dispatch_async(serialQueue4, ^{
        NSLog(@"4");
    });
    dispatch_async(serialQueue5, ^{
        NSLog(@"5");
    });
    
    // 使用target queue
    //创建目标串行队列
    dispatch_queue_t targetSerialQueue = dispatch_queue_create("com.gcd.setTargetQueue2.targetSerialQueue", NULL);

    //设置执行阶层
    dispatch_set_target_queue(serialQueue1, targetSerialQueue);
    dispatch_set_target_queue(serialQueue2, targetSerialQueue);
    dispatch_set_target_queue(serialQueue3, targetSerialQueue);
    dispatch_set_target_queue(serialQueue4, targetSerialQueue);
    dispatch_set_target_queue(serialQueue5, targetSerialQueue);
    
    dispatch_async(serialQueue1, ^{
        NSLog(@"1");
    });
    dispatch_async(serialQueue2, ^{
        NSLog(@"2");
    });
    dispatch_async(serialQueue3, ^{
        NSLog(@"3");
    });
    dispatch_async(serialQueue4, ^{
        NSLog(@"4");
    });
    dispatch_async(serialQueue5, ^{
        NSLog(@"5");
    });
    
}

- (void)deadLocktTest
{
    // 串行死锁的例子（这里不会crash，在线程A执行串行任务task1的过程中，又在线程B中投递了一个task2到串行队列同时使用dispatch_sync等待，死锁，但GCD不会测出）
        //==============================
    dispatch_queue_t sQ1 = dispatch_queue_create("st01", 0);
    dispatch_async(sQ1, ^{
        NSLog(@"Enter");
        dispatch_sync(dispatch_get_main_queue(), ^{
            dispatch_sync(sQ1, ^{
                NSArray *a = [NSArray new];
                NSLog(@"Enter again %@", a);
            });
        });
        NSLog(@"Done");
    });
}

// 美团的面试题
- (void)meituanInterview
{
    __block int a = 0;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
    while (a < 5) {
        
            NSLog(@"%@ ==== %d",[NSThread currentThread],a);
            a ++;
        
    }
    });
    
    NSLog(@"%@ *** %d",[NSThread currentThread],a);
}
@end
