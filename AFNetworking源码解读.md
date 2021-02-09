# AFNetworking 3.0

## NSURLSession

NSURLSession的流程：

- 创建`NSURLSessionConfig`对象
- 用`NSURLSessionConfig`创建`NSURLSession`对象
- 用NSURLSession 创建对应的task对象，并用`resume`执行
- 在`delegate`或者`completion block`中响应网络事件及数据 

## AFHTTPSessionManager

### 初始化

- 初始化session和`NSURLSessionConfiguration`，并持有`NSURLSessionConfiguration`

- 创建session的串行队列，将operationQueue的最大并发数设置为**1**（但多个task的回调是并发的）

  ```objective-c
  self.session = [NSURLSession sessionWithConfiguration:self.sessionConfiguration delegate:self delegateQueue:self.operationQueue];
  ```

  这里调用了系统方法，因为在iOS 9以后，使用`NSURLSession`来管理网络请求

- 设置序列化及默认证书

- 初始化任务ID字典，其中键值对为`<taskid, delegate>`，保存起来后，通过taskid操作 

- 创建锁`NSLock`确保线程安全

  ```objc
  //默认为json解析
  self.responseSerializer = [AFJSONResponseSerializer serializer];
  
  //设置默认证书 无条件信任证书https认证
  self.securityPolicy = [AFSecurityPolicy defaultPolicy];
  
  // 为什么要收集: cancel resume supend : task : id
  //delegate= value taskid = key
  self.mutableTaskDelegatesKeyedByTaskIdentifier = [[NSMutableDictionary alloc] init];
  
  //使用NSLock确保线程安全
  self.lock = [[NSLock alloc] init];
  self.lock.name = AFURLSessionManagerLockName;
  ```

  

### 发送请求

#### KVC & KVO 

在设置`AFHTTPRequestSerializer`时，观察其某个属性是否被设置，被修改

AFNetworking 改自动触发为手动触发

```objective-c
@interface AFHTTPRequestSerializer ()
//某个request需要观察的属性集合
@property (readwrite, nonatomic, strong) NSMutableSet *mutableObservedChangedKeyPaths;

@end
  
@implementation AFHTTPRequestSerializer
  
  
- (instancetype)init {
   // KVO的使用
    self.mutableObservedChangedKeyPaths = [NSMutableSet set];
    for (NSString *keyPath in AFHTTPRequestSerializerObservedKeyPaths()) {
        if ([self respondsToSelector:NSSelectorFromString(keyPath)]) {
            //自己给自己的方法添加观察者
            [self addObserver:self forKeyPath:keyPath options:NSKeyValueObservingOptionNew context:AFHTTPRequestSerializerObserverContext];
        }
    }
}

#pragma mark - NSKeyValueObserving
/**
 如果kvo的触发机制是默认出发。则返回true，否则返回false。在这里，只要是`AFHTTPRequestSerializerObservedKeyPaths`里面的属性，我们都取消自动出发kvo机制，使用手动触发。
 为什么手动，我猜应该是为了在监听这些属性时可以用于某些特殊的操作，比如测试这些属性变化是否崩溃等。
 @param key kvo的key
 @return bool值
 */
+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key {
    if ([AFHTTPRequestSerializerObservedKeyPaths() containsObject:key]) {
        return NO;
    }

    return [super automaticallyNotifiesObserversForKey:key];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(__unused id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if (context == AFHTTPRequestSerializerObserverContext) {
        if ([change[NSKeyValueChangeNewKey] isEqual:[NSNull null]]) {
            [self.mutableObservedChangedKeyPaths removeObject:keyPath];
        } else {
            [self.mutableObservedChangedKeyPaths addObject:keyPath];
        }
    }
}

- (NSMutableURLRequest *)requestWithMethod:(NSString *)method
                                 URLString:(NSString *)URLString
                                parameters:(id)parameters
                                     error:(NSError *__autoreleasing *)error
{
       //将request的各种属性遍历,给NSMutableURLRequest自带的属性赋值
      for (NSString *keyPath in AFHTTPRequestSerializerObservedKeyPaths()) {
          //给设置过得的属性，添加到request（如：timeout）
          if ([self.mutableObservedChangedKeyPaths containsObject:keyPath]) {
              //通过kvc动态的给mutableRequest添加value
              [mutableRequest setValue:[self valueForKeyPath:keyPath] forKey:keyPath];
          }
      }                                
}


@end
```



## HTTPS

### 流程

![img](AFNetworking源码解读.assets/https-intro.png)

1. 客户端发送请求给服务端，服务端（有私钥和公钥，由自己或者机构生成）

2. 服务端返回公钥

3. 客户端（TLS完成）验证公钥，如果没问题，生成随机Key

4. 使用公钥，加密传输随机Key

5. 服务端使用私钥解密（因为客户端使用服务端的公钥加密的），获取Key，使用Key 隐藏内容

6. 使用客户端Key响应加密内容，

7. 客户端使用Key解密内容（这里是对称加密，这个秘钥就是key）

   

## 面试

1. AFNetworking 2.0 与 3.0版本有什么区别（滴滴 二面）

| AFNetworking 2.0                                             | AFNetworking 3.0                                             |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| NSURLConnection                                              | NSURLSession (原因是iOS 9.0以后，NSURLConnection被弃用)      |
| 常驻线程：用来并发请求，和处理数据回调；避免多个网络请求的线程开销(不用开辟一个线程，就保活一条线程)； | 因为NSURLSession可以指定回调delegateQueue，NSURLConnection而不行；NSURLConnection的一大痛点就是：发起请求后，而需要一直处于等待回调的状态。而3.0后NSURLSession解决的这个问题；NSURLSession发起的请求，不再需要在当前线程进行回调，可以指定回调的delegateQueue，这样就不用为了等待代理回调方法而保活线程了 |
| 并发请求：系统根据情况控制最大并发数；2.0的operationQueue是用来添加operation并进行并发请求的，所以不要设置为1。 | 最大并发数设置：3.0的operationQueue是用于接收NSURLSessionDelegate回调的；self.operationQueue.maxConcurrentOperationCount = 1，是为了达到串行回调的效果，况且加了锁； |

总结起来三点：

- 2.0使用NSURLConnection，3.0使用NSURLSession
- 2.0使用常驻线程处理并发，3.0使用URLSession，可以指定对调delegateQueue
- operationQueue的使用不同

2. `AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];`创建`AFHTTPSessionManager`的时候，使用的什么设计模式？

   **普通**初始化方法，而非单例！！！

   ```
   + (instancetype)manager {
       return [[[self class] alloc] initWithBaseURL:nil];
   }
   ```

   

