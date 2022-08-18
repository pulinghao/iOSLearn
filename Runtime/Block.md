# Block语法

# 截获变量

## 自动变量

- 只复制block中用到的变量，复制的是一个值



- 不能修改

如果对外部的局部变量，修改时，需要加`__block`修饰符修饰，否则会报错。

对外部的Objective-C对象，例如NSMutableArray添加元素，并不会报错。原因时，没有修改array这个指针

```objective-c
id array = [[NSMutableArray alloc] init];
void ^blk(void) = ^{
	NSObject *obj = [[NSObject alloc] init];
	[array addObject:obj];
}
```

但如果进行赋值的操作，就会出错。使用`__block`修饰符修饰

```objective-c
id array = [[NSMutableArray alloc] init];
void ^blk(void) = ^{
	array = [[NSMutableArray alloc] init]; //出错
}
```



使用C语言数组时，小心使用指针，因为Blocks截获自动变量的方法，<font color='red'>**并没有实现对C语言数组的捕获**</font>

![image-20220816105811317](/Users/pulinghao/Library/Application Support/typora-user-images/image-20220816105811317.png)

## 静态局部变量

## 静态全局变量

## 全局变量

# 实现原理

## 不带局部变量

## 带局部变量

### 不修改

### 修改（__block）

如果要修改被捕获的变量，有几个方法

- 使用以下几种变量，Block直接修改

  - 静态局部变量：传递静态局部变量的指针给block

  ```c
  int *static_val = __celf->static_val; //局部变量
  ```

  - 静态全局变量：直接访问
  - 全局变量：直接访问

- 把捕获的变量作为参数，以指针的形式传入

```c
int val = 10;
void (^blk)(int* a) = ^(int* a){
    *a = *a + 2;
    NSLog(@"%d",*a);
};
val = 20;
blk(&val);
NSLog(@"%d",val);
// 输出22,22
```

#### __block说明符

#### block的复制

```c
//以下代码在MRC中运行
    __block int i = 0;
    NSLog(@"%p",&i);
    
    void (^myBlock)(void) = [^{
        i ++;
        NSLog(@"这是Block 里面%p",&i);
    }copy];
```

输出为

```c
0x7fff5fbff818
<__NSMallocBlock__: 0x100203cc0>
这是Block 里面 0x1002038a8
```

从栈上复制到堆上，`__block`捕获的对象，也被复制到了堆上。此时，栈上的forwading指针指向的是堆上的那个`__block`对象。而堆上的`__block`对象，指向的是它自己。

<img src="https://img.halfrost.com/Blog/ArticleImage/21_6.jpg" alt="img" style="zoom:50%;" />



下面的结果，因为没有被复制，也就是没有复制到堆上。所以forwarding的值不变

```c
//以下代码在MRC中运行
    __block int i = 0;
    NSLog(@"%p",&i);//0x7fff5fbff818
    
    void (^myBlock)(void) = ^{
        i ++;
        NSLog(@"Block 里面的%p",&i); //0x7fff5fbff818
    };
    
    
    NSLog(@"%@",myBlock);
    
    myBlock();
```



# 类型

| 类型         | _NSConcreteGlobalBlock                       | _NSConcreteStackBlock                                | _NSConcreteMallocBlock                 |
| ------------ | -------------------------------------------- | ---------------------------------------------------- | -------------------------------------- |
| 是否持有对象 | 不持有对象                                   | 不持有                                               | 持有                                   |
| 定义         | 没有用到外界变量<br>只用到全局变量、静态变量 | 只用到外部局部变量、成员属性变量，<br>没有强指针引用 | 有强指针引用或copy修饰的成员属性引用的 |
| 生命周期     | 生命周期从创建到应用程序结束。               | 系统控制                                             | 程序员控制                             |



<font color='red'>但是当Block为函数参数的时候，就需要我们手动的copy一份到堆上了</font>。除了系统的接口，例如GCD和usingBlock的方法，系统会自动copy。



# 补充

对于对象来说，

在MRC环境下，`__block`根本不会对指针所指向的对象执行copy操作，而只是把指针进行的复制。
而在ARC环境下，对于声明为`__block`的外部对象，在block内部会进行retain，以至于在block环境内能安全的引用外部对象。对于没有声明__block的外部对象，在block中也会被retain。



在ARC环境下，其实也存在Stack类型的Block

> 在ARC环境下，Block也是存在__NSStackBlock的时候的，平时见到最多的是_NSConcreteMallocBlock，是因为我们会对Block有赋值操作，所以ARC下，block 类型通过=进行传递时，会导致调用objc_retainBlock->_Block_copy->_Block_copy_internal方法链。并导致 __NSStackBlock__ 类型的 block 转换为 __NSMallocBlock__ 类型。

```c
#import <Foundation/Foundation.h>

int main(int argc, const char * argv[]) {
    
    __block int temp = 10;
    
    NSLog(@"%@",^{NSLog(@"*******%d %p",temp ++,&temp);});
   
    return 0;
}
```





# Tip

- 看是否持有对象，只要打印出retainCount即可

```objective-c
//以下是在MRC下执行的
NSObject * obj = [[NSObject alloc]init];
NSLog(@"1.Block外 obj = %lu",(unsigned long)obj.retainCount);

void (^myBlock)(void) = [^{
    NSLog(@"Block中 obj = %lu",(unsigned long)obj.retainCount);
}copy];

NSLog(@"2.Block外 obj = %lu",(unsigned long)obj.retainCount);

myBlock();

[myBlock release];

NSLog(@"3.Block外 obj = %lu",(unsigned long)obj.retainCount);
```

输出为

```
1.Block外 obj = 1
2.Block外 obj = 2
Block中 obj = 2
3.Block外 obj = 1
```

