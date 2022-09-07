# 核心概念

将“操作”添加到队列中。`NSOperation`是一个抽象类，不能直接使用。定义子类公有的属性和方法。NSOperation、NSOperationQueue 是基于 **GCD** 更高一层的封装。

子类：

- NSInvocationOperation 
- NSBlockOperation

## **NSInvocationOperation**

- `start`方法会在<font color='red'>**当前线程**</font>执行和调度。
- `start`如果在主线程，就会阻塞主线程
- 除非放到`NSOperationQueue`，会在子线程运行

## **NSBlockOperation**

- `blockOperationWithBlock`默认在**<font color='red'>当前线程</font>**，当操作比较多的时候，比如`addExecutionBlock`时，也可能在其他线程。
-  `addExecutionBlock` 添加的任务，会开辟多个子线程
- `start` 会阻塞当前线程
- 任务多了，就不确定哪个会在主线程中执行了

## 自定义Operation

（这儿可以看下AFN 2.7版本的源码）

继承自`NSOperation`

- `main`函数中，写要执行的操作。当main执行完，操作就结束了

```objective-c
// 重写自定义类的main方法实现封装操作
-(void)main
{
    // 要执行的操作
}
```

- `start`执行
- ***重写的 `start` 方法一定不能调用 `[super start]`***
- 创建的子类时，需要考虑到可能会添加到串行和并发队列的不同情况，需要重写不同的方法。
- 对于串行操作，仅仅需要重新`main`方法就行，在这个方法中添加想要实现的功能。
- 对于并发操作，重写四个方法：`start`、`asynchronous`、`executing`、`finished`。需要自己创建自动释放池，因为异步操作无法访问主线程的自动释放池。

### 串行

### 并发

- 重写方法

  - 必需重写四个方法：`start`、`asynchronous`、`executing`、`finished`

  - start(必需)：所有并发操作必须重写此方法，并需要使用自定义的实现替换默认行为。任何时候都不能调用父类的start方法。 即不可使用super。重写的start方法负责以**异步的方式**启动一个操作，无论是开启一个线程还是调用异步函数，都可以在start方法中进行。注意在开始操作之前，应该在start中更新操作的执行状态，因为要给KVO的键路径发送当前操作的执行状态，方便查看操作状态。

    在自定义的Operation中，在子线程中执行，即重写start方法

  ```objc
  - (void)start {
      [self.lock lock];
      if ([self isCancelled]) {
          [self performSelector:@selector(cancelConnection) onThread:[[self class] networkRequestThread] withObject:nil waitUntilDone:NO modes:[self.runLoopModes allObjects]];
      } else if ([self isReady]) {
          self.state = AFOperationExecutingState;  // 调用setter方法，触发KVO
  
          [self performSelector:@selector(operationDidStart) onThread:[[self class] networkRequestThread] withObject:nil waitUntilDone:NO modes:[self.runLoopModes allObjects]];
      }
      [self.lock unlock];
  }
  ```

  ​	*注意，这里要确保线程是活着的！*

  - `main`(可选)：在这个方法中，放置执行给定任务所需的代码。应该定义一个自定义初始化方法，以便更容易创建自定义类的实例。当如果定义了自定义的getter和setter方法，必须确保这些方法可以从多个线程安全地调用。虽然可以在start方法中执行任务，但使用此方法实现任务可以更清晰地分离设置和任务代码,即在start方法中调用mian方法。注意:要定义独立的自动释放池与别的线程区分开。
  - `isFinished`(必需)：表示是否已完成。需要实现KVO通知机制。
  - `isAsynchronous`(必需)：默认返回 NO ，表示非并发执行。并发执行需要自定义并且返回 YES。后面会根据这个返回值来决定是否并发。
  - `isExecuting`(必需)：表示是否执行中，需要实现KVO通知机制。

  ```objc
  - (BOOL)isExecuting {
      return self.state == AFOperationExecutingState;
  }
  - (BOOL)isFinished {
      return self.state == AFOperationFinishedState;
  }
  
  - (BOOL)isConcurrent {
      return YES;
  }
  ```

  KVO机制

  ```objective-c
  static inline NSString * AFKeyPathFromOperationState(AFOperationState state) {
      switch (state) {
          case AFOperationReadyState:
              return @"isReady";
          case AFOperationExecutingState:
              return @"isExecuting";
          case AFOperationFinishedState:
              return @"isFinished";
          case AFOperationPausedState:
              return @"isPaused";
          default: {
  #pragma clang diagnostic push
  #pragma clang diagnostic ignored "-Wunreachable-code"
              return @"state";
  #pragma clang diagnostic pop
          }
      }
  }
  
  
  - (void)setState:(AFOperationState)state {
      if (!AFStateTransitionIsValid(self.state, state, [self isCancelled])) {
          return;
      }
  
      [self.lock lock];
      NSString *oldStateKey = AFKeyPathFromOperationState(self.state);
      NSString *newStateKey = AFKeyPathFromOperationState(state);
  
      [self willChangeValueForKey:newStateKey];
      [self willChangeValueForKey:oldStateKey];
      _state = state;
      [self didChangeValueForKey:oldStateKey];
      [self didChangeValueForKey:newStateKey];
      [self.lock unlock];
  }
  ```

