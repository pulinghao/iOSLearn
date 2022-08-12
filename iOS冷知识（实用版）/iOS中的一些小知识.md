# 1. load

`+(void)load`方法的调用，是以函数指针调用的

```c
 // Call all +loads for the detached list.
  for (i = 0; i < used; i++) {
      Category cat = cats[i].cat;
      load_method_t load_method = (load_method_t)cats[i].method; //IMP强转为load_method_t
      Class cls;
      if (!cat) continue;

      cls = _category_getClass(cat);
      if (cls  &&  cls->isLoadable()) {
          if (PrintLoading) {
              _objc_inform("LOAD: +[%s(%s) load]\n", 
                           cls->nameForLogging(), 
                           _category_getName(cat));
          }
          (*load_method)(cls, @selector(load));  
          cats[i].cat = nil;
      }
  }
```

定义了一个函数指针

```c
typedef void(*load_method_t)(id, SEL);  // 定义了一个函数指针，叫 load_method_t
```

# 2. 什么是IMP

IMP的定义在`objc.h`文件中，本质上也是一个函数指针，因此可以与`load_method_t`这个结构强转，也就是[1. load](#1. load) 方法中IMP强转为`load_method_t`

```c
/// A pointer to the function of a method implementation. 
#if !OBJC_OLD_DISPATCH_PROTOTYPES
typedef void (*IMP)(void /* id, SEL, ... */ ); 
#else
typedef id _Nullable (*IMP)(id _Nonnull, SEL _Nonnull, ...); 
#endif

```

# 3. 什么是@selector SEL

IMP的定义在`objc.h`文件中，本质上也是一个函数指针，因此可以与`load_method_t`这个结构强转，也就是 [1.load](#1.load)方法中IMP强转为`load_method_t`

> IOS SEL（@selector）原理
>
> 其中@selector（）是取类方法的编号，取出的结果是SEL类型。
> SEL：类成员方法的指针，与C的函数指针不一样，函数指针直接保存了方法的地址，而SEL只是方法的编号。

```c
SEL method = @selector(func);//定义一个类方法的指针，selector查找是当前类（包含子类）的方法
```

