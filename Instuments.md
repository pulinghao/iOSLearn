# TimeProfile

## 插桩

`os_signpost`结合TimeProfile在性能优化的数据展示中能够更加直观、方便。

`os_signpost_interval_begin`

`os_signpost_interval_end`

```objective-c
//引入头文件
#import <os/signpost.h>
//宏定义,实际开发中,区分Debug、Release
#define SP_BEGIN_LOG(subsystem, category, name) \
os_log_t m_log_##name = os_log_create((#subsystem), (#category));\
os_signpost_id_t m_spid_##name = os_signpost_id_generate(m_log_##name);\
os_signpost_interval_begin(m_log_##name, m_spid_##name, (#name));

#define SP_END_LOG(name) \
os_signpost_interval_end(m_log_##name, m_spid_##name, (#name));

//耗时统计
- (void)viewDidAppear:(BOOL)animated {
    /*
     统计这段区间的执行次数,耗时,等等,更加直观
     SP_BEGIN_LOG(systemname, category, name);
     systemname:自定义,可以用bundleId
     category:在timeprofile中统计分类时使用,相同的扼categroy在同一个分类下
     name:具体统计名称
     */
    SP_BEGIN_LOG(custome, gl_log, viewDidAppear);
    [super viewDidAppear:animated];
    [NSThread sleepForTimeInterval:2];
    [self.view bringSubviewToFront:self.enterBtn];
    NSLog(@"viewDidAppear");
    SP_END_LOG(viewDidAppear);
    
    
    os_log_t m_log = os_log_create("custome", "gl_log");\
    for(int i = 0; i < 10; i++) {
        os_signpost_id_t signid_1 = os_signpost_id_generate(m_log);
        os_signpost_interval_begin(m_log, signid_1, "asynctest");
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSLog(@"打印的第%d遍",i);
            os_signpost_interval_end(m_log, signid_1, "asynctest", "index%d",i);
        });
    }
}
```



```objectivec
//
//  ViewController.m
//  SignpostTest
//
//  Created by tongleiming on 2020/2/12.
//  Copyright © 2020 tongleiming. All rights reserved.
//

#import "ViewController.h"
#include <os/signpost.h>


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //[self mySignpost];
    //[self mySignpostAdditional];
    [self mySignpostSingle];
}

// 时间间隔
- (void)mySignpost {
    os_log_t refreshLog = os_log_create("com.example.your-app", "RefreshOperations");
    
    // To do that, we're going to add another piece of data to our signpost calls called a signpost ID.
    // The signpost ID will tell the system that these are the same kind of operation but each one is different from each other.
    // So if two operations overlap but they have different signpost IDs, the system will know that they're two different intervals.
    // signpost id用来区分相同log，相同name的记录
    
    // You can make signpost IDs with this constructor here that takes a log handle,
    // let spid = OSSignpostID(log: refreshLog)
    os_signpost_id_t spidForRefresh = os_signpost_id_generate(refreshLog);
    // 第二个参数叫做"Signpost ID"，第三个参数叫做"Sigpost name"
    os_signpost_interval_begin(refreshLog, spidForRefresh, "forLoop");
    
    
    
    NSArray *array = @[@"hello", @"world"];
    for (NSString *str in array) {
        // but you can also make them with an object.
        // let spid = OSSignpostID(log: refreshLog, object:element)
        // This could be useful if you have some object that represents the work that you're trying to do and the same signpost ID will be generated as long as you use the same instance of that object.
        //    So this means you don't have to carry or store the signpost ID around.
        // NSObject *obj = [NSObject new];
        // os_signpost_id_t signpostID = os_signpost_id_make_with_pointer(m_log_name, (__bridge const void * _Nullable)(obj));
        // 有了额外的对象指针，开始和结束语句甚至可以保存到不同的源文件中
        os_signpost_id_t spid = os_signpost_id_make_with_pointer(refreshLog, (__bridge const void * _Nullable)(str));
        os_signpost_interval_begin(refreshLog, spid, "Refresh");
        [NSThread sleepForTimeInterval:0.5];
        os_signpost_interval_end(refreshLog, spid, "Refresh");
    }
    
    os_signpost_interval_end(refreshLog, spidForRefresh, "forLoop");
}

// 携带元数据
- (void)mySignpostAdditional {
    os_log_t refreshLog = os_log_create("com.example.your-app", "RefreshOperations");
    os_signpost_id_t spidForRefresh = os_signpost_id_generate(refreshLog);
    int i = 100;
    // 额外携带的参数和os_log格式一样
    // 验证在instruments中是如何显示的
    // 携带的元数据按照instruments的格式化显示方式显示的话，instruments还会进行统计分析{xcode:}
    os_signpost_interval_begin(refreshLog, spidForRefresh, "forLoop", "Start the task");
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        os_signpost_interval_end(refreshLog, spidForRefresh, "forLoop", "Finished with size %d", i);
    });
}

// 事件类型的os_signpost，标记了一个特定时间点
// 如何将category定义为".pointsOfInterest"
// 在Time Profile中查看"兴趣点"
- (void)mySignpostSingle {
    os_log_t refreshLog = os_log_create("com.example.your-app", OS_LOG_CATEGORY_POINTS_OF_INTEREST);
    os_signpost_id_t spidForRefresh = os_signpost_id_generate(refreshLog);
    os_signpost_event_emit(refreshLog, spidForRefresh, "refresh", "test_meta_name");
}

// 有条件地开启和关闭signpost
- (void)conditionOpenSignPost {
    os_log_t refreshLog;
    // 环境变量中存在"SIGNPOSTS_FOR_REFRESH"，则会开启
    if ([NSProcessInfo.processInfo.environment.allKeys containsObject:@"SIGNPOSTS_FOR_REFRESH"]) {
        refreshLog = os_log_create("com.example.your-app", "RefreshOperations");
    } else {
        refreshLog = OS_LOG_DISABLED;
    }
    
    os_signpost_id_t spidForRefresh = os_signpost_id_generate(refreshLog);
    os_signpost_interval_begin(refreshLog, spidForRefresh, "forLoop");
    os_signpost_interval_end(refreshLog, spidForRefresh, "forLoop");
}

// 自定义instrument WWDC 2018 Creating Custom Instruments

@end
```

