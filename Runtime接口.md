

头文件引入`#import <objc/message.h>`

# Runtime

- 调用父类方法`[super function]`与`objc_msgSendSuper`

  ```c
  //如下的方法调用
  [super func];
  
  //构造父类结构体
  struct objc_super superStruct = {
          self,
          class_getSuperclass(object_getClass(self))
      };
  // 转换成runtime的形式
  objc_msgSendSuper(&superStruct,SEL);
  ```

  

- OC字符串转C字符串

  ```c
  char *str = (__bridge void *)@"objc";
  ```

  



# 实例

- 修改ISA指针`object_setClass`

  将self的isa指针指向新的类，并不会改变[self class]的值，只是改变self->isa的值

  ```c
   //object_setClass(<#id  _Nullable obj#>, <#Class  _Nonnull __unsafe_unretained cls#>)
   object_setClass(self, newClass);
  ```

## 关联属性

- 设置关联对象`objc_setAssociatedObject`

  ```c
  /**
  	param1: 需要绑定的对象
  	param2: 关联的属性key
  	param3: 关联的数据value，id类型  
  	param4: 关联的类型，4种，assign是弱引用
  */
  objc_setAssociatedObject(self, (__bridge void *)@"objc", observer, OBJC_ASSOCIATION_ASSIGN);
  ```

- 获取关联对象`objc_getAssociatedObject`

  ```c
  /**
  	param1: 需要绑定的对象
  	param2: 关联的属性名字
  */
  id object = objc_getAssociatedObject(self, (__bridge void *)@"objc");
  ```

  

# 类

- 创建类`objc_allocateClassPair`

  创建一个新类

  ```c
  /**
  	param1: 父类
  	param2: 新类的名字，转C字符串
  	param3: 额外的字节数，不常用
  */
  newClass = objc_allocateClassPair([self class], newName.UTF8String, 0);
  
  ```

- 类的注册`objc_registerClassPair`

  与类的创建何用，需要把创建的类，放到系统内存

- 给父类发送``msgSend``消息

  ```c
  static void tz_setter(id self, SEL _cmd, id newValue) {
      NSLog(@"%s", __func__);
      
    // 构造父类的objc_super结构体
      struct objc_super superStruct = {
          self,
          class_getSuperclass(object_getClass(self))
      };
      
      // 改变父类的值
      objc_msgSendSuper(&superStruct, _cmd, newValue);
      
      // 通知观察者， 值发生改变了
      // 观察者
      id observer = objc_getAssociatedObject(self, (__bridge void *)@"objc");
      NSString* setterName = NSStringFromSelector(_cmd);
      NSString* key = getterForSetter(setterName);
      
      objc_msgSend(observer, @selector(observeValueForKeyPath:ofObject:change:context:), key, self, @{key:newValue}, nil);
  }
  ```

  

# 方法

- 获取实例方法`class_getInstanceMethod`

  ```c
  /**
  	param1: 类
  	param2: SEL名
  */
  Method classMethod = class_getInstanceMethod([self class], @selector(class));
  ```

- 给类添加方法`class_addMethod`

  ```c
  const char* classTypes = method_getTypeEncoding(classMethod);
  // IMP
  IMP myImp = class_getMethodImplementation([self class], @selector(my_class));   
  /**
  	param1: 类名
  	param2: 要添加的SEL名
  	param3: IMP实现，如果是OC的方法，需要转成IMP，如果是C的方法，需要参考OC消息转发的格式
  */
  class_addMethod(newClass, @selector(class), (IMP)myImp, classTypes);
  
  // OC方法
  // my_class不是IMP，而是一个SEL
  - (Class)my_class
  {
      NSLog(@"my class");
      return class_getSuperclass(object_getClass(self));
  }
  
  // c方法
  Class tz_class(id self, SEL _cmd) {
      return class_getSuperclass(object_getClass(self));
  }
  ```

- 获取方法的IMP`method_getImplementation`

  ```
  Method newMethod = class_getInstanceMethod([Person class], @selector(run));
  IMP imp = method_getImplementation(newMethod);
  ```

  

- 设置方法的IMP`method_setImplementation`

  交换两个方法，如下

  ```objective-c
  Person *p = [[Person alloc] init];
  [p walk];
  
  Method oldMethod = class_getInstanceMethod([Person class], @selector(walk));
  Method newMethod = class_getInstanceMethod([Person class], @selector(run));
  IMP imp = method_getImplementation(newMethod);
  method_setImplementation(oldMethod, imp);
  [p walk];
  
  //也可以设置C语言指针
  void doSth(){
    
  }
  method_setImplementation(oldMethod, (IMP)doSth);
  ```

  



# clang

编译带UIKit的文件

```shell
clang -x objective-c -rewrite-objc -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator.sdk  XXX.m文件
```

