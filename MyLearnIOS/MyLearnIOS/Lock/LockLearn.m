//
//  LockLearn.m
//  MyLearnIOS
//
//  Created by pulinghao on 2021/1/29.
//

#import "LockLearn.h"
#import <libkern/OSAtomic.h>
#import <pthread.h>
#import <os/lock.h>

// 按目前的耗时排序
//  [self osspinLock];            // 1. OSSpinLock 自旋锁 (会导致优先级反转，不再安全iOS10+废弃)
// https://blog.ibireme.com/2016/01/16/spinlock_is_unsafe_in_ios/?utm_source=tuicool
//  [self osUnfairLock];          // 1. os_unfair_lock 互斥锁 (iOS10+, 休眠)
//  [self semaphore];             // 2. dispatch_semaphore 信号量，保证关键代码不并发执行
//  [self pthreadMutex];          // 3. pthread_mutex 互斥锁 (苹果做出了优化, 性能不比semaphore差, 而且肯定安全)
//  [self nsLock];                // 4. NSLock 互斥锁 (封装了pthread_mutex，type是PTHREAD_MUTEX_ERRORCHECK，也就是当同一个线程获得同一个锁的时候，会返回错误)
//  [self nsCondition];           // 5. NSCondition 条件锁 (用pthread_cond_t实现NSLocking协议, 能实现NSLock所有功能, 封装了一个互斥锁和信号量)
//  [self pthreadMutexRecursive]; // 6. pthread_mutex(recursive) 递归锁 需要设置PTHREAD_MUTEX_RECURSIVE
//  [self nsRecursiveLock];       // 7. NSRecursiveLock 递归锁
//  [self nsConditionLock];       // 8. NSConditionLock 条件锁
//  [self synchronized];          // 9. @synchronized 互斥锁 (用pthread_mutex_t实现的) OC层面，传入一个OC对象，通过对象的哈希值来作为标识符得到互斥锁，存入到一个数组里面
//  [self deadLock];  // 死锁

//  [self POSIX_Codictions]; // POSIXConditions 条件锁：互斥锁 + 条件锁
//  [self pthreadReadWrite]; // 读写锁
@interface LockLearn()

@property (nonatomic, strong) NSMutableArray *items;

@end

@implementation LockLearn{
    pthread_mutex_t mutex;
    pthread_cond_t condition;
    Boolean ready_to_go;
}


/// 自旋锁
- (void)testOSSpinLock{
    NSArray *items = @[@"1", @"2", @"3",@"4",@"5"];
    self.items = [[NSMutableArray alloc] init];
    __block OSSpinLock osslock = OS_SPINLOCK_INIT; // 初始化
    for (int i = 0; i < items.count; i++) {
      dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        OSSpinLockLock(&osslock); // 加锁
        sleep(items.count - i);
        [self.items addObject:items[i]];
        NSLog(@"current thread : %@",[NSThread currentThread]);
        NSLog(@"%@", self.items);
        OSSpinLockUnlock(&osslock); // 解锁
      });
    }
}

- (void)testOSSpinLock2{
    __block OSSpinLock oslock = OS_SPINLOCK_INIT;
    //线程1
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"线程1 准备上锁");
        OSSpinLockLock(&oslock);
        sleep(4);
        NSLog(@"线程1");
        NSLog(@"当前线程:%@",[NSThread currentThread]);
//        OSSpinLockUnlock(&oslock);
        NSLog(@"线程1 解锁成功");
        NSLog(@"--------------------------------------------------------");
    });

    //线程2
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"线程2 准备上锁");
        OSSpinLockLock(&oslock);
        // 线程2在这里会等待线程1 执行完，在执行下面的任务
        NSLog(@"线程2");
        NSLog(@"当前线程:%@",[NSThread currentThread]);
        OSSpinLockUnlock(&oslock);
        NSLog(@"线程2 解锁成功");
    });
}

- (void)testOSUnfairLock
{
    NSArray *items = @[@"1", @"2", @"3",@"4",@"5"];
    self.items = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < items.count; i++) {
      dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        os_unfair_lock_t unfairLock = &(OS_UNFAIR_LOCK_INIT); // 必须在线程里初始化
        os_unfair_lock_lock(unfairLock); // 加锁
        sleep(items.count - i);
        [self.items addObject:items[i]];
        NSLog(@"线程1 资源1: %@", self.items);
        os_unfair_lock_unlock(unfairLock); // 解锁
      });
    }
}

- (void)testPThread
{
    // 必须是全局变量，局部变量会被CPU回收
    static pthread_mutex_t pLock;
    // 初始化锁
    pthread_mutex_init(&pLock, NULL);
     //1.线程1
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"线程1 准备上锁");
        pthread_mutex_lock(&pLock);
        sleep(3);
        NSLog(@"线程1");
        pthread_mutex_unlock(&pLock);
    });

    //1.线程2
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"线程2 准备上锁");
        int value = pthread_mutex_lock(&pLock);
        NSLog(@"value :%d",value);
        NSLog(@"线程2");
        pthread_mutex_unlock(&pLock);
    });
}

