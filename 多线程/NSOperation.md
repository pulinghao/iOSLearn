# 核心概念

将“操作”添加到队列中。`NSOperation`是一个抽象类，不能直接使用。定义子类公有的属性和方法

子类：

- NSInvocationOperation 
- NSBlockOperation

## **NSInvocationOperation**

- `start`方法会在<font color='red'>当前线程</font>执行和调度。
- `start`如果在主线程，就会阻塞主线程
- 除非放到`NSOperationQueue`，会在子线程运行

## **NSBlockOperation**

- `blockOperationWithBlock`默认在**主线程**
- 通过 `addExecutionBlock` 添加的任务，会开辟多个子线程
- start 会阻塞当前线程
- 任务多了，就不确定哪个会在主线程中执行了

## 自定义Operation

继承自`NSOperation`

- main函数中，写要执行的操作

```objective-c
// 重写自定义类的main方法实现封装操作
-(void)main
{
    // 要执行的操作
}
```

- start执行

几种状态

- 就绪

- 取消
- 运行
- 结束



# **NSOperationQueue**

- 将任务添加到队列的方法，**自动是在子线程中执行，不会卡死主线程**
- 添加到队列以后，就自动开始执行，内部Operation调用 start -> main
- 本质上是GCD面向对象的封装
- 最大并发数

在设置最大并发数时macConcurrentOperationCount。例如设置为2。此时活跃的线程一共有主线程、线程1、线程2。但是也会有可能出现线程3，执行任务。原因在于在NSOperation中，任务执行完成后，系统会回收线程。但此时只要线程池中，有多余线程，就会去取新的线程出来。所以可能出现新的线程。但是再同一时间里，始终只有两个线程在运行。

> 线程数有系统决定，用户决定不了

- 挂起

1）挂起时，正在线程上执行的操作不会暂停！挂起的是队列

2）如果队列本来就是挂起的，那么就是始终挂起的。添加了任务，也会处于等待状态

- 操作数 operationCount

队列中的操作数

- 取消

  - 队列挂起的时候,不会清空内部的操作.只有在队列继续的时候才会清空!
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

> 注意：暂停和取消只能暂停或取消处于<font color='red'>**等待状态**</font>的任务，<font color='red'>不能暂停或取消</font>正在执行中的任务，必须等正在执行的任务执行完毕之后才会暂停，如果想要暂停或者取消正在执行的任务，可以在每个任务之间即每当执行完一段耗时操作之后，判断是否任务是否被取消或者暂停。如果想要精确的控制，则需要将判断代码放在任务之中，但是不建议这么做，频繁的判断会消耗太多时间

- 依赖`addOperations: waitUntilFinished`

这个接口，如果后面的waitUntilFinished的参数设置为YES，就会卡住**当前**线程。

- 如何判断卡不卡主线程？

只要往视图里面，拖入一个`UIScrollView`的控件，在运行的时候，看能否拖动这个控件即可。

如果产生循环依赖，A依赖B，B依赖A。不会造成死锁，但是会造成队列不工作



# 原理分析



# 参考文档

[iOS NSOperation 源码分析原理](https://www.jianshu.com/p/b4ae9ef8fafe)

