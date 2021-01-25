//
//  NIOPerson.m
//  MyLearnIOS
//
//  Created by zhanghuiqiang on 2021/1/24.
//

#import "NIOPerson.h"
#import <objc/runtime.h>
@implementation NIOPerson

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Method m1 = class_getInstanceMethod(self, @selector(introduce));
        Method m2 = class_getInstanceMethod(self, @selector(nio_introduce));
        if (class_addMethod(self, @selector(introduce), method_getImplementation(m1), method_getTypeEncoding(m1))) {
            class_replaceMethod(self, @selector(nio_introduce), method_getImplementation(m2), method_getTypeEncoding(m1));
        } else {
            method_exchangeImplementations(m1, m2);
        }
        
    });
}

- (void)nio_introduce
{
    NSLog(@"nio_introduce");
}
@end
