# GCD的使用

队列挂起，任务能否继续执行？

## 主队列

- 主队列在APP的`main`函数之前，就被创建出来了

NSThread有两个函数`main`和`start`

## 栅栏函数

- 封装网络请求的时候，不可以用<font color='red'>栅栏函数！！！</font>(AFN的网络队列，与这个添加网络任务的队列，不是一个队列)
- 栅栏函数，必须创建在<font color='red'>'**并发队列**</font>上

## 调度组

多线程执行的两个问题

- 顺序执行
- 线程安全
- 解决在不同队列中，任务同步执行的问题，都放到一个组中

设计思路

- 创建要同步的组
- 设置超时时间`dispatch_group_wait`，在规定时间内执行完，返回0；否则返回非0
- 使用`dispatch_group_notify`同步结果

```objective-c
/**
 调度组测试
 */
- (void)groupDemo{
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    
    dispatch_group_async(group, queue, ^{
        //创建调度组
        // AFN task
    });
    
    dispatch_group_async(group, queue, ^{
        //创建调度组
        // AFN task
    });
    
    long timeout = dispatch_group_wait(group, 0.5); //DISPATCH_TIME_FOREVER 一直等待完成
    if (timeout == 0) {
        dispatch_group_notify(group, queue, ^{
            // Your task
        });
        
    }
}
```

## 源

1. 创建queue和source

```objective-c
self.queue = dispatch_queue_create("com.tz.cn.cooci", 0);
// source依赖main queue
self.source = dispatch_source_create(DISPATCH_SOURCE_TYPE_DATA_ADD, 0, 0, dispatch_get_main_queue());
```

2. 将source作用于整个线程中
3. 封装source事件，需要回调的触发函数

```c
// 保存代码块 ---> 异步 dispatch_source_set_event_handler()
    // 封装我们需要回调的触发函数
dispatch_source_set_event_handler(self.source, ^{
    NSUInteger value = dispatch_source_get_data(self.source);
    self.totalComplete += value;
    NSLog(@"进度：%.2f", self.totalComplete/100.0);
    self.progressView.progress = self.totalComplete/100.0;
});
```

4. 开始任务resume，原因是**source创建后，默认挂起**

```c
// resume (OC): dispatch_resume (c)
// [task resume]

dispatch_resume(self.source);   

void dispatch_resume(dispatch_object_t object);
```

`dispatch_resume`可以继续任何dispatch_object_t对象，前提是必须这个对象被挂起了。如果这个对象销毁了

5. 外部事件传入，暂停任务

```objective-c
- (IBAction)didClickStartOrPauseAction:(id)sender {
    if (self.isRunning) {// 正在跑就暂停
        dispatch_suspend(self.source);
        dispatch_suspend(self.queue);// mainqueue 挂起
        self.isRunning = NO;
        [sender setTitle:@"暂停中..." forState:UIControlStateNormal];
    }else{
        dispatch_resume(self.source);
        dispatch_resume(self.queue);
        self.isRunning = YES;
        [sender setTitle:@"加载中..." forState:UIControlStateNormal];
    }
}
```

6. 设置触发函数`dispatch_source_merge_data`

```objective-c
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    NSLog(@"点击开始加载");
    for (NSUInteger index = 0; index < 100; index++) {
        dispatch_async(self.queue, ^{
            if (!self.isRunning) {
                NSLog(@"暂停下载");
                return ;
            }
            sleep(2);

            dispatch_source_merge_data(self.source, 1);
        });
    }
}
```

```
void dispatch_source_merge_data(dispatch_source_t source, uintptr_t value);
```

- source：源
- value：

# GCD源码

源码库位置：`libdispatch`

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

`##`表示字符串替代。`#`是“字符串化”的意思。出现在宏定义中的`#`是把跟在后面的参数转换成一个字符串。

如果`##`后的参数本身也是一个宏的话，`##`会阻止这个宏的展开，**也就是只替换一次。**

## 获取队列的三种方式

### 队列的结构

```c
typedef struct dispatch_introspection_queue_s {
	dispatch_queue_t queue;
	dispatch_queue_t target_queue;    //set_target_queue，处理同等优先级
	const char *label;
	unsigned long serialnum;     	     //串行队列数
	unsigned int width;                // 与栅栏有关
	unsigned int suspend_count;
	unsigned long enqueued:1,
			barrier:1,                     // 是否有栅栏函数
			draining:1,									   // 是否死锁
			global:1,											 // 全局
			main:1;												 // 主队列
} dispatch_introspection_queue_s;
```



### 手动创建

位于文件：queue.h中

`dispatch_queue_create(const char *label, dispatch_queue_attr_t attr)`

```c
// 创建一个队列 .label 属性是怎么配置
// attr 性质:  并发 串行
dispatch_queue_t dispatch_queue_create(const char *label, dispatch_queue_attr_t attr)
{
	return _dispatch_queue_create_with_target(label, attr,
			DISPATCH_TARGET_QUEUE_DEFAULT, true);
}
```

- `label`：名字
- `atrr`：属性
- 串行（NULL，或者是0）
- 并发

看下更深层次的源码`_dispatch_queue_create_with_target`的实现：

1. 获取队列的属性（串行 并行）
2. 从根队列获取`_dispatch_get_root_queue`
3. 获取到合适队列后，设置名字
4. 将创建后的队列，放到GCD的内部管理`_dispatch_introspection_queue_create`

