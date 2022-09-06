什么是autolayout





# 简介

## 约束

Cassowary 的核心是基于 **约束（Constraint）** 来描述视图之间的关系。约束本质上就是一个方程式：

```
item1.attribute1 = multiplier × item2.attribute2 + constant
```



![view-formula](/Users/pulinghao/Github/iOSLearn/视图/view-formula.png)

该约束表示红色视图的左边界在蓝色视图的右边界再往右 8 个像素点。**注意，这里的 `=` 并不是赋值的意思，而是相等的意思**。

在自动布局系统中，约束不仅可以定义两个视图之间的关系，还可以定义单个视图的两个不同属性之间的关系，如：在视图的高度和宽度之间设置比例。**一般而言，一个视图需要<font color='red'>四个</font>约束来决定其大小和位置**。

## 约束规则

### 属性 `NSLayoutAttribute`

### 关系`NSLayoutRelation`

### 约束层级

约束描述两个视图之间的关系，但是前提是：**两个视图必须属于同一个视图层级结构。**这种层级结构有两种：

1. 一个视图是另一个视图的子视图
2. 两个视图在一个窗口下有一个非 `nil` 的公共祖先视图

### 约束优先级

约束具有优先级。当布局引擎计算布局时，会按照优先级从高到低的顺序逐个计算。

如果发现一个可选的约束无法被满足时，就会跳过这个约束，计算下一个约束。

有时候，即使一个约束无法被正好适配，它依然可以影响布局。iOS定义了4种优先级

```objective-c
static const UILayoutPriority UILayoutPriorityRequired = 1000; 
static const UILayoutPriority UILayoutPriorityDefaultHigh = 750; 
static const UILayoutPriority UILayoutPriorityDefaultLow = 250; 
static const UILayoutPriority UILayoutPriorityFittingSizeLevel = 50;
```

## 布局

布局的构建主要由 **布局引擎**（Layout Engine）完成。

### 尺寸约束

事实上，在上文 **约束创建** 中创建的约束就已经包含了尺寸约束。这里的再次提到尺寸约束，主要是针对 `Self-Sizing` 的视图。

### 固有尺寸 & 内容优先级

iOS 中有部分视图具有**固有内容尺寸**（intrinsic content size），固有内容尺寸就是视图内容和边距所占据的尺寸。比如，`UIButton` 的固有内容尺寸等于 Title 的尺寸加上内容边距（margin）。

|                    View                    |         Intrinsic Content Size         |
| :----------------------------------------: | :------------------------------------: |
|                  Sliders                   |      Defines only the width (iOS)      |
| Labels, buttons, switches, and text fields | Defines both the height and the width. |
|         Text views and image views         |    Intrinsic content size can vary.    |

固有内容尺寸的大小还受内容优先级的影响，内容优先级有以下两个方面：

- **`Content Hugging Priority`**
- **`Content Compression Resistance Priority`**

`Content Hugging Priority`：表示一个视图抗拉伸的优先级，数值越高优先级越高，越不容易被拉伸。

`Content Compressing Priority`：表示一个视图抗压缩的优先级，数值越高优先级越高，越不容易被压缩。

![intrinsic_content_size](/Users/pulinghao/Github/iOSLearn/视图/intrinsic_content_size.png)

默认情况下，视图的 `Content Hugging Priority` 值是 `250`，`Content Compression Resistance Priority` 值是 `750`。因此，拉伸视图比压缩视图更容易。

### 对齐矩形

在自动布局中，我们可能会认为约束是使用 `frame` 来确定视图的大小和位置的，但实际上，它使用的是 **对齐矩形**（alignment rect）。在大多数情况下，`frame` 和 `alignment rect` 是相等的，所以我们这么理解也没什么不对。

那么为什么是使用 `alignment rect`，而不是 `frame` 呢？

有时候，我们在创建复杂视图时，可能会添加各种装饰元素，如：阴影，角标等。为了降低开发成本，我们会直接使用设计师给的切图。如下所示：

![alignment-rect](/Users/pulinghao/Github/iOSLearn/视图/alignment-rect.jpeg)