补充一下，NSOperation内部添加了对上面那些状态的键值观察

<img src="/Users/pulinghao/Library/Application Support/typora-user-images/image-20220818003814141.png" alt="image-20220818003814141" style="zoom:50%;" />

注意：自己创建自动释放池，异步操作无法访问主线程的自动释放池



### Operation的几种状态

- 就绪

- 取消
- 运行
- 结束



# **NSOperationQueue**

- 将任务添加到队列的方法，**自动是在子线程中执行，不会卡死主线程**
- 添加到队列以后，就自动开始执行，内部Operation调用 start -> main
- 本质上是GCD面向对象的封装
- 最大并发数

在设置最大并发数时maxConcurrentOperationCount。例如设置为2。此时活跃的线程一共有主线程、线程1、线程2。但是也会有可能出现线程3，执行任务。原因在于在NSOperation中，任务执行完成后，系统会回收线程。但此时只要线程池中，有多余线程，就会去取新的线程出来。所以可能出现新的线程。但是再同一时间里，**始终只有两个线程在运行。**

> 线程数有系统决定，用户决定不了

- 挂起

1）挂起时，正在线程上执行的操作不会暂停！挂起的是队列

2）如果队列本来就是挂起的，那么就是始终挂起的。添加了任务，也会处于等待状态

- 操作数 operationCount

队列中的操作数

- 取消

  - 队列挂起的时候,不会清空内部的操作。只有在队列继续的时候才会清空!
  - 正在执行的操作也不会被取消!
  - 需要取消某个Operation，需要对`isCacelled`属性进行监听

  ```objective-c
  // 取消队列操作
  [self.opQueue cancelAllOperations];
  // 某个Operation内部
  -(void)main
  {
      if(isCancelled){
        return;
      }
    // 执行你需要的任务
  }
  ```

> 注意：暂停和取消只能暂停或取消处于<font color='red'>**等待状态**</font>的任务，<font color='red'>不能</font>暂停或取消**<font color='red'>正在执行中</font>**的任务，必须等正在执行的任务执行完毕之后才会暂停，如果想要暂停或者取消正在执行的任务，可以在每个任务之间即每当执行完一段耗时操作之后，判断是否任务是否被取消或者暂停。
>
> 如果想要精确的控制，则需要将判断代码放在任务之中，但是不建议这么做，频繁的判断会消耗太多时间

- 依赖`- (void)addOperations:(NSArray *)ops waitUntilFinished:(BOOL)wait;`

这个接口，如果后面的waitUntilFinished的参数设置为YES，就会卡住**当前**线程。

- 如何判断卡不卡主线程？

只要往视图里面，拖入一个`UIScrollView`的控件，在运行的时候，看能否拖动这个控件即可。

如果产生循环依赖，A依赖B，B依赖A。不会造成死锁，但是会造成队列不工作

## 添加任务

1. `-(void)addOperation:(NSOperation *)op;`
2. `-(void)addOperationWithBlock:(void (^)(void))block;`

