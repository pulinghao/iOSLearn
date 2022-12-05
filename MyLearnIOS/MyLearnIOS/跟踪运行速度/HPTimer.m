//
//  HPTimer.m
//  MyLearnIOS
//
//  Created by pulinghao on 2022/8/10.
//

#import "HPTimer.h"
#import <mach/mach.h>


@interface HPTimer ()

@property (nonatomic, strong) HPTimer *parent;
@property (nonatomic, strong) NSMutableArray *children;
@property (nonatomic, assign) uint64_t startTime;
@property (nonatomic, assign) uint64_t stopTime;
@property (nonatomic, assign) BOOL  stopped;

@property (nonatomic, copy) NSString *threadName;

@end
@implementation HPTimer

+ (HPTimer *)startWithName:(NSString *)name{
    NSMutableDictionary *tls = [[NSThread currentThread] threadDictionary];
    HPTimer *top = [tls objectForKey:@"hp-timer-top"];
    HPTimer *rv = [[HPTimer alloc] initWithParent:top name:name];
    [tls setObject:rv forKey:@"hp-timer-top"];
    rv.startTime = mach_absolute_time();
    return rv;
}

- (instancetype)initWithParent:(HPTimer *)parent name:(NSString *)name{
    if (self = [super init]) {
        self.parent = parent;
        self.name = name;
        self.stopped = NO;
        self.children = [NSMutableArray array];
        self.threadName = [NSThread currentThread].name;
        if (parent) {
            [parent.children addObject:self];
        }
    }
    return self;
}

- (uint64_t)stop{
    self.stopTime = mach_absolute_time();
    self.stopped = YES;
    self.timeNanos = self.stopTime - self.startTime;
    NSMutableDictionary *tls = [NSThread currentThread].threadDictionary;
    if (self.parent) {
        [tls setObject:self.parent forKey:@"hp-timer-top"];
    }
    return  self.timeNanos;
}

- (void)printTree{
    [self printTreeWithNode:self intent:@""];
}

- (void)printTreeWithNode:(HPTimer *)node intent:(NSString *)intent{
    if (node) {
        NSLog(@"HPTimer:>>>>%@[%@][%@]->%lld ns",intent,self.threadName,self.name,self.timeNanos);
        NSArray *children = node.children;
        if (children.count > 0) {
            intent = [intent stringByAppendingString:@" "];
            for (NSUInteger i = 0; i < children.count; i++) {
                [self printTreeWithNode:[children objectAtIndex:i] intent:intent];
            }
        }
    }
}

@end
