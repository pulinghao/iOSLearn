# Block语法

# 截获变量

## 自动变量

- 只复制block中用到的变量，复制的是一个值

  - 如果是普通变量

  ```c
  int val = __cself->val;
  ```

  

  - 如果是对象，例如

```c
NSMutableString * str = [[NSMutableString alloc]initWithString:@"Hello,"];
void (^myBlock)(void) = ^{
    [str appendString:@"World!"];
    NSLog(@"Block中 str = %@",str);
};
```

在捕获的是指针；

```c
static void __main_block_func_0(struct __main_block_impl_0 *__cself) {
  NSMutableString *str = __cself->str;
  //...
}
```



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

```c
int main(){
	static int static_k = 3;
}
```

捕获

```c
static void __main_block_func_0(struct __main_block_impl_0 *__cself) {
  int *static_k = __cself->static_k; // bound by copy
}
```

静态局部变量被捕获进来，以地址的形式访问

## 静态全局变量

```c
static int static_global_j = 2;
int main(){

}
```

捕获时，直接捕获；操作的时候，操作的就是`static_global_j`

```c
static void __main_block_func_0(struct __main_block_impl_0 *__cself) {
  static_global_j ++;
  NSLog((NSString *)&__NSConstantStringImpl__var_folders_45_k1d9q7c52vz50wz1683_hk9r0000gn_T_main_6fe658_mi_0,static_global_j);
    }
```



## 全局变量

```c
int global_i = 2;
int main(){

}
```

同静态全局变量：捕获时，直接捕获；操作的时候，操作的就是`global_i`



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

```objective-c
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

<img src="https://img.halfrost.com/Blog/ArticleImage/21_6.jpg" alt="img" style="zoom:40%;" />



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



| 对象的引用计数 | 堆Block                      | 栈Block        |
| -------------- | ---------------------------- | -------------- |
| __block修饰    | 不增加引用计数               | 不增加引用计数 |
| 无__block修饰  | 捕获，并拷贝，加两次引用计数 | 不增加引用计数 |



# `__block`原理

## 普通非对象的变量

```c
#import <Foundation/Foundation.h>

int main(int argc, const char * argv[]) {
    __block int i = 0;
    void (^myBlock)(void) = ^{
        i ++;
        NSLog(@"%d",i);
    }; 
    myBlock();
    return 0;
}
```

转成C++的代码

```c
struct __Block_byref_i_0 {
  void *__isa;
__Block_byref_i_0 *__forwarding;
 int __flags;
 int __size;
 int i;//存储实际值
};

static void __main_block_func_0(struct __main_block_impl_0 *__cself) {
  __Block_byref_i_0 *i = __cself->i; // bound by ref

 (i->__forwarding->i) ++;
        NSLog((NSString *)&__NSConstantStringImpl__var_folders_45_k1d9q7c52vz50wz1683_hk9r0000gn_T_main_3b0837_mi_0,(i->__forwarding->i));
}

int main(int argc, const char * argv[]) {
    __attribute__((__blocks__(byref))) __Block_byref_i_0 i = {(void*)0,(__Block_byref_i_0 *)&i, 0, sizeof(__Block_byref_i_0), 0}; //构造函数，原来的val变成了一个结构体

    void (*myBlock)(void) = ((void (*)())&__main_block_impl_0((void *)__main_block_func_0, &__main_block_desc_0_DATA, (__Block_byref_i_0 *)&i, 570425344));

    ((void (*)(__block_impl *))((__block_impl *)myBlock)->FuncPtr)((__block_impl *)myBlock);

    return 0;
}
```

- 将原来的变量val，构造一个<font color='red'>结构体`__Block_byref_i_0`</font>
- 让这个结构体的指向 i
- 实际改动的是forwarding指针指向的值

## 普通对象

### 非__block修饰

```objc
id obj = [[NSObject alloc]init];
NSLog(@"block_obj = [%@ , %p] , obj = [%@ , %p]",block_obj , &block_obj , obj , &obj);
    
void (^myBlock)(void) = ^{
    NSLog(@"***Block中****block_obj = [%@ , %p] , obj = [%@ , %p]",block_obj , &block_obj , obj , &obj);
  // obj的地址跟外边的地址是一样的
};
```

转换为C++，使用的是指针，所以地址不会变化

```c
struct __main_block_impl_0 {
  struct __block_impl impl;
  struct __main_block_desc_0* Desc;
  id obj;
  __Block_byref_block_obj_0 *block_obj; // by ref
  __main_block_impl_0(void *fp, struct __main_block_desc_0 *desc, id _obj, __Block_byref_block_obj_0 *_block_obj, int flags=0) : obj(_obj), block_obj(_block_obj->__forwarding) {
    impl.isa = &_NSConcreteStackBlock;
    impl.Flags = flags;
    impl.FuncPtr = fp;
    Desc = desc;
  }
};

static void __main_block_func_0(struct __main_block_impl_0 *__cself) {
  id obj = __cself->obj; // bound by copy

  NSLog((NSString *)&__NSConstantStringImpl__var_folders_45_k1d9q7c52vz50wz1683_hk9r0000gn_T_main_e64910_mi_1,(block_obj->__forwarding->block_obj) , &(block_obj->__forwarding->block_obj) , obj , &obj);
}
```



## __block修饰

```objc

__block id block_obj = [[NSObject alloc]init];
NSLog(@"block_obj = [%@ , %p] , obj = [%@ , %p]",block_obj , &block_obj , obj , &obj);

void (^myBlock)(void) = ^{
    NSLog(@"***Block中****block_obj = [%@ , %p] , obj = [%@ , %p]",block_obj , &block_obj , obj , &obj);
   //ARC环境下，输出地址不同；MRC环境下，输出地址相同，因为MRC下，这是一个栈block，不拷贝
};
```

传递的是一个结构体，结构体的内部forwarding指向了block_obj的地址

```c
struct __Block_byref_block_obj_0 {
  void *__isa;
__Block_byref_block_obj_0 *__forwarding;
 int __flags;
 int __size;
 void (*__Block_byref_id_object_copy)(void*, void*);
 void (*__Block_byref_id_object_dispose)(void*);
 id block_obj;  //默认带strong修饰符，会引起引用计数+1
};
static void __main_block_func_0(struct __main_block_impl_0 *__cself) {
  __Block_byref_block_obj_0 *block_obj = __cself->block_obj; // bound by ref
   NSLog((NSString *)&__NSConstantStringImpl__var_folders_45_k1d9q7c52vz50wz1683_hk9r0000gn_T_main_e64910_mi_1,(block_obj->__forwarding->block_obj) , &(block_obj->__forwarding->block_obj) , obj , &obj);
    }
```



# 补充

对于对象来说，

在MRC环境下，`__block`根本不会对指针所指向的对象执行copy操作，而只是把指针进行的复制。
而在ARC环境下，对于声明为`__block`的外部对象，在block内部会进行`retain`，以至于在block环境内能安全的引用外部对象。对于没有声明__block的外部对象，在block中也会被retain。

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



# 参考文档

[](https://halfrost.com/ios_block/)