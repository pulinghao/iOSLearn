# GCD

## dispatch_object_c 联合抽象类

```c
// 简化
// 如果是C++的环境
#if defined(__cplusplus)
typedef struct dispatch_object_s {
private:
	dispatch_object_s();
	~dispatch_object_s();
	dispatch_object_s(const dispatch_object_s &);
	void operator=(const dispatch_object_s &);
} *dispatch_object_t;

// 如果是C的环境，我们主要用下面的这个
#else /* Plain C */
typedef union {
	struct _os_object_s *_os_obj;
	struct dispatch_object_s *_do;
	struct dispatch_continuation_s *_dc;
	struct dispatch_queue_s *_dq;
	struct dispatch_queue_attr_s *_dqa;
	struct dispatch_group_s *_dg;
	struct dispatch_source_s *_ds;
	struct dispatch_mach_s *_dm;
	struct dispatch_mach_msg_s *_dmsg;
	struct dispatch_source_attr_s *_dsa;
	struct dispatch_semaphore_s *_dsema;
	struct dispatch_data_s *_ddata;
	struct dispatch_io_s *_dchannel;
	struct dispatch_operation_s *_doperation;
	struct dispatch_disk_s *_ddisk;
} dispatch_object_t __attribute__((__transparent_union__));
```

- `dispatch_object_s`

该结构体在`object_internal.h`的定义如下：

```c
struct dispatch_object_s {
	_DISPATCH_OBJECT_HEADER(object);
};

#define _DISPATCH_OBJECT_HEADER(x) \
	struct _os_object_s _as_os_obj[0]; \ //创建结构体数组 _os_object_s
	OS_OBJECT_STRUCT_HEADER(dispatch_##x); \
	struct dispatch_##x##_s *volatile do_next; \
	struct dispatch_queue_s *do_targetq; \
	void *do_ctxt; \
	void *do_finalizer
```

`##`表示字符串替代。`#`是“字符串化”的意思。出现在宏定义中的#是把跟在后面的参数转换成一个字符串。

如果##后的参数本身也是一个宏的话，##会阻止这个宏的展开，**也就是只替换一次。**

## 获取队列的三种方式

### dispatch_queue_create

dispatch_queue_create(const char *label, dispatch_queue_attr_t attr)

- label：名字
- atrr：属性

	- 串行
	- 并发

### 主队列：dispatch_get_main_queue

### 全局队列：dispatch_get_global_queue

## dispatch_sync

### dispatch_sync_f

- 串行队列:dq_width = 1，触发dispatch_barrier_sync_f

	- 上锁：_dispatch_queue_try_acquire_barrier_sync

		- _dispatch_queue_try_acquire_barrier_sync_and_suspend

			- 获取队列的dq_state值（这是原子操作）
			- 判断dq_state是否为默认值（init|role)
			- 如果是第一次lock，返回true，并修改dq_state的值（这样后续访问到的都是修改后的值）
			- 否则，返回false，dq_state的值不变

	- 获取不到锁，则进入等待：_dispatch_sync_f_slow

		- _dispatch_sync_wait

			- 检测是否发生死锁：_dispatch_sync_wait_prepare

				- 判断是否发生死锁

					- 串行队列执行task1
					- task1中有个任务是向串行队列执行task2
					- task2的插入方式是dispatch_sync，阻塞当前的线程
					- 一个线程，在两个Task中产生了竞争关系。线程必须等task1执行完才能插入task2；但是插入task2这个任务阻塞了正在执行task1的线程

			- 判断一个队列是否被线程上了两次锁：_dq_state_drain_locked_by
			- 入队等待：_dispatch_queue_push_sync_waiter
			- 等待前面的任务完成，线程再取
			- 等待结束，执行client代码_dispatch_sync_invoke_and_complete_recurse

	- 不需等待，执行_dispatch_queue_barrier_sync_invoke_and_complete
	- 不开新线程，串行执行

- 并发队列

	- _dispatch_sync_function_invoke_inline

		- _dispatch_thread_frame_push  //保护现场
		- _dispatch_client_callout    // 回调client
		- _dispatch_thread_frame_pop    //恢复

	- _dispatch_queue_non_barrier_complete
	- 不开新线程，串行执行

### 参数：dispatch_queue_t，dispatch_block_t

## dispatch_async

### 任务打包 _dispatch_continuation_init

- work的代码放在这个里面，控制执行和释放_dispatch_call_block_and_release

### _dispatch_continuation_async

- 串行队列：_dispatch_continuation_push
- 并行队列：_dispatch_async_f2

## 数据结构

### dispatch_queue_t

## dispatch_once

### dispatch_once_t val

### 第一个线程进来的时候，由于val与NULL的值相同，所以执行block中的方法

- block执行完后，val的值被刷新，不为0

	- 后续再进来，比较val与NULL不等，所以都不会再执行block

### 由于第一个线程把val修改了，所以别的线程都无法执行block

# GCD的高级用法

##  dispatch_set_target_queue

`dispatch_set_target_queue(dispatch_object_t object, dispatch_queue_t queue);`

> 第一个参数是要执行变更的队列（不能指定主队列和全局队列）
>
> 第二个参数是目标队列（指定全局队列）

两个作用：

- 使某个队列成为另外一个队列的执行队列
- 修改用户队列的目标队列，使多个serial queue在目标queue上一次只有一个执行

### 变更优先级

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

### 变更执行队列

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

