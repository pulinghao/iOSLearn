//
//  NSObject+MultiDelegate.m
//  MyLearnIOS
//
//  Created by pulinghao on 2021/2/1.
//

#import "NSObject+MultiDelegate.h"
#import <objc/runtime.h>

static const NSString *kMultDelegateString = @"kMultiDelegateString";

@implementation NSObject (MultiDelegate)

- (void)setMultiDelegate:(MultiDelegateOC *)multiDelegate
{
    objc_setAssociatedObject(self, kMultDelegateString.UTF8String, multiDelegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (MultiDelegateOC *)multiDelegate
{
    MultiDelegateOC *multiDelegaet = objc_getAssociatedObject(self, kMultDelegateString.UTF8String);
//    MultiDelegateOC *multiDelegate = objc_getAssociatedObject(self,@selector(multiDelegate));
    if (multiDelegaet == nil) {
        multiDelegaet = [[MultiDelegateOC alloc] init];
        objc_setAssociatedObject(self, kMultDelegateString.UTF8String, multiDelegaet, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return multiDelegaet;
}


- (void)addMultiDelegate:(id)delegate
{
    [self.multiDelegate addDelegate:delegate];
}

- (void)addDelegate:(id)delegate beforeDelegate:(id)otherDelegate
{
    [self.multiDelegate addDelegate:self beforeDelegate:otherDelegate];
}
- (void)addDelegate:(id)delegate afterDelegate:(id)otherDelegate
{
    [self.multiDelegate addDelegate:self afterDelegate:otherDelegate];
}


- (void)removeMultiDelegate:(id)delegate
{
    [self.multiDelegate removeDelegate:self];
}

- (void)removeAllDelegates
{
    [self.multiDelegate removeAllDelegates];
}
@end
