# 第二章

# ViewController之间的解耦

### 问题

使用系统的跳转方式，会对ViewController之间产生依赖，并且会将绑定跳转事件的控件也耦合进去。

### 中介者模式

用一个对象来封装一组对象之间的逻辑。它避免了对象之间的显式引用。

书中引入了一个中介者`CoordinatingController`，在这个类中，整合了另外三个类的跳转关系

```objective-c
#import "CanvasViewController.h"
#import "PaletteViewController.h"
#import "ThumbnailViewController.h"
```

后续修改只在`CoordinatingController`中即可，它会根据按钮的点击事件，以及按钮的`tag`（这里，相当于按钮根据tag，知道自己要做什么事情，跳转哪个VC），从而做对应的处理

# Coding Tips

## 协议的使用

Protocol在iOS编程中，经常被用到。传统的实现多个子类实现某个方法的方式是，所有子类继承一个基类，而基类自己有一个未被实现的公有方法，所以继承的子类自己覆盖这个方法。这样做的缺点就是，实现某个方法的前提是，所有的类必须有一个基类。

在《第二章》中，看到一个操作。既可以保证这个类能实现对应的方法，也不用确保这个类继承自某个具体的类。只需要让**所有需要实现这个方法**的类，都遵循一个协议即可。

![image-20210707223454040](Objective-C设计模式.assets/image-20210707223454040.png)

