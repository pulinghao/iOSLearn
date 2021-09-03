以TikTok为例，进行分析。相关工具

- TikTok.ipa
- WeChat.ipa
- MachOView

# 数据段和代码段

```c
//hello.c
#include <stdio.h>

int global_uninit_val;
int global_init_val =123;
static int static_val =456;
int main()
{
    int a = 1;;
    printf("helloworld\n");
    return 1;
}
```

在**Linux**环境下内存的分布情况：

<img src="/Users/pulinghao/Library/Application Support/typora-user-images/image-20210903143330087.png" alt="image-20210903143330087" style="zoom:50%;" />

# Header

使用MachOView软件打开TikTok的可执行文件

<img src="/Users/pulinghao/Library/Application Support/typora-user-images/image-20210901154657760.png" alt="image-20210901154657760" style="zoom:50%;" />

- magic number 为`FEDEFACF`, 判断为64位的Mach-O文件
- 只有一种架构，ARM64
- File Type 为 `MH_EXECUTE`，说明是可执行文件

打开Wechat.ipa文件

<img src="/Users/pulinghao/Library/Application Support/typora-user-images/image-20210901155448032.png" alt="image-20210901155448032" style="zoom:50%;" />

- 支持两种架构ARMv7和ARM64
- Magic Number为 `BEBAFECA`，胖结构
- Number of Architecture为2，说明了支持两种架构





# Section



# fishhook

fishhook是facebook推出的一款用于hook C函数的工具。我们利用hook`strlen`函数的方式，来看下其工作原理。示例代码如下：

## hook strlen函数

```c
#import <Foundation/Foundation.h>
#include "fishhook.h"

// 原始函数
static int (*orignal_strlen)(const char* _s);

// 新函数
int new_strlen(const char *_s){
    return 123;
}


int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        char *str = "hello world";
        int length = strlen(str);  //断点1
        printf("%ld\n",length);    //断点2
        struct rebinding strlen_rebinding = {"strlen",new_strlen,(void *)&orignal_strlen};
        
        rebind_symbols((struct rebinding[1]){strlen_rebinding}, 1);
        
        length = strlen(str);
        printf("%ld\n",length); //断点3
    }
    return 0;
}

```

输出如下：

```
123
```

## 载入image

在Product路径下，获取可执行文件

<img src="/Users/pulinghao/Library/Application Support/typora-user-images/image-20210903112641240.png" alt="image-20210903112641240" style="zoom:50%;" />



```c

int rebind_symbols(struct rebinding rebindings[], size_t rebindings_nel) {
  int retval = prepend_rebindings(&_rebindings_head, rebindings, rebindings_nel);
  if (retval < 0) {
    return retval;
  }
  // If this was the first call, register callback for image additions (which is also invoked for
  // existing images, otherwise, just run on existing images
  if (!_rebindings_head->next) { //第一次加载的时候，next = NULL,所以会把image加载进来
    _dyld_register_func_for_add_image(_rebind_symbols_for_image);
  } else {
    uint32_t c = _dyld_image_count();
    for (uint32_t i = 0; i < c; i++) {
      _rebind_symbols_for_image(_dyld_get_image_header(i), _dyld_get_image_vmaddr_slide(i));
    }
  }
  return retval;
}
```

`_dyld_register_func_for_add_image`

这个方法当镜像 *Image* 被 *load* 或是 *unload* 的时候都会由 dyld 主动调用。当该方法被触发时，会为每个镜像触发其回调方法。之后则将其镜像与其回调函数进行绑定（但是未进行初始化）。使用 `_dyld_register_func_for_add_image` 注册的回调将在镜像中的 terminators 启动后被调用。

```c

/*
 * The following functions allow you to install callbacks which will be called   
 * by dyld whenever an image is loaded or unloaded.  During a call to _dyld_register_func_for_add_image()
 * the callback func is called for every existing image.  Later, it is called as each new image
 * is loaded and bound (but initializers not yet run).  The callback registered with
 * _dyld_register_func_for_remove_image() is called after any terminators in an image are run
 * and before the image is un-memory-mapped.
 */
extern void _dyld_register_func_for_add_image(void (*func)(const struct mach_header* mh, intptr_t vmaddr_slide))    __OSX_AVAILABLE_STARTING(__MAC_10_1, __IPHONE_2_0);
extern void _dyld_register_func_for_remove_image(void (*func)(const struct mach_header* mh, intptr_t vmaddr_slide)) __OSX_AVAILABLE_STARTING(__MAC_10_1, __IPHONE_2_0);

_dyld_register_func_for_add_image(_rebind_symbols_for_image);
```

