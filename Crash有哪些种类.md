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
   调用abort函数生成的信号。例如一些C库的函数（strlen）
   `SIGABRT is a BSD signal sent by an application to itself when an NSException or obj_exception_throw is not caught.`
- SIGBUS
   非法地址, 包括内存地址对齐(alignment)出错。比如访问一个四个字长的整数, 但其地址不是4的倍数。它与SIGSEGV的区别在于后者是由于对合法存储地址的非法访问触发的(如访问不属于自己存储空间或只读存储空间)。
- SIGFPE
   在发生致命的算术运算错误时发出. 不仅包括**浮点运算错误**, 还包括溢出及**除数为0**等其它所有的算术的错误。
- SIGKILL
   用来立即结束程序的运行. 本信号不能被阻塞、处理和忽略。如果管理员发现某个进程终止不了，可尝试发送这个信号。
- **<font color='red'>SIGSEGV（常见）</font>**
   试图访问未分配给自己的内存, 或试图往没有写权限的内存地址写数据.
  - 试图访问未分配给自己的内存
  - 试图往没有写权限的内存地址写数据
  - 空指针
  - 数组越界
  - 栈溢出等

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



# NSException

- NSException 异常是 OC 代码导致的 crash。
- NSException 异常和 Signal 信号异常，这两类都可以通过注册相关函数来捕获：
- NSSetUncaughtExceptionHandler 用来做异常处理，功能非常有限。引起崩溃的大多数原因如：内存访问错误、重复释放等错误，它就无能为力了，因为这种错误它抛出的是 Signal。

```objective-c

// 保存注册的 exception 捕获方法
	NSUncaughtExceptionHandler * oldExceptionHandler;
	// 自定义的 exception 异常处理
	void ExceptionHandler(NSException * exception);
	
	void RegisterExceptionHandler()  {
	    if(NSGetUncaughtExceptionHandler() != ExceptionHandler) {
	        oldExceptionHandler = NSGetUncaughtExceptionHandler();
	    }
	    NSSetUncaughtExceptionHandler(ExceptionHandler);
	}


/**
	 *  @brief  exception 崩溃处理
	 */
	void ExceptionHandler(NSException * exception) {
	    // 使 UncaughtExceptionCount 递增
	    int32_t exceptionCount = OSAtomicIncrement32(&UncaughtExceptionCount);
	    
	    // 超出允许捕获错误的次数
	    if (exceptionCount > UncaughtExceptionMaximum) {
	        return;
	    }
	    
	    // 获取调用堆栈
	    NSMutableDictionary * userInfo = [NSMutableDictionary dictionaryWithDictionary:[exception userInfo]];
	    userInfo[kUncaughtCallStackKey] = [exception callStackSymbols];
	    
	    NSException * exp = [NSException exceptionWithName:exception.name
	                                                reason:exception.reason
	                                              userInfo:userInfo];
	    // 在主线程中执行方法
	    [[[UncaughtExceptionHandler alloc] init] performSelectorOnMainThread:@selector(dealException:)
	                                                              withObject:exp
	                                                           waitUntilDone:YES];
	    
	    // 调用保存的 handler
	    if (oldExceptionHandler) {
	        oldExceptionHandler(exception);
	    }
	}


```



# 收集调用的堆栈

调用堆栈的收集可以利用系统 api，

```objective-c
	+ (NSArray *)backtrace {
	    /*  指针列表。
	
	        ①、backtrace 用来获取当前线程的调用堆栈，获取的信息存放在这里的 callstack 中
	        ②、128 用来指定当前的 buffer 中可以保存多少个 void* 元素
	     */
	    void * callstack[128];
	    
	    // 返回值是实际获取的指针个数
	    int frames = backtrace(callstack, 128);
	    
	    // backtrace_symbols 将从 backtrace 函数获取的信息转化为一个字符串数组，每个字符串包含了一个相对于 callstack 中对应元素的可打印信息，包括函数名、偏移地址、实际返回地址。
	    // 返回一个指向字符串数组的指针
	    char **strs = backtrace_symbols(callstack, frames);
	    
	    NSMutableArray * backtrace = [NSMutableArray arrayWithCapacity:frames];
	    for (int i = 0; i < frames; i++) {
	        [backtrace addObject:[NSString stringWithUTF8String:strs[i]]];
	    }
	    free(strs);
	    return backtrace;
	}

```

# 堆栈符号化

系统 api 获取的堆栈信息可能只是一串内存地址。

思路：找到当前应用对于的 dsym 符号表文件，

-  symbolicatecrash（Xcode 的 Organizer 内置了）
- dwarfdump，
- atos

还原 crash 堆栈内存地址对应的符号名。需要注意，<font color='red'>如果应用中使用了自己或第三方的动态库，应用崩溃在动态库 Image 而不是主程序 Image 中，我们需要有对应动态库的 dsym 符号表才能符号化</font>



地址空间布局随机化(Address space layout randomization)，就是每次应用加载时，使用随机的一个地址空间，这样能有效防止被攻击。

VM Address 是编译后 Image 的**起始位置**，Load Address 是在运行时加载到虚拟内存的起始位置，Slide 是加载到内存的偏移，这个偏移值是一个随机值，每次运行都不相同，有下面公式：

```
Stack Address = Symbol Address + Slide
```

<img src="https://img-blog.csdnimg.cn/d25875b0799d472e89dbe58f1245ad63.png?x-oss-process=image/watermark,type_ZHJvaWRzYW5zZmFsbGJhY2s,shadow_50,text_Q1NETiBARm9yZXZlcl93ag==,size_20,color_FFFFFF,t_70,g_se,x_16#pic_center" alt="在这里插入图片描述" style="zoom:50%;" />

Stack Address 位于 0x1046eea14

相对Load Address 0x1046e8000 偏移了 27156。（Stack Address = Load Address + Offset)

已知 VM Address 为 0x100000000，Load Address 为 0x1046e8000，可以得到 Slide 为 0x46e8000。通过公式 Symbol Address = Stack Address - Slider 求得 Symbol Address 为 0x100006a14





# 参考文档

[iOS之深入解析崩溃Crash的收集调试与符号化分析](https://blog.csdn.net/Forever_wj/article/details/120068863?spm=1001.2101.3001.6650.5&utm_medium=distribute.pc_relevant.none-task-blog-2%7Edefault%7EBlogCommendFromBaidu%7Edefault-5-120068863-blog-119517507.pc_relevant_multi_platform_whitelistv3&depth_1-utm_source=distribute.pc_relevant.none-task-blog-2%7Edefault%7EBlogCommendFromBaidu%7Edefault-5-120068863-blog-119517507.pc_relevant_multi_platform_whitelistv3&utm_relevant_index=9)