```c
// 1. 定义 dispatch_queue_attr
#define DISPATCH_DECL(name) OS_OBJECT_DECL_SUBCLASS(name, dispatch_object)
#define OS_OBJECT_DECL_SUBCLASS(name, super) \
		OS_OBJECT_DECL_IMPL(name, <OS_OBJECT_CLASS(super)>)

DISPATCH_DECL(dispatch_queue_attr);
OS_OBJECT_DECL_SUBCLASS(dispatch_queue_attr, dispatch_object)
OS_OBJECT_DECL_IMPL(dispatch_queue_attr, <OS_OBJECT_CLASS(super)>)
  

DISPATCH_NOINLINE
static dispatch_queue_t
_dispatch_queue_create_with_target(const char *label, dispatch_queue_attr_t dqa,
		dispatch_queue_t tq, bool legacy)
{
  // tq 为NULL
	// 设置队列属性：默认: 串行
	// _dispatch_get_default_queue_attr
  
	if (!slowpath(dqa)) {
		dqa = _dispatch_get_default_queue_attr();
		// _dispatch_queue_attr
	} else if (dqa->do_vtable != DISPATCH_VTABLE(queue_attr)) { // 排除非queue_attr的报错 其实剩下就是并发了 _dispatch_queue_attr_vtable
		// OS_dispatch_queue_attr_class
		DISPATCH_CLIENT_CRASH(dqa->do_vtable, "Invalid queue attribute");
	}

	//
	// Step 1: Normalize arguments (qos, overcommit, tq)
	//
	// qos 就是服务质量
	dispatch_qos_t qos = _dispatch_priority_qos(dqa->dqa_qos_and_relpri);
#if !HAVE_PTHREAD_WORKQUEUE_QOS
	if (qos == DISPATCH_QOS_USER_INTERACTIVE) {
		qos = DISPATCH_QOS_USER_INITIATED;
	}
	if (qos == DISPATCH_QOS_MAINTENANCE) {
		qos = DISPATCH_QOS_BACKGROUND;
	}
#endif // !HAVE_PTHREAD_WORKQUEUE_QOS

	//  是否overcommit（即queue创建的线程数是否允许超过实际的CPU个数）
	_dispatch_queue_attr_overcommit_t overcommit = dqa->dqa_overcommit;
	if (overcommit != _dispatch_queue_attr_overcommit_unspecified && tq) {
		if (tq->do_targetq) {
			// overcommit 的queue 必须是全局的
			DISPATCH_CLIENT_CRASH(tq, "Cannot specify both overcommit and "
					"a non-global target queue");
		}
	}

	// _dispatch_get_root_queue 合适的队列
  
	// 因为用户创建的queue的tq一定为NULL，因此，只要关注tq == NULL的分支即可，我们删除了其余分支
	if (!tq) {//// 自己创建的queue，tq都是null
		tq = _dispatch_get_root_queue(//// 在root queue里面去取一个合适的queue当做target queue
				qos == DISPATCH_QOS_UNSPECIFIED ? DISPATCH_QOS_DEFAULT : qos, // 无论是用户创建的串行还是并行队列，其qos都没有指定，因此，qos这里都取DISPATCH_QOS_DEFAULT
				overcommit == _dispatch_queue_attr_overcommit_enabled);// 1
		if (slowpath(!tq)) {// 如果根据create queue是传入的属性无法获取到对应的tq，crash
			DISPATCH_CLIENT_CRASH(qos, "Invalid queue attribute");
		}
	}

	//
	// Step 2: Initialize the queue
	//

	if (legacy) {
		// if any of these attributes is specified, use non legacy classes
		if (dqa->dqa_inactive || dqa->dqa_autorelease_frequency) {
			legacy = false;
		}
	}

	const void *vtable;
	dispatch_queue_flags_t dqf = 0;
	// 根据不同的queue类型，设置vtable。vtable实现了SERIAL queue 和 CONCURRENT queue的行为差异。
	if (legacy) { // 之前的类型
		vtable = DISPATCH_VTABLE(queue);
	} else if (dqa->dqa_concurrent) { // 并发
		vtable = DISPATCH_VTABLE(queue_concurrent);
	} else { //  串行
		vtable = DISPATCH_VTABLE(queue_serial);
	}
	switch (dqa->dqa_autorelease_frequency) {
	case DISPATCH_AUTORELEASE_FREQUENCY_NEVER:
		dqf |= DQF_AUTORELEASE_NEVER;
		break;
	case DISPATCH_AUTORELEASE_FREQUENCY_WORK_ITEM:
		dqf |= DQF_AUTORELEASE_ALWAYS;
		break;
	}
	if (legacy) {
		dqf |= DQF_LEGACY;
	}
	if (label) {
		const char *tmp = _dispatch_strdup_if_mutable(label);
		if (tmp != label) {
			dqf |= DQF_LABEL_NEEDS_FREE;
			label = tmp;
		}
	}

	//  _dispatch_object_alloc 给queue开辟h内存
	dispatch_queue_t dq = _dispatch_object_alloc(vtable,
			sizeof(struct dispatch_queue_s) - DISPATCH_QUEUE_CACHELINE_PAD);
	// _dispatch_queue_init 调用初始化
	// 初始化dq，可以看到dqa->dqa_concurrent，对于并发队列，其queue width是DISPATCH_QUEUE_WIDTH_MAX，而串行队列其width是1
	_dispatch_queue_init(dq, dqf, dqa->dqa_concurrent ?
			DISPATCH_QUEUE_WIDTH_MAX : 1, DISPATCH_QUEUE_ROLE_INNER |
			(dqa->dqa_inactive ? DISPATCH_QUEUE_INACTIVE : 0));

	// 设置dq的名字
	dq->dq_label = label;
	dq->dq_priority = dqa->dqa_qos_and_relpri;
	if (!dq->dq_priority) {
		// legacy way of inherithing the QoS from the target
		_dispatch_queue_priority_inherit_from_target(dq, tq);
	} else if (overcommit == _dispatch_queue_attr_overcommit_enabled) {
		dq->dq_priority |= DISPATCH_PRIORITY_FLAG_OVERCOMMIT;
	}
	if (!dqa->dqa_inactive) {
		_dispatch_queue_inherit_wlh_from_target(dq, tq);
	}
	_dispatch_retain(tq);
	dq->do_targetq = tq;// 这一步，很关键！！！ 将root queue设置为dq的target queue，root queue和新创建的queue联合在了一起
	_dispatch_object_debug(dq, "%s", __func__);
// 将新创建的dq，添加到GCD内部管理的叫做_dispatch_introspection的queue列表中。这是GCD内部维护的一个queue列表
	return _dispatch_introspection_queue_create(dq);
}

dispatch_queue_t
_dispatch_introspection_queue_create(dispatch_queue_t dq)
{
	TAILQ_INIT(&dq->diq_order_top_head);
	TAILQ_INIT(&dq->diq_order_bottom_head);
	_dispatch_unfair_lock_lock(&_dispatch_introspection.queues_lock);
	TAILQ_INSERT_TAIL(&_dispatch_introspection.queues, dq, diq_list);
	_dispatch_unfair_lock_unlock(&_dispatch_introspection.queues_lock);

	DISPATCH_INTROSPECTION_INTERPOSABLE_HOOK_CALLOUT(queue_create, dq);
	if (DISPATCH_INTROSPECTION_HOOK_ENABLED(queue_create)) {
		_dispatch_introspection_queue_create_hook(dq);
	}
	return dq;
}
```

最后返回的队列结构如下：

