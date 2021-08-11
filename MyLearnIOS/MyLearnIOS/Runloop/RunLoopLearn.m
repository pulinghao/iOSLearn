//
//  RunLoopLearn.m
//  MyLearnIOS
//
//  Created by pulinghao on 2021/8/10.
//

#import "RunLoopLearn.h"

static RunLoopLearn *g_runLoop = nil;

@interface RunLoopLearn(){
    CFRunLoopObserverRef _observer;
    CFRunLoopActivity _activity;
    CFRunLoopTimerRef _timer;
}

@end



@implementation RunLoopLearn

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_runLoop = [[self alloc] init];
    });
    return g_runLoop;
}

- (void)startMonitor
{
    CFRunLoopObserverContext context = {0,(__bridge  void *)self,NULL,NULL};
    CFRunLoopTimerContext timeContext = {0, (__bridge  void *)self, NULL, NULL, NULL};
    _observer = CFRunLoopObserverCreate(kCFAllocatorDefault, kCFRunLoopAllActivities, YES, 0, &runLoopObserverCallBack, &context);
    
    _timer = CFRunLoopTimerCreate(kCFAllocatorDefault, CFAbsoluteTimeGetCurrent(), 1.0, 0, 0, &runloopTimerCallBack, &timeContext);
    CFRunLoopAddObserver(CFRunLoopGetMain(), _observer, kCFRunLoopCommonModes);
//    CFRunLoopAddTimer(CFRunLoopGetMain(), _timer, kCFRunLoopCommonModes);
    
    dispatch_block_t blk = ^{
        NSLog(@"plh log monitoring");
    };
    CFRunLoopPerformBlock(CFRunLoopGetMain(), kCFRunLoopCommonModes, blk);
}


- (void)stopMonitor
{
    if (!_observer) {
        return;
    }
    
    CFRunLoopRemoveObserver(CFRunLoopGetMain(), _observer, kCFRunLoopCommonModes);
    CFRelease(_observer);
    _observer = nil;
    
    if (_timer) {
        CFRunLoopTimerInvalidate(_timer);
        CFRelease(_timer);
        _timer = 0;
    }
}

static void runloopTimerCallBack(CFRunLoopTimerRef timer, void*info){
    RunLoopLearn *object = (__bridge RunLoopLearn *)info;
    NSLog(@"runloopTimerCallBack ");
}
//static void
static void runLoopObserverCallBack(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info){
    RunLoopLearn *object = (__bridge RunLoopLearn *)info;
    object->_activity = activity;
    
    /* Run Loop Observer Activities */
//    typedef CF_OPTIONS(CFOptionFlags, CFRunLoopActivity) {
//        kCFRunLoopEntry = (1UL << 0),    // 进入RunLoop循环(这里其实还没进入)
//        kCFRunLoopBeforeTimers = (1UL << 1),  // RunLoop 要处理timer了
//        kCFRunLoopBeforeSources = (1UL << 2), // RunLoop 要处理source了
//        kCFRunLoopBeforeWaiting = (1UL << 5), // RunLoop要休眠了
//        kCFRunLoopAfterWaiting = (1UL << 6),   // RunLoop醒了
//        kCFRunLoopExit = (1UL << 7),           // RunLoop退出（和kCFRunLoopEntry对应）
//        kCFRunLoopAllActivities = 0x0FFFFFFFU
//    };
    
    if (activity == kCFRunLoopEntry) {  // 即将进入RunLoop
        NSLog(@"runLoopObserverCallBack - %@",@"kCFRunLoopEntry");
    } else if (activity == kCFRunLoopBeforeTimers) {    // 即将处理Timer
        NSLog(@"runLoopObserverCallBack - %@",@"kCFRunLoopBeforeTimers");
    } else if (activity == kCFRunLoopBeforeSources) {   // 即将处理Source
        NSLog(@"runLoopObserverCallBack - %@",@"kCFRunLoopBeforeSources");
    } else if (activity == kCFRunLoopBeforeWaiting) {   //即将进入休眠
        NSLog(@"runLoopObserverCallBack - %@",@"kCFRunLoopBeforeWaiting");
    } else if (activity == kCFRunLoopAfterWaiting) {    // 刚从休眠中唤醒
        NSLog(@"runLoopObserverCallBack - %@",@"kCFRunLoopAfterWaiting");
    } else if (activity == kCFRunLoopExit) {    // 即将退出RunLoop
        NSLog(@"runLoopObserverCallBack - %@",@"kCFRunLoopExit");
    } else if (activity == kCFRunLoopAllActivities) {
        NSLog(@"runLoopObserverCallBack - %@",@"kCFRunLoopAllActivities");
    }
    
}


@end
