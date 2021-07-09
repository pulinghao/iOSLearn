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

# 第三章 原型模式

- 深复制和浅复制
- NSObject的深复制，实现`CopyWithZone`协议

在`Mark.h`文件中，声明`copy`接口，要求子类实现

```objective-c
@protocol Mark <NSObject, NSCopying, NSCoding>

- (id) copy;
```

子类`Dot.h`中，实现`copyWithZone`的方法

```objective-c

- (id)copyWithZone:(NSZone *)zone
{
  Dot *dotCopy = [[[self class] allocWithZone:zone] initWithLocation:location_];
  // copy the color
  [dotCopy setColor:[UIColor colorWithCGColor:[color_ CGColor]]];
  // copy the size
  [dotCopy setSize:size_];
  
  return dotCopy;
}

```

> Mark协议采用了NSObject协议，而Mark的具体类采用了Mark协议并且子类化NSObject类。NSObject协议没有声明copy方法，但是NSObject声明了。NSObject型的接收器收到copy消息时，NSObject依次向其采用了NSCopying协议的子类转发消息。子类要实现所需的在NSCopying中定义的copyWithZone:zone方法，返回自身的副本。如果子类没有实现此方法，那么会抛出NSInvalidArgumentException异常实例。

我推测合理的解释是说：其实每个子类本身都实现了copyWithZone方法，那么调用copy方法的时候，自然而然会走copyWithZone方法。但是子类并没有继承一个NSCopying协议，为了使得编译通过，所以在Mark协议中，声明了copy方法。

# 第四章 工厂模式

> 定义：定义创建对象的接口，让子类决定实例化哪一个类。工厂方法使得一个类的实例化延迟到其子类。

场景：

- 编译时，无法准确预期要创建对象的类；
- 类想让子类决定运行时创建什么；
- 类有若干辅助类为其子类，而你香江返回哪个子类这一信息局部化

CoacoTouch中的NSNumber用到了，例如[NSNumber numberWithBool:YES];

# Coding Tips

## 协议的使用

Protocol在iOS编程中，经常被用到。传统的实现多个子类实现某个方法的方式是，所有子类继承一个基类，而基类自己有一个未被实现的公有方法，所以继承的子类自己覆盖这个方法。这样做的缺点就是，实现某个方法的前提是，所有的类必须有一个基类。

在《第二章》中，看到一个操作。既可以保证这个类能实现对应的方法，也不用确保这个类继承自某个具体的类。只需要让**所有需要实现这个方法**的类，都遵循一个协议即可。

![image-20210707223454040](Objective-C设计模式.assets/image-20210707223454040.png)