```c
DISPATCH_USED inline
dispatch_introspection_queue_s
dispatch_introspection_queue_get_info(dispatch_queue_t dq)
{
	bool global = (dq->do_xref_cnt == DISPATCH_OBJECT_GLOBAL_REFCNT) ||
			(dq->do_ref_cnt == DISPATCH_OBJECT_GLOBAL_REFCNT);
	uint64_t dq_state = os_atomic_load2o(dq, dq_state, relaxed);

	dispatch_introspection_queue_s diq = {
		.queue = dq,
		.target_queue = dq->do_targetq,
		.label = dq->dq_label,
		.serialnum = dq->dq_serialnum,   //串行队列数
		.width = dq->dq_width,           //跟信号量有关
		.suspend_count = _dq_state_suspend_cnt(dq_state) + dq->dq_side_suspend_cnt,
		.enqueued = _dq_state_is_enqueued(dq_state) && !global,
		.barrier = _dq_state_is_in_barrier(dq_state) && !global,  // 是否有展览函数
		.draining = (dq->dq_items_head == (void*)~0ul) ||         // 是否死锁
				(!dq->dq_items_head && dq->dq_items_tail),
		.global = global,                                          // 是否全局
		.main = (dq == &_dispatch_main_q),
	};
	return diq;
}
```

### 根队列

系统提供了一系列的根队列，全局队列和主队列都是从根队列创建的

```c
struct dispatch_queue_s _dispatch_root_queues[] = {  //结构体数组
	_DISPATCH_ROOT_QUEUE_ENTRY(MAINTENANCE, 0,
		.dq_label = "com.apple.root.maintenance-qos",
		.dq_serialnum = 4,
	),
	_DISPATCH_ROOT_QUEUE_ENTRY(MAINTENANCE, DISPATCH_PRIORITY_FLAG_OVERCOMMIT,
		.dq_label = "com.apple.root.maintenance-qos.overcommit",
		.dq_serialnum = 5,
	),
	_DISPATCH_ROOT_QUEUE_ENTRY(BACKGROUND, 0,
		.dq_label = "com.apple.root.background-qos",
		.dq_serialnum = 6,
	),
	_DISPATCH_ROOT_QUEUE_ENTRY(BACKGROUND, DISPATCH_PRIORITY_FLAG_OVERCOMMIT,
		.dq_label = "com.apple.root.background-qos.overcommit",
		.dq_serialnum = 7,
	),
	_DISPATCH_ROOT_QUEUE_ENTRY(UTILITY, 0,
		.dq_label = "com.apple.root.utility-qos",
		.dq_serialnum = 8,
	),
	_DISPATCH_ROOT_QUEUE_ENTRY(UTILITY, DISPATCH_PRIORITY_FLAG_OVERCOMMIT,
		.dq_label = "com.apple.root.utility-qos.overcommit",
		.dq_serialnum = 9,
	),
	_DISPATCH_ROOT_QUEUE_ENTRY(DEFAULT, DISPATCH_PRIORITY_FLAG_DEFAULTQUEUE,  //global queue设置为 0，0时，走这个队列
		.dq_label = "com.apple.root.default-qos",
		.dq_serialnum = 10,
	),
	_DISPATCH_ROOT_QUEUE_ENTRY(DEFAULT,
			DISPATCH_PRIORITY_FLAG_DEFAULTQUEUE | DISPATCH_PRIORITY_FLAG_OVERCOMMIT,
		.dq_label = "com.apple.root.default-qos.overcommit",
		.dq_serialnum = 11,
	),
	_DISPATCH_ROOT_QUEUE_ENTRY(USER_INITIATED, 0,
		.dq_label = "com.apple.root.user-initiated-qos",
		.dq_serialnum = 12,
	),
	_DISPATCH_ROOT_QUEUE_ENTRY(USER_INITIATED, DISPATCH_PRIORITY_FLAG_OVERCOMMIT,
		.dq_label = "com.apple.root.user-initiated-qos.overcommit",
		.dq_serialnum = 13,
	),
	_DISPATCH_ROOT_QUEUE_ENTRY(USER_INTERACTIVE, 0,
		.dq_label = "com.apple.root.user-interactive-qos",
		.dq_serialnum = 14,
	),
	_DISPATCH_ROOT_QUEUE_ENTRY(USER_INTERACTIVE, DISPATCH_PRIORITY_FLAG_OVERCOMMIT,
		.dq_label = "com.apple.root.user-interactive-qos.overcommit",
		.dq_serialnum = 15,
	),
};
```

### 主队列

`dispatch_get_main_queue()`

```c
dispatch_get_main_queue(void)
{
	return DISPATCH_GLOBAL_OBJECT(dispatch_queue_t, _dispatch_main_q);
//	return ((OS_OBJECT_BRIDGE dispatch_queue_t)&(_dispatch_main_q));
}

#define DISPATCH_GLOBAL_OBJECT(type, object) ((OS_OBJECT_BRIDGE type)&(object))
```

本质上，主队列是串行队列的子集

```c
DISPATCH_DECL_SUBCLASS(dispatch_queue_main, dispatch_queue_serial);
#define DISPATCH_DECL_SUBCLASS(name, base) OS_OBJECT_DECL_SUBCLASS(name, base)
OS_OBJECT_DECL_SUBCLASS(dispatch_queue_main,dispatch_queue_serial)
#define OS_OBJECT_DECL_SUBCLASS(name, super) \
		OS_OBJECT_DECL_IMPL(name, <OS_OBJECT_CLASS(super)>)
// 将指针，指向dispatch_queue_serial
OS_OBJECT_DECL_IMPL(dispatch_queue_main,<OS_OBJECT_CLASS(dispatch_queue_serial)>)
  
#define OS_OBJECT_DECL_IMPL(name, ...) \
		OS_OBJECT_DECL_PROTOCOL(name, __VA_ARGS__) \
		typedef NSObject<OS_OBJECT_CLASS(name)> \
				* OS_OBJC_INDEPENDENT_CLASS name##_t
```



### 全局队列

```c
dispatch_queue_t
dispatch_get_global_queue(long priority, unsigned long flags)
{
	if (flags & ~(unsigned long)DISPATCH_QUEUE_OVERCOMMIT) {
		return DISPATCH_BAD_INPUT;
	}
	dispatch_qos_t qos = _dispatch_qos_from_queue_priority(priority);//4
#if !HAVE_PTHREAD_WORKQUEUE_QOS
	if (qos == QOS_CLASS_MAINTENANCE) {
		qos = DISPATCH_QOS_BACKGROUND;
	} else if (qos == QOS_CLASS_USER_INTERACTIVE) {
		qos = DISPATCH_QOS_USER_INITIATED;
	}
#endif
	if (qos == DISPATCH_QOS_UNSPECIFIED) {
		return DISPATCH_BAD_INPUT;
	}
	return _dispatch_get_root_queue(qos, flags & DISPATCH_QUEUE_OVERCOMMIT);
}

// 实际最后拿到的队列是
//_DISPATCH_ROOT_QUEUE_ENTRY(DEFAULT, DISPATCH_PRIORITY_FLAG_DEFAULTQUEUE,  //global queue设置为 0，0时，走这个队列
//		.dq_label = "com.apple.root.default-qos",
//		.dq_serialnum = 10,
//	),
```