调用栈如图所示：

<img src="/Users/pulinghao/Library/Application Support/typora-user-images/image-20210903122708685.png" alt="image-20210903122708685" style="zoom:50%;" />

也就是说，当`_dyld_register_func_for_add_image`的函数执行完以后，再走进回调函数里`_rebind_symbols_for_image`。此时，就拿到了head和slide数据

```c
static void _rebind_symbols_for_image(const struct mach_header *header,
                                      intptr_t slide) {
    rebind_symbols_for_image(_rebindings_head, header, slide);
}
```



## 重绑定寻址

```c
static void rebind_symbols_for_image(struct rebindings_entry *rebindings,
                                     const struct mach_header *header,
                                     intptr_t slide) {
    Dl_info info;
    if (dladdr(header, &info) == 0) {
        return;
    }

    // 声明几个查找量:
    // linkedit_segment, symtab_command, dysymtab_command
    segment_command_t *cur_seg_cmd;
    segment_command_t *linkedit_segment = NULL;
    struct symtab_command* symtab_cmd = NULL;
    struct dysymtab_command* dysymtab_cmd = NULL;

    // 初始化游标
    // header = 0x100000000 - 二进制文件基址默认偏移
    // sizeof(mach_header_t) = 0x20 - Mach-O Header 部分
    // 首先需要跳过 Mach-O Header
    uintptr_t cur = (uintptr_t)header + sizeof(mach_header_t);
    // 遍历每一个 Load Command，游标每一次偏移每个命令的 Command Size 大小
    // header -> ncmds: Load Command 加载命令数量
    // cur_seg_cmd -> cmdsize: Load 大小
    for (uint i = 0; i < header->ncmds; i++, cur += cur_seg_cmd->cmdsize) {
        // 取出当前的 Load Command
        cur_seg_cmd = (segment_command_t *)cur;
        // Load Command 的类型是 LC_SEGMENT
        if (cur_seg_cmd->cmd == LC_SEGMENT_ARCH_DEPENDENT) {
            // 比对一下 Load Command 的 name 是否为 __LINKEDIT
            if (strcmp(cur_seg_cmd->segname, SEG_LINKEDIT) == 0) {
                // 检索到 __LINKEDIT
                linkedit_segment = cur_seg_cmd;
            }
        }
        // 判断当前 Load Command 是否是 LC_SYMTAB 类型
        // LC_SEGMENT - 代表当前区域链接器信息
        else if (cur_seg_cmd->cmd == LC_SYMTAB) {
            // 检索到 LC_SYMTAB
            symtab_cmd = (struct symtab_command*)cur_seg_cmd;
        }
        // 判断当前 Load Command 是否是 LC_DYSYMTAB 类型
        // LC_DYSYMTAB - 代表动态链接器信息区域
        else if (cur_seg_cmd->cmd == LC_DYSYMTAB) {
            // 检索到 LC_DYSYMTAB
            dysymtab_cmd = (struct dysymtab_command*)cur_seg_cmd;
        }
    }

    // 容错处理
    if (!symtab_cmd || !dysymtab_cmd || !linkedit_segment ||
        !dysymtab_cmd->nindirectsyms) {
        return;
    }

    // slide: ASLR 偏移量
    // vmaddr: SEG_LINKEDIT 的虚拟地址
    // fileoff: SEG_LINKEDIT 地址偏移
    // 式①：base = SEG_LINKEDIT真实地址 - SEG_LINKEDIT地址偏移
    // 式②：SEG_LINKEDIT真实地址 = SEG_LINKEDIT虚拟地址 + ASLR偏移量
    // 将②代入①：Base = SEG_LINKEDIT虚拟地址 + ASLR偏移量 - SEG_LINKEDIT地址偏移
    uintptr_t linkedit_base = (uintptr_t)slide + linkedit_segment->vmaddr - linkedit_segment->fileoff;
    // 通过 base + symtab 的偏移量 计算 symtab 表的首地址，并获取 nlist_t 结构体实例
    nlist_t *symtab = (nlist_t *)(linkedit_base + symtab_cmd->symoff);
    // 通过 base + stroff 字符表偏移量计算字符表中的首地址，获取字符串表
    char *strtab = (char *)(linkedit_base + symtab_cmd->stroff);
    // 通过 base + indirectsymoff 偏移量来计算动态符号表的首地址
    uint32_t *indirect_symtab = (uint32_t *)(linkedit_base + dysymtab_cmd->indirectsymoff);

    // 归零游标，复用
    cur = (uintptr_t)header + sizeof(mach_header_t);
    // 再次遍历 Load Commands
    for (uint i = 0; i < header->ncmds; i++, cur += cur_seg_cmd->cmdsize) {
        cur_seg_cmd = (segment_command_t *)cur;
        // Load Command 的类型是 LC_SEGMENT
        if (cur_seg_cmd->cmd == LC_SEGMENT_ARCH_DEPENDENT) {
            // 查询 Segment Name 过滤出 __DATA 或者 __DATA_CONST
            if (strcmp(cur_seg_cmd->segname, SEG_DATA) != 0 &&
                strcmp(cur_seg_cmd->segname, SEG_DATA_CONST) != 0) {
                continue;
            }
            // 遍历 Segment 中的 Section
            for (uint j = 0; j < cur_seg_cmd->nsects; j++) {
                // 取出 Section
                section_t *sect = (section_t *)(cur + sizeof(segment_command_t)) + j;
                // flags & SECTION_TYPE 通过 SECTION_TYPE 掩码获取 flags 记录类型的 8 bit
                // 如果 section 的类型为 S_LAZY_SYMBOL_POINTERS
                // 这个类型代表 lazy symbol 指针 Section
                if ((sect->flags & SECTION_TYPE) == S_LAZY_SYMBOL_POINTERS) {
                    // 进行 rebinding 重写操作
                    perform_rebinding_with_section(rebindings, sect, slide, symtab, strtab, indirect_symtab);
                }
                // 这个类型代表 non-lazy symbol 指针 Section
                if ((sect->flags & SECTION_TYPE) == S_NON_LAZY_SYMBOL_POINTERS) {
                    perform_rebinding_with_section(rebindings, sect, slide, symtab, strtab, indirect_symtab);
                }
            }
        }
    }
}
```

