梳理简历中可能会被考察到的问题

# 1 技能清单

# 2 项目经历

## 2.1室内导航

### 背景&目的

基于视觉定位算法，实现室内场景下的定位与导航功能。

- 视觉AR
  - 视觉定位算法，利用图像匹配算法，实现定位
  - 3D渲染引擎，主要是基于Lua脚本实现
- 步骑行
  - 室内导航系统，内容包括：获取定位点后重新算路、平面偏航与跨楼层偏航策略
  - 视觉定位算法的生命周期维护，包括算法启动、重启、停止等，捕获算法异常等问题，提供不同的交互方案

### 系统设计

- 主要还是MVC设计模式，Controller负责交互

- 封装与AR SDK通信的独立模块ARController，主要负责与AR SDK接口通信，以代理回调的方式透传数据；

- 封装与ARController及步行ViewController的桥接模块ARManager，负责与AR SDK通信，导航状态的维护，当前位姿的检测等；

  

### 视频流 & Mock系统

#### CVPixelBufferRef 与 CMSampleBufferRef

在iOS里，我们经常能看到 CVPixelBufferRef 这个类型，在Camera 采集返回的数据里得到一个CMSampleBufferRef，而每个CMSampleBufferRef里则包含一个 CVPixelBufferRef，在视频硬解码的返回数据里也是一个 CVPixelBufferRef。

```objective-c
CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
```



#### MovieReader

```objective-c
- (BOOL)loadMovieAndStartReading {
    self.movieAsset = [AVAsset assetWithURL:[NSURL fileURLWithPath:self.filePath]];
    if (self.movieAsset == nil) {
        return false;
    }
    NSError* error;
    self.assetReader = [AVAssetReader assetReaderWithAsset:self.movieAsset error:&error];
    if (error) {
        NSLog(@"[SXMovieReder Error]: %@", [error localizedDescription]);
        return false;
    }
    self.movieAssetVideoTrack = [[self.movieAsset tracksWithMediaType:AVMediaTypeVideo] firstObject];
    if (self.movieAssetVideoTrack == nil) {
        return false;
    }
    self.assetReaderOutput = [[AVAssetReaderTrackOutput alloc] initWithTrack:self.movieAssetVideoTrack outputSettings:@{(NSString *)kCVPixelBufferPixelFormatTypeKey: @(self.pixelForamt)}];
    if (self.assetReaderOutput == nil) {
        return false;
    }
    [self.assetReader addOutput:self.assetReaderOutput];
    self.currentFrameIndex = -1;
    return [self.assetReader startReading];
}
```



### ARKit

- 初始化

ARKit有步骑行上层的ARCameraView接管，基于此设置ARSession和ARConfiguration。初始化做了如下工作：

1. 初始化`ARSession`，是整个ARKit驱动的核心，并把delegate设置为self；
2. 设置ARContentView，并设置缓存大小为`1280 * 720`，这是AR区域的展示大小
3. 设置ARConfiguration为`Tracking`模式，并将输出格式设置为720
4. 不启动ARSession

```objc
- (void)setupARModule API_AVAILABLE(ios(11.0)){
    if (@available(iOS 11.0, *)) {
        self.arSession = [[ARSession alloc] init];
        self.arSession.delegate = self;

        self.arContentView = [[BMVPSARContentView alloc] initWithFrame:self.bounds BufferSize:CGSizeMake(1280, 720)];
        [self addSubview:self.arContentView];
        
        self.arWorldTrackingConfiguration = [[ARWorldTrackingConfiguration alloc] init];
        if (@available(iOS 11.3, *)) {
            NSArray *formats = [ARWorldTrackingConfiguration supportedVideoFormats];
            for (ARVideoFormat *format in formats) {
                if (format.imageResolution.height == 720) {
                    self.arWorldTrackingConfiguration.videoFormat = format;
                }
            }
            self.arWorldTrackingConfiguration.autoFocusEnabled = NO;
        } else {
            // Fallback on earlier versions
        }
        [self setIsARSessionRunning:NO];
        
        self.vpsView = [[BMVPSView alloc] initWithFrame:self.bounds];
        self.vpsView.delegate = self;
        [self addSubview:self.vpsView];
    }
}
```

- ARConfiguration

室内导航中，设置的模式为ARWorldTrackingConfiguration；

ARWorldTrackingConfiguration

跟踪设备相对于ARKit可以使用设备的后置摄像头找到并*跟踪的任何表面，人物或已知图像和对象的位置和方向*。

ARGeoTrackingConfiguration ？？

ARPositionalTrackingConfiguration？？



- ARKit的启动