## 同步 `dispatch_sync`

`dispatch_sync`方法，本质是有`dispatch_sync_f`来实现的。

> Dispatch_sync函数可简化源代码，是简版的dispatch_group_wait

### dispatch_sync_f

```c
DISPATCH_NOINLINE
void
dispatch_sync_f(dispatch_queue_t dq, void *ctxt, dispatch_function_t func)
{
	// 1.有堵塞 同步+串行队列 : 死锁 , 等
	if (likely(dq->dq_width == 1)) {
		return dispatch_barrier_sync_f(dq, ctxt, func);
	}

	// 2.全局并发
	// Global concurrent queues and queues bound to non-dispatch threads
	// always fall into the slow case, see DISPATCH_ROOT_QUEUE_STATE_INIT_VALUE
	if (unlikely(!_dispatch_queue_try_reserve_sync_width(dq))) {
		return _dispatch_sync_f_slow(dq, ctxt, func, 0);
	}

	// 3.自定义并发
	_dispatch_introspection_sync_begin(dq);
	if (unlikely(dq->do_targetq->do_targetq)) {
		return _dispatch_sync_recurse(dq, ctxt, func, 0);
	}
	_dispatch_sync_invoke_and_complete(dq, ctxt, func);
}

DISPATCH_NOINLINE
void
dispatch_barrier_sync_f(dispatch_queue_t dq, void *ctxt,
		dispatch_function_t func)
{
	// 获取当前thread id
	dispatch_tid tid = _dispatch_tid_self();

	// The more correct thing to do would be to merge the qos of the thread
	// that just acquired the barrier lock into the queue state.
	//
	// However this is too expensive for the fastpath, so skip doing it.
	// The chosen tradeoff is that if an enqueue on a lower priority thread
	// contends with this fastpath, this thread may receive a useless override.
	//
	// Global concurrent queues and queues bound to non-dispatch threads
	// always fall into the slow case, see DISPATCH_ROOT_QUEUE_STATE_INIT_VALUE
	// 当前线程尝试绑定获取串行队列的lock
	if (unlikely(!_dispatch_queue_try_acquire_barrier_sync(dq, tid))) {
		// 线程获取不到queue的lock，则串行入队等待，当前线程阻塞
		return _dispatch_sync_f_slow(dq, ctxt, func, DISPATCH_OBJ_BARRIER_BIT);
	}

	// 加入栅栏函数的 递归查找 是否等待
	_dispatch_introspection_sync_begin(dq);
	if (unlikely(dq->do_targetq->do_targetq)) {
		return _dispatch_sync_recurse(dq, ctxt, func, DISPATCH_OBJ_BARRIER_BIT);
	}
	// 不需要等待，则走这里
	_dispatch_queue_barrier_sync_invoke_and_complete(dq, ctxt, func);
}


DISPATCH_ALWAYS_INLINE DISPATCH_WARN_RESULT
static inline bool
_dispatch_queue_try_acquire_barrier_sync_and_suspend(dispatch_queue_t dq,
		uint32_t tid, uint64_t suspend_count)
{
	uint64_t init  = DISPATCH_QUEUE_STATE_INIT_VALUE(dq->dq_width);
	uint64_t value = DISPATCH_QUEUE_WIDTH_FULL_BIT | DISPATCH_QUEUE_IN_BARRIER |
			_dispatch_lock_value_from_tid(tid) |
	(suspend_count * DISPATCH_QUEUE_SUSPEND_INTERVAL);// _dispatch_lock_value_from_tid 会去取tid二进制数的2到31位 作为值（从0位算起）
	uint64_t old_state, new_state;
	// 这里面有一堆宏定义的原子操作，事实是
	// 尝试将new_state赋值给dq.dq_state。 首先会用原子操作(atomic_load_explicit)取当前dq_state的值，作为old_state。如果old_state 不是dq_state的默认值(init | role)， 则赋值失败，返回false（这说明之前已经有人更改过dq_state,在串行队列中，一次仅允许一个人更改dq_state）, 获取lock失败。否则dq_state赋值为new_state（利用原子操作atomic_compare_exchange_weak_explicit 做赋值）, 返回true，获取lock成功。
	return os_atomic_rmw_loop2o(dq, dq_state, old_state, new_state, acquire, {
		uint64_t role = old_state & DISPATCH_QUEUE_ROLE_MASK;
		if (old_state != (init | role)) {// 如果dq_state已经被修改过，则直接返回false，不更新dq_state为new_state
			os_atomic_rmw_loop_give_up(break);
		}
		new_state = value | role;
	});
}

```



- 串行队列宽度:dq_width = 1，触发`dispatch_barrier_sync_f`

	- 上锁：`_dispatch_queue_try_acquire_barrier_sync`

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

			- 判断一个队列是否被线程上了两次锁：`_dq_state_drain_locked_by`
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

判断一个队列，是否被同一个线程上了两次锁。<font color='red'>**串行队列的不可重入性！**</font>会产生死锁的代码：

```c
_dispatch_sync_wait(dispatch_queue_t top_dq, void *ctxt,
		dispatch_function_t func, uintptr_t top_dc_flags,
		dispatch_queue_t dq, uintptr_t dc_flags)
{
	pthread_priority_t pp = _dispatch_get_priority();
	dispatch_tid tid = _dispatch_tid_self();
	dispatch_qos_t qos;
	uint64_t dq_state;
	
	// A ---> C  A 堵塞
	// A ---> C --> A  死锁
	// 是否是挂起 等待
	// A 堵塞
	dq_state = _dispatch_sync_wait_prepare(dq);
	// 如果当前的线程已经拥有目标queue，这时候在调用_dispatch_sync_wait，则会触发crash
	// 这里的判断逻辑是lock的owner是否是tid(这里因为在dq_state的lock里面加入了tid的值，所有能够自动识别出死锁的情况：同一个串行队列被同一个线程做两次lock)
	// 死锁 -- 告诉编译器 优化
	if (unlikely(_dq_state_drain_locked_by(dq_state, tid))) {
		DISPATCH_CLIENT_CRASH((uintptr_t)dq_state,
				"dispatch_sync called on queue "
				"already owned by current thread");
	}
  
  //....省略
}

DISPATCH_ALWAYS_INLINE
static inline bool
_dispatch_lock_is_locked_by(dispatch_lock lock_value, dispatch_tid tid)
{
	// A (value) : 里面有一个调度 =  C(value)
	
	// equivalent to _dispatch_lock_owner(lock_value) == tid
	
	// A 执行 value 线程
	// 线程  vlaue
	return ((lock_value ^ tid) & DLOCK_OWNER_MASK) == 0;
}
```



