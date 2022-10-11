# High performance drawing on iOS — Part 2

在上一篇文章中，我讨论了关于CPU渲染2D图形的方式。在这篇文章中，我将介绍两种不同的方法，来使用GPU的并行性。

**CoreGraphics使用到了CPU来渲染，而Core Animation使用的是GPU来渲染**。在这个文章中，我会使用GPU来做渲染，也就是Core Animation的方案。

# Sublayer **GPU**-based drawing

这项技术使用了`UIBezierPaths`和`CALayer`来渲染，并在`UIImageView`中保存这些渲染。

举个例子，假设我们在触动屏幕的时候，绘制一条线

```swift
var currentTouchPosition: CGPoint?

override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let newTouchPoint = touches.first?.location(in: self) else { return }
    currentTouchPosition = newTouchPoint
}
```

我们可以在触动的时候，两点之间绘制一条线

```swift
override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let newTouchPoint = touches.first?.location(in: self) else { return }
    guard let previousTouchPoint = currentTouchPosition else { return }
    drawBezier(from: previousTouchPoint, to: newTouchPoint)
    currentTouchPosition = newTouchPoint
}
```

看一下`drawBezier`具体实现

```swift
func drawBezier(from start: CGPoint, to end: CGPoint) {
    // 1 创建一个新的Layer
    setupDrawingLayerIfNeeded()
    // 2 创建线的layer和贝塞尔实例
    let line = CAShapeLayer()  // lineLayer将被添加上去
    let linePath = UIBezierPath()
    // 3 设置线的layer的一些属性
    line.contentsScale = UIScreen.main.scale
    linePath.move(to: start)
    linePath.addLine(to: end)
    line.path = linePath.cgPath
    line.fillColor = lineColor.cgColor
    line.opacity = 1
    line.lineWidth = lineWidth
    line.lineCap = .round
    line.strokeColor = lineColor.cgColor

    drawingLayer?.addSublayer(line) //将line layer添加上去

    // 4 当前Layer超过400个时，渲染
    if let count = drawingLayer?.sublayers?.count, count > 400 {
        flattenToImage()
    }
}
```

下面看下`flattenToImage`的方法

```swift
func flattenToImage() {
    UIGraphicsBeginImageContextWithOptions(bounds.size, false, Display.scale)
    if let context = UIGraphicsGetCurrentContext() {

        // keep old drawings
        if let image = self.image {
            image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        }

        // add new drawings
        drawingLayer?.render(in: context)

        let output = UIGraphicsGetImageFromCurrentImageContext()
        self.image = output
    }
    clearSublayers()
    UIGraphicsEndImageContext()
}
```

上边的代码实现了以下功能：

1. 获取当前image中的内容，在当前的上下文环境`context`中把它 `draw`出来
2. 然后，获取`drawingLayer`的内容，并`render`出来
3. 最后，将上下文`context`赋值给了`self.image`

上面Flattening的方式不是很理想，因为很依赖CPU。这个方式在绘制时很稳定。理想情况下，可以摆脱CGContext，使用Core Animation来渲染

# draw(_layer:ctx:) GPU-based drawing

这个方法有点类似于`draw(rect:)`,但是有别于它，这个方法名字叫`draw(_layer:ctx:)`

我们从UIView的子类开始，在`touchesMoved`这个方法中，我们报错了在一条line array中，新touch的位置，然后我们调用`layer.setNeedsDisplay(rect:)`来执行渲染。调用这个方法，也是为了做到局部渲染。

```swift
override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let newTouchPoint = touches.first?.location(in: self) else { return }

    let lastTouchPoint: CGPoint = line.last ?? .zero
    line.append(newTouchPoint)
    let rect = calculateRectBetween(lastPoint: lastTouchPoint, newPoint: newTouchPoint)
    layer.setNeedsDisplay(rect)  //渲染
}
```

下一步，就是重写`draw(_layer:ctx:)`这个方法来使用GPU。在这里，我们使用`CAShapeLayer`来渲染，而不是使用`CGContext`，这样就不依赖于CPU了

```swift
  override func draw(_ layer: CALayer, in ctx: CGContext) {
      // 1
      let drawingLayer = self.drawingLayer ?? CAShapeLayer()
      // 2
      drawingLayer.contentsScale = UIScreen.main.scale
      // 3
      let linePath = UIBezierPath()
      // 4
      for (index, point) in line.enumerated() {
          if index == 0 {
              linePath.move(to: point)
          } else {
              linePath.addLine(to: point)
          }
      }

      drawingLayer.path = linePath.cgPath
      drawingLayer.opacity = 1
      drawingLayer.lineWidth = lineWidth
      drawingLayer.lineCap = .round
      drawingLayer.fillColor = UIColor.clear.cgColor
      drawingLayer.strokeColor = lineColor.cgColor
      
      // 5
      if self.drawingLayer == nil {
          self.drawingLayer = drawingLayer
          layer.addSublayer(drawingLayer)
      }
  }
```

上述代码做了以下几个操作：

1. 复用了当前的Layer，或者创建一个Layer
2. 匹配当前设备的scale
3. 创建贝塞尔曲线的实例
4. 绘制path
5. 将绘制后的drawingLayer，添加到当前的layer上（这是个入参）

注意，这个过程要避免因为点数过多，而带来性能损耗。当点数超过25个点时，我们使用新的Flatten方法

```swift
func checkIfTooManyPoints() {
      let maxPoints = 25 
      if line.count > maxPoints { // 点数超过
          updateFlattenedLayer()
          // we leave two points to ensure no gaps or sharp angles
          _ = line.removeFirst(maxPoints - 2)
      }
  }
```

让我们来看下如何实现的

```swift
func updateFlattenedLayer() {
    // 1
    guard let drawingLayer = drawingLayer,
        // 2
        let optionalDrawing = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(
            NSKeyedArchiver.archivedData(withRootObject: drawingLayer, requiringSecureCoding: false))
            as? CAShapeLayer,
        // 3
        let newDrawing = optionalDrawing else { return }
    // 4
    self.layer.addSublayer(newDrawing)
}
```

1. 获取可用的drawingLayer，这个layer可能之前在`draw()`方法中渲染过
2. 将这些layer encode为一个对象，并在后续使用的时候，decode
3. 获得一个新的layer
4. 添加到当前layer上，并渲染

新的layer不再是用CPU绘制的形式产生，而是encode/decode的方式，从而节省CPU的运行时间。

实际上，是把生成的layer用encode为一个对象，然后再解码出来（当需要再次使用的时候）



这个方法于前者的区别，主要是在最后渲染不同，前者还是用到了CPU，并且作为UIImageView的属性放了进去，而这个方法是采用继承自UIView，然后重写了`draw(rect:ctx:)`这个方法来实现。

# 收益

使用这种方式渲染， 11代iPad的帧率为120



# 总结

两篇文章中，提到了下面4个方式渲染

- Low performance **CPU**-based drawing
- High performance **CPU**-based drawing
- Sublayer **GPU**-based drawing (what I ended up using in my game)
- Draw(layer:ctx:) **GPU**-based drawing

第一种方式还是比较耗性能的，2，3，4的方案都还OK



# 参考文档

[High performance drawing on iOS — Part 2](https://medium.com/@almalehdev/high-performance-drawing-on-ios-part-2-2cb2bc957f6)