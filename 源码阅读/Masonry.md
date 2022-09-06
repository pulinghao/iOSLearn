# 接口

## 更新视图

`mas_updateContraints`

- 更新的约束，必须是在原来的make约束的基础之上，不能是新的约束

例如，原来的约束为

```objective-c
[self.speView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.mas_centerY);
        make.left.mas_equalTo(self.stationNameLabel.mas_right).mas_offset(nearW + 10);
        make.size.mas_equalTo(CGSizeMake(1, 12));
    }];
```

那么，新的约束，只能围绕着 `stationNameLabel`去布局

```objective-c
 [self.speView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.stationNameLabel.mas_right).mas_offset(5);
}];
```



# 原理



## 寻找公共父视图

```objc
- (instancetype)mas_closestCommonSuperview:(MAS_VIEW *)view {
  //
  // secondViewSuperview参考视图

  //firstView 和 secondView 两个的公共父视图
  MAS_VIEW *closestCommonSuperview = nil;

  MAS_VIEW *secondViewSuperview = view;
  while (!closestCommonSuperview && secondViewSuperview) {
      MAS_VIEW *firstViewSuperview = self;
      while (!closestCommonSuperview && firstViewSuperview) {
          if (secondViewSuperview == firstViewSuperview) {
              closestCommonSuperview = secondViewSuperview;
          }
          firstViewSuperview = firstViewSuperview.superview;
      }
      secondViewSuperview = secondViewSuperview.superview;
  }
  return closestCommonSuperview;
}
```

## install接口

```objective-c
- (NSArray *)install {
    if (self.removeExisting) {
        // 将已经存在的约束移除
        NSArray *installedConstraints = [MASViewConstraint installedConstraintsForView:self.view];
        for (MASConstraint *constraint in installedConstraints) {
            [constraint uninstall];
        }
    }
    NSArray *constraints = self.constraints.copy;
    for (MASConstraint *constraint in constraints) {
        constraint.updateExisting = self.updateExisting;
        [constraint install];
    }
    [self.constraints removeAllObjects];
    return constraints;
}
```

## 新约束如何添加上去去？

```objective-c
- (MASConstraint *)constraint:(MASConstraint *)constraint addConstraintWithLayoutAttribute:(NSLayoutAttribute)layoutAttribute {
    MASViewAttribute *viewAttribute = [[MASViewAttribute alloc] initWithView:self.view layoutAttribute:layoutAttribute];
    MASViewConstraint *newConstraint = [[MASViewConstraint alloc] initWithFirstViewAttribute:viewAttribute];
    
    // 如果constraint == nil, 会直接走下面的逻辑，直接把约束添加到约束数组里
    if ([constraint isKindOfClass:MASViewConstraint.class]) {
        //replace with composite constraint
        NSArray *children = @[constraint, newConstraint];
        MASCompositeConstraint *compositeConstraint = [[MASCompositeConstraint alloc] initWithChildren:children];
        compositeConstraint.delegate = self;
        // 这一句，是把老的约束，替换成新的约束 compositeConstraint
        [self constraint:constraint shouldBeReplacedWithConstraint:compositeConstraint];
        return compositeConstraint;
    }
    if (!constraint) {
        newConstraint.delegate = self;
        [self.constraints addObject:newConstraint];
    }
    return newConstraint;
}
```



# 参考文档

[源码解读——Masonry](https://www.jianshu.com/p/a294ab266858/)

# 代码Tip

## 父类未实现，子类实现的宏定义

如果子类没有实现，那么会崩溃，在输出信息中，打印出异常信息

```objective-c
#define MASMethodNotImplemented() \
    @throw [NSException exceptionWithName:NSInternalInconsistencyException \
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass.", NSStringFromSelector(_cmd)] \
                                 userInfo:nil]
// 使用
- (MASConstraint * (^)(CGFloat multiplier))multipliedBy { MASMethodNotImplemented(); }
```

## 用约束实现动画效果

```objective-c
// 设置动画执行完毕后的布局
- (void)updateConstraints {
    [self.movingButton remakeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(100));
        make.height.equalTo(@(100));
        
        if (self.topLeft) {
            make.left.equalTo(self.left).with.offset(10);
            make.top.equalTo(self.top).with.offset(10);
        }
        else {
            make.bottom.equalTo(self.bottom).with.offset(-10);
            make.right.equalTo(self.right).with.offset(-10);
        }
    }];
    
    //according to apple super should be called at end of method
    [super updateConstraints];
}


// tell constraints they need updating
[self setNeedsUpdateConstraints];
// update constraints now so we can animate the change
[self updateConstraintsIfNeeded];
[UIView animateWithDuration:0.4 animations:^{
        // 这一步才会去挪动方块，执行真正的渲染
        // 下面这一句一定要放到动画的中间
        [self layoutIfNeeded];
}];
```

## 链式语法

链式语法，利用iOS的三个点

- 是一个get方法
- 是用`block`来传参
- 链式的核心是，返回`self`

```objective-c
self.doSth.setName(@"123");

- (Person *)doSth{
  // your code
  return self;
}

- (Person* (^)(NSString *name))setName{
   Person* (^block)(NSString *name) = ^(NSString *name){
     NSLog(@"%@",name);
     return self;
   }
   return block;
}
```