- (void)testRecursiveLock
{
    static pthread_mutex_t pLock;
    pthread_mutexattr_t attr;
    pthread_mutexattr_init(&attr); //初始化attr并且给它赋予默认
    pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_RECURSIVE); //设置锁类型，这边是设置为递归锁
    pthread_mutex_init(&pLock, &attr);
    pthread_mutexattr_destroy(&attr); //销毁一个属性对象，在重新进行初始化之前该结构不能重新使用

    //1.线程1
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        static void (^RecursiveBlock)(int);
        RecursiveBlock = ^(int value) {
            pthread_mutex_lock(&pLock);
            if (value > 0) {
                NSLog(@"value: %d", value);
                RecursiveBlock(value - 1);
            }
            pthread_mutex_unlock(&pLock);
        };
        RecursiveBlock(5);
    });
}

- (void)testConditionLock
{
    NSCondition *cLock = [NSCondition new];
    //线程1
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"start");
        [cLock lock];
        [cLock waitUntilDate:[NSDate dateWithTimeIntervalSinceNow:2]];
        // 2s后，打印线程1
        NSLog(@"线程1");
        [cLock unlock];
    });
}

// 与信号量很像
- (void)testCondition2
{
    NSCondition *cLock = [NSCondition new];
    //线程1
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [cLock lock];
        NSLog(@"线程1加锁成功");
        [cLock wait];
        NSLog(@"线程1");
        [cLock unlock];
    });

    //线程2
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [cLock lock];
        NSLog(@"线程2加锁成功");
        [cLock wait];
        NSLog(@"线程2");
        [cLock unlock];
    });

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        sleep(2);
        NSLog(@"唤醒一个等待的线程");
        [cLock signal];
    });
}

// 下面重复加锁，会造成死锁
- (void)testNSLock
{
    NSLock *rLock = [NSLock new];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        static void (^RecursiveBlock)(int);
        RecursiveBlock = ^(int value) {
            [rLock lock];
            if (value > 0) {
                NSLog(@"线程%d", value);
                RecursiveBlock(value - 1);
            }
            [rLock unlock];
        };
        RecursiveBlock(4);
    });
}

- (void)testConditionLock2
{
    NSConditionLock *cLock = [[NSConditionLock alloc] initWithCondition:0];

    //线程1
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if([cLock tryLockWhenCondition:0]){
            NSLog(@"线程1");
           [cLock unlockWithCondition:1];
        }else{
             NSLog(@"失败");
        }
    });

    //线程2
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [cLock lockWhenCondition:3];
        NSLog(@"线程2");
        [cLock unlockWithCondition:2];
    });

    //线程3
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [cLock lockWhenCondition:1];
        NSLog(@"线程3");
        [cLock unlockWithCondition:3];
    });
}

#pragma mark - POSIXConditions 条件锁 互斥锁 + 条件锁
- (void)POSIX_Codictions {
  // 线程被一个 互斥 和 条件 结合的信号来唤醒
  ready_to_go = false;
  pthread_mutex_init(&mutex, NULL);
  pthread_cond_init(&condition, NULL);
  
  [self waitOnConditionFunction];
  [self signalThreadUsingCondition];
  // 参考: https://juejin.im/post/5a0a92996fb9a0451f307479
}

- (void)waitOnConditionFunction {
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    pthread_mutex_lock(&mutex); // Lock the mutex.
    while(ready_to_go == false) {
      NSLog(@"wait...");
      pthread_cond_wait(&condition, &mutex); // 休眠
    }
    NSLog(@"done");
    ready_to_go = false;
    pthread_mutex_unlock(&mutex);
  });
}

- (void)signalThreadUsingCondition {
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    pthread_mutex_lock(&mutex); // Lock the mutex.
    ready_to_go = true;
    NSLog(@"true");
    pthread_cond_signal(&condition); // Signal the other thread to begin work.
    pthread_mutex_unlock(&mutex);
  });
}


// 读写锁
- (void)pthreadReadWrite {
  __block pthread_rwlock_t rwLock;
  pthread_rwlock_init(&rwLock, NULL);

  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    pthread_rwlock_wrlock(&rwLock);
    NSLog(@"3 写 begin");
    sleep(3);
    NSLog(@"3 写 end");
    pthread_rwlock_unlock(&rwLock);
  });

  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    pthread_rwlock_rdlock(&rwLock);
    NSLog(@"1 读 begin");
    sleep(1);
    NSLog(@"1 读 end");
    pthread_rwlock_unlock(&rwLock);
  });

  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    pthread_rwlock_rdlock(&rwLock);
    NSLog(@"2 读 begin");
    sleep(2);
    NSLog(@"2 读 end");
    pthread_rwlock_unlock(&rwLock);
  });
}
@end
