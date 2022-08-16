//
//  RuntimeLearn.m
//  MyLearnIOS
//
//  Created by zhanghuiqiang on 2021/1/18.
//

#import "RuntimeLearn.h"
#import "Person.h"
#import "Dog.h"
#import <objc/runtime.h>

struct method_t {
    // The representation of a "big" method. This is the traditional
    // representation of three pointers storing the selector, types
    // and implementation.
    struct big {
        SEL name;
        const char *types;
        IMP imp;
    }selbig;
    
};
@implementation RuntimeLearn

- (void)exchangeMethod
{
    Person *p = [[Person alloc] init];
    [p walk];
    
    Method oldMethod = class_getInstanceMethod([Person class], @selector(walk));
    Method newMethod = class_getInstanceMethod([Person class], @selector(run));
    struct method_t *newMethod2 = class_getInstanceMethod([Person class], @selector(run));
    IMP imp = method_getImplementation(newMethod2->selbig.imp);
    method_setImplementation(oldMethod, imp);
    [p walk];
}


- (void)resolve
{
    Person *p = [[Person alloc] init];
    [p walk];
    
//    [Person walkwalk];
}

- (void)forwardingTarget{
    Person *p = [[Person alloc] init];
    [p walkDog];
}

- (void)invocation{
    Person *p = [[Person alloc] init];
    [p nioIntroduce];
}
@end
