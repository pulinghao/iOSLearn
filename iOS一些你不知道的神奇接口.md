# 视图

## 按钮点击范围

```objective-c
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent*)event {
    CGRect bounds = self.bounds;
     bounds = CGRectInset(bounds, -10, -10);
   // CGRectContainsPoint  判断点是否在矩形内
    return CGRectContainsPoint(bounds, point);
}

// // 改变图片的点击范围
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    
    // 控件范围宽度多40，高度20
    CGRect bounds = CGRectInset(self.bounds, -20, -20);
    NSLog(@"point = %@",NSStringFromCGPoint(point));
  // 贝塞尔曲线
    UIBezierPath *path1 = [UIBezierPath bezierPathWithRect:CGRectMake(-20, 0, 40, 120)];
    UIBezierPath *path2 = [UIBezierPath bezierPathWithRect:CGRectMake(self.frame.size.width - 20, 0, 40, 120)];
    if (([path1 containsPoint:point] || [path2 containsPoint:point])&& CGRectContainsPoint(bounds, point)){
        //如果在path区域内，返回YES
        return YES;
    }
    return NO;
}
```

``CGRectContainsPoint``接口，用于判断某个点是否在某个矩形区域内