### 



## 异步`dispatch_async`

实现：

```c
void
dispatch_async(dispatch_queue_t dq, dispatch_block_t work)
{
	
	dispatch_continuation_t dc = _dispatch_continuation_alloc();
	// 设置标志位
	uintptr_t dc_flags = DISPATCH_OBJ_CONSUME_BIT;
    // 将work打包成dispatch_continuation_t
	_dispatch_continuation_init(dc, dq, work, 0, 0, dc_flags);
	_dispatch_continuation_async(dq, dc);
}
```

这里需要说一下`dispatch_continuation_t`的大致结构

```c
#define DISPATCH_CONTINUATION_HEADER(x) \
	union { \
		const void *do_vtable; \
		uintptr_t dc_flags; \
	}; \
	union { \
		pthread_priority_t dc_priority; \
		int dc_cache_cnt; \
		uintptr_t dc_pad; \
	}; \
	struct dispatch_##x##_s *volatile do_next; \
	struct voucher_s *dc_voucher; \
	dispatch_function_t dc_func; \  
	void *dc_ctxt; \
	void *dc_data; \
	void *dc_other
```

dc_flags：标志位

dc_func：方法回调

dc_ctxt：当前的任务

### 任务打包 `_dispatch_continuation_init`

```c
static inline void
_dispatch_continuation_init(dispatch_continuation_t dc,
		dispatch_queue_class_t dqu, dispatch_block_t work,
		pthread_priority_t pp, dispatch_block_flags_t flags, uintptr_t dc_flags)
{
  //dc_flags = DISPATCH_OBJ_CONSUME_BIT
	dc->dc_flags = dc_flags | DISPATCH_OBJ_BLOCK_BIT;
	// 将work封装到dispatch_continuation_t中
	dc->dc_ctxt = _dispatch_Block_copy(work);
	_dispatch_continuation_priority_set(dc, pp, flags);

	if (unlikely(_dispatch_block_has_private_data(work))) {
		// always sets dc_func & dc_voucher
		// may update dc_priority & do_vtable
		return _dispatch_continuation_init_slow(dc, dqu, flags);
	}

	
	if (dc_flags & DISPATCH_OBJ_CONSUME_BIT) {// 之前的flag 被设置为DISPATCH_OBJ_CONSUME_BIT，因此会走这里
		dc->dc_func = _dispatch_call_block_and_release;// 这里是设置dc的功能函数：1. 执行block 2. release block对象
	} else {
		dc->dc_func = _dispatch_Block_invoke(work);  // 执行函数
	}
	_dispatch_continuation_voucher_set(dc, dqu, flags);
}
```

任务打包的实现过程：

1. 复制任务

```c
dc->dc_ctxt = _dispatch_Block_copy(work);
```

2. 根据串行还是并发，设置保存方式

```c
if (dc_flags & DISPATCH_OBJ_CONSUME_BIT) {// 之前的flag 被设置为DISPATCH_OBJ_CONSUME_BIT，因此会走这里
		dc->dc_func = _dispatch_call_block_and_release;// 这里是设置dc的功能函数：1. 执行block 2. release block对象
	} else {
		dc->dc_func = _dispatch_Block_invoke(work);
	}
```



- work的代码放在这个里面，控制执行和释放_dispatch_call_block_and_release

### 异步入口

```c
void
_dispatch_continuation_async(dispatch_queue_t dq, dispatch_continuation_t dc)
{
	_dispatch_continuation_async2(dq, dc,
			dc->dc_flags & DISPATCH_OBJ_BARRIER_BIT);
}

static inline void
_dispatch_continuation_async2(dispatch_queue_t dq, dispatch_continuation_t dc,
		bool barrier)
{
	// 如果是用barrier插进来的任务或者是串行队列，直接将任务加入到队列
	if (fastpath(barrier || !DISPATCH_QUEUE_USES_REDIRECTION(dq->dq_width))) {
		return _dispatch_continuation_push(dq, dc);
	}
	 // 并行队列走这里
	return _dispatch_async_f2(dq, dc);
}
```

#### 串行队列

将block推进到队列里，并且更新

```c
static inline void
_dispatch_queue_push_inline(dispatch_queue_t dq, dispatch_object_t _tail,
		dispatch_qos_t qos)
{
	struct dispatch_object_s *tail = _tail._do;
	dispatch_wakeup_flags_t flags = 0;
	// If we are going to call dx_wakeup(), the queue must be retained before
	// the item we're pushing can be dequeued, which means:
	// - before we exchange the tail if we may have to override
	// - before we set the head if we made the queue non empty.
	// Otherwise, if preempted between one of these and the call to dx_wakeup()
	// the blocks submitted to the queue may release the last reference to the
	// queue when invoked by _dispatch_queue_drain. <rdar://problem/6932776>
	bool overriding = _dispatch_queue_need_override_retain(dq, qos);
	// 加入到自己的队列
	// block --> 队列 更新
	if (unlikely(_dispatch_queue_push_update_tail(dq, tail))) {
		if (!overriding) _dispatch_retain_2(dq->_as_os_obj);
		_dispatch_queue_push_update_head(dq, tail); //更新头部
		flags = DISPATCH_WAKEUP_CONSUME_2 | DISPATCH_WAKEUP_MAKE_DIRTY;
	} else if (overriding) {
		flags = DISPATCH_WAKEUP_CONSUME_2;
	} else {
		return;
	}
	return dx_wakeup(dq, qos, flags);
}
```

异步串行的原因，执行了`_dispatch_queue_push_queue`，顺序压栈

