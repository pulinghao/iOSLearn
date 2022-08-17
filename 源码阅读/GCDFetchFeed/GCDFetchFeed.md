# ReactiveCocoa

## 1. 属性监听与绑定

```objective-c
#define RAC_(TARGET, KEYPATH, NILVALUE) \
    [[RACSubscriptingAssignmentTrampoline alloc] initWithTarget:(TARGET) nilValue:(NILVALUE)][@keypath(TARGET, KEYPATH)]
/*
    [[RACSubscriptingAssignmentTrampoline alloc] initWithTarget:self nilValue:nil][@keypath(self, feeds)];
    RACSubscriptingAssignmentTrampoline *line = [[RACSubscriptingAssignmentTrampoline alloc] initWithTarget:self nilValue:nil];
    这种写法，等同于是对一个对象设置属性
    对象设置属性，出了用点语法以外，还可以用KeyPath的方式设置，例如 object["name"] = @"Tom",
    这样的话，会调用 - (void)setObject:(RACSignal *)signal forKeyedSubscript:(NSString *)keyPath  这个方法
//  line[@"feed"] = @[@1,@2];
*/
    RAC(self, feeds) = [[[SMDB shareInstance] selectAllFeeds]
                        map:^id(NSMutableArray *feedsArray) {
                            if (feedsArray.count > 0) {
                                //
                            } else {
                                feedsArray = [SMFeedStore defaultFeeds];
                            }
                            return feedsArray;
                        }];
```



### 知识点

#### 1） 设置属性

为了防止程序崩溃，RAC使用了` - (void)setObject:(RACSignal *)signal forKeyedSubscript:(NSString *)keyPath`方法来设置属性。它和`- (void)setObject:(RACSignal *)signal forKey:(NSString *)keyPath`有几点不同：

- 当调用`setObject:forKey:`传入nil的时候会崩溃，使用`setObject:forKeyedSubscript:`则不会
- 如果调用`setObject:forKey:`需要传递空值，可以使用NSNull
- 使用下标赋值等效于调用`setObject:forKeyedSubscript:`方法，`RAC()`这个宏定义实际上就是下标赋值

```objective-c
NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
[dict setObject:@"jack" forKey:@"name"];
dict[@"name"] = @"jack"; //@{@"name":@"jack"},等效于[mutableDictionary setObject:value forKeyedSubscript:@"name"];
dict[@"name"] = nil;     //@{}

[dict setObject:nil forKeyedSubscript:@"sex"];
[dict setObject:nil forKey:@"sex"];   //崩溃
```



#### 2）绑定

```objective-c
id obj = [[SMDB shareInstance] selectAllFeeds];
RACSubscriptingAssignmentTrampoline *line = [[RACSubscriptingAssignmentTrampoline alloc] initWithTarget:self nilValue:nil];
line[@"feeds"] = obj;
```

- `selectAllFeeds`返回的是一个RACSignal，内部有Feeds数组数据
- 在执行第三步的赋值时，其实是由这个信号量实现`self`和`feeds`数据的绑定

<img src="/Users/pulinghao/Library/Application Support/typora-user-images/image-20210907160903850.png" alt="image-20210907160903850" style="zoom:50%;" />

```objc
- (RACDisposable *)setKeyPath:(NSString *)keyPath onObject:(NSObject *)object nilValue:(id)nilValue {
	RACDisposable *subscriptionDisposable = [self subscribeNext:^(id x) {
    __strong NSObject *object __attribute__((objc_precise_lifetime)) = (__bridge __strong id)objectPtr;
		[object setValue:x ?: nilValue forKeyPath:keyPath];
	} error {
	}
}
```

`[object setValue:x ?: nilValue forKeyPath:keyPath];`**这句实现了将值赋值给属性的操作**，但是这个是block的回调

内部`subscribeNext`这个接口中，获取了x的值，也就是一开始构造RACSignal赋值的值

