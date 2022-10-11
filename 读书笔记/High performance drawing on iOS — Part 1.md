# High performance drawing on iOS — Part 1

原文地址：https://medium.com/@almalehdev/high-performance-drawing-on-ios-part-1-f3a24a0dcb31

我将提供4种不同的渲染方案，但是他们在实现和性能上有很大的不同。

# 基于CPU的低性能绘制

最简单的绘制方式，一般地，我们会继承自`UIImageView`，然后来作为你的画布

```swift
let renderer = UIGraphicsImageRenderer(size: bounds.size)
image = renderer.image { ctx in
 image?.draw(in: bounds)
 lineColor.setStroke() // any color
 ctx.cgContext.setLineCap(.round)
 ctx.cgContext.setLineWidth(lineWidth) // any width
 ctx.cgContext.move(to: previousTouchPosition)
 ctx.cgContext.addLine(to: newTouchPosition)
 ctx.cgContext.strokePath()
}
```

这种方法在iPhone6上OK，但是在最新的iPad11上，帧率只有17。经过问题的定位，原来是

```swift
image = renderer.image { ctx in ... }
```

和

```swift
image?.draw(in: bounds)
```

1. 渲染器创建基于一些列渲染指令的UImage，这是CPU密集型的
2. 闭包里，还包括了绘制`draw`的命令，这也是CPU密集的

之所以老的设备比新的设备快，是因为

- iPhone 6s只有1亿个像素左右的密度，而iPad有4亿个
- iPhone 6s的刷新率是60，而iPad是120，touchMoved在iPad上会被调用两次

注意，CPU密集型的操作，是一个**单线程操作**，多核不能带来收益。

# 基于CPU的高性能绘制

这种方法以UIView的`draw（_rect:）`方法为中心，您不能直接调用它。相反，您可以通过对视图调用`setNeedsDisplay（）`来调用该方法。这里绘制的想法是，将要绘制的点存储在数组中（这是在touchesMoved中完成的），然后在`draw（_rect:）`中循环这些点以执行实际绘制。

```swift
override func draw(_ rect: CGRect) {
    guard let context = UIGraphicsGetCurrentContext() else { return }
    context.setStrokeColor(UIColor.red.cgColor)
    context.setLineWidth(5)
    context.setLineCap(.round)
    //这里lines是已经保存好的形状点数据了
    lines.forEach { (line) in
        for (index, point) in line.enumerated() {
            if index == 0 {
                context.move(to: point)
            } else {
                context.addLine(to: point)
            }
        }
    }
    context.strokePath()
}
```

虽然上述代码有所提升，但是CPU仍然会增长。下面提一些优化点

## 局部的setNeedsDisplay

首先，与其调用`setNeedsDisplay`，它将整个视图标记为需要重画，我们实际上应该调用它的同级`setNeedsDisplay（_rect:）`，它只会将该视图中的一个小rect标记为脏的，需要重画。

因此，我们需要计算出这个局部矩形

```swift
override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let newTouchPoint = touches.first?.location(in: self) else { return }

    var lastTouchPoint: CGPoint = .zero

    if let lastIndex = lines.indices.last {
        // get reference to last point
        if let lastPoint = lines[lastIndex].last { lastTouchPoint = lastPoint }

        // add new point
        lines[lastIndex].append(newTouchPoint)
    }

    let rect = calculateRectBetween(lastPoint: lastTouchPoint, newPoint: newTouchPoint)
		//局部刷新
    setNeedsDisplay(rect)
}
```

OC中局部刷新的方法是

```objective-c
[self setNeedsDisplayInRect:CGRectMake(0, 0, 100, 200)];
```

## flatten Image

每次完成一些操作后，就立刻转换成位图

```swift
override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesBegan(touches, with: event)
  	//操作完成，转换成为诶图
    flattenImage()
}
// called from touches ended
func flattenImage() {
    flattenedImage = self.getImageRepresentation()
    line.removeAll()
}

// convert view to bitmap
func getImageRepresentation() -> UIImage? {
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.isOpaque, 0.0)
    defer { UIGraphicsEndImageContext() }
    if let context = UIGraphicsGetCurrentContext() {
        self.layer.render(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        return image
    }
    return nil
}
```

 并在`draw`方法中，渲染这个位图

```swift
 override func draw(_ rect: CGRect) {
    super.draw(rect)
    guard let context = UIGraphicsGetCurrentContext() else { return }

    // draw the flattened image if it exists
    // 取出位图，并渲染
    if let image = flattenedImage {
        image.draw(in: self.bounds)
    }

    context.setStrokeColor(lineColor.cgColor)
    context.setLineWidth(lineWidth)
    context.setLineCap(.round)

    for (index, point) in line.enumerated() {
        if index == 0 {
            context.move(to: point)
        } else {
            context.addLine(to: point)
        }
    }
    context.strokePath()
}
```

# 总结

- 使用`UIGraphicsImageRenderer`的方法，低性能绘制
- CPU绘制是单线程的
- 高性能的绘制在setNeedsDisplay中中
  - 局部绘制
  - 在适当的时机，转换成位图

# 参考文档

[UIGraphicsImageRenderer](https://developer.apple.com/documentation/uikit/uigraphicsimagerenderer?language=objc)

