//
//  Person.m
//  MyLearnIOS
//
//  Created by zhanghuiqiang on 2021/1/18.
//

#import "Person.h"
#import <objc/runtime.h>
#import "Dog.h"

@interface Person()

@property (nonatomic, strong) NSObject *A;

@end
@implementation Person

//- (void)walk{
//    NSLog(@"%s",__func__);
//}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.A = [[NSObject alloc] init];
    }
    return self;
}



- (void)doSomeThing
{
    NSLog(@"do some thing");
}
+ (void)run{
    NSLog(@"%s",__func__);
}

void walk(){
    NSLog(@"add %s",__func__);
}

void swim(id self, SEL sel){
    NSLog(@"swim");
}

+ (BOOL)resolveInstanceMethod:(SEL)sel
{
    NSLog(@"%s",__func__);
    if (sel == @selector(walk)) {
        return class_addMethod(self, sel, (IMP)walk, "v@:");
    }
    
    if (sel == @selector(swim)) {
        return class_addMethod(self, sel, (IMP)swim, "v@:");
    }
    return [super resolveInstanceMethod:sel];
}
- (void)testKindOfClass
{
    BOOL res1 = [self isKindOfClass:[NSObject class]];
    id obj = NSObject.self;
    id obj2 = [NSObject class];
    BOOL res2 = [NSObject.self isKindOfClass:[NSObject class]];
    
    NSLog(@"res1 [self isKindOfClass:[NSObject class]]:%d" , res1);
    NSLog(@"res2 [NSObject.self isKindOfClass:[NSObject class]] : %d",res2);
}


// 动态方法解析
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


// 备用接收者
- (id)forwardingTargetForSelector:(SEL)aSelector{
    if (@selector(walk) == aSelector) {
        return [Dog new];
    }
    return [super forwardingTargetForSelector:aSelector];
}


// 完整消息转发
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector{
    if (@selector(walk) == aSelector) {
        // 提供方法签名
        return [NSMethodSignature signatureWithObjCTypes:"v@:"];
    }
    return [super methodSignatureForSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation{
    
    // 方式一：转发给别人
//    SEL sel = [anInvocation selector];
//    Dog *dog = [Dog new];
//    if ([dog respondsToSelector:sel]) {
//        [anInvocation invokeWithTarget:[Dog new]];
//    }
    
    // 方式二：转发给自己
    anInvocation.selector = @selector(introduce);
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


//- (void)sleep{
//    NSLog(@"sleep");
//}


@end
