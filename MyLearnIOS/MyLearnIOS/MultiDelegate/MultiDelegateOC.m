//
//  MultiDelegateOC.m
//  MyLearnIOS
//
//  Created by pulinghao on 2021/2/1.
//

#import "MultiDelegateOC.h"

@interface PLHPrivate_WeakDelegateObject : NSObject

@property (weak, nonatomic) id delegate;

@end

@implementation PLHPrivate_WeakDelegateObject

- (NSString *)description{
    return [NSString stringWithFormat:@"%@",self.delegate];
}

@end

@interface MultiDelegateOC()

@property (readwrite,strong,nonatomic) NSMutableArray* delegates;

@end

@implementation MultiDelegateOC

- (instancetype)init
{
    if(self = [super init])
    {
        self.silentWhenEmpty = YES;
    }
    return self;
}

- (PLHPrivate_WeakDelegateObject *)findDelegateObjectByDelegate:(id)delegate{
    if(!delegate){
        return nil;
    }
    NSArray *delegates = [NSArray arrayWithArray:self.delegates];
    for (PLHPrivate_WeakDelegateObject *delegateObject in delegates) {
        if(delegateObject.delegate && [delegateObject.delegate isEqual:delegate]){
            return delegateObject;
        }
    }
    return nil;
}

- (void)addDelegate:(id)delegate
{
    [self addDelegate:delegate before:NO otherDelegate:nil];
}

- (void)addDelegate:(id)delegate beforeDelegate:(id)otherDelegate{
    [self addDelegate:delegate before:YES otherDelegate:otherDelegate];
}

- (void)addDelegate:(id)delegate afterDelegate:(id)otherDelegate{
    [self addDelegate:delegate before:NO otherDelegate:otherDelegate];
}

- (void)addDelegate:(id)delegate before:(BOOL)before otherDelegate:(id)otherDelegate{
    @synchronized (self) {
        if(!delegate){
            return;
        }
        PLHPrivate_WeakDelegateObject *otherDelegateObject = [self findDelegateObjectByDelegate:otherDelegate];
        PLHPrivate_WeakDelegateObject *delegateObject = [self findDelegateObjectByDelegate:delegate];
        if(!delegateObject){
            delegateObject = [[PLHPrivate_WeakDelegateObject alloc]init];
            delegateObject.delegate = delegate;
            if(!otherDelegateObject){
                [self.delegates addObject:delegateObject];
                return;
            }
        }else{
            if(!otherDelegateObject){
                return;
            }
            [self.delegates removeObject:delegateObject];
        }
        NSInteger index = [self.delegates indexOfObject:otherDelegateObject];
        if(!before){
            index = [self.delegates indexOfObject:otherDelegateObject]+1;
            if(index > self.delegates.count){
                index = self.delegates.count;
            }
        }
        [self.delegates insertObject:delegateObject atIndex:index];
    }
}

// 清理所有的 delegate为空的 delegateObject
- (void)fg_private_compact{
    @synchronized (self) {
        NSArray *delegates = [NSArray arrayWithArray:self.delegates];
        for (PLHPrivate_WeakDelegateObject *delegateObject in delegates) {
            if(!delegateObject.delegate){
                [self.delegates removeObject:delegateObject];
            }
        }
    }
}

- (void)removeDelegate:(id)delegate{
    @synchronized (self) {
        PLHPrivate_WeakDelegateObject *exist = [self findDelegateObjectByDelegate:delegate];
        if(exist){
            [self.delegates removeObject:exist];
        }
    }
}

- (void)removeAllDelegates
{
    @synchronized (self) {
        [self.delegates removeAllObjects];
    }
}

- (BOOL)respondsToSelector:(SEL)aSelector{
    if ([super respondsToSelector:aSelector]) {
        return YES;
    }
    
    // 清理一遍delegate为空的delegate对象
    [self fg_private_compact];
    
    NSArray *delegaets = [NSArray arrayWithArray:self.delegates];
    for (PLHPrivate_WeakDelegateObject *obj in delegaets) {
        if (obj.delegate && [obj.delegate respondsToSelector:aSelector]) {
            return YES;
        }
    }
    return NO;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector{
    NSMethodSignature *signature = [super methodSignatureForSelector:aSelector];
    NSArray* delegates = [NSArray arrayWithArray:self.delegates];
    for (PLHPrivate_WeakDelegateObject *obj in delegates) {
        if (!obj.delegate) {
            continue;
        }
        // 如果有代理能实现这个方法，交给代理去做
        signature = [obj.delegate methodSignatureForSelector:aSelector];
        if (signature) {
            break;
        }
    }
    if (!signature && self.silentWhenEmpty) {
        return [NSMethodSignature signatureWithObjCTypes:"v@:@"];
    }
    return signature;
}


- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    SEL selector = [anInvocation selector];
    BOOL responded = NO;
    void *returnValue = NULL;
    NSArray *delegates = [NSArray arrayWithArray:self.delegates];
    
    for (PLHPrivate_WeakDelegateObject *obj in delegates) {
        if (obj.delegate && [obj.delegate respondsToSelector:selector]) {
            // 转发给代理去实现
            [anInvocation invokeWithTarget:obj.delegate];
            
            if (anInvocation.methodSignature.methodReturnLength != 0) {
                void *value = nil;
                [anInvocation getReturnValue:&value];
                if (value) {
                    returnValue = value;
                }
            }
            responded = YES;
        }
    }
    
    if (returnValue) {
        [anInvocation setReturnValue:&returnValue];
    }
    
    if (!responded && !self.silentWhenEmpty) {
        [self doesNotRecognizeSelector:selector];
    }
}


- (NSMutableArray *)delegates{
    if(!_delegates){
        _delegates = [[NSMutableArray alloc]init];
    }
    return _delegates;
}
@end
