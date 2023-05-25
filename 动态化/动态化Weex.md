> 细心的读者会发现，大前端依赖的不是前端语言或者前端的各种编程框架，而是虚拟机和渲染引擎。——戴铭

本节重点介绍Week，围绕Weex的

- 使用

- 渲染流程
- 通信接口
- 原理

## 使用Weex

使用CoacoPods集成

<img src="/Volumes/MacHD_M2/Users/pulinghao/Github/iOSLearn/动态化/动态化Weex.assets/image-20230213004151337.png" alt="image-20230213004151337" style="zoom:50%;" />

在ViewController中引入Weex实例

```
- (void)viewDidLoad{
	[super viewDidLoad];
	_instance = [[WXSDKInstance alloc]] init];
	_instance.onCreate = ^(UIView *view){
		// 拿到weex渲染的view
		[weakSelf.weexView removeFromSuperView]; //清理掉原来的weexView
		weakSelf.weexView = view;
		[weakSelf.view addSubView:weakSelf.weexView];
	};
	_instance.onFailed = ^(NSError *error){
		//渲染失败
	}
	_instance.renderFinish = ^(UIVew *view){
		//处理redner finish
	}
	
	// 从网络加载模板
	[_instance.renderURL:url options:@{//配置}];
}
```



## 通信

### JavaScript调端能力

<img src="/Volumes/MacHD_M2/Users/pulinghao/Github/iOSLearn/动态化/动态化Weex.assets/image-20230213004723386.png" alt="image-20230213004723386" style="zoom:50%;" />

- 首先，需要实现的方法的类Your Native Module，需要遵循WXModuleProtocol
- 然后将这个Module，注册到WeekSDKEngine中
- 最后在前端JS里，通过weex.require("Your Native Module").showSomething("name")来调用方法

那么WeekEngine是如何注册这个ShowSomething方法的

- 通过NSClassFromString()的反射方法，获取注册的类，也就是当weex.require("Your Native Module")中的部分
-  然后执行一个查找方法的循环
  - 从当前的类的methodList查找方法（这个方法是在注册的时候，由wx_eport_method_+行号+方法名组成的，被注册在全局的Config中）
  - 判断这个方法名是否有前缀，
    - 如果有前缀，通过NSSelectorFromString的反射方法，构造这个方法
    - 否则继续查找
  - 找到的这个方法，会被以{name : method}的方式，存到本地的方法列表中



## 从Vue 到 JS Bundle

Weex中的.we文件，使用自己设计的DSL模板语法，也支持样式和JS，最终会被解析成JS可识别的对象，也就是JS Bundle。在解析 HTML语言的标签时，使用的npm组件parse 5，会将HTML标签解析后生成JSON对象。

不同的标签由不同的weex组件处理：

- CSS样式：weex-styler
- template: weex-template

### 端内运行JS Bundle的原理

在端内，通过JS Framework来解析生成好的 JSBundle。解析的结果，是JSON格式的Virtual Dom。

JS Framework会在WeexSDK初始化的时候执行。

#  [Weex VS RN](https://zhuanlan.zhihu.com/p/21677103)

|           | Weex                       | React Native                         |
| --------- | -------------------------- | ------------------------------------ |
| JS Bundle | 只打业务Bundle，无分包加载 | 业务Bundle + JS 基础库，需要分包加载 |
| JS基础库  | 集成在Weex SDK中           | 部分集成                             |
|           | 更加关注性能               |                                      |

# [Weex 源码阅读](https://juejin.cn/post/6844903470537900045?spm=ata.21736010.0.0.5a6f60c6UIpDpW#heading-2)

## 初始化

```objective-c
#pragma mark weex
- (void)initWeexSDK
{
    [WXAppConfiguration setAppGroup:@"AliApp"];
    [WXAppConfiguration setAppName:@"WeexDemo"];
    [WXAppConfiguration setExternalUserAgent:@"ExternalUA"];

    [WXSDKEngine initSDKEnvironment];

    [WXSDKEngine registerHandler:[WXImgLoaderDefaultImpl new] withProtocol:@protocol(WXImgLoaderProtocol)];
    [WXSDKEngine registerHandler:[WXEventModule new] withProtocol:@protocol(WXEventModuleProtocol)];

    [WXSDKEngine registerComponent:@"select" withClass:NSClassFromString(@"WXSelectComponent")];
    [WXSDKEngine registerModule:@"event" withClass:[WXEventModule class]];
    [WXSDKEngine registerModule:@"syncTest" withClass:[WXSyncTestModule class]];

#if !(TARGET_IPHONE_SIMULATOR)
    [self checkUpdate];
#endif

#ifdef DEBUG
    [self atAddPlugin];
    [WXDebugTool setDebug:YES];
    [WXLog setLogLevel:WXLogLevelLog];

    #ifndef UITEST
        [[ATManager shareInstance] show];
    #endif
#else
    [WXDebugTool setDebug:NO];
    [WXLog setLogLevel:WXLogLevelError];
#endif
}
```

看一下WXSDKEngine初始化内部环境的代码

