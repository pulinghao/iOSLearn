# View Debugger

# Exception BreakPoint

当程序崩溃时，添加异常断点（点击Xcode左下角，选择`Add Exception BreakPoint`）。

<img src="WWDC2015-高级调试和 Address Sanitizer.assets/image-20210402231057903.png" alt="image-20210402231057903" style="zoom:50%;" />

断点类型：

- Objective-C
- C++

设置异常断点后，在控制台(LLDB)里面就看不到任何东西了。

发生崩溃时，在LLDB中输入，表示第一个参数，就可以拿到异常对象本身了。这个操作也可以在添加断点`Add Action`来做。



```
po $arg1 
```

<img src="WWDC2015-高级调试和 Address Sanitizer.assets/image-20210402231231161.png" alt="image-20210402231231161" style="zoom:50%;" />

# Add Action Debug

给断点添加Action以后，并且执行完Action之后，继续运行。

记得勾选`Automatically continue after evaluation actions`

<img src="WWDC2015-高级调试和 Address Sanitizer.assets/image-20210402235712121.png" alt="image-20210402235712121" style="zoom:50%;" />

# Address Santitizer

## 解决问题

- 内存可能被篡改
- 随机异常

避免内存操作的方式有：

- 使用Swift
- 或者使用ARC

出现内存问题可疑性很高的地方：

- 直接动态分配内存
- C/C++ 互相操作

Address Santitizer的优势

- 在运行时发现错误
- 可以在iOS上执行

## 常见的错误清单

- Use After Free：使用释放的内存
- Heap buffer overflow：堆缓存溢出
- stack buffer overflow：栈缓存溢出
- Global variable overflow：全局变量溢出
- C++的容器溢出
- Use After Return：返回后使用

使用，进入Edit  Scheme，勾选

<img src="WWDC2015-高级调试和 Address Sanitizer.assets/image-20210403002224079.png" alt="image-20210403002224079" style="zoom:50%;" />

AS还可以告诉我们，内存错误的地址是在哪里。

<img src="WWDC2015-高级调试和 Address Sanitizer.assets/image-20210403002503525.png" alt="image-20210403002503525" style="zoom:50%;" />

WWDC大会视频中，犯的错误是，把原来属于一个结构体的内存，当做一个指针内存执行`sizeof`方法了。

`sizeof（指针）`的大小是4个字节（或者8个字节）；而一个带有双精度double类型的结构体`sizeof(struct)`至少16个字节。NSData在转换的时候，一定要知道转换的类型

<img src="WWDC2015-高级调试和 Address Sanitizer.assets/image-20210403003013658.png" alt="image-20210403003013658" style="zoom:50%;" />



点击左侧Debug UI，可以看到内存的布局

<img src="WWDC2015-高级调试和 Address Sanitizer.assets/image-20210403003138997.png" alt="image-20210403003138997" style="zoom:50%;" />

## 工作原理

0. 打开AS之后，clang编译生成二进制工具码（里面带有AS的信息）。在运行时，asan dylib会被加载到可执行文件中。

<img src="WWDC2015-高级调试和 Address Sanitizer.assets/image-20210403004501918.png" alt="image-20210403004501918" style="zoom:50%;" />

1. AS会把进程中的内存，做一个映射Shadow Memory
2. Shadow Memory展示了内存中，是否为可访问的地址相关信息。无效的内存为红色区域

<img src="WWDC2015-高级调试和 Address Sanitizer.assets/image-20210403004014006.png" alt="image-20210403004014006" style="zoom:50%;" />

3. 加入内存检测

<img src="WWDC2015-高级调试和 Address Sanitizer.assets/image-20210403003900882.png" alt="image-20210403003900882" style="zoom:50%;" />

4. Shadow Memory
   1. IsPoisoned方法需要被执行得足够快
   2. 影子内存中，每8个字节就有1个被跟踪
   3. 没有被分配内存，在进程启动时候保存，在需要时使用
   4. 算法：先右移3位（除以8），在添加一个常数偏移，如果这个位置上的值不为0，就说明这块内存被使用了

<img src="WWDC2015-高级调试和 Address Sanitizer.assets/image-20210403004956394.png" alt="image-20210403004956394" style="zoom:50%;" />

5. 在编译器时，AS在变量之间插入了Poison区域。在函数运行时，进入Poison区；当栈销毁的时候，Poison区域解毒

<img src="WWDC2015-高级调试和 Address Sanitizer.assets/image-20210403010143343.png" alt="image-20210403010143343" style="zoom:50%;" />

6. 类似的还有全局区，提前在要访问的内存之前，插入Poison检测

<img src="WWDC2015-高级调试和 Address Sanitizer.assets/image-20210403010414150.png" alt="image-20210403010414150" style="zoom:50%;" />

## 对性能的影响

- 2x-5x降速CPU
- 2x-3x内存增长

## 其他性能检测工具

- Guard Malloc
  - 不需要重新编译
  - 不能在iOS设备运行

- NSZombie
  - 获取被过度释放的对象
  - 使用zombie来替换dealloc
  - Zombie Instrument更加推荐

- Malloc Scribble
  - 调查未初始化变量的问题
  - 使用0xAA填充分配的内存
  - 使用0x55填充被释放的内存

- Leaks
  - 循环引用
  - Abandoned memory，被放弃的内存

# 参考链接

B栈链接：[wwdc2015-高级调试和 Address Sanitizer](https://www.bilibili.com/video/BV1CA411q7jc/?spm_id_from=333.788.videocard.1)