```c
DISPATCH_NOINLINE
void
_dispatch_queue_class_wakeup(dispatch_queue_t dq, dispatch_qos_t qos,
		dispatch_wakeup_flags_t flags, dispatch_queue_wakeup_target_t target)
{
	
	// 这里target 如果dq是root queue大概率为null，否则，target == DISPATCH_QUEUE_WAKEUP_TARGET, 调用_dispatch_queue_push_queue，将自定义dq入队，然后会在调用一遍wake up，最终在root queue中执行方法
	if (target) {
		uint64_t old_state, new_state, enqueue = DISPATCH_QUEUE_ENQUEUED;
		if (target == DISPATCH_QUEUE_WAKEUP_MGR) {
			enqueue = DISPATCH_QUEUE_ENQUEUED_ON_MGR;
		}
		qos = _dispatch_queue_override_qos(dq, qos);
		os_atomic_rmw_loop2o(dq, dq_state, old_state, new_state, release, {
			new_state = _dq_state_merge_qos(old_state, qos);
			if (likely(!_dq_state_is_suspended(old_state) &&
					!_dq_state_is_enqueued(old_state) &&
					(!_dq_state_drain_locked(old_state) ||
					(enqueue != DISPATCH_QUEUE_ENQUEUED_ON_MGR &&
					_dq_state_is_base_wlh(old_state))))) {
				new_state |= enqueue;
			}
			if (flags & DISPATCH_WAKEUP_MAKE_DIRTY) {
				new_state |= DISPATCH_QUEUE_DIRTY;
			} else if (new_state == old_state) {
				os_atomic_rmw_loop_give_up(goto done);
			}
		});

		if (likely((old_state ^ new_state) & enqueue)) {
			dispatch_queue_t tq;
			if (target == DISPATCH_QUEUE_WAKEUP_TARGET) {
				// the rmw_loop above has no acquire barrier, as the last block
				// of a queue asyncing to that queue is not an uncommon pattern
				// and in that case the acquire would be completely useless
				//
				// so instead use depdendency ordering to read
				// the targetq pointer.
				os_atomic_thread_fence(dependency);
				tq = os_atomic_load_with_dependency_on2o(dq, do_targetq,
						(long)new_state);
			} else {
				tq = target;
			}
			
			// 异步串行 也会 顺序执行
			// 异步并发 创建线程
			dispatch_assert(_dq_state_is_enqueued(new_state));
			return _dispatch_queue_push_queue(tq, dq, new_state);
		}
#if HAVE_PTHREAD_WORKQUEUE_QOS
		if (unlikely((old_state ^ new_state) & DISPATCH_QUEUE_MAX_QOS_MASK)) {
			if (_dq_state_should_override(new_state)) {
				return _dispatch_queue_class_wakeup_with_override(dq, new_state,
						flags);
			}
		}
	} else if (qos) {
		//
		// Someone is trying to override the last work item of the queue.
		//
		uint64_t old_state, new_state;
		os_atomic_rmw_loop2o(dq, dq_state, old_state, new_state, relaxed, {
			if (!_dq_state_drain_locked(old_state) ||
					!_dq_state_is_enqueued(old_state)) {
				os_atomic_rmw_loop_give_up(goto done);
			}
			new_state = _dq_state_merge_qos(old_state, qos);
			if (new_state == old_state) {
				os_atomic_rmw_loop_give_up(goto done);
			}
		});
		if (_dq_state_should_override(new_state)) {
			return _dispatch_queue_class_wakeup_with_override(dq, new_state,
					flags);
		}
#endif // HAVE_PTHREAD_WORKQUEUE_QOS
	}
done:
	if (likely(flags & DISPATCH_WAKEUP_CONSUME_2)) {
		return _dispatch_release_2_tailcall(dq);
	}
}
```



#### 并发队列

执行`_dispatch_async_f2`

```c
static void
_dispatch_async_f2(dispatch_queue_t dq, dispatch_continuation_t dc)
{
	// <rdar://problem/24738102&24743140> reserving non barrier width
	// doesn't fail if only the ENQUEUED bit is set (unlike its barrier width
	// equivalent), so we have to check that this thread hasn't enqueued
	// anything ahead of this call or we can break ordering
	// 如果还有任务，slowpath表示很大可能队尾是没有任务的。
	// 实际开发中也的确如此，一般情况下我们不会dispatch_async之后又马上跟着一个dispatch_async
	if (slowpath(dq->dq_items_tail)) {
		return _dispatch_continuation_push(dq, dc);
	}

	if (slowpath(!_dispatch_queue_try_acquire_async(dq))) {
		return _dispatch_continuation_push(dq, dc);
	}
    // async 重定向，任务的执行由自动定义queue转入root queue
	return _dispatch_async_f_redirect(dq, dc,
			_dispatch_continuation_override_qos(dq, dc));
}
```

##### 任务重定向

1. 在并发队列池中(root queue)，找到合适的队列

```c
static void
_dispatch_async_f_redirect(dispatch_queue_t dq,
		dispatch_object_t dou, dispatch_qos_t qos)
{
	// 这里会走进if的语句，因为_dispatch_object_is_redirection内部的dx_type(dou._do) == type条件为否
	if (!slowpath(_dispatch_object_is_redirection(dou))) {
		dou._dc = _dispatch_async_redirect_wrap(dq, dou);
	}
	// dq换成所绑定的root队列
	dq = dq->do_targetq;

	// Find the queue to redirect to
	// 基本不会走里面的循环，主要做的就是找到根root队列
	while (slowpath(DISPATCH_QUEUE_USES_REDIRECTION(dq->dq_width))) {
		if (!fastpath(_dispatch_queue_try_acquire_async(dq))) {
			break;
		}
		if (!dou._dc->dc_ctxt) {
			// find first queue in descending target queue order that has
			// an autorelease frequency set, and use that as the frequency for
			// this continuation.
			dou._dc->dc_ctxt = (void *)
					(uintptr_t)_dispatch_queue_autorelease_frequency(dq);
		}
		dq = dq->do_targetq;
	}

	// 把装有block信息的结构体装进所在队列对应的root_queue里面
	dx_push(dq, dou, qos);
}
```

#### 添加线程

在`_dispatch_global_queue_poke_slow`方法中，有一个添加线程的接口。

```c
static void
_dispatch_global_queue_poke_slow(dispatch_queue_t dq, int n, int floor){
#if HAVE_PTHREAD_WORKQUEUE_QOS
		r = _pthread_workqueue_addthreads(remaining,
				_dispatch_priority_to_pp(dq->dq_priority));
#elif DISPATCH_USE_PTHREAD_WORKQUEUE_SETDISPATCH_NP
		r = pthread_workqueue_addthreads_np(qc->dgq_wq_priority,
				qc->dgq_wq_options, remaining);
#endif
}
```

从其他的资料来看，其实是workqueue添加了线程。