```objective-c
+ (void)initSDKEnvironment
{
    // 打点记录状态
    WX_MONITOR_PERF_START(WXPTInitalize)
    WX_MONITOR_PERF_START(WXPTInitalizeSync)

    // 加载本地的main.js
    NSString *filePath = [[NSBundle bundleForClass:self] pathForResource:@"main" ofType:@"js"];
    NSString *script = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];

    // 初始化SDK环境
    [WXSDKEngine initSDKEnvironment:script];

    // 打点记录状态
    WX_MONITOR_PERF_END(WXPTInitalizeSync)

    // 模拟器版本特殊代码
#if TARGET_OS_SIMULATOR
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [WXSimulatorShortcutManager registerSimulatorShortcutWithKey:@"i" modifierFlags:UIKeyModifierCommand | UIKeyModifierAlternate action:^{
            NSURL *URL = [NSURL URLWithString:@"http://localhost:8687/launchDebugger"];
            NSURLRequest *request = [NSURLRequest requestWithURL:URL];

            NSURLSession *session = [NSURLSession sharedSession];
            NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                                    completionHandler:
                                          ^(NSData *data, NSURLResponse *response, NSError *error) {
                                              // ...
                                          }];

            [task resume];
            WXLogInfo(@"Launching browser...");

            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self connectDebugServer:@"ws://localhost:8687/debugger/0/renderer"];
            });

        }];
    });
#endif
}
```

整个初始化过程分为4步

- WXMonitor监视状态
- 加载本地main.js
- WXSDKEngine初始化
- 模拟器WXSimulatorShortcutManager连接本地server



#### 1. WXMonitor监视器记录状态（使用线程安全的字典）

WXMonitor是一个普通的对象，它里面只存储了一个线程安全的字典WXThreadSafeMutableDictionary。

```objc
@interface WXThreadSafeMutableDictionary<KeyType, ObjectType> : NSMutableDictionary
@property (nonatomic, strong) dispatch_queue_t queue;
@property (nonatomic, strong) NSMutableDictionary* dict;
@end
```

在这个字典初始化的时候会初始化一个queue。

```objc
- (instancetype)init
{
    self = [self initCommon];
    if (self) {
        _dict = [NSMutableDictionary dictionary];
    }
    return self;
}

- (instancetype)initCommon
{
    self = [super init];
    if (self) {
        NSString* uuid = [NSString stringWithFormat:@"com.taobao.weex.dictionary_%p", self]; // %p，获取指针地址，确保唯一
        _queue = dispatch_queue_create([uuid UTF8String], DISPATCH_QUEUE_CONCURRENT);  
    }
    return self;
}
```

每次生成一次WXThreadSafeMutableDictionary，就会有一个与之内存地址向对应的Concurrent的queue相对应。

这个queue就保证了线程安全。

```objective-c
- (NSUInteger)count
{
    __block NSUInteger count;
    dispatch_sync(_queue, ^{
        count = _dict.count;
    });
    return count;
}

- (id)objectForKey:(id)aKey
{
    __block id obj;
    dispatch_sync(_queue, ^{
        obj = _dict[aKey];
    });
    return obj;
}

- (NSEnumerator *)keyEnumerator
{
    __block NSEnumerator *enu;
    dispatch_sync(_queue, ^{
        enu = [_dict keyEnumerator];
    });
    return enu;
}

- (id)copy{
    __block id copyInstance;
    dispatch_sync(_queue, ^{
        copyInstance = [_dict copy];
    });
    return copyInstance;
}
```

count、objectForKey:、keyEnumerator、copy这四个操作都是同步操作，用dispatch_sync保护线程安全。

```objective-c
- (void)setObject:(id)anObject forKey:(id<NSCopying>)aKey
{
    aKey = [aKey copyWithZone:NULL];
    dispatch_barrier_async(_queue, ^{
        _dict[aKey] = anObject;
    });
}

- (void)removeObjectForKey:(id)aKey
{
    dispatch_barrier_async(_queue, ^{
        [_dict removeObjectForKey:aKey];
    });
}

- (void)removeAllObjects{
    dispatch_barrier_async(_queue, ^{
        [_dict removeAllObjects];
    });
}
```

`setObject:forKey:`、`removeObjectForKey:`、`removeAllObjects`这三个操作加上了`dispatch_barrier_async`。

#### 2. 加载本地main.js

#### 3. WXSDKEngine 初始化

注册Components（就是控件Div、List、Text等等），Modules，Handlers 和 执行JSFramework。

组件注册这里比较关键的一点是注册类方法。