其中，(a) 是设计师给的切图，(c) 是这个图的 `frame`。显然，我们在布局时，不想将阴影和角标考虑进入（视图的 `center` 和底边、右边都发生了偏移），而只考虑中间的核心部分，如图 (b) 中框出的矩形所示。

对齐矩形就是用来处理这种情况的。`UIView` 提供了方法可以实现从 `frame` 得到 `alignment rect` 以及从 `alignment rect` 得到 `frame`。

```objective-c
// The alignment rectangle for the specified frame.
- (CGRect)alignmentRectForFrame:(CGRect)frame;

// The frame for the specified alignment rectangle.
- (CGRect)frameForAlignmentRect:(CGRect)alignmentRect;
```



## 自动布局的过程



![the-render-loop](/Users/pulinghao/Github/iOSLearn/视图/the-render-loop.png)

Auto layout 在 view 显示之前，多引入了两个步骤：`updating constraints` 和 `laying out views`。每一个步骤都依赖于上一个。display 依赖 layout，而 layout 依赖 updating constraints。 `updating constraints->layout->display`

> 避免约束和手写布局一起用

### **约束更新**`updating constraints`

<font color='red'>从下到上（from subview to superView)</font>。为下一步 layout 准备信息。可以通过调用方法 `setNeedUpdateConstraints` 去触发此步。

```objective-c
- (void)updateConstraints;
```

触发时机

- initWithFrame时候调用，但是要求重写以下方法,并返回YES。

```
+ (BOOL)requiresConstraintBasedLayout NS_AVAILABLE_IOS(6_0);
```

- `setNeedsUpdateConstraints`
- `updateConstraintsIfNeeded`

### **布局更新**`layout`

<font color='red'>从上到下(from superview to subview)</font>。主要应用上一步的信息去设置 view 的 center 和 bounds。我们可以通过条用 `setNeedsLayout` 来触发布局更新。这并不会立刻应用布局，而是延迟进行处理。因为所有的布局请求将会被合并到一个布局操作中。这种延迟处理的过程被称为 `Deferred Layout Pass`。

```objective-c
- (void)layoutSubviews;
```

触发时机

- initWithFrame时候调用，但是rect的值不能为CGRectZero。
- `setNeedsLayout`
- `layoutIfNeeded`
- 自己的frame发生改变时,约束也会导致frame改变。
- 添加**子视图**或者子视图frame改变时，约束也会导致frame改变。
- 视图被添加到UIScrollView，滚动UIScrollView。

### **显示重绘**`display redraw`

<font color='red'>从上到下(from superview to subview)</font>。此步把 view 渲染到屏幕上，它与你是否使用 Auto layout 无关，其操作是从上向下 (from super view to subview)，通过调用 setNeedsDisplay 触发。

触发时机

- initWithFrame时候调用，但是rect的值不能为CGRectZero。
- `setNeedsDisplay`

应该避免**布局传递**！！！也就是说，在下一步设置layout的时候，又触发了上一步的`updateConstraints`!!!

<img src="/Users/pulinghao/Library/Application Support/typora-user-images/image-20220821210950444.png" alt="image-20220821210950444" style="zoom:50%;" />



# autolayout生命周期



## Constraints Change

Layout Engine将

- 视图
- 约束
- 优先级
- 固定大小

通过计算换成最终的位置和大小



触发约束变化的几个条件：

- 添加、删除视图
- 设置约束
- 优先级变更

LayoutEngine在碰到约束变化后，重新计算布局，调用`[superView setNeedsLayout]`方法。（这里是superview，不是super）



## Deferred Layout Pass

过程如下：

- 做容错处理。
- <font color='red'>从上到下（superview -> subview)</font>调用layoutSubviews。通过Cassowary算法计算各个子视图的位置，算出来后将子视图的frame从Layout Engine拷贝出来。
- 后续与手写布局一样



区别上：多一个布局计算的过程。



# 性能

iOS12 的 Auto Layout 更加完善的利用了Cassowary算法的更新策略，使得AutoLayout已经基本拥有手写布局相同的性能。开发者完全可以放心使用。



# 相关文档

[系统理解 iOS 自动布局](http://chuquan.me/2019/09/25/systematic-understand-ios-autolayout/)
