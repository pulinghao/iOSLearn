# YYModel

## Coding Tips

### 强制内连

```
#define force_inline __inline__ __attribute__((always_inline))
```

`__inline__ __attribute__((always_inline))` 的意思是强制内联.所有加  `__inline__ __attribute__((always_inline))` 修饰的函数在被调用的时候不会被编译成函数调用,而是直接扩展到调用函数体内.

# YYCache



# YYImage