```objective-c


- (void)registerMethods
{
    Class currentClass = NSClassFromString(_clazz);

    if (!currentClass) {
        WXLogWarning(@"The module class [%@] doesn't exit！", _clazz);
        return;
    }

    while (currentClass != [NSObject class]) {
        unsigned int methodCount = 0;
        // 获取类的方法列表
        Method *methodList = class_copyMethodList(object_getClass(currentClass), &methodCount);
        for (unsigned int i = 0; i < methodCount; i++) {
            // 获取SEL的字符串名称
            NSString *selStr = [NSString stringWithCString:sel_getName(method_getName(methodList[i])) encoding:NSUTF8StringEncoding];

            BOOL isSyncMethod = NO;
            // 如果是SEL名字带sync，就是同步方法
            // 注意 wx_export_method 这个前缀
            if ([selStr hasPrefix:@"wx_export_method_sync_"]) {
                isSyncMethod = YES;
            // 如果是SEL名字不带sync，就是异步方法
            } else if ([selStr hasPrefix:@"wx_export_method_"]) {
                isSyncMethod = NO;
            } else {
                // 如果名字里面不带wx_export_method_前缀的方法，那么都不算是暴露出来的方法，直接continue，进行下一轮的筛选
                continue;
            }

            NSString *name = nil, *method = nil;
            SEL selector = NSSelectorFromString(selStr);
            if ([currentClass respondsToSelector:selector]) {
                method = ((NSString* (*)(id, SEL))[currentClass methodForSelector:selector])(currentClass, selector);
            }

            if (method.length <= 0) {
                WXLogWarning(@"The module class [%@] doesn't has any method！", _clazz);
                continue;
            }

            // 去掉方法名里面带的：号
            NSRange range = [method rangeOfString:@":"];
            if (range.location != NSNotFound) {
                name = [method substringToIndex:range.location];
            } else {
                name = method;
            }

            // 最终字典里面会按照异步方法和同步方法保存到最终的方法字典里
            NSMutableDictionary *methods = isSyncMethod ? _syncMethods : _asyncMethods;
            [methods setObject:method forKey:name];
        }

        free(methodList);
        currentClass = class_getSuperclass(currentClass);
    }

}
```

#### 如何暴露类方法

这里的做法也比较常规，找到对应的类方法，判断名字里面是否带有“sync”来判断方法是同步还是异步方法。这里重点**需要解析的是组件的方法是如何转换成类方法**的暴露出去的。

Weex是通过里面通过`WX_EXPORT_METHOD`宏做到对外暴露类方法的。

```objective-c
#define WX_EXPORT_METHOD(method) WX_EXPORT_METHOD_INTERNAL(method,wx_export_method_)

#define WX_EXPORT_METHOD_INTERNAL(method, token) \
+ (NSString *)WX_CONCAT_WRAPPER(token, __LINE__) { \
    return NSStringFromSelector(method); \
}

#define WX_CONCAT_WRAPPER(a, b)    WX_CONCAT(a, b)

#define WX_CONCAT(a, b)   a ## b
```

WX_EXPORT_METHOD宏会完全展开成下面这个样子：

```objectivec
#define WX_EXPORT_METHOD(method)

+ (NSString *)wx_export_method_ __LINE__ { \
    return NSStringFromSelector(method); \
}
```

举个例子，在WXWebComponent的第52行里面写了下面这一行代码：

```objective-c
WX_EXPORT_METHOD(@selector(goBack))
```





那么这个宏在预编译的时候就会被展开成下面这个样子：

```objective-c
+ (NSString *)wx_export_method_52 {
    return NSStringFromSelector(@selector(goBack));
}
```

于是乎在WXWebComponent的类方法里面就多了一个wx_export_method_52的方法。由于在同一个文件里面，WX_EXPORT_METHOD宏是不允许写在同一行的，所以转换出来的方法名字肯定不会相同。但是不同类里面行数就没有规定，行数是可能相同的，从而不同类里面可能就有相同的方法名。

比如在WXScrollerComponent里面的第58行

```objc
WX_EXPORT_METHOD(@selector(resetLoadmore))
```

<img src="/Volumes/MacHD_M2 - Data/Users/pulinghao/Github/iOSLearn/动态化/动态化Weex.assets/image-20230219011437044.png" alt="image-20230219011437044" style="zoom:50%;" />

（这儿补充一个最新版Weex中`resetLoadmore`方法截图，其实就是一行代码，写在implementation里）

WXTextAreaComponent里面的第58行

```less
WX_EXPORT_METHOD(@selector(focus))
```

这两个是不同的组件，但是宏展开之后的方法名是一样的，这两个不同的类的类方法，是有重名的，但是完全不会有什么影响，因为获取类方法的时候是通过class_copyMethodList，保证这个list里面都是唯一的名字即可。

还有一点需要说明的是，虽然用class_copyMethodList会获取所有的类方法(+号方法)，但是可能有人疑问了，那不通过`WX_EXPORT_METHOD`宏对外暴露的普通的+号方法，不是也会被筛选进来么？

回答：是的，会被class_copyMethodList获取到，但是这里有一个判断条件，会避开这些不通过`WX_EXPORT_METHOD`宏对外暴露的普通的+号类方法。

如果不通过WX_EXPORT_METHOD宏来申明对外暴露的普通的+号类方法，那么名字里面就不会带`wx_export_method_`的前缀的方法，那么都不算是暴露出来的方法，上面筛选的代码里面会直接continue，进行下一轮的筛选，所以不必担心那些普通的+号类方法会进来干扰。