```objective-c
- (RACDisposable *)subscribe:(id<RACSubscriber>)subscriber {
	// 省略
	if (self.didSubscribe != NULL) {
        // 单例写法 [RACScheduler.subscriptionScheduler ...]
		RACDisposable *schedulingDisposable = [RACScheduler.subscriptionScheduler schedule:^{
      // didSubscribe 在createSignal的时候赋值
     	 // subscriber 在 执行 subsribeNext的时候，被赋值
			RACDisposable *innerDisposable = self.didSubscribe(subscriber);  
			[disposable addDisposable:innerDisposable];
		}];

		[disposable addDisposable:schedulingDisposable];
	}
	
	return disposable;
}
```

需要注意的是：

```objective-c
RACDisposable *innerDisposable = self.didSubscribe(subscriber); 
```

这段代码，**不仅执行了`self.didSubscribe(subscriber)`里面的block，而且把block的返回值赋值了`innerDisposable`**

```objc
- (RACDisposable *)subscribeNext:(void (^)(id x))nextBlock error:(void (^)(NSError *error))errorBlock completed:(void (^)(void))completedBlock {
	// 这里为 RACSubscriber 的next error complete等block赋值
    // 赋值以后，马上执行 didSubscribe里的方法
	RACSubscriber *o = [RACSubscriber subscriberWithNext:nextBlock error:errorBlock completed:completedBlock];
	return [self subscribe:o];
}
```

在`RACDisposable *innerDisposable = self.didSubscribe(subscriber);  `中，`subscriber`这个对象执行`sendNext`，就可以拿到用户设置的值，并最终给self赋值

```objc
[subscriber sendNext:feedsArray];

- (void)sendNext:(id)value {
	@synchronized (self) {
		void (^nextBlock)(id) = [self.next copy];
		if (nextBlock == nil) return;
		nextBlock(value);
	}
}
```

这里的`nextBlock`就在`- (RACDisposable *)subscribeNext:(void (^)(id x))nextBlock error:(void (^)(NSError *error))errorBlock completed:(void (^)(void))completedBlock `这个接口中，赋值的`nextBlock`

【启发】

1. 一般的设计思路是`self.feed = obj`，即右边的值决定左边的值。RAC的设计思路是，一切都是信号，所有的操作都有信号来完成。在这里，self，feed还有obj这些数据都被封装到了信号里面去，并由一个封装了Obj的信号，来实现self.feed数据的绑定。
2. 很多操作，在创建的时候就决定了。比如说我要赋值，那么我创建一个信号量，这个信号量专门用来赋值操作



#### 3）调用

在RAC中，订阅者`subscriber`先设置了`nextBlock`，但没有真正调用这个Block，直到订阅者`subscriber`执行了`sendNext`方法。

```objective-c
// 赋值
+ (instancetype)subscriberWithNext:(void (^)(id x))next error:(void (^)(NSError *error))error completed:(void (^)(void))completed {
    RACSubscriber *subscriber = [[self alloc] init];

    subscriber->_next = [next copy];
    subscriber->_error = [error copy];
    subscriber->_completed = [completed copy];

    return subscriber;
}

// 执行
- (void)sendNext:(id)value {
    @synchronized (self) {
        void (^nextBlock)(id) = [self.next copy];
        if (nextBlock == nil) return;

        nextBlock(value);
    }
}

RACSignal *signal = [self createSignal];
    [signal subscribeNext:^(id x) {
        NSLog(@"aaa");  // 不会打印aaa
    }];


- (RACSignal *)createSignal{
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSLog(@"signal created");
        [subscriber sendNext:nil]; //打印aaa
        return nil;
    }];
}
```



## 2. Map 和 FlattenMap

先看一段代码，目的是操作让self的属性name，由Tom改为Jack

```objective-c
RACSignal *nameSig = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
    [subscriber sendNext:@"Tom"];
    [subscriber sendCompleted];  // sendCompleted必须写，否则下面赋值的时候会出现崩溃
    return nil;
}];
// 这一步操作，self的name属性被赋值为Tom
RAC(self, name) = nameSig;

// 构造一个空的信号
//    RACSignal *single = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
//        return nil;
//    }];
// 这里只能用name才能改变生效，single不行
RACSignal *sig = [nameSig map:^id(id value) {
    NSString *temp = (NSString *)value;
    temp = @"Jack";
    return temp;
}];
RAC(self, name) = sig;
```

