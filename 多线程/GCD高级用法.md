# dispatch_set_target_queue

`dispatch_set_target_queue(dispatch_object_t object, dispatch_queue_t queue);`

> 第一个参数是要执行变更的队列（不能指定主队列和全局队列）
>
> 第二个参数是目标队列（指定全局队列）

两个作用：

- 使某个队列成为另外一个队列的执行队列
- 修改用户队列的目标队列，使多个serial queue在目标queue上一次只有一个执行

## 变更优先级

使得参数一`dispatch_object_t`的优先级，与参数二`dispatch_queue_t`的优先级相同

```objective-c
- (void)useTargetQueue
{
    //优先级变更的串行队列，初始是默认优先级
    dispatch_queue_t serialQueue = dispatch_queue_create("com.gcd.setTargetQueue.serialQueue", NULL);

    //优先级不变的串行队列（参照），初始是默认优先级
    dispatch_queue_t serialDefaultQueue = dispatch_queue_create("com.gcd.setTargetQueue.serialDefaultQueue", NULL);

    //变更前
    dispatch_async(serialQueue, ^{
        NSLog(@"1");
    });
    dispatch_async(serialDefaultQueue, ^{
        NSLog(@"2");
    });

    //获取优先级为后台优先级的全局队列
    dispatch_queue_t globalDefaultQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    
    // 将 serialQueue 的优先级，设置为 DISPATCH_QUEUE_PRIORITY_BACKGROUND 的全局队列优先级一样
    dispatch_set_target_queue(serialQueue, globalDefaultQueue);

    //变更后
    dispatch_async(serialQueue, ^{
        NSLog(@"1");
    });
    dispatch_async(serialDefaultQueue, ^{
        NSLog(@"2");
    });
}
```

## 变更执行队列

它会把需要执行的任务对象指定到不同的队列中去处理，这个任务对象可以是dispatch队列，也可以是dispatch源。而且这个过程可以是动态的，可以实现队列的动态调度管理等等。比如说有两个队列`dispatchA`和`dispatchB`，这时把`dispatchA`指派到`dispatchB`：

`dispatch_set_target_queue(dispatchA, dispatchB)`;

那么dispatchA上还未运行的block会在dispatchB上运行。这时如果暂停dispatchA运行：

`dispatch_suspend(dispatchA)`;

则只会暂停dispatchA上原来的block的执行，dispatchB的block则不受影响。而如果暂停dispatchB的运行，则会暂停dispatchA的运行。

```objective-c
dispatch_queue_t serialQueue1 = dispatch_queue_create("com.gcd.setTargetQueue2.serialQueue1", NULL);
dispatch_queue_t serialQueue2 = dispatch_queue_create("com.gcd.setTargetQueue2.serialQueue2", NULL);
dispatch_queue_t serialQueue3 = dispatch_queue_create("com.gcd.setTargetQueue2.serialQueue3", NULL);

dispatch_async(serialQueue1, ^{
    NSLog(@"1");
});
dispatch_async(serialQueue2, ^{
    NSLog(@"2");
});
dispatch_async(serialQueue3, ^{
    NSLog(@"3");
});

// 执行顺序为1，3，2  没有固定顺序！！

//创建目标串行队列
dispatch_queue_t targetSerialQueue = dispatch_queue_create("com.gcd.setTargetQueue2.targetSerialQueue", NULL);

//设置执行阶层
dispatch_set_target_queue(serialQueue1, targetSerialQueue);
dispatch_set_target_queue(serialQueue2, targetSerialQueue);
dispatch_set_target_queue(serialQueue3, targetSerialQueue);

dispatch_async(serialQueue1, ^{
    NSLog(@"1");
});
dispatch_async(serialQueue2, ^{
    NSLog(@"2");
});
dispatch_async(serialQueue3, ^{
    NSLog(@"3");
});

//执行顺序为 1， 2， 3 ,有顺序了
```

