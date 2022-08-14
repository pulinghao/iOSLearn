# isa

什么是isa指针？

```c
union isa_t {
    isa_t() { } // 构造函数
    isa_t(uintptr_t value) : bits(value) { }

    Class cls;
    uintptr_t bits;
#if defined(ISA_BITFIELD)
    struct { 					 // 位域的声明
        ISA_BITFIELD;  // defined in isa.h
    };
#endif
};
```

- 区别non_pointer和pointer的优化

手机做了non-pointer的优化，而PC没有做优化

- isa_t使用的是联合体结构

共有3个成员 cls、bits和struct结构的一个字段，共用一个地址

 对某一个成员赋值，会覆盖其他成员的值（也不奇怪，因为他们共享一块内存。但前提是成员所占字节数相同，当成员所占字节数不同时只会覆盖相应字节上的值，比如对char成员赋值就**不会把整个int成员覆盖掉**，因为char只占一个字节，而int占四个字节） [iOS底层-isa结构(isa_t)](https://www.jianshu.com/p/6b6bf1c27d8e)

- 位域

什么是位域？位域的优势？

```c
struct
{
  type [member_name] : width ;
};
```

Type:只能为 int(整型)，unsigned int(无符号整型)，signed int(有符号整型) 三种类型，决定了如何解释位域的值。

member_name:位域的名称。

width:位域中位的数量。宽度必须小于或等于指定类型的位宽度，而且最小值为1。

- cls

`Class`是`objc_class`结构体指针类型，`cls`在64位架构下是占8字节。

- bits

`bits` 是一个无符号长整形，占 8 个字节。

# objc_object

```c
struct objc_object {
	Class isa  OBJC_ISA_AVAILABILITY;
};

struct objc_object {
private:
    isa_t isa;
public:
  // ISA() assumes this is NOT a tagged pointer object
  Class ISA();
}
```

## id

一个指向类的实例指针

```c
/// A pointer to an instance of a class.
typedef struct objc_object *id;
```



## 初始化

当传入为pointer isa时，被当做普通的指针初始化

当传入nonpointer为true时，也即是手机端的程序

```c
inline void 
objc_object::initIsa(Class cls, bool nonpointer, bool hasCxxDtor) 
{ 
    ASSERT(!isTaggedPointer()); 
    
    if (!nonpointer) {
        isa = isa_t((uintptr_t)cls);  //被当做普通的指针初始化
    } else {
        isa_t newisa(0);
        newisa.bits = ISA_MAGIC_VALUE;
        // isa.magic is part of ISA_MAGIC_VALUE
        // isa.nonpointer is part of ISA_MAGIC_VALUE
        newisa.has_cxx_dtor = hasCxxDtor;
        newisa.shiftcls = (uintptr_t)cls >> 3;
        isa = newisa;
    }
}
```



# objc_class

```c
struct objc_class {
    Class isa  OBJC_ISA_AVAILABILITY;
#if !__OBJC2__
    Class super_class;
    const char *name;
    long version;
    long info;
    long instance_size;
    struct objc_ivar_list *ivars;
    **struct objc_method_list **methodLists**;
    **struct objc_cache *cache**;
    struct objc_protocol_list *protocols;
#endif
};
```



# objc_method_list



```c
struct objc_method_list {
    struct objc_method_list *obsolete;
    int method_count;

#ifdef __LP64__
    int space;
#endif

    /* variable length structure */
    struct objc_method method_list[1];
};

struct objc_method {
    SEL method_name;
    char *method_types;    /* a string representing argument/return types */
    IMP method_imp;
};
```





# 消息传递