这里`异步`插入并发队列，将ARKit放在子线程中运行，没有问题。避免主线程卡死！

```objective-c
- (void)runARCamera API_AVAILABLE(ios(11.0)){
    if (@available(iOS 11.0, *)) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self.arSession runWithConfiguration:self.arWorldTrackingConfiguration];
        });
        
        [self setIsARSessionRunning:YES];
    }
}
```

- ARKit 回调的数据

ARKit的回调数据，封装在ARFrame中，里面有：

- `capturedImage`：`CVPixelBufferRef`的图像数据
- `camera`：获取Image的camera，通过camera的相机数据，可以得到当前相机在空间坐标系的位置，具体看高度检测

```objective-c
#pragma mark - ARSessionDelegate
- (void)session:(ARSession *)session didUpdateFrame:(ARFrame *)frame API_AVAILABLE(ios(11.0)){
    if(self.mode == BMVPSCameraIndoorAR || self.mode == BMVPSCameraOutdoorAR){
        if (_delegate && [_delegate respondsToSelector:@selector(captureARFrame:)]) {
            [_delegate captureARFrame:frame];
        }
    }
}
```

这里拿到了ARFrame，如何把ARFrame转换成CMSampleBuffer?

ARFrame里有个属性 capturedImage，是CVPixelBufferRef格式的，从摄像机拿到的数据都是这个格式

```objc
@interface ARFrame : NSObject <NSCopying>

/**
 A timestamp identifying the frame.
 */
@property (nonatomic, readonly) NSTimeInterval timestamp;


/**
 The frame’s captured image.
 */
@property (nonatomic, readonly) CVPixelBufferRef capturedImage;
```

将 CVPixelBufferRef （CoreVideo框架）转换为 CMSampleBuffer(CoreMedia框架)，CMSampeBuffer提供了方法，可以转换（实时上，后者是包含前者的）因为要上屏。

```objective-c
- (CMSampleBufferRef)sampleBufferFromPixelBuffer:(CVPixelBufferRef)pixelBuffer {
    CMFormatDescriptionRef formatDesc;
    CMVideoFormatDescriptionCreateForImageBuffer(kCFAllocatorDefault, pixelBuffer, &formatDesc);
    CMSampleTimingInfo timingInfo;
    timingInfo.presentationTimeStamp = CMClockGetTime(CMClockGetHostTimeClock());
    timingInfo.duration = CMTimeMake(4, 120);
    CMSampleBufferRef outBuffer;
    CMSampleBufferCreateReadyWithImageBuffer(kCFAllocatorDefault, pixelBuffer, formatDesc, &timingInfo, &outBuffer);
    return outBuffer;
}
```

拿到SampleBuffer以后，怎么上屏的？

使用 AVSampleBufferDisplayLayer 上屏

```objective-c
CGRect rect = [self renderVRectForRenderSize:bufferSize FillViewSize:frame.size];
self.displayLayer = [[AVSampleBufferDisplayLayer alloc] init];
self.displayLayer.frame = rect;
self.displayLayer.position = self.center;
[self.layer addSublayer:self.displayLayer];

- (void)updateSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    if (self.displayLayer.status == AVQueuedSampleBufferRenderingStatusFailed) {
        [self.displayLayer flushAndRemoveImage];
    }
    
    if ([self.displayLayer isReadyForMoreMediaData]) {
        [self.displayLayer enqueueSampleBuffer:sampleBuffer];
    } else {
        [self.displayLayer flushAndRemoveImage];
        [self.displayLayer enqueueSampleBuffer:sampleBuffer];
    }
}
```



如果是普通导航，使用的AVFoundation框架，回调里本身就是CMSampleBuffer

```objc
#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    if (_delegate && [_delegate respondsToSelector:@selector(captureOutput:)]) {
        [_delegate captureOutput:sampleBuffer];
    }
}
```



- 监测ARSession的开启与关闭

ARKit本身不提供状态监听接口，需要遵守`ARSessionObserver`协议。为了检测ARKit被中断和启动，需要自己设置一个标志位。

```objective-c
@property (nonatomic, assign) BOOL isARSessionRunning  API_AVAILABLE(ios(11.0));//标志位(判断ARSession是否正在运行）

#pragma mark - ARSessionObserver
- (void)sessionWasInterrupted:(ARSession *)session API_AVAILABLE(ios(11.0)){
    [self setIsARSessionRunning:NO];
}

- (void)sessionInterruptionEnded:(ARSession *)session API_AVAILABLE(ios(11.0)){
    [self setIsARSessionRunning:YES];
}
```



### CoreMotion

### 高度检测

方案一：使用ARKit的3D坐标

