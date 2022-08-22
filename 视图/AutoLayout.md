什么是autolayout



# 简介

## 自动布局的过程

Auto layout 在 view 显示之前，多引入了两个步骤：`updating constraints` 和 `laying out views`。每一个步骤都依赖于上一个。display 依赖 layout，而 layout 依赖 updating constraints。 `updating constraints->layout->display`

> 避免约束和手写布局一起用

### updating constraints

<font color='red'>从下到上（from subview to superView)</font>。为下一步 layout 准备信息。可以通过调用方法 `setNeedUpdateConstraints` 去触发此步。

```
- (void)updateConstraints;
```

### layout

<font color='red'>从上到下(from superview to subview)</font>。主要应用上一步的信息去设置 view 的 center 和 bounds

```
- (void)layoutSubviews;
```



### display

此步时把 view 渲染到屏幕上，它与你是否使用 Auto layout 无关，其操作是从上向下 (from super view to subview)，通过调用 setNeedsDisplay 触发。



应该避免**布局传递**！！！也就是说，在下一步设置layout的时候，又触发了上一步的update contraints!!!

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