注意这里做了下面几件事情：

1. 初始化游标：确认基地址、symtab 表、字符串表和动态符号表的首地址。这些在Load Commands的区域里，可以被找到。如图所示：

<img src="/Users/pulinghao/Library/Application Support/typora-user-images/image-20210903124601210.png" alt="image-20210903124601210" style="zoom:50%;" />

2. 在每个Section中，去进行rebind操作

> 为什么 *Linkedit Segment* 首地址信息十分重要，因为在 *Load Command* 中，`LC_SYMTAB` 和 `LC_DYSYMTAB` 的中所记录的 Offset 都是基于 **__LINKEDIT** 段的。而 `LC_SYMTAB` 中通过偏移量可以拿到**symtab 符号表首地址**、**strtab 符号名称字符表首地址**以及**indirect_symtab 跳转表首地址**。

```c
int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        char *str = "hello world";
        int length = strlen(str);  //断点1
        printf("%ld\n",length);    //断点2
        struct rebinding strlen_rebinding = {"strlen",new_strlen,(void *)&orignal_strlen};
        
        rebind_symbols((struct rebinding[1]){strlen_rebinding}, 1);
        
        length = strlen(str);
        printf("%ld\n",length); //断点3
    }
    return 0;
}
```

### 断点1

在执行到断点1时，先获取整个MachO文件的基地址`0x0000000100000000`

```
(lldb)image list
```

<img src="/Users/pulinghao/Library/Application Support/typora-user-images/image-20210903144952071.png" alt="image-20210903144952071" style="zoom:50%;" />

通过MachOView软件可以看到，`strlen`函数的偏移地址为`0x8070`

