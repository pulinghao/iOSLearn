# 分类

- Mach异常：是指最底层的内核级异常。用户态的开发者可以直接通过Mach API设置thread，task，host的异常端口，来捕获Mach异常。
- Unix信号：又称BSD 信号，如果开发者没有捕获Mach异常，则会被host层的方法ux_exception()将异常转换为对应的UNIX信号，并通过方法threadsignal()将信号投递到出错线程。可以通过方法signal(x, SignalHandler)来捕获signal。
- NSException：应用级异常，它是未被捕获的Objective-C异常，导致程序向自身发送了SIGABRT信号而崩溃，是**app自己可控**的，对于未捕获的Objective-C异常，是可以通过try catch来捕获的，或者通过`NSSetUncaughtExceptionHandler()`机制来捕获。

![img](https://upload-images.jianshu.io/upload_images/5219632-04e43775dfba56f8.png?imageMogr2/auto-orient/strip|imageView2/2/format/webp)



# Mach异常

所有Mach异常未处理，**它将在host层被ux_exception转换为相应的Unix信号，并通过threadsignal将信号投递到出错的线程**。



iOS系统自带的 Apple’s Crash Reporter 记录在设备中的Crash日志，Exception Type项通常会包含两个元素： Mach异常 和 Unix信号。

```
Exception Type:         EXC_BAD_ACCESS (SIGSEGV)
Exception Subtype:      KERN_INVALID_ADDRESS at 0x041a6f3
```

因此，`EXC_BAD_ACCESS (SIGSEGV)`表示的意思是：Mach层的`EXC_BAD_ACCESS`异常，在host层被转换成`SIGSEGV`信号投递到出错的线程。既然最终以信号的方式投递到出错的线程，那么就可以通过注册signalHandler来捕获信号:

```
signal(SIGSEGV,signalHandler); // 监听 Unix 信号
```



## 埋入异常检测

```objective-c
#import <mach/mach.h>

+ (void)createAndSetExceptionPort {
    mach_port_t server_port;
    kern_return_t kr = mach_port_allocate(mach_task_self(), MACH_PORT_RIGHT_RECEIVE, &server_port);
    assert(kr == KERN_SUCCESS);
    NSLog(@"create a port: %d", server_port);

    kr = mach_port_insert_right(mach_task_self(), server_port, server_port, MACH_MSG_TYPE_MAKE_SEND);
    assert(kr == KERN_SUCCESS);

    kr = task_set_exception_ports(mach_task_self(), EXC_MASK_BAD_ACCESS | EXC_MASK_CRASH, server_port, EXCEPTION_DEFAULT | MACH_EXCEPTION_CODES, THREAD_STATE_NONE);

    [self setMachPortListener:server_port];
}

+ (void)setMachPortListener:(mach_port_t)mach_port {
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      mach_msg_header_t mach_message;

      mach_message.msgh_size = 1024;
      mach_message.msgh_local_port = mach_port;

      mach_msg_return_t mr;

      while (true) {
          mr = mach_msg(&mach_message,
                        MACH_RCV_MSG | MACH_RCV_LARGE,
                        0,
                        mach_message.msgh_size,
                        mach_message.msgh_local_port,
                        MACH_MSG_TIMEOUT_NONE,
                        MACH_PORT_NULL);

          if (mr != MACH_MSG_SUCCESS && mr != MACH_RCV_TOO_LARGE) {
              NSLog(@"error!");
          }

          mach_msg_id_t msg_id = mach_message.msgh_id;
          mach_port_t remote_port = mach_message.msgh_remote_port;
          mach_port_t local_port = mach_message.msgh_local_port;

          NSLog(@"Receive a mach message:[%d], remote_port: %d, local_port: %d",
                msg_id,
                remote_port,
                local_port);
          abort();
      }
  });
}

// 构造BAD MEM ACCESS Crash
- (void)makeCrash {
  NSLog(@"********** Make a [BAD MEM ACCESS] now. **********");
  *((int *)(0x1234)) = 122;
}
```

程序最后，会在断点abort()的位置崩溃

![image-20220808000249385](/Users/pulinghao/Library/Application Support/typora-user-images/image-20220808000249385.png)

# Unix Signal

Unix Signal 其实是由 Mach port 抛出的信号转化的，那么都有哪些信号呢？

- SIGHUP
   本信号在用户终端连接(正常或非正常)结束时发出, 通常是在终端的控制进程结束时, 通知同一session内的各个作业, 这时它们与控制终端不再关联。
- SIGINT
   程序终止(interrupt)信号, 在用户键入INTR字符(通常是Ctrl-C)时发出，用于通知前台进程组终止进程。
- SIGQUIT
   和SIGINT类似, 但由QUIT字符(通常是Ctrl-)来控制. 进程在因收到SIGQUIT退出时会产生core文件, 在这个意义上类似于一个程序错误信号。
- SIGABRT
   调用abort函数生成的信号。
   `SIGABRT is a BSD signal sent by an application to itself when an NSException or obj_exception_throw is not caught.`
- SIGBUS
   非法地址, 包括内存地址对齐(alignment)出错。比如访问一个四个字长的整数, 但其地址不是4的倍数。它与SIGSEGV的区别在于后者是由于对合法存储地址的非法访问触发的(如访问不属于自己存储空间或只读存储空间)。
- SIGFPE
   在发生致命的算术运算错误时发出. 不仅包括浮点运算错误, 还包括溢出及除数为0等其它所有的算术的错误。
- SIGKILL
   用来立即结束程序的运行. 本信号不能被阻塞、处理和忽略。如果管理员发现某个进程终止不了，可尝试发送这个信号。
- SIGSEGV
   试图访问未分配给自己的内存, 或试图往没有写权限的内存地址写数据.
- SIGPIPE
   管道破裂。这个信号通常在进程间通信产生，比如采用FIFO(管道)通信的两个进程，读管道没打开或者意外终止就往管道写，写进程会收到SIGPIPE信号。

## 插入检测

```objective-c
#include <execinfo.h>

void InstallSignalHandler(void) {
    signal(SIGHUP, handleSignalException); // 注册监听
    signal(SIGINT, handleSignalException);
    signal(SIGQUIT, handleSignalException);
    signal(SIGABRT, handleSignalException);
    signal(SIGILL, handleSignalException);
    signal(SIGSEGV, handleSignalException);
    signal(SIGFPE, handleSignalException);
    signal(SIGBUS, handleSignalException);
    signal(SIGPIPE, handleSignalException);
}

void handleSignalException(int signal) {
    NSMutableString * crashInfo = [[NSMutableString alloc]init];
    [crashInfo appendString:[NSString stringWithFormat:@"signal:%d\n",signal]];
    [crashInfo appendString:@"Stack:\n"];
    void* callstack[128];
    int i, frames = backtrace(callstack, 128);
    char** strs = backtrace_symbols(callstack, frames);
    for (i = 0; i <frames; ++i) {
        [crashInfo appendFormat:@"%s\n", strs[i]];
    }
    NSLog(@"%@", crashInfo);
}

// 构造BAD MEM ACCESS Crash
- (void)makeCrash {
  NSLog(@"********** Make a [BAD MEM ACCESS] now. **********");
  *((int *)(0x1234)) = 122;
}
```

程序无法打印出日志，只能在控制台输出里看到