- 调用map方法，重新构造了一个信号
- nameSig中的值Tom，在map的block中以value形式透传，并被修改，这个block的返回值，就是修改以后的值
- `RAC(self,name) = sig` 这句就是把新的Jack赋值给了name，流程参考章节一
- 整体上其实就是讲原来的`Tom`信号量，通过`map`方法，修改为一个`Jack`信号量

#### Block的包装和解包

map方法中，大量使用到了block的包装

<img src="/Users/pulinghao/Library/Application Support/typora-user-images/image-20210908164811672.png" alt="image-20210908164811672" style="zoom:50%;" />

<img src="/Users/pulinghao/Library/Application Support/typora-user-images/image-20210908164838799.png" alt="image-20210908164838799" style="zoom:50%;" />

#### 区别

```objective-c
- (instancetype)map:(id (^)(id value))block {  // map里的block返回值是id类型
	NSCParameterAssert(block != nil);

	Class class = self.class;

	return [[self flattenMap:^RACStream * (id value) { //flattenMap里面返回值是一个RACStream
        id returnValue = block(value);        //这里block返回一个对象
        id obj = [class return:returnValue];  // 把block返回的值封装为一个returnSignal
        RACStream *stream = [class return:block(value)];
		return stream;  //返回一个信号 return:这个接口在RACReturnSingle内又定义
	}] setNameWithFormat:@"[%@] -map:", self.name];
}

```



| 对比                 | Map            | flattenMap       |
| -------------------- | -------------- | ---------------- |
| block返回            | id类型（对象） | RACStream 信号流 |
| 信号发出的值不是信号 | 使用           | -                |
| 信号发出的值是信号   | -              | 使用             |



## 3. 信号生成与订阅

<img src="/Users/pulinghao/Library/Application Support/typora-user-images/image-20210908185856841.png" alt="image-20210908185856841" style="zoom:50%;" />

## Tips

1. 参数为空警告

```objc
#define NSCParameterAssert(condition) NSCAssert((condition), @"Invalid parameter not satisfying: %@", @#condition)

NSCParameterAssert(format != nil);
```



## 参考链接

[对setObject:forKey:与setObject:forKeyedSubscript:的理解](https://blog.csdn.net/weixin_34220179/article/details/88061007)





# FMDB

FMDB本质实现了对`sqlite3`的封装

## 1.可变参数接口设计

```objc
 rs = [db executeQuery:@"select * from feeditem where iscached = ? and isread = ? order by iid desc", @(0), @(0)];

- (FMResultSet *)executeQuery:(NSString*)sql, ... {
    va_list args;
    va_start(args, sql);
    
    id result = [self executeQuery:sql withArgumentsInArray:nil orDictionary:nil orVAList:args];
    // 内部实现还有
  	// obj = va_arg(args, id);
    va_end(args);
    return result;
}
```

- `va_list args`定义一个`va_list`变量，
- `va_start(args, sql);`让args指向`sql`后面的那个参数的地址
- `obj = va_arg(args, id);`获取可变参数args的内容，它的类型为id类型
- `va_end(args)`清空args

## 参考链接

[va_list原理及用法](https://blog.csdn.net/aihao1984/article/details/5953668?utm_medium=distribute.pc_relevant.none-task-blog-2%7Edefault%7ECTRLIST%7Edefault-2.no_search_link&depth_1-utm_source=distribute.pc_relevant.none-task-blog-2%7Edefault%7ECTRLIST%7Edefault-2.no_search_link)



# 宏

##  双井号`##`

- `##`的意思是连接后面的参数
- 当可变参数的个数为0时，且前面有`逗号`时，省略`逗号`

```
(NSLog)((format), ##__VA_ARGS__);
// 当__VA_ARGS为0时,等价于下面
(NSLog)((format))
```

## 单井号 `#`

- 字符串化，给后面的内容两头加上""

```
#expression
// 等价于 "expression"
```

## 参考链接

[宏定义的黑魔法 - 宏菜鸟起飞手册](https://onevcat.com/2014/01/black-magic-in-macro/)

