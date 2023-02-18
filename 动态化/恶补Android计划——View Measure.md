# FrameLayout源码

## onMeasure

### 过程一

1. 遍历所有子View，记录子View的最大宽高(height + padding + margin)
2. FrameLayout的尺寸 = 子View的最大宽高 + padding + margin
3. 注意，对于不确定大小的模式，子View 有 match_parent属性的，需要为子View重新测量

### 过程二

当match_parent时

1. 遍历所有子节点中，match_parent节点
2. 对match_parent的节点，使用第一个阶段中，父View的尺寸进行度量



## onLayout

FrameLayout对每个子View的layout过程是相同的，

1. 它遍历所有子view，通过子View的gravity属性进行x，y轴的偏移量计算，
2. 最后调用`child.layout()`对子View进行布局