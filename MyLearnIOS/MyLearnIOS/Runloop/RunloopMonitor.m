//
//  RunloopMonitor.m
//  MyLearnIOS
//
//  Created by pulinghao on 2021/8/30.
//  使用Runloop来进行性能检测

#import "RunloopMonitor.h"

static RunloopMonitor *g_runLoop = nil;


@interface RunloopMonitor(){
    CFRunLoopObserverRef _observer;
    BOOL _isMonitoring;
    CFRunLoopActivity _currentActivity;
    dispatch_semaphore_t _sema;
}

@end
@implementation RunloopMonitor


+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_runLoop = [[self alloc] init];
    });
    return g_runLoop;
}


- (instancetype)init
{
    self = [super init];
    if (self) {
        _isMonitoring = YES;
        [self addContext];
    }
    return self;
}

- (void)addContext
{
    CFRunLoopObserverContext context = {
        0,
        (__bridge void *)self,
        &CFRetain,
        &CFRelease,
        NULL
    };
    
    _observer = CFRunLoopObserverCreate(kCFAllocatorDefault, kCFRunLoopAllActivities, YES, 0, &runloopCallBack, &context);
    CFRunLoopAddObserver(CFRunLoopGetMain(), _observer, kCFRunLoopCommonModes);
    
}

#define WAIT_TIME 1
#define OUT_TIME 100*NSEC_PER_MSEC
- (void)startMonitor
{
    _sema = dispatch_semaphore_create(0);
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        while (self->_isMonitoring) {
            if (self->_currentActivity == kCFRunLoopBeforeWaiting) {
                // 处理休眠前的事件
                __block BOOL timeOut = YES;
                // 添加一个任务到主队列中，如果这个任务超过了WAIT_TIME，那么就说明超时了
                dispatch_async(dispatch_get_main_queue(), ^{
                    timeOut = NO;
                });
                // 子线程等待了WAIT_TIME的时间
                [NSThread sleepForTimeInterval:WAIT_TIME];
                if (timeOut) {
                    NSLog(@"before waiting time out");
                }
            } else {
                // 处理timer，source和唤醒后的事件
                long result = dispatch_semaphore_wait(self->_sema,  dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC));
                if (result != 0) {
                    // 说明任务超时了
                    NSLog(@"after waiting time out");
                }
            }
        }
    });
}
static void runloopCallBack(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info)
{
    RunloopMonitor *object = (__bridge RunloopMonitor *)info;
    object->_currentActivity = activity;
    dispatch_semaphore_t sema = object->_sema;
    dispatch_semaphore_signal(sema);
}
@end
