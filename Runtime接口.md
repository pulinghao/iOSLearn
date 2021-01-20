

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

  

- 消息转发`objc_msgSend`，源码位于`objc_msg-arm64.s`

  ```asm
  	ENTRY _objc_msgSend
  	UNWIND _objc_msgSend, NoFrame
  
  	
  	cmp	p0, #0			// nil check and tagged pointer check,p0是消息接收者
  #if SUPPORT_TAGGED_POINTERS
  	b.le	 		//  (MSB tagged pointer looks negative)  //b.le意思是小于等于0，走LNilOrTagged 分支
  #else
  	b.eq	LReturnZero     //b.eq意思是等于0，走LReturnZero  分支
  #endif
  	ldr	p13, [x0]		// p13 = isa
  	GetClassFromIsa_p16 p13, 1, x0	// p16 = class
  LGetIsaDone:
  	// calls imp or objc_msgSend_uncached
  	CacheLookup NORMAL, _objc_msgSend, __objc_msgSend_uncached
  
  #if SUPPORT_TAGGED_POINTERS
  LNilOrTagged:
  	b.eq	LReturnZero		// nil check
  	GetTaggedClass
  	b	LGetIsaDone
  // SUPPORT_TAGGED_POINTERS
  #endif
  
  LReturnZero:    //
  	// x0 is already zero
  	mov	x1, #0
  	movi	d0, #0
  	movi	d1, #0
  	movi	d2, #0
  	movi	d3, #0
  	ret
  
  	END_ENTRY _objc_msgSend
  ```

  注意`GetClassFromIsa_p16`这个汇编方法，本质还是做了下面的掩码操作，得到`isa`

  ```asm
  .macro ExtractISA
  	and    $0, $1, #ISA_MASK
  .endmacro
  ```

  > .macro 的语法相当于是define，定义了一个宏

  ```asm
  .macro MethodTableLookup
  	
  	SAVE_REGS MSGSEND
  
  	// lookUpImpOrForward(obj, sel, cls, LOOKUP_INITIALIZE | LOOKUP_RESOLVER)
  	// receiver and selector already in x0 and x1
  	mov	x2, x16
  	mov	x3, #3
  	bl	_lookUpImpOrForward  // 在方法列表里找方法
  
  	// IMP in x0
  	mov	x17, x0
  
  	RESTORE_REGS MSGSEND
  
  .endmacro
  
  ```

  > 汇编中的方法_lookUpImpOrForward比C语言中的同名方法，多一个下划线，同名C方法
  >
  > `extern IMP lookUpImpOrForward(id obj, SEL, Class cls, int behavior);`

  

- 动态解析

  resolveInstanceMethod方法，会被调用两次，为什么？

  【答】第一次触发动态解析，调用resolve；第二次是消息转发，进入forwarding逻辑了，再次调用resolve。通过lldb调试打印调用栈`bt`可以发现

  ```shell
  #第二次调用
  * thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 2.1
    * frame #0: 0x000000010206770b MyLearnIOS`+[Person resolveInstanceMethod:](self=Person, _cmd="resolveInstanceMethod:", sel="walk") at Person.m:22:5
      frame #1: 0x00007fff20185ef2 libobjc.A.dylib`resolveInstanceMethod(objc_object*, objc_selector*, objc_class*) + 159
      frame #2: 0x00007fff20185cfe libobjc.A.dylib`resolveMethod_locked(objc_object*, objc_selector*, objc_class*, int) + 345
      frame #3: 0x00007fff201858a7 libobjc.A.dylib`class_getInstanceMethod + 47
      frame #4: 0x00007fff2042f83f CoreFoundation`__methodDescriptionForSelector + 281
      frame #5: 0x00007fff2042f8e8 CoreFoundation`-[NSObject(NSObject) methodSignatureForSelector:] + 30
      frame #6: 0x00007fff20424c09 CoreFoundation`___forwarding___ + 420
      frame #7: 0x00007fff20427068 CoreFoundation`__forwarding_prep_0___ + 120
  
  #第一次调用
  * thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 2.1
    * frame #0: 0x000000010206770b MyLearnIOS`+[Person resolveInstanceMethod:](self=Person, _cmd="resolveInstanceMethod:", sel="walk") at Person.m:22:5
      frame #1: 0x00007fff20185ef2 libobjc.A.dylib`resolveInstanceMethod(objc_object*, objc_selector*, objc_class*) + 159
      frame #2: 0x00007fff20185cfe libobjc.A.dylib`resolveMethod_locked(objc_object*, objc_selector*, objc_class*, int) + 345
      frame #3: 0x00007fff2017421b libobjc.A.dylib`_objc_msgSend_uncached + 75
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

- 与`@selector()`等价 方法

  ```objective-c
  @selector(yourname) //与下面的方法等价
  sel_registerName("yourname");
  
  ```

  

# clang

编译带UIKit的文件

```shell
clang -x objective-c -rewrite-objc -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator.sdk  XXX.m文件
```