## 控制任务的执行方式

### 串行

- 控制最大并发数

`maxConcurrentOperationCount = 1`  

- 控制依赖，让任务按照顺序执行

### 并发

`maxConcurrentOperationCount > 1`



## NSOperation的操作依赖

## NSOperation 优先级

`queuePriority`属性，默认是`NSOperationQueuePriorityNormal`

对于添加到队列中的操作，首先进入准备就绪的状态（就绪状态取决于操作之间的**依赖关系**），然后进入就绪状态的操作的**开始执行顺序**（<font color='red'>非结束执行顺序</font>）由操作之间相对的优先级决定（优先级是操作对象自身的属性）

**那么，什么样的操作才是进入就绪状态的操作呢？**

- 当一个操作的所有依赖都已经完成时，操作对象通常会进入准备就绪状态，等待执行。
- `queuePriority` 属性决定了**进入准备就绪状态下的操作**之间的开始执行顺序。并且，优先级不能取代依赖关系。
- 如果一个队列中既包含高优先级操作，又包含低优先级操作，并且两个操作都已经准备就绪，那么**队列先执行高优先级操作**。比如上例中，如果 op1 和 op4 是不同优先级的操作，那么就会先执行**优先级高**的操作。
- 如果，一个队列中既包含了准备就绪状态的操作，又包含了未准备就绪的操作，**未准备就绪的操作优先级比准备就绪的操作优先级高**。那么，虽然准备就绪的操作优先级低，也会优先执行。优先级不能取代依赖关系。如果要控制操作间的启动顺序，则必须使用依赖关系。

# NSOperation与 NSOperationQueue 线程间通信

在子线程中做一些耗时操作，在主线程中同步UI

- 创建一个operationQueue
- 在这个queue中添加子线程的任务
- 在这个子线程任务中，给主线程队列添加更新UI任务

```objc
/**
 * 线程间通信
 */
- (void)communication {

    // 1.创建队列
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];

    // 2.添加操作
    [queue addOperationWithBlock:^{
        // 异步进行耗时操作
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"1---%@", [NSThread currentThread]); // 打印当前线程
        }

        // 回到主线程
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            // 进行一些 UI 刷新等操作
            for (int i = 0; i < 2; i++) {
                [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
                NSLog(@"2---%@", [NSThread currentThread]); // 打印当前线程
            }
        }];
    }];
}
```

# NSOperation、NSOperationQueue 线程同步和线程安全



启动两个NSOperationQueue，分别执行任务（例如对同一个变量++），最终得到的结果是错乱的。

解决方案：给线程加锁



# 同步

- 使用依赖
- 使用`- (void)waitUntilFinished;`阻塞当前线程，直到该操作结束。

两个NSOperation，在执行第二个的时候，需要等待第一个执行完（此时，队列是并发队列）

```objc
// 创建队列
 NSOperationQueue *queue = [[NSOperationQueue alloc] init];
 // 创建操作
 NSBlockOperation *blockOp = [NSBlockOperation blockOperationWithBlock:^{
     [NSThread sleepForTimeInterval:3]; // 模拟耗时操作
 }];
 NSBlockOperation *block2Op = [NSBlockOperation blockOperationWithBlock:^{
     NSLog(@"block2Op -- begin");
     [blockOp waitUntilFinished]; // 等blockOp操作对象的任务执行完，才能接着往下执行
     NSLog(@"block2Op --end");
 }];
 // 执行
 [queue addOperation:blockOp];
 [queue addOperation:block2Op];
```



- 或者`- (void)waitUntilAllOperationsAreFinished;`



# 补充两张图

![opreation](/Users/pulinghao/Github/iOSLearn/多线程/opreation.png)

![operation2](/Users/pulinghao/Github/iOSLearn/多线程/operation2.png)





# 原理分析



# 参考文档

[iOS NSOperation 源码分析原理](https://www.jianshu.com/p/b4ae9ef8fafe)

[NSOperation的进阶使用和简单探讨](https://juejin.cn/post/6844903721097248782)

[细说 NSOperation](https://juejin.cn/post/6844904003768320014)