## 数据结构

### dispatch_queue_t

创建串行队列（默认）

```c
dispatch_queue_t serialQueue = disptach_queue_create("com.queue.myserial",NULL);
```



> ARC环境下，已经能够管理 dispatch_queue的引用和释放了，不需要再额外执行 dispatch_release() 和 dispatch_retain()

### dispatch_once

### dispatch_once_t val

### 第一个线程进来的时候，由于val与NULL的值相同，所以执行block中的方法

- block执行完后，val的值被刷新，不为0

	- 后续再进来，比较val与NULL不等，所以都不会再执行block
	- 由于第一个线程把val修改了，所以别的线程都无法执行block



# GCD的高级用法

## 获取queue的label

```
dispatch_queue_get_label(dispatch_queue_t _Nullable queue);
```

判断当前queue是不是main queue

传入的参数为`DISPATCH_CURRENT_QUEUE_LABEL`

```c
dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL) == dispatch_queue_get_label(dispatch_get_main_queue())
```



##  dispatch_set_target_queue

解决手动创建的队列(`dispatch_queue_create()`)无法设置优先级的问题！！！

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

则只会暂停`dispatchA`上原来的block的执行，`dispatchB`的block则不受影响。而如果暂停`dispatchB`的运行，则会暂停`dispatchA`的运行。

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

### 使用场景

- 并行改串行

再多个Serial Dispatch Queue中用set_target_queue指定目标为某一个Serial Dispatch Queue，能够将并行执行的多个Serial Dispatch Queue，在目标Serial Dispatch Queue上 **串行**

- 线程同步

无序变有序

## Dispatch Group

解决以下两个问题

- 使用Concurrent Dispatch Queue
- 同时使用多个Serial Dispatch Queue同步



`dispatch_group_notify`

```c
dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
dispatch_group_t group = dispatch_group_create();
dispatch_group_async(group, queue, ^{
    NSLog(@"blk0");
});
dispatch_group_async(group, queue, ^{
    NSLog(@"blk1");
});
dispatch_group_async(group, queue, ^{
    NSLog(@"blk2");
});
dispatch_group_notify(group, dispatch_get_main_queue(), ^{
    // 同步上边所有的任务
    NSLog(@"done");
})
```



`dispatch_group_wait`

```c
dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
dispatch_group_t group = dispatch_group_create();
dispatch_group_async(group, queue, ^{
    NSLog(@"blk0");
});
dispatch_group_async(group, queue, ^{
    NSLog(@"blk1");
});
dispatch_group_async(group, queue, ^{
    NSLog(@"blk2");
});
dispatch_group_wait(group, DISPATCH_TIME_FOREVER);  //永久等待
```

判断操作是否在规定时间内完成

```c
dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
  dispatch_group_t group = dispatch_group_create();
  dispatch_group_async(group, queue, ^{
      NSLog(@"blk0");
  });
  dispatch_group_async(group, queue, ^{
      sleep(2); // sleep 2s
      NSLog(@"blk1");
  });
  dispatch_group_async(group, queue, ^{
      NSLog(@"blk2");
  });

  dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 2ull * NSEC_PER_SEC);
  long result = dispatch_group_wait(group, time);
  if (result == 0) {
      // 全部任务执行完成
      NSLog(@"done");
  } else {
      // 某个任务还在执行
      NSLog(@"false");  //输出false
  }
```



## 栅栏函数

`dispatch_barrier_async`

创建的队列必须是并发队列，不能是全局队列`dispatch_get_global_queue`。因为栅栏函数相当于是给全局队列加同步锁

- 实现同步读，异步写

```objc
// 多读
- (id)objectForKey:(NSString *)key {
    __block id obj;
    // 同步读取指定数据:
    dispatch_sync(self.concurrent_queue, ^{
        // 阻塞当前线程，将任务添加到并发队列
        // 同步执行
        // 还是在当前线程下执行（不开新的线程）
        obj = [self.dataCenterDic objectForKey:key];
    });
    return obj;
}

// 单写
- (void)setObject:(id)obj forKey:(NSString *)key {
    // 异步栅栏调用设置数据:
    dispatch_barrier_async(self.concurrent_queue, ^{
        // 栅栏函数的作用，等待并发队列上的所有任务执行完，再执行
        [self.dataCenterDic setObject:obj forKey:key];
    });
}
```

- 添加图片

```c
dispatch_queue_t con = dispatch_queue_create("cooci", DISPATCH_QUEUE_CONCURRENT); //必须是自定义的队列
for (int i = 0; i < 5000; i++) {
    dispatch_async(con, ^{
        NSString *name = [NSString stringWithFormat:@"%d.jpg",i % 10];
        NSURL *url = [[NSBundle mainBundle] URLForResource:name withExtension:nil];
        NSData *data = [NSData dataWithContentsOfURL:url];
        UIImage *image = [UIImage imageWithData:data];
        dispatch_barrier_async(con, ^{
            [self.mArray addObject:image];
        });
    });
}
```



## dispatch_apply

重复相同的任务，或者对数组内的所有元素，执行相同的任务（顺序不一定）

```c
dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
dispatch_apply(10, queue, ^(size_t index) {
    NSLog(@"%zu",index);
});
```

与`dispatch_sync`方法相同，也会阻塞当前的线程



## 信号量

`dispatch_semaphore_t`

`dispatch_semaphore_create()` 创建信号量

`dispatch_semaphore_wait` 如果信号量的值>=1,则减1，并返回0；否则的话，，返回非0

```c
dispatch_semaphore_t sema = dispatch_semaphore_create(1);
    
dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 2ull * NSEC_PER_SEC);
long result = dispatch_semaphore_wait(sema, time);
if (result == 0) {
    // 如果sema >= 1，则-1,并返回0
} else {
    // 否则返回非0
}
```

`dispatch_semaphore_signal()` 信号量 + 1



## Dispatch Source

`Dispatch Source` 与 `Dispatch Queue`不同，它可以取消。取消时，必须执行的处理可指定为回调用的Block形式。