```objective-c
 // 拿到ARFrame后，侦测用户是否有高度的变化(识别用户是否在电梯上）
simd_float4x4 transform = frame.camera.transform;
SCNMatrix4 mat = SCNMatrix4FromMat4(transform);
SCNVector3 pos = SCNVector3Make(mat.m41,mat.m42 ,mat.m43);
[self.vpsController saveCurrentHeight:pos.y];
```

方案二：使用气压计

## 2.2 VPS室内定位







相关文档

[CVPixelBufferRef 生成方式](https://blog.csdn.net/weixin_50912862/article/details/115763227)

## 2.3 UIScrollView改造



## 现状

内外两个ScrollView的交互切换、手势切换有问题

旧框架，内外过渡不连续，动画不流畅，有顿挫感



## 目标

- 交互流畅，提升用户体验
- 降低接入成本，提升开发效率



## Step

1. 核心滑动能力开发
2. 通用能力接口
3. 落地：首页
4. 旧框架兼容
5. 推广其他业务

### 滑动能力

#### 思路

- 以ScrollView作为容器
- 滑动过程依赖外部ScrollView，禁用内部的滑动
- 动态捕获内部的SrollView



#### 动态捕获ScrollView

在手指触碰滑动控件的时候，在事件响应链中，只能捕获需要滑动的内部scrollView，并对其进行监听，保障如webView或其他内容会发生变化的scrollView在变化时可以同步更新滑动控件的状态。

- 智能识别可以滑动的View并捕捉：响应链从前往后优先寻找第一个可滑动的ScrollView(有可以滑动的区域)；若没有，寻找符合一定**tag**规则(由滑动控件规定规则，业务方配置)的ScrollView并对其进行监听；若还没有则智能选择(目前是寻找最高的)其中一个ScrollVIew做监听
- 监听scrollView，确保scrollView的contentSize、contentInsets等发生变化时，滑动控件可以及时刷新
- 



### 推广

业务方需要滑动控件做什么？

答：传入一个业务方的页面，允许该页面在屏幕内上下滑动，滑动行为可以和页面内部的ScrollVIew衔接。

所以业务方需要做的只有两件事情：

1. 传入View
2. 配置上下滑动需要吸附的位置（非必选项，若不配 置则没有吸附点自然滑动即可）



如何接入？

修改继承关系，引入了fake层

```objective-c
@interface BMXXXScene : BMDragBaseScene
->
@interface BMXXXScene : BMDragBaseXXXScene_fake
```

### 挑战和问题

#### 1. 滑动和惯性减速过程中，属于TrackingModeRunloop，底图不绘制怎么办

方法一：提供了一个在TrackingModeRunloop下运行的DisplayLink，由该link调用底图的绘制，保证在TrackingMode时底图也可以回执。
BMTrackingModeDisplayLink使用方式如下：

```o
[BMTrackingModeDisplayLink setTrackingModeDisplay:0.3  //运行时长
                                           maxFPS:0   //可以限制绘制的FPS
                                       linkAction:^{
                                                   [ws.dragScene.mapView drawFrame];
                                                  }];
```

方法二：

提供了可选滑动模式，可以在手指离开屏幕后，指定需要滑动的方式不使用TrackingMode，而是使用CA的动画来完成后续惯性效果(CA动画不会进入TrackingMode)。

```objective-c
//辅助方法，执行动画
- (void)__liteAnimateToOffset:(CGPoint)offset
                          vel:(CGFloat)vel
                   completion:(void (^)(BOOL isFinish))completion;
```

#### 2.动态捕获内部scrollView的时机只发生下手指按下的那一刻，若当时内部scrollView的内容还没有加载出来不能滑动，那么接下来即时加载出来也不能滑动内部了

使用”智能”捕获 + 监听：
当寻找内部scrollView时，若没找到当前可以滑动的，就寻找一个“未来可能滑动”的scrollView，对其进行监听，当监听到其确实可以滑动后，再进行捕获和关联。

- ~~附选方案1(未采用)：把响应链内所有scrollVIew进行监听，但在大部分情况会做很多无意义的捕获和监听。没有采用该方案。~~
- **附选方案2**：打破与业务方代码无耦合的界限，业务方可以主动告知哪个scrollView需要做加载。添加了一个数字宏。业务方可以把scrollView的tag设置为此数字或者其倍数，当寻找到满足该条件的scrollView的时候就进行捕获和监听。
- **附选方案3**：用一种基于业务现状和使用经验进行猜测的方法，比如猜测frame最高的可能会变为可滑动。

3. scrollView互相嵌套产生的手势、点击冲突如何解决

点击手势：

使用系统提供的配置和代理方法

```objective-c
UIScrollVIew.canCancelContentTouches
UIScrollVIew.delaysContentTouches
- (BOOL)touchesShouldCancelInContentView:(UIView *)view;
- (BOOL)touchesShouldBegin:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event inContentView:(UIView *)view;
```

进行配置，保障内部的点击取消点击效果不受外部影响。

滑动手势：

- ~~方案1(已弃用)：hook内部的UIPanGesture或UIScrollVIew，修改或禁用其位置的移动。使用了一段时间该方案，但系统行为本身是黑盒，只hook一部分会对系统行为产生了一些难以控制的影响，比如打乱了系统对手势的begin和cancel分发。此方案已弃用~~

- **方案2**：使用系统的手势代理方法，有条件的无效掉内部的滑动行为，处理内部有需要横滑的scrollView时无效掉外部的滑动

  ```
  (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer* )otherGestureRecognizer;
  
  (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer* )otherGestureRecognizer;
  
  (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer* )otherGestureRecognizer;
  ```



- ## 3. 全/半卡切换时与底图联动导致卡顿问题解决方案

  使用滑动控件制作小卡、半卡、大卡等切换效果时，如果同时触发底图的移图或者缩放等渲染操作，由于渲染操作会大量占用那个CPU，会导致强依赖CPU的ScrollView滑动、卡片切换交卡顿。

  

- ```objective-c
  /*
   当发生了非内部滑动、两个吸附点间切换的行为时，
   BMDragScrollV2View可以选择是使用自然的滑动过渡到另一个吸附点（BMDragScrollV2DecelerateStyleNature），
   或是使用[UIView animate]的动画（BMDragScrollV2DecelerateStyleCAAnimation）.
   二者区别在于ScrollNatrue使用系统scrollView的滑动效果，滑动过程较自然，并且会触发didScroll方法依次经过各个滑动位置
   滑动过程中会使runloop处于TrackingMode。
   BMDragScrollV2DecelerateStyleCAAnimation:
   使用系统的[UIView animationXXX...]方法播放吸附滑动效果，数值上会直接跳跃到目标数值，
   没有中间过程（中间过程数值变化会反映在layer.presentationLayer上用动画播放出来）。
   缺点是效果和随时交互的能力没有StyleNature好。
   优点是动画播放过程是在系统的动画控制进程(BackBoard-GPU)上，即使APP的的主线程进行了大量运算占用了CPU导致主线程卡顿了也不会影响动画播放
   所以如果切换过程中需要做一些CPU运算如修改底图（大量几何运算），可以使用StyleCAAnimation的方式避免CPU的繁忙导致切换效果不流畅。
   没有实现该方法时，读取defaultDecelerateStyle
   */
  - (BMDragScrollV2DecelerateStyle)dragScrollViewDecelerate:(BMDragScrollV2View *)dragScrollView
                                                      fromH:(CGFloat)fromH
                                                        toH:(CGFloat)toH
                                                     reason:(NSString *)reason;
  ```

  在代理中，实现下面的方法
  
- ```objective-c
  - (BMDragScrollV2DecelerateStyle)dragScrollViewDecelerate:(BMDragScrollV2View *)dragScrollView
                                                      fromH:(CGFloat)fromH toH:(CGFloat)toH
                                                     reason:(NSString *)reason {
      //手指离开后，卡片状态即将从当前的fromH展示高度滑动到toH的展示高度
      if (<本次滑动会和底图联动，CPU可能会拥挤，希望把滑动动画切换到GPU上运行>) {
          //返回BMDragScrollV2DecelerateStyleCAAnimation后，切换动画会以Core Animation运行，开始动画后，即使CPU被占用，动画也可以正常播放
          return BMDragScrollV2DecelerateStyleCAAnimation;
      } else {
          //本次卡片状态切换正常进行即可
          return BMDragScrollV2DecelerateStyleDefault; //返回任意类型都可以，看业务需要
      }
  }
  ```




## 2.4 组件包大小优化

背景：

组件包大小版本约束为100KB，每次大版本迭代都有超过100KB的资源

思路

- 删去无用的资源图片
  - 不再内部使用的图片
  - 2x，3x图保留一张
  - 运营类图片，云端存储
  - 与其他业务相似的图片保留一张

手段：

1. `LSUnusedResource`加强版，能够将注释中的图片检索出来、无用的暗黑模式图片检索、仅与业务相关的无用图片检索出来
2. 相似图片检索工具等



- 无用类、无用方法删除
  - 无用方法去除，包括静态库和动态库（C、C++的无用方法，编译时不会被编入）
  - LinkMap方案，查找无用类、无用方法
  - 重复代码扫描，工具`simian`
