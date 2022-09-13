//
//  MyProxy.m
//  MyLearnIOS
//
//  Created by pulinghao on 2021/2/3.
//  使用NSProxy来实现多继承


#import "MyProxy.h"

@interface THProxyA : NSProxy
@property (nonatomic, strong) id target;
@end
@implementation THProxyA
- (id)initWithObject:(id)object {
    self.target = object;
    return self;
}
- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector {
    return [self.target methodSignatureForSelector:selector];
}
- (void)forwardInvocation:(NSInvocation *)invocation {
    [invocation invokeWithTarget:self.target];
}
@end


@interface THProxyB : NSObject
@property (nonatomic, strong) id target;
@end
@implementation THProxyB
- (id)initWithObject:(id)object {
    self = [super init];
    if (self) {
        self.target = object;
    }
    return self;
}

- (BOOL)respondsToSelector:(SEL)aSelector{
    return true;
}
- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector {
    return [self.target methodSignatureForSelector:selector];  //这个方法不会走到
}
- (void)forwardInvocation:(NSInvocation *)invocation {
    [invocation invokeWithTarget:self.target];
}
@end



@interface MyProxy()

@property (nonatomic, weak) id innerObject;

@end

@implementation MyProxy

- (instancetype)initWithObj:(id)obj{
    _innerObject = obj;
    return self;
}

+(instancetype)proxyWithObj:(id)object{
    return [[MyProxy alloc] initWithObj:object];
}


- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel{
    //这里可以返回任何NSMethodSignature对象，你也可以完全自己构造一个
    return [_innerObject methodSignatureForSelector:sel];
}
- (void)forwardInvocation:(NSInvocation *)invocation{
    if([_innerObject respondsToSelector:invocation.selector]){
        NSString *selectorName = NSStringFromSelector(invocation.selector);
        NSLog(@"Before calling %@",selectorName);
        [invocation retainArguments];
        NSMethodSignature *sig = [invocation methodSignature];
        //获取参数个数，注意再本例里这里的值是3，为什么呢？
        //对，就是因为objc_msgSend的前两个参数是隐含的
        NSUInteger cnt = [sig numberOfArguments];
        //本例只是简单的将参数和返回值打印出来
        for (int i = 0; i < cnt; i++) {
            const char * type = [sig getArgumentTypeAtIndex:i];
            if(strcmp(type, "@") == 0){
                __weak id obj;    //这儿必须用弱持有修饰
                [invocation getArgument:&obj atIndex:i];
                //这里输出的是："parameter (0)'class is MyProxy"
                //也证明了这是objc_msgSend的第一个参数
                NSLog(@"parameter (%d)'class is %@",i,[obj class]);
            }
            else if(strcmp(type, ":") == 0){
                SEL sel;
                [invocation getArgument:&sel atIndex:i];
                //这里输出的是:"parameter (1) is barking:"
                //也就是objc_msgSend的第二个参数
                NSLog(@"parameter (%d) is %@",i,NSStringFromSelector(sel));
            }
            else if(strcmp(type, "q") == 0){
                int arg = 0;
                [invocation getArgument:&arg atIndex:i];
                //这里输出的是:"parameter (2) is int value is 4"
                //稍后会看到我们再调用barking的时候传递的参数就是4
                NSLog(@"parameter (%d) is int value is %d",i,arg);
            }
        }
        //消息转发
        [invocation invokeWithTarget:_innerObject];
        const char *retType = [sig methodReturnType];
        if(strcmp(retType, "@") == 0){
            NSObject *ret;
            [invocation getReturnValue:&ret];
            //这里输出的是:"return value is wang wang!"
            NSLog(@"return value is %@",ret);
        }
        NSLog(@"After calling %@",selectorName);
    }
}
@end

@implementation MyDog
-(NSString *)barking:(NSInteger)months{
   
    NSString *temp = months > 3 ? @"wang wang!" : @"eng eng!";
    NSLog(@"barking:%@",temp);
    return temp;
}

- (void)test{
    NSString *string = @"test";
    THProxyA *proxyA = [[THProxyA alloc] initWithObject:string];
    THProxyB *proxyB = [[THProxyB alloc] initWithObject:string];
    NSLog(@"%d", [proxyA respondsToSelector:@selector(length)]);  // 1
    NSLog(@"%d", [proxyB respondsToSelector:@selector(length)]);  // 0
    NSLog(@"%d", [proxyA isKindOfClass:[NSString class]]);   // 1
    NSLog(@"%d", [proxyB isKindOfClass:[NSString class]]);   // 0
}
@end