```objc
@interface GCDLearn()
@property (nonatomic, strong) dispatch_source_t timer; //强引用
@end

- (instancetype)init
{
    self = [super init];
    if (self) {
        _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    }
    return self;
}

-(void)useDispatchTime{
    // 定时器任务
    // 5s后执行任务,允许延迟1s
    NSTimeInterval period = 0.5;
    dispatch_source_set_timer(_timer, dispatch_time(DISPATCH_TIME_NOW, 5ull * NSEC_PER_SEC), DISPATCH_TIME_FOREVER, 1ull * NSEC_PER_SEC);
//    dispatch_source_set_timer(_timer, dispatch_walltime(NULL, 0), period * NSEC_PER_SEC, 0);

    // 指定事件
    dispatch_source_set_event_handler(_timer, ^{
        NSLog(@"wake up");
    
        // 这儿取消(否则的话，会一直做下去）
        // 不取消的话，会有内存泄露的问题
        dispatch_source_cancel(_timer);
    });
    
    dispatch_source_set_cancel_handler(_timer, ^{
        NSLog(@"取消");
    });
    
    // 启动timer
    dispatch_resume(_timer);
}
```

也可以在dealloc中，停止timer

```objc
- (void)starttimer{
    // ...
		// 设置回调
    __weak typeof(self) wself = self;
    dispatch_source_set_event_handler(sourceTimer, ^{
        NSLog(@"num = %ld", wself.num ++); //注意：需要使用weakSelf，不然会内存泄漏
    });
    dispatch_resume(sourceTimer);
}

- (void)dealloc {
    NSLog(@"DetailViewController dealloc");
    // 如果前面block回调使用了weakSelf，那么cancel可以写在这里
    dispatch_source_cancel(self.timer);
}
// 输出为 
// num = 1
// num = 2
// num = 3
// 点击退出时，被dealloc
```

> 注意：虽然在GCD的Block中，使用self，不会造成循环引用。但是前提是，这个Block执行完以后，会释放self。如果是dispatch_source的一个定时器，Block任务始终会持有self，因此这里可能会造成循环引用。需要主动调用cancel才行。



## 检查线程数量 & 防止线程爆炸

使用`task_threads()`接口，返回所有线程端口

```c
// 获取电当前task的所有线程
mach_msg_type_number_t count;
thread_act_array_t threads;
task_threads(mach_task_self(), &threads, &count);
```

使用KKThreadMonitor

` pthread_introspection_hook_install(kk_pthread_introspection_hook_t);` hook了线程的相关方法

监听回调，

- PTHREAD_INTROSPECTION_THREAD_CREATE：创建线程
- PTHREAD_INTROSPECTION_THREAD_DESTROY : 销毁线程

```c
void kk_pthread_introspection_hook_t(unsigned int event, pthread_t thread, void *addr, size_t size)
{
    if (old_pthread_introspection_hook_t) {
        old_pthread_introspection_hook_t(event, thread, addr, size);
    }
    if (event == PTHREAD_INTROSPECTION_THREAD_CREATE) {
        threadCount = threadCount + 1;
        if (isMonitor && (threadCount > maxThreadCountThreshold)) {
            maxThreadCountThreshold += 5;
            kk_Alert_Log_CallStack(false, 0);
        }
        threadCountIncrease = threadCountIncrease + 1;
        if (isMonitor && (threadCountIncrease > threadIncreaseThreshold)) {
            kk_Alert_Log_CallStack(true, threadCountIncrease);
        }
    }
    else if (event == PTHREAD_INTROSPECTION_THREAD_DESTROY){
        threadCount = threadCount - 1;
        if (threadCount < KK_THRESHOLD) {
            maxThreadCountThreshold = KK_THRESHOLD;
        }
        if (threadCountIncrease > 0) {
            threadCountIncrease = threadCountIncrease - 1;
        }
    }
}
```



# 参考链接

[iOS多线程——Dispatch Source](https://www.jianshu.com/p/880c2f9301b6)

[iOS libdispatch浅析](https://www.jianshu.com/p/b99f6a2e3b78)

[dispatch_sync死锁问题研究](https://www.jianshu.com/p/44369c02b62a)

[GCD源码吐血分析(2)——dispatch_async/dispatch_sync/dispatch_once/dispatch group](https://blog.csdn.net/u013378438/article/details/81076116?utm_medium=distribute.pc_relevant.none-task-blog-baidujs_title-0&spm=1001.2101.3001.4242)

# Coding Tips

## 关于const void* 指针

```c
const void *vtable;// 指向常量
dispatch_queue_flags_t dqf = 0;
// 根据不同的queue类型，设置vtable。vtable实现了SERIAL queue 和 CONCURRENT queue的行为差异。
if (legacy) { // 之前的类型
  vtable = DISPATCH_VTABLE(queue);  
} else if (dqa->dqa_concurrent) { // 并发
  vtable = DISPATCH_VTABLE(queue_concurrent);
} else { //  串行
  vtable = DISPATCH_VTABLE(queue_serial);
}
```

`const void *a`这是定义了一个指针a，a可以指向任意类型的值，但它指向的值必须是常量，在这种情况下，我们不能修改被指向的对象，但可以使指针指向其他对象。

## dispatch上锁

本质是一个互斥锁，注意互斥锁的概念

```c
DISPATCH_ALWAYS_INLINE
static inline void
_dispatch_unfair_lock_lock(dispatch_unfair_lock_t l)
{
	dispatch_lock value_self = _dispatch_lock_value_for_self();
	if (likely(os_atomic_cmpxchg(&l->dul_lock,
			DLOCK_OWNER_NULL, value_self, acquire))) {
		return;
	}
	return _dispatch_unfair_lock_lock_slow(l, DLOCK_LOCK_NONE);
}
```

本质上，调用了`os_atomic_cmpxchg`

直接上结论：可以理解为`p`变量相当于`atomic_t`类型的`ptr`指针用于获取当前内存访问制约规则`m`的值，用于对比旧值`e`，若相当就赋值新值`v`；

```c
#define os_atomic_cmpxchg(p, e, v, m) \
        ({ _os_atomic_basetypeof(p) _r = (e); \
        atomic_compare_exchange_strong_explicit(_os_atomic_c11_atomic(p), \
        &_r, v, memory_order_##m, memory_order_relaxed); })

typedef enum memory_order {
  memory_order_relaxed = __ATOMIC_RELAXED,
  memory_order_consume = __ATOMIC_CONSUME,
  memory_order_acquire = __ATOMIC_ACQUIRE,
  memory_order_release = __ATOMIC_RELEASE,
  memory_order_acq_rel = __ATOMIC_ACQ_REL,
  memory_order_seq_cst = __ATOMIC_SEQ_CST
} memory_order;
```

## 结构体的点式初始化

```c
// 定义
typedef struct Student{
    char *name;
    int  age;
    int  classNum;
}Student;

// 点式初始化
Student s ={
            .name = "Kt",
            .age = 13,
            .classNum = 1,
        };
Student p;
p.name = "pP";
p.age = 11;
p.classNum = 2;
```

