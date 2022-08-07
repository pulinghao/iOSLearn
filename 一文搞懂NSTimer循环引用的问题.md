众所周知，使用NSTimer在添加self（比如某个VC）作为target的时候，会出现循环引用的问题。原因是，创建Timer的方法

```objective-c
+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(nullable id)userInfo repeats:(BOOL)yesOrNo
```

这个方法，在传入target时，是强引用的。



这里，有人会说把对Timer的停止放在`dealloc`方法里，但是`dealloc`方法的执行，只在self的引用计数为0的时候，但此时Timer还是持有self的，因此self的引用计数 ≠ 0，dealloc方法永远不会被执行。



常规的方法是引入中间对象WeakTarget，来解决用。

那么如何设计这个中间对象呢？

- 使用weak的特性，当引用计数为0的时候，置为nil
- 使用Timer的特性，当停止Timer时，置为nil