<img src="/Users/pulinghao/Library/Application Support/typora-user-images/image-20210903145122505.png" alt="image-20210903145122505" style="zoom:50%;" />

从而得到，这个入口地址为`0x100008070`

查看这块内存的值：

```shell
memory read baseAddress+offset
```

<img src="/Users/pulinghao/Library/Application Support/typora-user-images/image-20210903145221962.png" alt="image-20210903145221962" style="zoom:50%;" />

执行这个指针（注意64位系统是8个字节读取）的汇编命令：

这里注意一下，**iOS是小端格式的！！！数据的高字节保存在内存的高地址**

```shell
dis -s 0x0100003f60
```

<img src="/Users/pulinghao/Library/Application Support/typora-user-images/image-20210903145322959.png" alt="image-20210903145322959" style="zoom:50%;" />

此时还看不出有什么东西来。因为`strlen`是被懒加载到系统中的，所以这段汇编没有意义

### 断点2

此时已经执行了`strlen`函数，这个函数被加载到系统中来。再去读一下刚才的那块内存`0x100008070`。可以发现值已经变掉了。

<img src="/Users/pulinghao/Library/Application Support/typora-user-images/image-20210903145453690.png" alt="image-20210903145453690" style="zoom:50%;" />

执行汇编命令：

```shell
dis -s 0x7fff20531540
```

<img src="/Users/pulinghao/Library/Application Support/typora-user-images/image-20210903145614964.png" alt="image-20210903145614964" style="zoom:50%;" />

可以发现，系统的`strlen`方法已经被加载进来了。

### 断点3

执行了rebind以后，系统的`strlen`接口被替换，同样的，看一下`0x100008070`内存

<img src="/Users/pulinghao/Library/Application Support/typora-user-images/image-20210903145745778.png" alt="image-20210903145745778" style="zoom:50%;" />

执行汇编命令：

```
dis -s 0x0100003d60
```

<img src="/Users/pulinghao/Library/Application Support/typora-user-images/image-20210903145817415.png" alt="image-20210903145817415" style="zoom:50%;" />

可以发现，此时方法已经被hook为自定义的方法`new_strlen`

## MachO-View中的操作

在MachO-View中，模拟重新绑定的操作

### Lazy Symbol Pointers

找到`strlen`的地址偏移为`8070`

<img src="/Users/pulinghao/Library/Application Support/typora-user-images/image-20210903150046828.png" alt="image-20210903150046828" style="zoom:50%;" />

### Indirect Symbols

在这个表中，找到`strlen`,其DATA值，就是方法的入口`0x004B`

<img src="/Users/pulinghao/Library/Application Support/typora-user-images/image-20210903150224039.png" alt="image-20210903150224039" style="zoom:50%;" />

### Symbol Table

将`0x004B`转成十进制的offset为75。它的Data字段表示在String Table中的偏移值为`0x013B`

<img src="/Users/pulinghao/Library/Application Support/typora-user-images/image-20210903150416029.png" alt="image-20210903150416029" style="zoom:50%;" />

### String Table

String Table的起始偏移为`0xC778`，加上strlen的偏移`0x013B`,就是`0xC8B3`

<img src="/Users/pulinghao/Library/Application Support/typora-user-images/image-20210903150828323.png" alt="image-20210903150828323" style="zoom:50%;" />

<img src="/Users/pulinghao/Library/Application Support/typora-user-images/image-20210903150952887.png" alt="image-20210903150952887" style="zoom:50%;" />

# 参考链接：

[Mach-O 文件格式探索](https://www.desgard.com/iOS-Source-Probe/C/mach-o/Mach-O%20%E6%96%87%E4%BB%B6%E6%A0%BC%E5%BC%8F%E6%8E%A2%E7%B4%A2.html)

[编译、链接学习笔记（二）目标文件的构成](https://blog.csdn.net/u013230511/article/details/77427821)

[iOS逆向工程 - fishhook原理](https://www.jianshu.com/p/4d86de908721)

# Tips

## 从指针地址中，获取指针

```c
//1. 指针地址的声明
//uintptr_t 修饰指针地址的，是个整型或者长整型数据，根据平台定
uintptr_t cur; 

// 2. 从这个地址zhong获取对应的指针
segment_command_t *cmd = (segment_command_t *)cur;
```

