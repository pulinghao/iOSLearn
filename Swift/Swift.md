# Swift常用语法

## ``?``用法

```swift
// 上面这个Optional的声明，是”我声明了一个Optional类型值，
// 它可能包含一个String值，也可能什么都不包含”，
// 也就是说实际上我们声明的是Optional类型，而不是声明了一个String类型 (这其实理解起来挺蛋疼的...)
var name: String?
```



## 数组

```swift
// 创建一个空数组，类型为 MKRouteStep
var steps: [MKRouteStep] = []
// 向数组添加元素
steps.append(item)
```

