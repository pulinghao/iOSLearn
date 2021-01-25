//
//  Person.m
//  MyLearnIOS
//
//  Created by zhanghuiqiang on 2021/1/18.
//

#import "Person.h"
#import <objc/runtime.h>
#import "Dog.h"
@implementation Person

//- (void)walk{
//    NSLog(@"%s",__func__);
//}

+ (void)run{
    NSLog(@"%s",__func__);
}

void walk(){
    NSLog(@"%s",__func__);
}

//+ (BOOL)resolveInstanceMethod:(SEL)sel
//{
//    NSLog(@"%s",__func__);
//    if (sel == @selector(walk)) {
//        return class_addMethod(self, sel, (IMP)walk, "v@:");
//    }
//    return [super resolveInstanceMethod:sel];
//}
//
//
//+ (BOOL)resolveClassMethod:(SEL)sel
//{
//    NSLog(@"%s",__func__);
//    if (sel == @selector(walkwalk)) {
//        //1.写法1
//        Method method = class_getInstanceMethod(object_getClass(self), @selector(run));
//        //2.写法2
//        Method method2 = class_getClassMethod(self, @selector(run));
//        IMP runImp = method_getImplementation(method);
//        const char* types = method_getTypeEncoding(method);
//        return class_addMethod(object_getClass(self),sel, runImp, types);
//    }
//    return [super resolveClassMethod:sel];
//}
//
//- (id)forwardingTargetForSelector:(SEL)aSelector{
//    if (@selector(walk) == aSelector) {
//        return [Dog new];
//    }
//    return [super forwardingTargetForSelector:aSelector];
//}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector{
    if (@selector(walk) == aSelector) {
        return [NSMethodSignature signatureWithObjCTypes:"v@:"];
    }
    return [super methodSignatureForSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation{
    
    // 转发给别人
    //[anInvocation invokeWithTarget:[Dog new]];
    
    // 转发给自己
    anInvocation.selector = @selector(run);
    anInvocation.target = self;
    [anInvocation invoke];
} 

- (void)run{
    NSLog(@"%s",__func__);
}

- (void)introduce
{
    NSLog(@"nio_introduce");
}
@end
