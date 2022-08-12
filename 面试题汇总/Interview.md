# 美团

- `int`，`long`,`NSInteger`的区别
- 如何实现关联对象的weak访问属性

[iOS - 一个崩溃 SIGSEGV / SEGV_ACCERR](https://www.jianshu.com/p/5f81d58b098a)

使用中间对象

```objective-c
@interface Wrapper : NSObject
@property (nonatomic, weak) id object;
@end

- (MyObject *)object {
    MyWrapper *wrapper = objc_getAssociatedObject(self, _cmd);
    return wrapper.object;
}
- (void)setObject:(MyObject *)object {
    SEL key = @selector(object);
    MyWrapper *wrapper = objc_getAssociatedObject(self, key);
    if (wrapper == nil) {
        wrapper = [[MyWrapper alloc] init];
        objc_setAssociatedObject(self, key, wrapper, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    wrapper.object = object;
}
```



- autoreleasepool的使用场景，为什么使用autoreleasepool？
- 