### 参考链接

[关于os_signpost使用](https://www.jianshu.com/p/d9dc0bbc8535)

# Leaks

## Leaks 定义

先看看 Leaks，从苹果的开发者文档里可以看到，一个 app 的内存分三类：
 **Leaked memory**: Memory unreferenced by your application that cannot be used again or freed (also detectable by using the Leaks instrument).

**Abandoned memory**: Memory still referenced by your application that has no useful purpose.

**Cached memory**: Memory still referenced by your application that might be used again for better performance.

翻译过来就是：

 **Leaked memory**: App中**不再**被引用到的内存，这个内存**不能**再次被使用或者释放；

**Abandoned memory**: 在App中仍然被程序引用，但是没有使用目的了

**Cached memory**: App中仍然被使用的内存，而且为了更好的性能，可能被再次使用

- Leaked memory 和 Abandoned memory 都属于应该释放而没释放的内存，都是【内存泄露】。
- 而 Leaks 工具只负责检测 Leaked memory，而不管 Abandoned memory。在 MRC 时代 Leaked memory 很常见，因为很容易忘了调用 release，但在 ARC 时代更常见的内存泄露是循环引用导致的 Abandoned memory，Leaks 工具查不出这类内存泄露，应用有限。

# Allocation

对于 Abandoned memory，可以用 Instrument 的 Allocations 检测出来。检测方法是用 Mark Generation 的方式，当你每次点击 Mark Generation 时，Allocations 会生成当前 App 的内存快照，而且 Allocations 会记录从上回内存快照到这次内存快照这个时间段内，新分配的内存信息。举一个最简单的例子：
 我们可以不断重复 push 和 pop 同一个 UIViewController，理论上来说，push 之前跟 pop 之后，app 会回到相同的状态。因此，在 push 过程中新分配的内存，在 pop 之后应该被 dealloc 掉，除了前几次 push 可能有预热数据和 cache 数据的情况。如果在数次 push 跟 pop 之后，内存还不断增长，则有内存泄露。因此，我们在每回 push 之前跟 pop 之后，都 Mark Generation 一下，以此观察内存是不是无限制增长。这个方法在 WWDC 的视频里：[Session 311 - Advanced Memory Analysis with Instruments](https://link.jianshu.com?t=http://developer.apple.com/videos/wwdc/2010/)（这个链接已经失效了，[视频转移到优酷上](https://v.youku.com/v_show/id_XMzE4MTEzMjQ3Ng==.html)），以及苹果的开发者文档：[Finding Abandoned Memory](https://link.jianshu.com?t=https://developer.apple.com/library/mac/recipes/Instruments_help_articles/FindingAbandonedMemory/FindingAbandonedMemory.html) 里有介绍。



[Demo](https://github.com/LeoMobileDeveloper/Blogs/blob/master/Instruments/Allocations.md)

# System Trace

## 附录

[iOS App启动优化（三）：二进制重排](https://juejin.cn/post/6844904168201666574)这篇文章里，讲了System  Trace的使用

[System Trace的使用](https://github.com/LeoMobileDeveloper/Blogs/blob/master/Instruments/SystemTrace.md)

# Address Sanitizer







# 参考链接

[iOS内存泄漏检测-MLeaksFinder学习及使用](https://www.jianshu.com/p/906b7328847a)

[iOS内存深入探索之Leaks](https://www.jianshu.com/p/12cadd05e370)

