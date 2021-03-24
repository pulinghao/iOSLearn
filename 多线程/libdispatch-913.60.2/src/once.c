/*
 * Copyright (c) 2008-2013 Apple Inc. All rights reserved.
 *
 * @APPLE_APACHE_LICENSE_HEADER_START@
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * @APPLE_APACHE_LICENSE_HEADER_END@
 */

#include "internal.h"

#undef dispatch_once
#undef dispatch_once_f


typedef struct _dispatch_once_waiter_s {
	volatile struct _dispatch_once_waiter_s *volatile dow_next;
	dispatch_thread_event_s dow_event;
	mach_port_t dow_thread;
} *_dispatch_once_waiter_t;

#define DISPATCH_ONCE_DONE ((_dispatch_once_waiter_t)~0l)

#ifdef __BLOCKS__
void
dispatch_once(dispatch_once_t *val, dispatch_block_t block)
{
	dispatch_once_f(val, block, _dispatch_Block_invoke(block));
}
#endif

#if DISPATCH_ONCE_INLINE_FASTPATH
#define DISPATCH_ONCE_SLOW_INLINE inline DISPATCH_ALWAYS_INLINE
#else
#define DISPATCH_ONCE_SLOW_INLINE DISPATCH_NOINLINE
#endif // DISPATCH_ONCE_INLINE_FASTPATH

DISPATCH_ONCE_SLOW_INLINE
static void
dispatch_once_f_slow(dispatch_once_t *val, void *ctxt, dispatch_function_t func)
{
#if DISPATCH_GATE_USE_FOR_DISPATCH_ONCE
	dispatch_once_gate_t l = (dispatch_once_gate_t)val;

	if (_dispatch_once_gate_tryenter(l)) {
		_dispatch_client_callout(ctxt, func);
		_dispatch_once_gate_broadcast(l);
	} else {
		_dispatch_once_gate_wait(l);
	}
#else
	// volatile：告诉编译器不要对此指针进行代码优化，因为这个指针指向的值可能会被其他线程改变
	_dispatch_once_waiter_t volatile *vval = (_dispatch_once_waiter_t*)val;
	struct _dispatch_once_waiter_s dow = { };
	_dispatch_once_waiter_t tail = &dow, next, tmp;
	dispatch_thread_event_t event;

	// 第一次执行时，*vval为0，此时第一个参数vval和第二个参数NULL比较是相等的，返回true，然后把tail赋值给第一个参数的值。如果这时候同时有别的线程也进来，此时vval的值不是0了，所以会来到else分支。
	if (os_atomic_cmpxchg(vval, NULL, tail, acquire)) {
		// 获取当前线程
		dow.dow_thread = _dispatch_tid_self();
		// 调用block函数，一般就是我们在外面做的初始化工作
		_dispatch_client_callout(ctxt, func);
		
		// 内部将DLOCK_ONCE_DONE赋值给val，将当前标记为已完成，返回之前的引用值。前面说过了，把tail赋值给val了，但这只是没有别的线程进来走到下面else分支，如果有别的线程进来next就是别的值了，如果没有别的信号量在等待，工作就到此结束了。
		next = (_dispatch_once_waiter_t)_dispatch_once_xchg_done(val);
		// 如果没有别的线程进来过处于等待，这里就会结束。如果有，则遍历每一个等待的信号量，然后一个个唤醒它们
		while (next != tail) {
			// 内部用到了thread_switch，避免优先级反转。把next->dow_next返回
			tmp = (_dispatch_once_waiter_t)_dispatch_wait_until(next->dow_next);
			event = &next->dow_event;
			next = tmp;
			// 唤醒信号量
			_dispatch_thread_event_signal(event);
		}
	} else {
		// 内部就是_dispatch_sema4_init函数，也就是初始化一个信号链表
		_dispatch_thread_event_init(&dow.dow_event);
		// next指向新的原子
		next = *vval;
		// 不断循环等待
		for (;;) {
			// 前面说过第一次进来后进入if分支，后面再次进来，会来到这里，但是之前if里面被标志为DISPATCH_ONCE_DONE了，所以结束。
			if (next == DISPATCH_ONCE_DONE) {
				break;
			}
			// 当第一次初始化的时候，同时有别的线程也进来，这是第一个线程已经占据了if分支，但其他线程也是第一进来，所以状态并不是DISPATCH_ONCE_DONE，所以就来到了这里
			// 比较vval和next是否一样，其他线程第一次来这里肯定是相等的
			if (os_atomic_cmpxchgv(vval, next, tail, &next, release)) {
				dow.dow_thread = next->dow_thread;
				dow.dow_next = next;
				if (dow.dow_thread) {
					pthread_priority_t pp = _dispatch_get_priority();
					_dispatch_thread_override_start(dow.dow_thread, pp, val);
				}
				// 等待唤醒，唤醒后就做收尾操作
				_dispatch_thread_event_wait(&dow.dow_event);
				if (dow.dow_thread) {
					
					_dispatch_thread_override_end(dow.dow_thread, val);
				}
				break;
			}
		}
		// 销毁信号量
		_dispatch_thread_event_destroy(&dow.dow_event);
	}
#endif
}

DISPATCH_NOINLINE
void
dispatch_once_f(dispatch_once_t *val, void *ctxt, dispatch_function_t func)
{
#if !DISPATCH_ONCE_INLINE_FASTPATH
	if (likely(os_atomic_load(val, acquire) == DLOCK_ONCE_DONE)) {
		return;
	}
#endif // !DISPATCH_ONCE_INLINE_FASTPATH
	return dispatch_once_f_slow(val, ctxt, func);
}
